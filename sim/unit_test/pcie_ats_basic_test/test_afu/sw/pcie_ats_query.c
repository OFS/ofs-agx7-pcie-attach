// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT

#include <assert.h>
#include <byteswap.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <x86gprintrin.h>
#include <x86intrin.h>

#include <opae/fpga.h>

// State from the AFU's JSON file, extracted using OPAE's afu_json_mgr script
#include "afu_json_info.h"

#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)
#define FLAGS_4K (MAP_PRIVATE | MAP_ANONYMOUS)
#define FLAGS_2M (FLAGS_4K | MAP_HUGETLB)
#define FLAGS_1G (FLAGS_2M | MAP_HUGE_1GB)

static bool is_ase_sim;

//
// enqcmd doesn't yet work on either the FPGA or external CPU slots. Leaving the
// instruction encoding here for reference.
//
#ifdef ENABLE_MY_ENQCMD
static inline unsigned char my_enqcmd(volatile void *portal, void *desc)
{
	unsigned char retry;
	asm volatile("sfence\t\n"
			".byte 0xf2, 0x0f, 0x38, 0xf8, 0x02\t\n"
			"setz %0\t\n"
			: "=r"(retry): "a" (portal), "d" (desc));
	return retry;
}
#endif

//
// Search for all accelerators matching the requested properties and
// connect to them. The input value of *num_handles is the maximum
// number of connections allowed. (The size of accel_handles.) The
// output value of *num_handles is the actual number of connections.
//
fpga_result
connectToMatchingAccels(const char *accel_uuid,
                        uint32_t *num_handles,
                        fpga_handle *accel_handles)
{
    fpga_properties filter = NULL;
    fpga_guid guid;
    const uint32_t max_tokens = 16;
    fpga_token accel_tokens[max_tokens];
    uint32_t num_matches;
    fpga_result r;

    assert(num_handles && *num_handles);
    assert(accel_handles);

    // Limit num_handles to max_tokens. We could be smarter and dynamically
    // allocate accel_tokens.
    if (*num_handles > max_tokens)
        *num_handles = max_tokens;

    // Don't print verbose messages in ASE by default
    setenv("ASE_LOG", "0", 0);

    // Set up a filter that will search for an accelerator
    fpgaGetProperties(NULL, &filter);
    fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);

    // Add the desired UUID to the filter
    uuid_parse(accel_uuid, guid);
    fpgaPropertiesSetGUID(filter, guid);

    // Do the search across the available FPGA contexts
    r = fpgaEnumerate(&filter, 1, accel_tokens, *num_handles, &num_matches);
    if (*num_handles > num_matches)
        *num_handles = num_matches;

    if ((FPGA_OK != r) || (num_matches < 1))
    {
        fprintf(stderr, "Accelerator %s not found!\n", accel_uuid);
        goto out_destroy;
    }

    // Open accelerators
    uint32_t num_found = 0;
    for (uint32_t i = 0; i < *num_handles; i += 1)
    {
        r = fpgaOpen(accel_tokens[i], &accel_handles[num_found], 0);
        if (FPGA_OK == r)
        {
            num_found += 1;

            // Is this an ASE simulation?
            fpga_properties accel_props;
            uint16_t vendor_id, dev_id;
            fpgaGetProperties(accel_tokens[i], &accel_props);
            fpgaPropertiesGetVendorID(accel_props, &vendor_id);
            fpgaPropertiesGetDeviceID(accel_props, &dev_id);
            is_ase_sim = (vendor_id == 0x8086) && (dev_id == 0xa5e);
        }

        fpgaDestroyToken(&accel_tokens[i]);
    }
    *num_handles = num_found;
    if (0 != num_found) r = FPGA_OK;

  out_destroy:
    fpgaDestroyProperties(&filter);

    return r;
}


// Wait for an ATS request or read to complete, signalled by a CSR write
static void wait_for_cpl(fpga_handle accel_handle)
{
    uint64_t v;

    do
    {
        usleep(10);
        fpgaReadMMIO64(accel_handle, 0, 9 * 8, &v);
    }
    while (v == 0);
}


