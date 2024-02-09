# Copyright (C) 2020-2023 Intel Corporation
# SPDX-License-Identifier: MIT

package require -exact qsys 18.0
  
    # create the system
	create_system apf
        set_project_property DEVICE AGFB014R24A2E2V
        set_project_property DEVICE_FAMILY Agilex
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

    # add the components
	add_component apf_clock_bridge ip/apf/apf_clock_bridge.ip altera_clock_bridge apf_clock_bridge 
	load_component apf_clock_bridge
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation apf_clock_bridge
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {0}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {false}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {0}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation

	add_component apf_reset_bridge ip/apf/apf_reset_bridge.ip altera_reset_bridge apf_reset_bridge 
	load_component apf_reset_bridge
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation apf_reset_bridge
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
	save_instantiation
    
	# add the connections
	add_connection apf_clock_bridge.out_clk/apf_reset_bridge.clk
	set_connection_parameter_value apf_clock_bridge.out_clk/apf_reset_bridge.clk clockDomainSysInfo {-1}
	set_connection_parameter_value apf_clock_bridge.out_clk/apf_reset_bridge.clk clockRateSysInfo {}
	set_connection_parameter_value apf_clock_bridge.out_clk/apf_reset_bridge.clk clockResetSysInfo {}
	set_connection_parameter_value apf_clock_bridge.out_clk/apf_reset_bridge.clk resetDomainSysInfo {-1}
    
	# add the exports
	set_interface_property clk EXPORT_OF apf_clock_bridge.in_clk
	set_interface_property rst_n EXPORT_OF apf_reset_bridge.in_reset
        add_component apf_default_slv ip/apf/apf_default_slv.ip axi4lite_rsp apf_default_slv 1.0
        load_component apf_default_slv
        set_component_parameter_value AW {6}
        set_component_parameter_value DW {64}
        set_component_parameter_value RSP_STATUS {0}
        set_component_parameter_value RSP_VALUE {0x0000000000000000}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_default_slv
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {1}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 6 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 6 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        save_instantiation
    
        add_connection apf_clock_bridge.out_clk/apf_default_slv.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_default_slv.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_default_slv.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_default_slv.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_default_slv.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_default_slv.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_default_slv.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_default_slv.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_default_slv.reset resetDomainSysInfo {-1}
    
        add_component apf_bpf_slv ip/apf/apf_bpf_slv.ip axi4lite_shim apf_bpf_slv 1.0
        load_component apf_bpf_slv
        set_component_parameter_value AW {18}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_bpf_slv
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 18 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 18 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 18 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 18 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_st2mm_slv ip/apf/apf_st2mm_slv.ip axi4lite_shim apf_st2mm_slv 1.0
        load_component apf_st2mm_slv
        set_component_parameter_value AW {16}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_st2mm_slv
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 16 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 16 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 16 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 16 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_uart_slv ip/apf/apf_uart_slv.ip axi4lite_shim apf_uart_slv 1.0
        load_component apf_uart_slv
        set_component_parameter_value AW {12}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_uart_slv
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 12 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 12 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 12 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 12 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_pr_slv ip/apf/apf_pr_slv.ip axi4lite_shim apf_pr_slv 1.0
        load_component apf_pr_slv
        set_component_parameter_value AW {16}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_pr_slv
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 16 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 16 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 16 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 16 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_achk_slv ip/apf/apf_achk_slv.ip axi4lite_shim apf_achk_slv 1.0
        load_component apf_achk_slv
        set_component_parameter_value AW {16}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_achk_slv
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 16 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 16 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 16 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 16 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_bpf_mst ip/apf/apf_bpf_mst.ip axi4lite_shim apf_bpf_mst 1.0
        load_component apf_bpf_mst
        set_component_parameter_value AW {20}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_bpf_mst
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_st2mm_mst ip/apf/apf_st2mm_mst.ip axi4lite_shim apf_st2mm_mst 1.0
        load_component apf_st2mm_mst
        set_component_parameter_value AW {20}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_st2mm_mst
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_mctp_mst ip/apf/apf_mctp_mst.ip axi4lite_shim apf_mctp_mst 1.0
        load_component apf_mctp_mst
        set_component_parameter_value AW {20}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_mctp_mst
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_component apf_uart_mst ip/apf/apf_uart_mst.ip axi4lite_shim apf_uart_mst 1.0
        load_component apf_uart_mst
        set_component_parameter_value AW {20}
        set_component_parameter_value DW {64}
        set_component_project_property HIDE_FROM_IP_CATALOG {false}
        save_component
        load_instantiation apf_uart_mst
        remove_instantiation_interfaces_and_ports
        add_instantiation_interface clock clock INPUT
        set_instantiation_interface_parameter_value clock clockRate {0}
        set_instantiation_interface_parameter_value clock externallyDriven {false}
        set_instantiation_interface_parameter_value clock ptfSchematicName {}
        add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
        add_instantiation_interface reset reset INPUT
        set_instantiation_interface_parameter_value reset associatedClock {clock}
        set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
        add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_slave axi4lite INPUT
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_slave associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_slave bridgesToMaster {}
        set_instantiation_interface_parameter_value altera_axi4lite_slave combinedAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readAcceptanceCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_slave writeAcceptanceCapability {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_slave readDataReorderingDepth {1}
        set_instantiation_interface_parameter_value altera_axi4lite_slave trustzoneAware {true}
        add_instantiation_interface_port altera_axi4lite_slave s_awaddr awaddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awprot awprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_awvalid awvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_awready awready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_wdata wdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wstrb wstrb 8 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_wvalid wvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_wready wready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bresp bresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_bvalid bvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_bready bready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_araddr araddr 20 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arprot arprot 3 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_slave s_arvalid arvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_slave s_arready arready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rdata rdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rresp rresp 2 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_slave s_rvalid rvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_slave s_rready rready 1 STD_LOGIC Input
        add_instantiation_interface altera_axi4lite_master axi4lite OUTPUT
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedClock {clock}
        set_instantiation_interface_parameter_value altera_axi4lite_master associatedReset {reset}
        set_instantiation_interface_parameter_value altera_axi4lite_master combinedIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingReads {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingTransactions {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master maximumOutstandingWrites {16/4}
        set_instantiation_interface_parameter_value altera_axi4lite_master readIssuingCapability {16}
        set_instantiation_interface_parameter_value altera_axi4lite_master trustzoneAware {true}
        set_instantiation_interface_parameter_value altera_axi4lite_master writeIssuingCapability {16/4}
        add_instantiation_interface_port altera_axi4lite_master m_awaddr awaddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awprot awprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_awvalid awvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_awready awready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_wdata wdata 64 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wstrb wstrb 8 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_wvalid wvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_wready wready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bresp bresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_bvalid bvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_bready bready 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_araddr araddr 20 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arprot arprot 3 STD_LOGIC_VECTOR Output
        add_instantiation_interface_port altera_axi4lite_master m_arvalid arvalid 1 STD_LOGIC Output
        add_instantiation_interface_port altera_axi4lite_master m_arready arready 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rdata rdata 64 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rresp rresp 2 STD_LOGIC_VECTOR Input
        add_instantiation_interface_port altera_axi4lite_master m_rvalid rvalid 1 STD_LOGIC Input
        add_instantiation_interface_port altera_axi4lite_master m_rready rready 1 STD_LOGIC Output
        save_instantiation
        
        add_connection apf_clock_bridge.out_clk/apf_bpf_slv.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_slv.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_slv.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_slv.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_slv.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_bpf_slv.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_bpf_slv.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_bpf_slv.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_bpf_slv.reset resetDomainSysInfo {-1}
        add_connection apf_clock_bridge.out_clk/apf_st2mm_slv.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_slv.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_slv.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_slv.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_slv.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_st2mm_slv.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_st2mm_slv.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_st2mm_slv.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_st2mm_slv.reset resetDomainSysInfo {-1}
        add_connection apf_clock_bridge.out_clk/apf_uart_slv.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_slv.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_slv.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_slv.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_slv.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_uart_slv.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_uart_slv.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_uart_slv.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_uart_slv.reset resetDomainSysInfo {-1}
        add_connection apf_clock_bridge.out_clk/apf_pr_slv.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_pr_slv.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_pr_slv.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_pr_slv.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_pr_slv.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_pr_slv.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_pr_slv.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_pr_slv.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_pr_slv.reset resetDomainSysInfo {-1}
        add_connection apf_clock_bridge.out_clk/apf_achk_slv.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_achk_slv.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_achk_slv.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_achk_slv.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_achk_slv.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_achk_slv.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_achk_slv.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_achk_slv.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_achk_slv.reset resetDomainSysInfo {-1}
        add_connection apf_clock_bridge.out_clk/apf_bpf_mst.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_mst.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_mst.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_mst.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_bpf_mst.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_bpf_mst.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_bpf_mst.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_bpf_mst.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_bpf_mst.reset resetDomainSysInfo {-1}
	add_connection apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressMapSysInfo {}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressWidthSysInfo {}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave arbitrationPriority {1}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave baseAddress {0x0000}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave defaultConnection {1}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave domainAlias {}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        add_connection apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave baseAddress {0x40000}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_bpf_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_clock_bridge.out_clk/apf_st2mm_mst.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_mst.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_mst.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_mst.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_st2mm_mst.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_st2mm_mst.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_st2mm_mst.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_st2mm_mst.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_st2mm_mst.reset resetDomainSysInfo {-1}
	add_connection apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressMapSysInfo {}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressWidthSysInfo {}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave arbitrationPriority {1}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave baseAddress {0x0000}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave defaultConnection {1}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave domainAlias {}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        add_connection apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave baseAddress {0x80000}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave baseAddress {0x00000}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave baseAddress {0x70000}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave baseAddress {0x40000}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave baseAddress {0x60000}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_st2mm_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_clock_bridge.out_clk/apf_mctp_mst.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_mctp_mst.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_mctp_mst.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_mctp_mst.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_mctp_mst.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_mctp_mst.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_mctp_mst.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_mctp_mst.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_mctp_mst.reset resetDomainSysInfo {-1}
	add_connection apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressMapSysInfo {}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressWidthSysInfo {}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave arbitrationPriority {1}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave baseAddress {0x0000}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave defaultConnection {1}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave domainAlias {}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        add_connection apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave baseAddress {0x80000}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave baseAddress {0x00000}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave baseAddress {0x70000}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave baseAddress {0x40000}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave baseAddress {0x60000}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_mctp_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_clock_bridge.out_clk/apf_uart_mst.clock
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_mst.clock clockDomainSysInfo {-1}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_mst.clock clockRateSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_mst.clock clockResetSysInfo {}
        set_connection_parameter_value apf_clock_bridge.out_clk/apf_uart_mst.clock resetDomainSysInfo {-1}
        add_connection apf_reset_bridge.out_reset/apf_uart_mst.reset
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_uart_mst.reset clockDomainSysInfo {-1}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_uart_mst.reset clockResetSysInfo {}
        set_connection_parameter_value apf_reset_bridge.out_reset/apf_uart_mst.reset resetDomainSysInfo {-1}
	add_connection apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressMapSysInfo {}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave addressWidthSysInfo {}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave arbitrationPriority {1}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave baseAddress {0x0000}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave defaultConnection {1}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave domainAlias {}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_default_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        add_connection apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave baseAddress {0x80000}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_achk_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave baseAddress {0x00000}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_bpf_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave baseAddress {0x70000}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_pr_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave baseAddress {0x40000}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_st2mm_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
        add_connection apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave addressMapSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave addressWidthSysInfo {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave arbitrationPriority {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave baseAddress {0x60000}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave defaultConnection {0}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave domainAlias {}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.enableEccProtection {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.enableInstrumentation {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.insertDefaultSlave {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.interconnectResetSource {DEFAULT}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.interconnectType {STANDARD}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.maxAdditionalLatency {1}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.syncResets {FALSE}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
        set_connection_parameter_value apf_uart_mst.altera_axi4lite_master/apf_uart_slv.altera_axi4lite_slave slaveDataWidthSysInfo {-1}
        
	set_interface_property apf_bpf_mst EXPORT_OF apf_bpf_mst.altera_axi4lite_slave
	set_interface_property apf_st2mm_mst EXPORT_OF apf_st2mm_mst.altera_axi4lite_slave
	set_interface_property apf_mctp_mst EXPORT_OF apf_mctp_mst.altera_axi4lite_slave
	set_interface_property apf_uart_mst EXPORT_OF apf_uart_mst.altera_axi4lite_slave
	set_interface_property apf_bpf_slv EXPORT_OF apf_bpf_slv.altera_axi4lite_master
	set_interface_property apf_st2mm_slv EXPORT_OF apf_st2mm_slv.altera_axi4lite_master
	set_interface_property apf_uart_slv EXPORT_OF apf_uart_slv.altera_axi4lite_master
	set_interface_property apf_pr_slv EXPORT_OF apf_pr_slv.altera_axi4lite_master
	set_interface_property apf_achk_slv EXPORT_OF apf_achk_slv.altera_axi4lite_master

    # set the the module properties
	set_module_property FILE {apf.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {apf}

    # save the system
    sync_sysinfo_parameters
    save_system apf
    
