#!/bin/bash
# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#

FACTORY_SOF="ofs_top.sof"
FACTORY_HPS_SOF="ofs_top_hps.sof"
pfg_file="ofs_top_pof.pfg"
pfg_hps_file="ofs_top_hps_pof.pfg"
pfg_flash_file="ofs_top_pof_flash.pfg"
pfg_hps_flash_file="ofs_top_hps_pof_flash.pfg"
fme_mif_file="fme_id.mif"
factory_image_info_file="factory_image_info.hex"
user1_image_info_file="user1_image_info.hex"
user2_image_info_file="user2_image_info.hex"
factory_image_info_text="factory_image_info.txt"
user1_image_info_text="user1_image_info.txt"
user2_image_info_text="user2_image_info.txt"
pacsign_infile_factory="ofs_top_page0_factory.bin"
pacsign_infile_user1="ofs_top_page1_user1.bin"
pacsign_infile_user2="ofs_top_page2_user2.bin"
pacsign_outfile_factory="ofs_top_page0_unsigned_factory.bin"
pacsign_outfile_user1="ofs_top_page1_unsigned_user1.bin"
pacsign_outfile_user2="ofs_top_page2_unsigned_user2.bin"
FACTORY_SOF_PRESENT="0"
FACTORY_HPS_SOF_PRESENT="0"
GEN_TYPE=""

# This script assumes that the calling shell has already changed the CWD 
# to this directory.
WORK_DIR=`realpath ../../`
LOCAL_SCRIPT_DIR=`realpath .`

# check for factory_image.sof, if not available, 
# copy over the ofs_fim.sof as the factory
if [ -e ${LOCAL_SCRIPT_DIR}/../output_files/${FACTORY_HPS_SOF} ]; then
   echo "Using ${FACTORY_HPS_SOF} as the factory image."
   cp --remove-destination ${LOCAL_SCRIPT_DIR}/../output_files/${FACTORY_HPS_SOF} ${LOCAL_SCRIPT_DIR}/${FACTORY_HPS_SOF}
   FACTORY_HPS_SOF_PRESENT="1"
   GEN_TYPE="ofs_top_hps"
   echo ""
else
    if [ -e ${LOCAL_SCRIPT_DIR}/../output_files/${FACTORY_SOF} ]; then
       echo "No ${FACTORY_HPS_SOF} factory image found, but ${FACTORY_SOF} exists."
       echo "Copying over ${FACTORY_SOF} as the factory image."
       cp --remove-destination ${LOCAL_SCRIPT_DIR}/../output_files/${FACTORY_SOF} ${LOCAL_SCRIPT_DIR}/${FACTORY_SOF}
       FACTORY_SOF_PRESENT="1"
       GEN_TYPE="ofs_top"
       echo ""
    else
        echo "Cannot find ${FACTORY_HPS_SOF} nor ${FACTORY_SOF}."
        exit 1
    fi
fi

# Creating Image Info Files for Flash Generation
python gen_image_info_hex.py ${LOCAL_SCRIPT_DIR}/../${fme_mif_file} ${LOCAL_SCRIPT_DIR}/../${factory_image_info_file} ${LOCAL_SCRIPT_DIR}/../${factory_image_info_text}
python gen_image_info_hex.py ${LOCAL_SCRIPT_DIR}/../${fme_mif_file} ${LOCAL_SCRIPT_DIR}/../${user1_image_info_file} ${LOCAL_SCRIPT_DIR}/../${user1_image_info_text}
python gen_image_info_hex.py ${LOCAL_SCRIPT_DIR}/../${fme_mif_file} ${LOCAL_SCRIPT_DIR}/../${user2_image_info_file} ${LOCAL_SCRIPT_DIR}/../${user2_image_info_text}

## blank bmc key - 4 bytes of FF
#python reverse.py blank_bmc_key_programmed blank_bmc_key_programmed.reversed
#objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/blank_bmc_key_programmed.reversed ${LOCAL_SCRIPT_DIR}/blank_bmc_key_programmed.reversed.hex

## blank bmc root key hash - 32 bytes of FF
#python ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash.reversed
#objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash.reversed ${LOCAL_SCRIPT_DIR}/blank_bmc_root_hash.reversed.hex

## blank sr (FIM) key - 4 bytes of FF
#python ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/blank_sr_key_programmed ${LOCAL_SCRIPT_DIR}/blank_sr_key_programmed.reversed 
#objcopy -I binary -O ihex blank_sr_key_programmed.reversed blank_sr_key_programmed.reversed.hex

## blank sr (FIM) root key hash - 32 bytes of FF
#python ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash.reversed
#objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash.reversed ${LOCAL_SCRIPT_DIR}/blank_sr_root_hash.reversed.hex


### option bits
#objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/pac_d5005_option_bits ${LOCAL_SCRIPT_DIR}/pac_d5005_option_bits.hex

### pac_d5005_rot_xip_factory>bin.reversed
#python ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory.bin ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory.bin.reversed
#objcopy -I binary -O ihex pac_d5005_rot_xip_factory.bin.reversed pac_d5005_rot_xip_factory.bin.reversed.hex

