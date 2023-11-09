// Copyright (C) 2001-2021 Intel Corporation
// SPDX-License-Identifier: MIT

// acl_ecc.svh
//
// Parameter computation helper functions for ECC
//
// Intended for usage in:
// - acl_ecc_decoder.sv
// - acl_ecc_encoder.sv
// - any file that instantiates either of the above, including testbench for ecc

`ifndef ACL_ECC_SVH
`define ACL_ECC_SVH

// How to compute the number of parity bits:
// For example, suppose we had 20 bits of data, let's assume we can add parity bits and the total number of bits would still be within the same power-of-2 group, in this case 32
// Under this assumption, dataWidth bits of data will require $clog2(dataWidth) Hamming parity bits and 1 overall parity bit, so the total number of bits is $clog2(dataWidth)+1+dataWidth
// Now we check if the assumption was met, once we add the parity bits do we still stay within the same power-of-2 group: check if $clog2($clog2(dataWidth)+1+dataWidth) == $clog2(dataWidth)
// If the assumption is met then our guess of the number of parity bits is correct, otherwise we are going up one power-of-2 so we need an extra parity bit
// This logic breaks down at small width where we have to go up by 2 or more power-of-2 groups to fit the parity bits, so the cases for dataWidth up to 4 have been handled separately
function int getParityBits;
input int dataWidth;
begin
    getParityBits = (dataWidth==1) ? 3 : (dataWidth<=4) ? 4 : ( $clog2($clog2(dataWidth)+1+dataWidth) == $clog2(dataWidth)) ? ($clog2(dataWidth)+1) : ($clog2(dataWidth)+2);
end
endfunction

// given the total data width and the desired group size, how many groups do we end up with?
function int getNumGroups;
input int dataWidth, eccGroupSize;
begin
    getNumGroups = (dataWidth + eccGroupSize - 1) / eccGroupSize;   //ceiling( dataWidth / eccGroupSize)
end
endfunction

// given the total data width and the desired group size, what is the size of the last group?
// all groups except possibly the last group will be of size eccGroupSize, the remainder goes in the last group
// last group size can be as low as 1 and as high as eccGroupSize
function int getLastGroupSize;
input int dataWidth, eccGroupSize;
begin
    getLastGroupSize = dataWidth - ((getNumGroups(dataWidth,eccGroupSize)-1) * eccGroupSize);
end
endfunction

// without ecc grouping (intended for secded_decoder and secded_encoder), determine the encoded width given the raw data width
function int getEncodedBits;
input int dataWidth;
begin
    getEncodedBits = getParityBits(dataWidth) + dataWidth;
end
endfunction

// with ecc grouping (intended for acl_ecc_decoder and acl_ecc_encoder), determine the encoded width given the raw data width and ecc group size
function int getEncodedBitsEccGroup;
input int dataWidth, eccGroupSize;
begin
    //total bits           = raw bits  +  parity bits of full group   * number of full groups                     + parity bits of last group
    getEncodedBitsEccGroup = dataWidth + (getParityBits(eccGroupSize) * (getNumGroups(dataWidth,eccGroupSize)-1)) + getParityBits(getLastGroupSize(dataWidth,eccGroupSize));
end
endfunction

`endif
