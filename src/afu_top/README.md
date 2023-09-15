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
            top_mux[/PF/VF Mux\]
            subgraph fim_afu_instances
                pf0(ST2MM)
                pf1(he_null)
                pf2(he_lb)
                pf3(virtio_stub)
                pf4(copy_engine)            
            end
            subgraph port_gasket
                subgraph afu_main
                    subgraph port_afu_instances
                        pg_mux_a[/PF/VF Mux\] <-- "VF0" --> pf0vf0(he_mem)
                        pg_mux_a[/PF/VF Mux\] <-- "VF1" --> pf0vf1(he_hssi)
                        pg_mux_a[/PF/VF Mux\] <-- "VF2" --> pf0vf2(mem_tg)
                    end
                end
            end
        end
    end
top_mux <--"PF0VF"--> pg_mux_a

top_mux <--"PF0"--> pf0
top_mux <--"PF1"--> pf1
top_mux <--"PF2"--> pf2
top_mux <--"PF3"--> pf3
top_mux <--"PF4"--> pf4

pf4 <---> HPS
pf0vf0 <---> mem0
pf0vf2 <---> mem1
pf0vf2 <---> mem2
pf0vf2 <---> mem3
pf0vf1 <---> HSSI

class TOP,AFU_TOP,Memory bg;
class port_gasket,fim_afu_instances afu_inst;
class afu_main pr;
class port_afu_instances pr_inst;
```

## Top-Level Modules

### PF/VF Mux
The PF/VF mux (`$OFS_ROOTDIR/ofs-common/src/common/lib/mux/pf_vf_mux_w_params.sv`) routes AXI-ST TLP requests from the PCIe subsystem to ports defined in [top_cfg_pkg.sv](mux/top_cfg_pkg.sv). The reference implementaiton provides two mux hierarchies:
* a top mux which is the root routing as follows: `PF0 -> Port 0`, `PF1 -> Port 1`, `PF2 -> Port 2`, `PF3 -> Port 3`, `PF4 -> Port 4`, `PF0VF -> Port 5`.
* a mux in the Partial Reconfiguration (PR) region attached to `Port 5` that routes every `PF0VF` to a separate port.

### FIM AFU Instances

[fim\_afu\_instances.sv](fim_afu_instances.sv) contains the static region (SR) AFU endpoints. The OFS reference implementation contains a seperate AXI-ST port for every PF/VF routed to this region:
* PF0 is routed to ST2MM (`$OFS_ROOTDIR/ofs-common/src/common/st2mm`) which translates AXI-ST TLP requests/completions from PCIe to AXI-Lite transfers connected to the OFS management fabric (APF/BPF).
* PF2 is routed to HE-Loopback
* PF3 is routed to a VirtIO stub (HE-Null with a unique GUID)
* PF4 is routed to the HPS Copy Engine for HPS enabled designs
* all other PCIe functions are routed to instances of the null exerciser: HE-Null

### Port Gasket

The port gasket (`$OFS_ROOTDIR/ofs-common/src/fpga_family/agilex/port_gasket`) implements the Partial Reconfiguration (PR) feature as well as supporting features for a PR design like remote signal tap and user clock. It also contains the PR boundary hierarchy and attaches to the PF0VF port.
