## Copyright 2021 Intel Corporation
## SPDX-License-Header: MIT

##
## When Signal Tap adds a node to collect data streams it may fail to annotate
## false paths between the data clock and the collector clock. This code adds
## them by looking for collector nodes and finding the clocks.
##
## Once Quartus is updated to handle this internally, the code here can either
## be removed or invoked conditionally based on Quartus version.
##

proc ofs_set_stp_false_paths {stp_inst} {
    post_message -type info "STP: Found instance ${stp_inst}"

    # Figure out the clock that is driving the STP I/O
    set jtag_clk_coll [get_clocks -nowarn -of_object ${stp_inst}|sld_signaltap_body|*|jtag_comm|*]
    set num_jtag_clks [get_collection_size $jtag_clk_coll]
    if {$num_jtag_clks == 0} {
        post_message -type warning "STP: Failed to find I/O clock."
        return
    }
    if {$num_jtag_clks > 1} {
        post_message -type warning "STP: Too many JTAG clocks in collection. Expected only one."
    }

    # There should be only one clock. Pick the first.
    set jtag_clk [lindex [query_collection -list_format $jtag_clk_coll] 0]
    post_message -type info "STP: Clocked by [get_clock_info -name $jtag_clk]"

    # Relax timing for all other clocks. The STP code will handle true clock crossing.
    set all_clks [get_clocks -nowarn -of_object ${stp_inst}|sld_signaltap_body|*|acq_core|*]
    foreach_in_collection clk $all_clks {
        if {[get_clock_info -name $jtag_clk] != [get_clock_info -name $clk]} {
            post_message -type info "STP: Setting false paths for [get_clock_info -name $clk]"

            # Multi-cycle paths have lower precedence than set_max_delay. The true Quartus-managed
            # clock crossing constraints for STP use set_max_delay, so we can safely constrain
            # the remainder of the interface here with only a few rules.

            set_multicycle_path -from $jtag_clk -to $clk -through ${stp_inst}|sld_signaltap_body|* -start 4
            set_multicycle_path -from $clk -to $jtag_clk -through ${stp_inst}|sld_signaltap_body|* -end 4
            set_multicycle_path -from $jtag_clk -to $clk -through ${stp_inst}|sld_signaltap_body|* -start -hold 4
            set_multicycle_path -from $clk -to $jtag_clk -through ${stp_inst}|sld_signaltap_body|* -end -hold 4

            set_multicycle_path -from $jtag_clk -to ${stp_inst}|sld_signaltap_body|*|acq_core|trigger_out_mode_ff -start 4
            set_multicycle_path -from $jtag_clk -to ${stp_inst}|sld_signaltap_body|*|acq_core|trigger_out_mode_ff -start -hold 4
        }
    }
}

# Find all instantiated STP nodes
foreach each_inst [get_entity_instances -nowarn sld_signaltap] {
    ofs_set_stp_false_paths ${each_inst} 
}
