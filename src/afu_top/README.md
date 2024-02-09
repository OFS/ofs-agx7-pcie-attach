# Accelerator Functional Unit (AFU) Top-level

This project area defines the top-level implementation of the AFU design. This includes the PF/VF routing to the various hierarchies and endpoints (described below), the endpoint behaviors, as well as connectivity to board peripherals (local memory, HSSI, HPS).

The reference AFU topology is:

```mermaid
%%{ init : {  "flowchart" : { "curve" : "linear" }}}%%

graph TD
    classDef bg fill:#161B22,stroke:#30363D,color:#fff;
    classDef pr fill:#173b20,color:#fff,stroke:#238636,stroke-width:3px,stroke-dasharray: 5 5;
    classDef pr_inst fill:#238636,color:#fff;
    classDef afu_inst fill:#121D2F,stroke:#214981,stroke-width:2px,color:#fff;
    
    subgraph TOP
        PCIe <---> top_mux

        subgraph Memory
            mem0[DDR4]
            mem1[DDR4]
            mem2[DDR4]
            mem3[DDR4]
        end
        subgraph HSSI

        end
        HPS
        subgraph AFU_TOP
            top_mux[/PF/VF Mux\] <--"PF0"--> ST2MM
            subgraph fim_afu_instances
                fim_mux_a[/PF/VF Mux\] <--"PF1"--> pf1(he_null)
                fim_mux_a[/PF/VF Mux\] <--"PF2"--> pf2(he_lb)
                fim_mux_a[/PF/VF Mux\] <--"PF3"--> pf3(virtio_stub)
                fim_mux_a[/PF/VF Mux\] <--"PF4"--> pf4(copy_engine)
            end
            subgraph port_gasket
                subgraph afu_main
                    pg_mux_a[/PF/VF Mux\]
                    pg_mux_a <-- "VF0" --> pf0vf0
                    pg_mux_a <-- "VF1" --> pf0vf1(he_hssi)
                    pg_mux_a <-- "VF2" --> pf0vf2(mem_tg)
                    subgraph port_afu_instances
                        pf0vf0(he_mem)
                        pf0vf1(he_hssi)
                        pf0vf2(mem_tg)
                    end
                end
            end
        end
    end
    top_mux <--"PF1+"--> fim_mux_a
    top_mux <--"PF0VF"--> pg_mux_a
    pf0vf0 <---> mem0
    pf0vf2 <--> mem1
    pf0vf2 <--> mem2
    pf0vf2 <--> mem3
    pf4 <-.-> HPS
    pf0vf1 <--> HSSI

    class TOP,AFU_TOP,Memory bg;
    class port_gasket,fim_afu_instances afu_inst;
    class afu_main pr;
    class port_afu_instances pr_inst;
```

## Top-Level Modules

### PF/VF Mux

The PF/VF mux routes AXI-ST TLP requests from the PCIe host to ports defined in [top_cfg_pkg.sv](mux/top_cfg_pkg.sv). The reference implementaiton provides three mux hierarchies:
* a top mux which is the root routing as follows: `PF0 -> Port 0`, `PF1+ -> Port 1`, `PF0VF -> Port 2`.
* a static region mux attached to Port 1 that routes every PF/VF to a separate port.
* a mux in the Partial Reconfiguration (PR) region attached to port 2 that routes every PF0VF to a separate port.

### ST2MM

ST2MM (`$OFS_ROOTDIR/ofs-common/src/common/st2mm`) translates AXI-ST TLP requests/completions from PCIe to AXI-Lite transfers connected to the OFS management fabric (APF/BPF). OFS requires that this function be implemented on PF0 of a design and this requirement is reflected in the common defined routing behavior that configures the top-level PF/VF routing (`$OFS_ROOTDIR/ofs-common/src/common/lib/mux/pf_vf_mux_default_rtable.vh`).

### FIM AFU Instances

[fim\_afu\_instances.sv](fim_afu_instances.sv) contains the static region (SR) AFU endpoints. The OFS reference implementation contains a seperate AXI-ST port for every PF/VF routed to this region.
* PF2 is routed to HE-Loopback
* PF3 is routed to a VirtIO stub (HE-Null with a unique GUID)
* PF4 is routed to the HPS Copy Engine for HPS enabled designs
* all other PCIe functions are routed to instances of the null exerciser: HE-Null

### Port Gasket

The port gasket implements the Partial Reconfiguration (PR) feature as well as supporting features for a PR design like remote signal tap and user clock. It also contains the PR boundary hierarchy and attaches to the PF0VF port.