int main(int argc, char *argv[])
{
    fpga_handle accel_handles[16];
    // Starts as max. number of connections, becomes the true number.
    uint32_t num_accel_handles = 16;

    uint64_t v;
    uint64_t cycles, prev_cycles;
    uint32_t pasid;
    fpga_result r;
    double afu_ns_per_cycle;

    // Find and connect to the accelerator(s)
    r = connectToMatchingAccels(AFU_ACCEL_UUID, &num_accel_handles, accel_handles);
    assert(FPGA_OK == r);

    uint64_t *buffer = mmap(NULL, 4095 * 5, (PROT_READ | PROT_WRITE), FLAGS_4K, -1, 0);

    // Bind the same PASID to each one
    for (int i = 0; i < num_accel_handles; i += 1)
    {
        if (i == 0)
        {
            fpgaReadMMIO64(accel_handles[i], 0, 7 * 8, &v);
            uint32_t bus_byte_width = v & 0xffff;
            uint32_t clock_mhz = (v >> 16) & 0xffff;
            printf("Clock MHz:      %d\n", clock_mhz);
            printf("Bus byte width: %d\n\n", bus_byte_width);

            afu_ns_per_cycle = 1000.0 / clock_mhz;
        }

        r = fpgaBindSVA(accel_handles[i], &pasid);
        if (FPGA_OK != r)
        {
            fprintf(stderr, "Can't allocate a PASID. Is ATS available?\n");
            exit(1);
        }
        printf("AFU%d: PASID %d\n", i, pasid);

        // PASID to AFU CSR
        fpgaWriteMMIO64(accel_handles[i], 0, 0 * 8, pasid);
    }

    for (int i = 0; i < num_accel_handles; i += 1)
    {
        printf("\nTesting AFU%d:\n", i);
        fpga_handle ah = accel_handles[i];

        fpgaWriteMMIO64(ah, 0, 1 * 8, (uint64_t) buffer);

        // ATS request length
        fpgaWriteMMIO64(ah, 0, 2 * 8, 2);

        printf("  ATS\n");
        fpgaWriteMMIO64(ah, 0, 7 * 8, 1);
        wait_for_cpl(ah);
        fpgaReadMMIO64(ah, 0, 10 * 8, &v);
        // ATS bytes are reversed
        v = bswap_64(v);
        fpgaReadMMIO64(ah, 0, 12 * 8, &cycles);
        printf("  VA 0x%" PRIx64 " -> PA 0x%" PRIx64 " (%.1f ns)\n", buffer, v, afu_ns_per_cycle * cycles);

        if (v == 0)
        {
            printf("\n  No backing storage for VA 0x%" PRIx64 "\n", buffer);

            // Trigger page request (PRS)
            printf("  Page request\n");
            fpgaWriteMMIO64(ah, 0, 7 * 8, 4);
            // Wait for PRS to finish -- wait until the busy cycle counter stops incrementing
            cycles = 0;
            do
            {
                usleep(10);
                prev_cycles = cycles;
                fpgaReadMMIO64(ah, 0, 12 * 8, &cycles);
            }
            while (prev_cycles != cycles);
            printf("  PRS VA 0x%" PRIx64 " complete (%.1f ns)\n", buffer, afu_ns_per_cycle * cycles);

            printf("\n  Attempting translation again:\n");
            fpgaWriteMMIO64(ah, 0, 7 * 8, 1);
            wait_for_cpl(ah);
            fpgaReadMMIO64(ah, 0, 10 * 8, &v);
            v = bswap_64(v);
            fpgaReadMMIO64(ah, 0, 12 * 8, &cycles);
            printf("  VA 0x%" PRIx64 " -> PA 0x%" PRIx64 " (%.1f ns)\n", buffer, v, afu_ns_per_cycle * cycles);
        }

        if (v)
        {
            // Found a translation. Read from the buffer, using PA.
            uint64_t pa = v & ~(uint64_t)0x7ff;  // Drop the flag bits
            buffer[0] = 0xc001d00d;
            fpgaWriteMMIO64(ah, 0, 1 * 8, pa);
            fpgaWriteMMIO64(ah, 0, 7 * 8, 2);
            wait_for_cpl(ah);
            fpgaReadMMIO64(ah, 0, 10 * 8, &v);
            fpgaReadMMIO64(ah, 0, 12 * 8, &cycles);
            printf("  Read from PA 0x%" PRIx64 " is 0x%" PRIx64 " (%.1f ns)\n", pa, v, afu_ns_per_cycle * cycles);
        }
        else
        {
            printf("  ERROR: Translation failed!\n");
        }

        // Done
        fpgaClose(ah);
    }

    return 0;
}