### pac_d5005_rot_xip_factory_header.bin.reversed
#python ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin.reversed
#objcopy -I binary -O ihex ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin.reversed ${LOCAL_SCRIPT_DIR}/pac_d5005_rot_xip_factory_header.bin.reversed.hex


# -- generate very special pof with no root entry hash information
# NOTE: This pass will generate the POF used for creating a condensed Flash image.
#       The POF for general use will be created after creating the unsigned Flash BIN below.
echo ">>> Generating POF for Flash BIN Creation (SOF Image Auto Size) <<<"
if [ $FACTORY_HPS_SOF_PRESENT = "1" ]; then
   if [ -e "${LOCAL_SCRIPT_DIR}/../${pfg_hps_flash_file}" ]; then
      echo "Using PFG file ${pfg_hps_flash_file}."
      cd "${LOCAL_SCRIPT_DIR}/.."
      quartus_pfg -c $pfg_hps_flash_file
   else
      echo "Cannot find PFG file: ${pfg_hps_flash_file}."
      exit 1
   fi
else
   if [ $FACTORY_SOF_PRESENT = "1" ]; then
      if [ -e "${LOCAL_SCRIPT_DIR}/../${pfg_flash_file}" ]; then
         echo "Using PFG file ${pfg_flash_file}."
         cd "${LOCAL_SCRIPT_DIR}/.."
         quartus_pfg -c $pfg_flash_file
      else
         echo "Cannot find PFG file: ${pfg_flash_file}."
         exit 1
      fi
   else
      echo "There are no valid SOFs present to process."
      exit 1
   fi
fi
# ------------------------------------------------------------------------------------------

#if [ -e "${LOCAL_SCRIPT_DIR}/../${pfg_file}" ]; then
#   echo "Using PFG file ${pfg_file}"
#   cd "${LOCAL_SCRIPT_DIR}/.."
#   quartus_pfg -c $pfg_file
#else
#   echo "Cannot find ${pfg_file}"
#   exit 1
#fi


# -- generate ihex from pof
quartus_cpf -c ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.pof ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.hexout


# -- convert to ihex to bin
objcopy -I ihex -O binary ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.hexout ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.bin


python ${LOCAL_SCRIPT_DIR}/extract_bitstream.py ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}_pof.map ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.bin ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_infile_factory "Factory_Image"
python ${LOCAL_SCRIPT_DIR}/extract_bitstream.py ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}_pof.map ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.bin ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_infile_user1 "User_Image_1"
python ${LOCAL_SCRIPT_DIR}/extract_bitstream.py ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}_pof.map ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.bin ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_infile_user2 "User_Image_2"

# -- read the image info txt string to pass to pacsign 
value_factory=$(<${LOCAL_SCRIPT_DIR}/../${factory_image_info_text})
value_user1=$(<${LOCAL_SCRIPT_DIR}/../${user1_image_info_text})
value_user2=$(<${LOCAL_SCRIPT_DIR}/../${user2_image_info_text})


# -- generate manufacturing image for 3rd party programmer to write to flash before board assembly
# uncomment following line if mfg image is desired
python ${LOCAL_SCRIPT_DIR}/reverse.py ${LOCAL_SCRIPT_DIR}/../output_files/${GEN_TYPE}.bin ${LOCAL_SCRIPT_DIR}/../output_files/mfg_ofs_fim_reversed.bin

# -- create unsigned FIM user image for fpgasupdate tool 
if which PACSign &> /dev/null ; then
    PACSign FACTORY -y -v -t UPDATE -H openssl_manager  -b ${value_factory} -i ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_infile_factory -o ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_outfile_factory
    PACSign SR -s 0 -y -v -t UPDATE -H openssl_manager  -b ${value_factory} -i ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_infile_user1 -o ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_outfile_user1
    PACSign SR -s 1 -y -v -t UPDATE -H openssl_manager  -b ${value_factory} -i ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_infile_user2 -o ${LOCAL_SCRIPT_DIR}/../output_files/$pacsign_outfile_user2
else
    echo "PACSign not found! Please manually sign ../output_files/$pacsign_infile." 1>&2
fi

# -- NOW: generate POF with maximum file sizes for general use.
echo ">>> Generating POF for General Purpose Use (SOF Image Maximum Size) <<<"
if [ $FACTORY_HPS_SOF_PRESENT = "1" ]; then
   if [ -e "${LOCAL_SCRIPT_DIR}/../${pfg_hps_file}" ]; then
      echo "Using PFG file ${pfg_hps_file}."
      cd "${LOCAL_SCRIPT_DIR}/.."
      quartus_pfg -c $pfg_hps_file
   else
      echo "Cannot find PFG file: ${pfg_hps_file}."
      exit 1
   fi
else
   if [ $FACTORY_SOF_PRESENT = "1" ]; then
      if [ -e "${LOCAL_SCRIPT_DIR}/../${pfg_file}" ]; then
         echo "Using PFG file ${pfg_file}."
         cd "${LOCAL_SCRIPT_DIR}/.."
         quartus_pfg -c $pfg_file
      else
         echo "Cannot find PFG file: ${pfg_file}."
         exit 1
      fi
   else
      echo "There are no valid SOFs present to process."
      exit 1
   fi
fi
