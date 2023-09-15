# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# This file contains Quartus assignments to disable warning messages
#------------------------------------

# Suppress warning message "parameter declared inside package <package> shall be treated as localparam"
set_global_assignment -name MESSAGE_DISABLE 21442

# Suppress warning message "generate block is allowed only inside loop and conditional generate in SystemVerilog mode"
set_global_assignment -name MESSAGE_DISABLE 21392

# Suppress warning message "Number of metastability protection registers is not specified"
set_global_assignment -name MESSAGE_DISABLE 272007

# Suppress warning message "Assertion warning: Number of metastability protection registers is not specified"
set_global_assignment -name MESSAGE_DISABLE 287001

# Suppress warning message on unused RAM node(s) being synthesized away in FIFO module
set_instance_assignment -name MESSAGE_DISABLE -to *|scfifo_inst|auto_generated|dpfifo* -entity top 14320
set_instance_assignment -name MESSAGE_DISABLE -to *|dcfifo_component|auto_generated|fifo_altera_syncram* -entity top 14320

# Disable .hex file load on preconfigured.mif
set_global_assignment -name MESSAGE_DISABLE 127005

# Suppress warning message on user clock muxing 
#set_instance_assignment -name MESSAGE_DISABLE -to user_clock|qph_user_clk|qph_user_clk_freq* -entity top 19017

# Disable "initial value of parameter" messages from Quartus synthesis. Not specifying a default type for some
# parameters is done intentionally where no reasonable default exists. Quartus will raise an error if no value
# is specified when a module or interface with undefined types is instantiated.
set_global_assignment -name MESSAGE_DISABLE 17377 
