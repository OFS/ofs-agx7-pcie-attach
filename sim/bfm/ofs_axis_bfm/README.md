# OFS PCIe Subsystem AXI Streaming Bus Functional Model (BFM)

Contained in this directory is an object-oriented, SystemVerilog bus functional model of the PCIe subsystem meant for use in OFS Unit Test simulations.  The following subsections will provide some information about the individual packages and the code/classes contained therein. 

# Table of Contents

1. [Introduction](#introduction)
2. [Packet Class Package](#packet_class_pkg)
   1. [Packet Header Abstract Base Class](#packet_header_abstract_base_class)
      1. [Packet Header Constructor](#packet_header_constructor)
      2. [Packet Header Function Methods](#packet_header_function_methods)
   2. [Packet Header Classes](#packet_header_classes)
      1. [Packet Header Unknown Class](#packet_header_unknown_class)
      2. [Packet Header Power User Memory Request Class](#packet_header_power_user_memory_request_class)
      3. [Packet Header Power User Atomic Request Class](#packet_header_power_user_atomic_request_class)
      4. [Packet Header Power User Completion Class](#packet_header_power_user_completion_class)
      5. [Packet Header Data Mover Memory Request Class](#packet_header_data_mover_memory_request_class)
      6. [Packet Header Data Mover Completion Class](#packet_header_data_mover_completion_class)
      7. [Packet Header Message Class](#packet_header_message_class)
      8. [Packet Header Vendor-Defined Message (VDM) Class](#packet_header_vendor_defined_message_class)
   3. [Packet Classes](#packet_classes)
      1. [Packet Abstract Base Class](#packet_abstract_base_class)
      2. [Packet Unknown Class](#packet_unknown_class)
      3. [Packet Power User Memory Request Class](#packet_power_user_memory_request_class)
      4. [Packet Power User Atomic Request Class](#packet_power_user_atomic_request_class)
      5. [Packet Power User Completion Class](#packet_power_user_completion_class)
      6. [Packet Data Mover Memory Request Class](#packet_data_mover_memory_request_class)
      7. [Packet Data Mover Completion Class](#packet_data_mover_completion_class)
      8. [Packet Power User Message Class](#packet_power_user_message_class)
      9. [Packet Power User Vendor-Defined Message (VDM) Class](#packet_power_user_vendor_defined_message_class)
3. [Tag Manager Class Package](#tag_manager_class_package)
   1. [Tag Manager Class](#tag_manager_class)
4. [PF/VF Status Class Package](#pfvf_status_class_package)
   1. [PF/VF Routing Class](#pfvf_routing_class)
5. [Packet Delay Class Package](#packet_delay_class_package)
   1. [Packet Delay Class](#packet_delay_class)
   2. [Packet Gap Delay Class](#packet_gap_delay_class)
   3. [Packet Delay Queue Class](#packet_delay_queue_class)
   4. [Packet Gap Delay Queue Class](#packet_gap_delay_queue_class)
6. [Host Transaction Class Package](#host_transaction_class_package)
   1. [Transaction Abstract Base Class](#transaction_abstract_base_class)
   2. [Read Transaction Class](#read_transaction_class)
   3. [Write Transaction Class](#write_transaction_class)
   4. [Atomic Transaction Class](#write_transaction_class)
   5. [Send Message Transaction Class](#send_message_transaction_class)
   6. [Send Vendor-Defined Message (VDM) Transaction Class](#send_vendor_defined_message_transaction_class)
7. [Host Memory Class Package](#host_memory_class_package)
   1. [Memory Access Class](#memory_access_class)
   2. [Memory Entry Class](#memory_entry_class)
   3. [Host Memory Class](#host_memory_class)
8. [Host AXI-ST Receive Class Package](#host_axis_receive_class_package)
   1. [Host AXI-ST Receive Class](#host_axis_receive_class)
9. [Host AXI-ST Send Class Package](#host_axis_send_class_package)
   1. [Host AXI-ST Send Class](#host_axis_send_class)
10. [Base and Concrete Class Implementations](#base_and_concrete_classes)
   1. [PCIe Function-Level Reset](#pcie_function_level_reset)
      1. [Host FLR Class Package](#host_flr_class_package)
         1. [Host FLR Event Class](#host_flr_event_class)
         2. [Host FLR Manager Class](#host_flr_manager_class)
      2. [Host FLR Top](#host_flr_top)
         1. [Host FLR Manager Concrete Class](#host_flr_manager_concrete_class)
   2. [Host Bus Functional Model (BFM)](#host_bus_functional_model)
      1. [Host Bus Functional Model (BFM) Class Package](#host_bus_functional_model_class_package)
         1. [Host Bus Functional Model (BFM) Abstract Base Class](#host_bus_functional_model_abstract_base_class)
      2. [Host Bus Functional Model (BFM) Top](#host_bus_functional_model_top)
         1. [Host Bus Functional Model (BFM) Concrete Class](#host_bus_functional_model_concrete_class)
         2. [Packet Delay Queue for TX_REQ AXI-ST Interface Concrete Class](#packet_delay_queue_for_tx_req_axi_s_interface_concrete_class)
         3. [Packet Gap Delay Queue for RX_REQ AXI-ST Interface Concrete Class](#packet_gap_delay_queue_for_rx_req_axi_s_interface_concrete_class)



## <a id="introduction">Introduction</a>

The job of a bus functional model (BFM) is to effectively represent or mimic a bus master's behavior in a simulation environment without having to include all of the detailed code necessary to synthesize it.  The BFM located here makes use of dynamically generated class objects and memory structures like dynamic arrays, queues, and associative arrays to implement functional blocks.  These dynamic structures are not synthesizable but are very useful and efficient in simulation.  Also, a BFM might include more features specifically needed for simulation like generating error conditions or failure tests to affirm the stability of the code it tests -- things not needed or outright avoided in synthesizable RTL.  Additional simulation features like statistics collection and performance reporting are often included in the BFM that may not have an analogous function in synthesizable code.

The following sections of this document will provide details on the packages, classes, and other code included in the BFM.  The code contained here was written in object-oriented SystemVerilog.  Some classes, particularly the Packet Class, have been written so that there is a class inheritance hierarchy that implements polymorphism: where the base class objects and the descendents all "look the same" so that they can coexist in the same queues, memories, and object handles.  Other high-level techniques, like using singleton objects will be covered in the classes where used.


## <a id="packet_class_pkg">Packet Class Package</a>

Packets are the basic method for requesting and moving data around in a PCIe-centric system like OFS.  The file `packet_class_pkg.sv` contains all of the packet class definitions for the OFS BFM.  This package contains the definitions for the packet headers and the packets with or without payloads.  The inheritance hierachy will be noted in the following subsections so that the composition of the packet classes are understood.  For all the packet types, they will all have the same methods in order to preserve polymorphism which allows all of the differnt packet types to externally look the same even though they may act differently.

The following sections will start with the header classes followed by the packet classes.


### <a id="packet_header_abstract_base_class">Packet Header Abstract Base Class</a>

`Class Name.......: PacketHeader`
`Class Inheritance: None`
`Source File......: packet_class_pkg.sv`

An abstract base class is a virtual class that cannot actually be created -- it is meant to be used as a foundation for other classes which will build upon it.  This is the case with the first class contained in `packet_class_pkg.sv` : `PacketHeader`.

Base class `PacketHeader` contains data members to support the construction of the standard PCIe Transaction Layer Packet (TLP) header fields.  All of the data members are `protected` in order to preserve encapsulation.  Only in cases where direct access to data member is absolutely required will a data member be listed as anything other than `protected` or `local` in scope.  The following diagram is an excerpt from _Section 2.2.4.1 of the PCI Express Base Specification, Rev. 4.0 Version 1.0_ showing some of the fields that are supported in this class.

![Standard TLP Header Format](./readme_media/standard_tlp_request_header_format.png "Standard TLP Header Format and Fields")*Figure 2.1: Standard TLP Header Format*

The `PacketHeader` base class also contains all of the function methods for the entire hierarchy of header classes in order to preserve polymorphism. Many of the function method definitions declared in the base class will be used as-is in the subsequent subclasses, but this is not always the case. Some of the function methods make no sense except only in special cases, for example the function:

```verilog
virtual function bit [3:0] get_mctp_vdm_code();
      // Static-zero function: this method does nothing in this abstract base 
      // class, but select child classes will define it.  It is declared here 
      // to maintain base class compatibility (polymorphism).
      return 4'b0000;
   endfunction
```

This function method only makes sense in the Vendor-Defined Message (VDM) headers.  Every other header class will have no need for it, so in the base class this method only returns a static `4'b0000` and will do so in all of the subclasses that inherit from it until it is redefined as needed in the VDM header class.

#### <a id="packet_header_constructor">Packet Header Constructor</a>

There are a few things to note in the `PacketHeader` constructor, shown here:

```verilog
// Constructor for PacketHeader
function new(
   input packet_format_t packet_format,
   input packet_header_op_t packet_header_op,
   input bit [9:0] length_dw
);
   this.packet_format = packet_format;
   this.packet_header_op = packet_header_op;
   this.length_dw = length_dw;
   this.tag = '0;
   this.tc = '0;
   this.at = '0;
   this.attr = '0;
   this.ep = '0;
   this.td = '0;
   this.th = '0;
   this.ln = '0;
   this.ph = '0;
   this.prefix = '0;
   this.prefix_type = '0;
   this.prefix_present = '0;
   this.pf_vf_route = PFVFRouting::get(); // Singleton object for PCIe setting.
   this.bar  = pf_vf_route.get_bar();
   this.slot = pf_vf_route.get_slot();
   this.pf   = pf_vf_route.get_pf();
   this.vf   = pf_vf_route.get_vf();
   this.vf_active = pf_vf_route.get_vfa();
   this.pf_vf_setting = pf_vf_route.get_env();
   this.last_pf_vf_setting = pf_vf_route.get_env();
   this.request_delay = 0;
   this.completion_delay = 65;
   this.gap = 5;
endfunction
```

Most of the assignments in the constructor are rather basic with most fields getting initialized to zeros.  However, there are some assignments in the constructor to note.

The settings for the BAR, slot, PF, VF and VF Active bits are set according the to values contained in an object called `pf_vf_route` which is a `PFVFRouting` object.  This is a global object called a "singleton" -- only one copy of this object can ever be created due to the way it is coded (visit that section to see the details).  This object maintains the "current" setting of the BAR, slot, PF, VF, and VF Active and sets any packet header created to contain these "current" values automatically.  Subsequent changes to the `pf_vf_routing` singleton object will not retroactively change these values -- only for newly created packet headers created after a change to the state the `PFVFRouting` object.

Also note that there are some "gap" and "delay" data members initialized in the constructor.  

The member `request_delay` is the delay for outgoing request packets in AXI-ST bus clock cycles.  This value will create a delay between the time when a packet is submitted for transmission and the time when it is actually transmitted on the AXI-ST interface RX_REQ.  Currently, this value is set to a default of zero, which means that the packet is transmitted immediately when received in RX_REQ interface packet queue.  

The second delay member is the `completion_delay`.  This is also measured in the number AXI-ST bus clock cycles.  This value creates a delay from the time when a is received on the TX AXI-ST interface and when a completion is returned from the RX_REQ AXI-ST interface back to the requester.Currently, this value is set to 65 clock cycles so that it emulates the delay exhibited by the current PCIe Subsystem.

The final "gap" and "delay" data member in the `PacketHeader` base class is `gap`.  This value inserts a delay between back-to-back request packets.  Currently, this value is set to 5 AXI-ST bus clock cycles.  This means that if more than one packet is placed in the RX_REQ interface queue between clock cycles, a delay of 5 clocks is inserted between the packets.  If it is desired to send a number of back-to-back packets on the RX_REQ interface, then the method `virtual function void set_gap(input uint32_t gap)` may be used with either packets or transactions to set the gap to zero -- sending the packets one after the other with no gaps.

#### <a id="packet_header_function_methods">Packet Header Function Methods</a>

Most of the methods included in `PacketHeader` are fairly straightforward.  Since the OFS BFM classes rely on encapsulation, almost all of the data members are declared as protected, keeping users from directly accessing the data members -- requiring working with the header classes as they are intended: with their respective methods.  Access to the data member variables is done via `get` or `set` methods that read and write these variables, respectively.  For instance, to work with the packet header's tag, there is a `get` function method to read it:

```verilog
   virtual function packet_tag_t get_tag();
      return this.tag;
   endfunction
```

There is also a corresponding `set` function method to write it:

```verilog
   virtual function void set_tag(input packet_tag_t tag);
      this.tag = tag;
      map_fields();
   endfunction
```

This type of access control is used for all of the data members in this class.

There are a few `pure virtual` methods in the abstract `PacketHeader` class.  Pure virtual functions declared in the abstract base class aren't defined except for their names, their return values, and their inputs.  Although definition of pure virtual functions aren't included in the base class, definition of these functions is _required_ in any derived class that is not abstract.  This is often done for methods that are needed in a class hierarchy, but their definition is dependent on the nature of the derived classes and required by their inclusion in other methods.  Two such important functions are `map_fields` and `assign_fields`.  Here are the declarations for these two functions in `PacketHeader`:

```verilog
   // Map Header Values to Double-Word Fields
   pure virtual protected function void map_fields();

   // Assign Header Values from Double-Word Fields
   pure virtual protected function void assign_fields();
```

As the comments indicate, the `map_fields` function method takes the values from the data members in the class and maps them to their corresponding double-word mapped bit fields in the header.  The eight double-word fields that form the header during packet assembly are declared as:

```verilog
   // Data Mapping into Double Words and Bytes
   protected bit [31:0] header_dw [8];
   protected bit [7:0] header_bytes [32];
```

Working with the double-word fields to map the data values is the easiest and most intuitive way since this is the way it illustrated in the PCIe Specification.  The `header_bytes` are created by streaming the `header_dw` words into bytes.  As the words are easier to work with when extracting and assigning values to fields, bytes are easier to work with when doing the actual packet assembly.

As `map_fields` maps data members into their corresponding fields for packet creation, the function `assign_fields` does the reverse by extracting the fields from a set of header double-words and assigning these values to their respective data members, depending on the header type.  As an example, the following code snippet shows the definitions of `map_fields` and `assign_fields` for the Power User Memory Request Header class `PacketHeaderPUMemReq` that is derived from `PacketHeader`:

```verilog
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw};
      header_dw[1] = {requester_id, tag[7:0], last_dw_be, first_dw_be};
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         header_dw[2] = address[63:32];
         header_dw[3] = {address[31:2], ph};
      end
      else
      begin
         header_dw[2] = {address[31:2], ph};
         header_dw[3] = '0;  // Blank Field for 3DW Addressing
      end
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, 1'b0, slot, bar, vf_active, vf, pf};
      header_dw[6] = '0; // Reserved Fields
      header_dw[7] = '0; // Reserved Fields
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ((fmt_type == MRD4) || (fmt_type == MRD3))
      begin
         packet_header_op = READ;
      end
      else
      begin
         if ((fmt_type == MWR4) || (fmt_type == MWR3))
            packet_header_op = WRITE;
         else
            packet_header_op = NULL;
      end
      {requester_id, tag[7:0], last_dw_be, first_dw_be} = header_dw[1];
      if ((fmt == HDR_4DW_NO_DATA) || (fmt == HDR_4DW_WITH_DATA))
      begin
         address[63:32] = header_dw[2];
         {address[31:2], ph} = header_dw[3];
      end
      else
      begin
         address[63:32] = '0;
         {address[31:2], ph} = header_dw[2];
      end
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, vf_active, vf, pf} = header_dw[5][23:0];
   endfunction
```

This mapping in and out of double-words is done differently for each of the header classes depending on their composition and need.


### <a id="packet_header_classes">Packet Header Classes</a>

In the following packet header sections, details about the derived header classes will be provided to help guide the user in choosing the correct class hierarchy when creating new classes.


#### <a id="packet_header_unknown_class">Packet Header Unknown Class</a>

`Class Name.......: PacketHeaderUnknown`
`Class Inheritance: PacketHeader`
`Source File......: packet_class_pkg.sv`

The `PacketHeaderUnknown` header class is a very flexible and generic class meant to be free from format restrictions enforced by other derived header classes.  The `map_fields` and `assign_fields` function methods in this class are empty functions: freeing up the user to format the header double-words as they want without the class correcting them.  This is particularly important if the user wants to create "errored" packets or packets with an unusual format that does not comply with the formatting enforced by other classes.  Having this freedom comes at a price however: the user will have to manually map all the header fields that are desired when creating packet headers as well as extracting the desired bit fields from received packets. 


#### <a id="packet_header_power_user_memory_request_class">Packet Header Power User Memory Request Class</a>

`Class Name.......: PacketHeaderPUMemReq`
`Class Inheritance: PacketHeader`
`Source File......: packet_class_pkg.sv`

The `PacketHeaderPUMemReq` header class is the first of our "work-horse" derived classes of `PacketHeader`.  Supported by this class are Power User Memory Request headers for read and write with 4DW or 3DW support for 64-bit or 32-bit addressing.  These packets form all of our Control and Status Register (CSR) reads and writes which drive most of the simulation unit tests.

The basic format supported with this class is depicted below, an excerpt from _Section 2.2.7 of the PCI Express Base Specification, Rev. 4.0 Version 1.0_ showing the fields required to support these packet types.

![Memory Request TLP Header Format](./readme_media/tlp_pu_mem_req_header_format.png "Memory Request TLP Header Format")*Figure 2.2.2: Memory Request TLP Header Format*

Data members to support the additional fields in the TLP Memory Request Header are included in `PacketHeaderPUMemReq`.  They are:

```verilog
   // Data Members
   protected uint64_t   address;
   protected bit [15:0] requester_id;
   protected bit  [3:0] first_dw_be;
   protected bit  [3:0] last_dw_be;
```

Since these data members are protected, there are corresponding get/set methods to access them.

The get/set methods for address actually include an additional get method to adjust the address for the first DW byte enable field:

```verilog
   virtual function uint64_t get_addr();
      return this.address;
   endfunction


   //---------------------------------------------------------------------------
   // This get method returns the memory request address adjusted by the
   // first DW byte enable field.  For each zero in the field, the byte address
   // is moved up on address location.
   //
   // This method assumes that the first DW byte enable fields bits are
   // contiguous and right adjusted.  If this is not the case, then the
   // address calculation should be done by reading the address with the
   // "get_addr" method and modifying as needed using the DW byte enable fetched
   // with the get method "get_first_dw_be".
   //---------------------------------------------------------------------------
   virtual function uint64_t get_addr_first_be_adjusted();
      uint64_t addr;
      int i;
      addr = this.address;
      for (i = 0; i < 4; i++)
      begin
         if (this.first_dw_be[i] == 1'b0)
         begin
            addr = addr + uint64_t'(1);
         end
      end
      return addr;
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.address = addr;
      this.set_packet_fmt_type(); // Done in case the address requires a change between 4DW and 3DW headers.
   endfunction
```

The requester ID value for this header is provided as an input to the constructor, and there is no set method to change this value after the object is created.  Changing the requester ID does not make sense here.  A packet with a differnt requester ID is essentially a different packet.  Therefore, the appropriate way to handle a requester ID change for a packet would be to create a new packet/header with the new requester ID provided to the constructor.  Reading the requester ID, however, is supported with a get method and may be done as often as needed.  Here is the code for the requester ID get method:

```verilog
   virtual function bit [15:0] get_requester_id();
      return this.requester_id;
   endfunction
```

Note that the `map_fields` and `assign_fields` methods in `PacketHeaderPUMemReq` (shown in previous section)  properly place and extract this field from the packet header.

Finally, the first DW byte enable and last DW byte enable fields allow the user to work with these fields:

```verilog
   virtual function bit [15:0] get_requester_id();
      return this.requester_id;
   endfunction


   virtual function bit [3:0] get_first_dw_be();
      return this.first_dw_be;
   endfunction


   virtual function void set_first_dw_be(input bit [3:0] first_dw_be);
      this.first_dw_be = first_dw_be;
      map_fields();
   endfunction


   virtual function bit [3:0] get_last_dw_be();
      return this.last_dw_be;
   endfunction


   virtual function void set_last_dw_be(input bit [3:0] last_dw_be);
      this.last_dw_be = last_dw_be;
      map_fields();
   endfunction
```

#### <a id="packet_header_power_user_atomic_request_class">Packet Header Power User Atomic Request Class</a>

`Class Name.......: PacketHeaderPUAtomic`
`Class Inheritance: PacketHeaderPUMemReq`
`Source File......: packet_class_pkg.sv`

Support for PCIe Atomic Operations is provided via the creation of the header class `PacketHeaderPUAtomic`.  The format for this header is relatively similar to the memory read and write requests, which is why it directly descends from the class `PacketHeaderPUMemReq`, inheriting all of its data members, requiring only one new data member: a variable specifying which atomic operation is to be carrieds out.

The constructor for this class adds some additional logic to the one inherited from `PacketHeaderPUMemReq`.  It makes sure that the payload length is valid for the respective atomic operation, or it "nulls" the packet and will make the BFM drop it.

Here is the constructor:

```verilog
   // Constructor for PacketHeaderPUAtomic 
   function new(
      input packet_header_atomic_op_t packet_header_atomic_op,
      input bit [15:0] requester_id,
      input uint64_t   address,
      input bit  [9:0] length_dw
   );
      super.new(
         .packet_header_op(ATOMIC), 
         .requester_id(requester_id),
         .address(address),
         .length_dw(length_dw),
         .first_dw_be(4'b1111),
         .last_dw_be(4'b1111)
      );
      if ( ((packet_header_atomic_op == FETCH_ADD) && ((length_dw == 10'd1) || (length_dw == 10'd2))) ||
           ((packet_header_atomic_op == SWAP)      && ((length_dw == 10'd1) || (length_dw == 10'd2))) ||
           ((packet_header_atomic_op == CAS)       && ((length_dw == 10'd2) || (length_dw == 10'd4)   || (length_dw == 10'd8))) )
      begin
         this.packet_header_op = ATOMIC;
         this.packet_header_atomic_op = packet_header_atomic_op;
      end
      else
      begin
         this.packet_header_op = NULL;
         this.packet_header_atomic_op = packet_header_atomic_op;
      end
      this.set_packet_fmt_type();
   endfunction
```

The PCIe Atomic Operations supported are:

1. Fetch-Add operations with operand field lengths of 1DW or 2DW (operand sizes of 32-bit and 64-bit).
   - Packet will contain one operand, the "add" value.
   - Packet will contain the address of the target memory location for the operation.
   - Operation: 
      - Adds the "add" value to the value at the target memory location.
      - Stores the result of the addition at the same memory location.
      - Returns the original value found at the memory location prior to the add operations.
2. Swap operations with operand field lengths of 1DW or 2DW (operand sizes of 32-bit and 64-bit).
   - Packet will contain one operand, the "swap" value.
   - Packet will contain the address of the target memory location for the operation.
   - Operation: 
      - Swaps the data at a target location with the "swap" value. 
      - Stores the "swap" value at the target address.
      - Returns the original value found at the memory location prior to the operation.
3. Compare-and-Swap operations with operand field lengths of 2DW, 4DW, or 8DW (operand sizes of 32-bit, 64-bit, and 128-bit).
   - Packet will contain two operands.
      - First operand is the "compare" value.
      - Second operand is the "swap" value.
   - Packet will contain the address of the target memory location for the operation.
   - Operation: 
      - First the data at the target memory location is compared to the "compare" value.
      - If the two values are different, no change to the target memory location occurs.
      - However, if the data at the target location is equal to the "compare" value, then a swap occurs.
         - The data at the target memory location is swapped with the "swap" value.
         - The "swap" data is stored at the target memory location.
      - Whether the swap occurs or not, the operation returns the original value found at the target memory location.

In all of the Atomic operations, the original data at the targeted memory location is returned back to the requester with a completion packet.

#### <a id="packet_header_power_user_completion_class">Packet Header Power User Completion Class</a>

`Class Name.......: PacketHeaderPUComletion`
`Class Inheritance: PacketHeaderPUMemReq`
`Source File......: packet_class_pkg.sv`

The `PacketHeaderPUComletion` header is another extremely important class that is used in concert with all of the packets requesting data.  For operations like reads and Atomic operations where data is returned from the completer to the requester, this data is sent back in the form of a completion packet.  

The basic format supported with this class is depicted below, an excerpt from _Section 2.2.9 of the PCI Express Base Specification, Rev. 4.0 Version 1.0_ showing the fields required to support this packet type.

![Completion TLP Header Format](./readme_media/standard_completion_header_format.png "Completion TLP Header Format")*Figure 2.2.4: CompletionTLP Header Format*

Data members have been added to this class to support the header fields shows in Figure 2.2.4 above.

Here is the source code showing the list of data members added in `PacketHeaderPUComletion`:

```verilog
   // Data Members
   protected data_present_type_t cpl_data_type;
   protected bit [15:0]   completer_id;
   protected cpl_status_t cpl_status;
   protected bit bcm; // Byte Count Modified
   protected bit [11:0]   byte_count; // TLP payload length in bytes 
   protected bit  [6:0]   lower_address;  // Lower byte address for starting byte of completion
```

The first data member in the list above determines whether or not this completion has a payload or not.  It's called `cpl_data_type` and it's type is `data_present_type_t` which is defined as follows in the `packet_class_pkg` package:

```verilog
typedef enum {
   NO_DATA_PRESENT,
   DATA_PRESENT
} data_present_type_t;
```

In use with the simulation unit tests, most or all of our expected completions will contain data, so `DATA_PRESENT` will be the overwhelmingly observed selection.  However, to keep compatibility with the PCIe Completion definition, the ability of the completions to have or not-have data will be enabled and the choice of TLP FMT/Type will follow accordingly.

Since the requester ID is already included in this class due to its inheritance from the `PacketHeaderPUMemReq` class, this does not need to be added to `PacketHeaderPUComletion`.  However, until now we have not needed the completer ID, so we add it now with the data member `completer_id`.  Like the requester ID, the completer ID is used during the construction of the `PacketHeaderPUComletion` object and should not be changed afterward.  Therefore, there is no set method for the completer ID and since the variable is `protected`, it cannot be changed outside of the class - enabling proper object data encapsulation.  However, the completer ID may be read as many times as needed with the use of a get method, `get_completer_id`:

```verilog
   virtual function bit [15:0] get_completer_id();
      return this.completer_id;
   endfunction
```

The status of the completion is contained in the variable `cpl_status` of type `cpl_status_t`.  This type is defined as follows in the `packet_class_pkg` package:

```verilog
typedef enum bit [2:0] {
   CPL_SUCCESS             = 3'b000,
   CPL_UNSUPPORTED_REQUEST = 3'b001,
   CPL_REQUEST_RETRY       = 3'b010,
   CPL_COMPLETER_ABORT     = 3'b100,
   CPL_ERROR               = 3'b111
} cpl_status_t;
```

The value of the completion status can be read or changed as needed.  The following two get/set methods enable this capability:

```verilog
   virtual function cpl_status_t get_cpl_status();
      return this.cpl_status;
   endfunction


   virtual function void set_cpl_status(
      input cpl_status_t cpl_status
   );
      this.cpl_status = cpl_status;
      map_fields();
   endfunction
```

The completion header bit, Byte Count Modified (BCM), is supported with both get and set methods.

Header fields `byte_count` and `lower_address` have somewhat different controls.  

The `byte_count` is provided as a 12-bit input into the constructor -- clearly meant to reflect the byte count of the standard 10-bit double-word lengths supplied with the memory request packets.  However, payload flexibility was in mind when supporting the byte count.  Later in the packet class package, the packet payloads are handled with dynamic byte arrays or byte queues.  The lengths of these memory structures are handled with 32-bit integers.  Converting back-and-forth between the 12-bit `byte_count` and a 32-bit unsigned integer would be a bit messy, so a couple of methods are provided to handle this and at the same time manage `byte_count`.  They are `get_length_bytes` and `set_length_bytes`:

```verilog
   virtual function uint32_t get_length_bytes();
      uint32_t total_bytes;
      if (byte_count == '0)
      begin
         total_bytes = 1024 * 4;
      end
      else
      begin
         total_bytes = uint32_t'(byte_count);
      end
      return total_bytes;
   endfunction


   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      // Future: Put some checking here in cast length_bytes[63:12] has any
      // ones in it.
      if (length_bytes == 1024*4)
         this.byte_count = '0;
      else
         this.byte_count = length_bytes[11:0];
      length_dw = (|byte_count[1:0]) ? (byte_count>>2) + 10'd1 : byte_count>>2;
      map_fields();
   endfunction
```

Note that in these methods, a double-word (DW) count is also maintained in case it is needed.  DW lengths can be managed using the get/set methods provided by the `PacketHeader` base class through inheritance.  This is stored in the data member `length_dw` which is also inherited from the class `PacketHeader`.   In case the 12-bit byte count needs to be fetched in its natural 12-bit form, it can be done with the get method, `get_byte_count`:

```verilog
   virtual function bit [11:0] get_byte_count();
      return this.byte_count;
   endfunction
```

The data member `lower_address` also has a somewhat hybrid way of being handled similar to `byte_count`.  Like `byte_count`, `lower_address` is also supplied to the class constructor as an input.  Addresses are often handled as an unsigned 64-bit integer throughout the testbench, so there are a couple of get/set methods to handle this.  The are called `get_addr` and `set_addr`:

```verilog
   virtual function uint64_t get_addr();
      return {'0, this.lower_address};
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.lower_address = addr[6:0];
      map_fields();
   endfunction
```

Also, as with `byte_count`, there is also a natively-sized 7-bit get method for fetching the `lower_address` called `get_lower_address`:

```verilog
   virtual function bit [6:0] get_lower_address();
      return this.lower_address;
   endfunction
```


#### <a id="packet_header_data_mover_memory_request_class">Packet Header Data Mover Memory Request Class</a>

`Class Name.......: PacketHeaderDMMemReq`
`Class Inheritance: PacketHeader`
`Source File......: packet_class_pkg.sv`

The header class `PacketHeaderDMMemReq` supports the Intel PCIe Subsystem Data Mover packet header format.  Data Mover format was devised to make large data transfers more efficient by allowing data transfers of up to 16MB instead of the usual maximum of 4096 bytes using a PCIe TLP.  To include the much larger 24-bit length field, some of the PCIe TLP's fields had to be repurposed, while others were preserved and carried over from the standard TLP header.  This class implements read and write memory requests using this expanded data throughput capability.

This proprietary packet header format is shown below, as excerpt from _Section 3.2.4.1.1.2 of the Intel PCIe Sub-System High-Level Architecture Specification, IP Revision 2.05, October 2022_ showing the fields required to support this packet type.  It also shows what PCIe FMT/Type is used with these packets.

![Data Mover Memory Request Packet Header Format](./readme_media/data_mover_mem_req_header_format.png "Data Mover Memory Request Packet Header Format")*Figure 2.2.5: Data Mover Memory Request Packet Header Format*

These packets use already-defined TLP FMT/Type values of 8'h20 for Data Mover Read (DMRd) and 8'h60 for Data Mover Write (DMWr).  These normally correspond to MRd (with 4DW header) and MWr (also with 4DW header) TLP FMT/Type encodings in Power User (PCIe TLP) format.  Since both Power User and Data Mover packets can coexist on the same AXI-ST bus, there was a way needed to differentiate the two during bus transactions.  This is done by using the AXI-ST bus's `tuser_vendor` bits to communicate this difference in real time.  Bit `tuser_vendor[0]` signals to the transaction receiver what format the packet header is in:

- `tuser_vendor[0] = 1'b0` indicates a Power User header (regular PCIe TLP).
- `tuser_vendor[0] = 1'b1` indicates a Data Mover header.

The BFM logic and the FIM AXI-ST interface logic must be able to decode this operation in order to properly sort the mixed traffic.  If, for some reason, an AXI-ST interface is not expected to carry mixed traffic, then this bit _can_ be ignored, but decoding one bit should not impose too much of a logic burden and supporting both packet formats would make the AXI-ST interfaces more robust and interchangeable in operation.

To support the Data Mover header format, the following data members for the `PacketHeaderDMMemReq` class are defined as follows:

```verilog
   // Data Members
   protected uint64_t host_address;
   protected uint64_t local_address;
   protected uint64_t meta_data;
   protected dm_length_t length;
   protected bit mm_mode;
```

The `host_address` field is handled with the standard `get_addr()` and `set_addr()` function methods as other header formats are done.

The `local_address` field is handled with its own set of get and set methods, `get_dm_local_addr()` and `set_dm_local_addr()`:

```verilog
   virtual function uint64_t get_dm_local_addr();
      return this.local_address;
   endfunction


   virtual function void set_dm_local_addr(
      input uint64_t dm_local_addr
   );
      this.local_address = dm_local_addr;
      map_fields();
   endfunction
```

Data member `meta_data` is also handled by it's own set of get and set methods, `get_dm_meta_data()` and `set_dm_meta_data()`:

```verilog
   virtual function uint64_t get_dm_meta_data();
      return this.meta_data;
   endfunction


   virtual function void set_dm_meta_data(
      input uint64_t dm_meta_data
   );
      this.meta_data = dm_meta_data;
      map_fields();
   endfunction
```

The `length` data member is declared with the type `dm_length_t`.  This is defined in the `host_bfm_types_pkg` package in the file `host_bfm_types_pkg.sv`.  Here is the type definition:

```verilog
typedef bit  [23:0] dm_length_t;
```

Get and set methods are also provided for `length` as follows:

```verilog
   virtual function uint32_t get_length_bytes();
      return uint32_t'(length);
   endfunction


   virtual function void set_length_bytes(
      input uint32_t length_bytes
   );
      this.length = length_bytes[23:0];
      map_fields();
   endfunction
```

The "memory mode" header bit `mm_mode` is used to determine what fields are populated in the Data Mover header at header words `header_dw[6]` and `header_dw[7]`, where the value can either the 64-bit local address or the 64-bit meta data field.  The `mm_mode` bit is managed by the regular set of get/set methods:

```verilog
   virtual function bit get_mm_mode();
      return this.mm_mode;
   endfunction


   virtual function void set_mm_mode(
      input bit mm_mode
   );
      this.mm_mode = mm_mode;
      map_fields();
   endfunction
```

Proper use of the `mm_mode` bit and the management of the header fields is done in the usual `map_fields()` and `assign_fields()` methods.  Note the switch between the local address and meta data fields in both:

```verilog
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length[11:2]};
      header_dw[1] = {host_address[1:0], length[23:12], length[1:0], tag[7:0], 8'b0000_0000};
      header_dw[2] = host_address[63:32];
      header_dw[3] = {host_address[31:2], ph};
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, mm_mode, this.slot, 4'b0000, this.vf_active, this.vf, this.pf};
      if (mm_mode)
      begin
         header_dw[6] = local_address[63:32];
         header_dw[7] = local_address[31:0];
      end
      else
      begin
         header_dw[6] = meta_data[63:32];
         header_dw[7] = meta_data[31:0];
      end
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length[11:2]} = header_dw[0];
      {host_address[1:0], length[23:12], length[1:0], tag[7:0]} = header_dw[1][31:8];
      host_address[63:32] = header_dw[2];
      {host_address[31:2], ph} = header_dw[3];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {mm_mode, slot, bar, vf_active, vf, pf} = header_dw[5][24:0];
      if (mm_mode)
      begin
         local_address[63:32] = header_dw[6];
         local_address[31:0]  = header_dw[7];
      end
      else
      begin
         meta_data[63:32] = header_dw[6];
         meta_data[31:0]  = header_dw[7];
      end
   endfunction
```

All of the aforementioned data members are also inputs into this class's constructor with one exception.  Since the local address field or the meta data field are applied to the header depending on the state of the `mm_mode` bit, there is a single input called `local_address_or_meta_data` that is of type `uint64_t` that stands in for either input since they are both also type `uint64_t`.  Please see the source code for the `PacketHeaderDMMemReq` constructor below, noting how the `mm_mode` input bit is used to control the data member assignments:

```verilog
   // Constructor for PacketHeaderDMMemReq 
   function new(
      input packet_header_op_t packet_header_op,
      input uint64_t host_address,
      input uint64_t local_address_or_meta_data,
      input dm_length_t length,
      input bit mm_mode
   );
      super.new(
         .packet_format(DATA_MOVER),
         .packet_header_op(packet_header_op),
         .length_dw( (|length[1:0]) ? (length>>2) + 10'd1 : length>>2 )
      );
      if ((packet_header_op == READ) || (packet_header_op == WRITE))
         this.packet_header_op = packet_header_op;
      else
         this.packet_header_op = NULL;
      this.host_address = host_address;
      this.mm_mode = mm_mode;
      if (mm_mode)
      begin
         this.local_address = local_address_or_meta_data;
         this.meta_data = '0;
      end
      else
      begin
         this.local_address = '0;
         this.meta_data = local_address_or_meta_data;
      end
      this.length = length;
      this.ph = 2'b00;
      this.set_packet_fmt_type();
   endfunction
```


#### <a id="packet_header_data_mover_completion_class">Packet Header Data Mover Completion Class</a>

`Class Name.......: PacketHeaderDMCompletion`
`Class Inheritance: PacketHeaderDMMemReq`
`Source File......: packet_class_pkg.sv`

The header class `PacketHeaderDMCompletion` is the completion counterpart for the Data Mover memory request class `PacketHeaderDMMemReq`.  Memory requests made with Data Mover reads (DMRd) will have their data returned with completion packets using this header.  Inheritance from the `PacketHeaderDMMemReq` class preserves the overall Data Mover header format and simplifies the code for this derived class.

The format for the Data Mover completion header is shown below, as excerpt from _Section 3.2.4.1.1.4 of the Intel PCIe Sub-System High-Level Architecture Specification, IP Revision 2.05, October 2022_ showing the fields required to support this packet type.  Note that the "RsvdP" fields are preserved from the original request packet received.

![Data Mover Completion Packet Header Format](./readme_media/data_mover_mem_req_header_format.png "Data Mover Completion Packet Header Format")*Figure 2.2.6: Data Mover Completion Header Format*

This packet uses an already-defined TLP FMT/Type value of 8'h4A which corresponds to a PCIe Completion TLP with Data (CplD).  As with the DMRd and DMWr requests, both Power User traffic and Data Mover Completions may coexist on the same AXI-ST bus, requiring a way to differentiate the PU and DM completions from one another during bus transactions.  This differentiation is done in the same manner as the DM Requests using the AXI-ST bus's `tuser_vendor` bits.  Bit `tuser_vendor[0]` signals to the transaction receiver what format the packet header is in:

- `tuser_vendor[0] = 1'b0` indicates a Power User header (regular PCIe TLP).
- `tuser_vendor[0] = 1'b1` indicates a Data Mover header.

The BFM logic and the FIM AXI-ST interface logic must be able to decode this operation in order to properly sort the mixed traffic.  If, for some reason, an AXI-ST interface is not expected to carry mixed traffic, then this bit _can_ be ignored, but decoding one bit should not impose too much of a logic burden and supporting both packet formats would make the AXI-ST interfaces more robust and interchangeable in operation.

To support the completion's functions, the following data members for the `PacketHeaderDMCompletion` class are as follows:

```verilog
   // Data Members
   protected cpl_status_t cpl_status;
   protected bit fc; // Final Completion.
   protected bit [23:0] lower_address;
   protected bit reordering_enable;
```

The Data Mover completion status `cpl_status` uses the same data type as that for the Power User: `cpl_status_t`.  This type is defined as follows in the `packet_class_pkg` package:

```verilog
typedef enum bit [2:0] {
   CPL_SUCCESS             = 3'b000,
   CPL_UNSUPPORTED_REQUEST = 3'b001,
   CPL_REQUEST_RETRY       = 3'b010,
   CPL_COMPLETER_ABORT     = 3'b100,
   CPL_ERROR               = 3'b111
} cpl_status_t;
```

The value of the completion status can be read or changed as needed.  The following two get/set methods may be used in this regard:

```verilog
   virtual function cpl_status_t get_cpl_status();
      return this.cpl_status;
   endfunction


   virtual function void set_cpl_status(
      input cpl_status_t cpl_status
   );
      this.cpl_status = cpl_status;
      map_fields();
   endfunction
```

Completions with a possible return payload size of up to 16MB might require some segmentation, where the return data might be broken up over several completion packets.  To signal to the receiver that the current completion is the last in a sequence, the `fc` bit or Final Completion bit, is set in the header.  As with other header bits, this one can be controlled with get/set methods:

```verilog
   virtual function bit get_fc();
      return this.fc;
   endfunction


   virtual function void set_fc(
      input bit fc
   );
      this.fc = fc;
      map_fields();
   endfunction
```

The completion's field `lower_address` is managed by the following two rather normal get/set methods:

```verilog
   virtual function uint64_t get_addr();
      return {'0,this.lower_address};
   endfunction


   virtual function void set_addr(
      input uint64_t addr
   );
      this.lower_address = addr[23:0];
      map_fields();
   endfunction
```

Note that the operand size is a uint64_t, or unsigned 64-bit value, instead of the lower address's normal 24 bits.  This is an effect of the repurposing of the function methods `set_addr()` and `get_addr()` which are defined earlier in the class hierarchy.  There _is_ a more direct way of reading the 24-bit lower address field with a method called `get_dm_lower_address()`:

```verilog
   virtual function bit [23:0] get_dm_lower_address();
      return this.lower_address;
   endfunction
```

The final data member in this class is not a data field for the header, but a decision bit helping guide how the `PacketHeaderDMCompletion` operates in system.  The `reordering_enable` bit is used to let the packet know whether or not packet reordering is enabled in the system.  When packet reordering is enabled, the length field size is 24 bits wide to accommodate 16MB transfer sizes.  When packet reordering is disabled, the length is truncated to 14 bits and bits [23:14] from the length field are repurposed to report bit [23:14] of the lower address field.

The reordering bit state is set in the constructor and not allowed to change afterward.  Reordering is considered the "state of the design", or a static setting, rather than a dynamic one that can change during the lifetime of a packet.  Currently, this bit is set to a static 1'b1 in this class's constructor as it is not currently envisioned to use it otherwise.  It is listed in the class in case this use case changes, in which case is simply needs to be added as an input to the constructor and set as needed.  The `reordering_enable` bit is used in the `map_fields()` and `assign_fields()` methods as specified to switch the `length` and `lower_address` fields as needed by the header format.  These methods are shown here:

```verilog
   virtual protected function void map_fields();
      header_dw[0] = {fmt_type, 1'b0, tc, 1'b0, attr[2], ln, th, td, ep, attr[1:0], 2'b00, length[11:2]};
      header_dw[1] = {{16{1'b0}}, cpl_status, {13{1'b0}}};
      header_dw[2] = {{16{1'b0}}, {8{1'b0}}, lower_address[7:0]};
      if (reordering_enable)
      begin
         header_dw[3] = {tag, fc, 1'b0, length[13:12], length[1:0], length[23:14], lower_address[13:8]};
      end
      else
      begin
         header_dw[3] = {tag, fc, 1'b0, length[13:12], length[1:0], lower_address[23:14], lower_address[13:8]};
      end
      header_dw[4] = {2'b00, prefix_present, prefix_type, prefix};
      header_dw[5] = {7'b0000000, mm_mode, this.slot, 4'b0000, this.vf_active, this.vf, this.pf};
      if (mm_mode)
      begin
         header_dw[6] = local_address[63:32];
         header_dw[7] = local_address[31:0];
      end
      else
      begin
         header_dw[6] = meta_data[63:32];
         header_dw[7] = meta_data[31:0];
      end
      header_bytes = {<<8{{<<32{header_dw}}}}; // Streaming Operator -- streaming DWs to bytes, little endian.
   endfunction


   virtual protected function void assign_fields();
      fmt_type = tlp_fmt_type_t'(header_dw[0][31:24]);
      tc       = header_dw[0][22:20];
      {attr[2],ln, th, td, ep, attr[1:0]}  = header_dw[0][18:12];
      length[11:2] = header_dw[0][9:0];
      cpl_status   = cpl_status_t'(header_dw[1][15:13]);
      lower_address[7:0] = header_dw[2][7:0];
      if (reordering_enable)
      begin
         {tag, fc} = header_dw[3][31:21];
         {length[13:12], length[1:0], length[23:14], lower_address[13:8]} = header_dw[3][19:0];
      end
      else
      begin
         {tag, fc} = header_dw[3][31:21];
         {length[13:12], length[1:0], lower_address[23:14], lower_address[13:8]} = header_dw[3][19:0];
      end
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {mm_mode, slot, bar, vf_active, vf, pf} = header_dw[5][24:0];
      if (mm_mode)
      begin
         local_address[63:32] = header_dw[6];
         local_address[31:0]  = header_dw[7];
      end
      else
      begin
         meta_data[63:32] = header_dw[6];
         meta_data[31:0]  = header_dw[7];
      end
   endfunction
```

The following code block shows the source code for the `PacketHeaderDMCompletion` constructor.  Note the static assignments for `reordering_enable`, as discussed, and the bit `fc`.  Currently, segmented completions for Data Mover is not enabled, so every completion is a "Final Completion".  However, when or if this changes in the future, this bit can be set as an input to the constructor instead of being statically set, or the set method `set_fc()` maybe be used to change its state.  Here is the constructor for the details:

```verilog
   // Constructor for PacketHeaderDMCompletion 
   function new(
      input cpl_status_t cpl_status, 
      input uint64_t local_address_or_meta_data,
      input dm_length_t length,
      input bit mm_mode,
      input bit [23:0] lower_address
   );
      super.new(
         .packet_header_op(COMPLETION),
         .host_address({64{1'b0}}),
         .local_address_or_meta_data(local_address_or_meta_data),
         .length(length),
         .mm_mode(mm_mode)
      );
      this.packet_header_op = COMPLETION;  // Super turns this to NULL.  Must be set correctly to COMPLETION.
      this.cpl_status = cpl_status;
      this.lower_address = lower_address;
      this.reordering_enable = 1'b1;  // For now, Reordering is always enabled per current IP usage.
      this.fc = 1'b1;  // For now, default to one completion per IP reordering setting scenario.
      this.set_packet_fmt_type();
   endfunction
```

#### <a id="packet_header_message_class">Packet Header Message Class</a>

`Class Name.......: PacketHeaderMsg`
`Class Inheritance: PacketHeader`
`Source File......: packet_class_pkg.sv`

General PCIe Message TLPs are supported by using the class `PacketHeaderMsg`.  Messages may be sent in a variety of ways within a PCIe system and this packet format is intended to support them.  This class supports the general message request format, but does not support all of the message fields used in all message types.  Most notably, the header double words #2 and #3 are simply provided as generic 32-bit inputs into the constructor and stored in data members `lower_msg` and `upper_msg`.  There is a get method for each of the fields, `get_lower_msg()` and `get_upper_msg()`, but no set method is provided -- meaning that these fields must be set during construction and not changed.  Message TLPs are posted like memory write requests, but their routing through the PCIe system can be based on address, ID, or an implicit route.  The routing subfield in Byte 3, bits [2:0], which is Byte 0 in the PCIe specification, communicates which routing method in intended and which specific message format the header takes.  More on this later.

The format for the message header is shown below, as excerpt from _Section 2.2.8.6 of the PCI Express Base Specification, Rev. 4.0 Version 1.0_ showing the fields required to support this packet type.

![PCIe Standard Message Header Format](./readme_media/standard_message_header_format.png "PCIe Standard Message Header Format")*Figure 2.2.7.1: PCIe Standard Message Header Format* 

The Type field in the message header is defined as `4'b10rrr`, where the 'rrr' is the message routing subfield (byte 3, bits[2:0] -- or byte 0, bits[2:0] of the PCIe specification).  Show below is a table describing the routing table definition as taken from _Section 2.2.8 of the PCI Express Base Specification, Rev. 4.0 Version 1.0_.

![Message Routing Subfield Definition](./readme_media/message_routing_table.png "Message Routing Subfield Definition")*Figure 2.2.7.2: Message Routing Subfield Definition*

To support this packet header format, the following data members for the `PacketHeaderMsg` class are as follow:

```verilog
   // Data Members
   protected data_present_type_t data_present;
   protected msg_route_t msg_route;
   protected bit [15:0]  requester_id;
   protected bit  [7:0]  msg_code;
   protected bit [31:0]  lower_msg;
   protected bit [31:0]  upper_msg;
```

The `data_present` flag lets this class know if a data payload is expected with this message and determines what FMT/Type the TLP will have.  Currently, there are no get/set methods for this variable.  It is an input into the constructor, and whether or not data is present can be determined by the FMT/Type of the header.  Selection of the header FMT/Type is done with the method `set_packet_fmt_type()` which is shown here:

```verilog
   virtual protected function void set_packet_fmt_type();
      if (data_present)
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSGD0) + int'(msg_route));
      end
      else
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSG0) + int'(msg_route));
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction
```

Here is the definition for the type `tlp_fmt_type_t` so that the above expressions may be understood:

```verilog
typedef enum bit [7:0] {
   MRD3       = 8'b000_0_0000,  // Covered in PacketHeaderPUMemReq Class
   CPL        = 8'b000_0_1010,  // Covered in PacketHeaderPUCompletion Class
   MRD4       = 8'b001_0_0000,  // Covered in PacketHeaderPUMemReq Class & PacketHeaderDMMemReq Class
   MSG0       = 8'b001_1_0000,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG1       = 8'b001_1_0001,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG2       = 8'b001_1_0010,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG3       = 8'b001_1_0011,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG4       = 8'b001_1_0100,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG5       = 8'b001_1_0101,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MWR3       = 8'b010_0_0000,  // Covered in PacketHeaderPUMemReq Class
   CPLD       = 8'b010_0_1010,  // Covered in PacketHeaderPUCompletion Class & PacketHeaderDMCompletion Class
   FETCH_ADD3 = 8'b010_0_1100,  // Covered in PacketHeaderPUAtomic Class
   SWAP3      = 8'b010_0_1101,  // Covered in PacketHeaderPUAtomic Class
   CAS3       = 8'b010_0_1110,  // Covered in PacketHeaderPUAtomic Class
   MWR4       = 8'b011_0_0000,  // Covered in PacketHeaderPUMemReq Class & PacketHeaderDMMemReq Class
   FETCH_ADD4 = 8'b011_0_1100,  // Covered in PacketHeaderPUAtomic Class
   SWAP4      = 8'b011_0_1101,  // Covered in PacketHeaderPUAtomic Class
   CAS4       = 8'b011_0_1110,  // Covered in PacketHeaderPUAtomic Class
   MSGD0      = 8'b011_1_0000,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD1      = 8'b011_1_0001,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD2      = 8'b011_1_0010,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD3      = 8'b011_1_0011,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD4      = 8'b011_1_0100,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD5      = 8'b011_1_0101,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   ERROR      = 8'b111_1_1111   // Fall-out Error Condition
} tlp_fmt_type_t;
```

The next data member, `msg_route` is defined as type `msg_route_t`.  The definition of this type is listed here:

```verilog
typedef enum bit [2:0] {
   TO_ROOT_COMPLEX             = 3'b000,
   ROUTED_BY_ADDRESS           = 3'b001,
   ROUTED_BY_ID                = 3'b010,
   BROADCAST_FROM_ROOT_COMPLEX = 3'b011,
   LOCAL_TERM_AT_RX            = 3'b100,
   ROUTED_TO_ROOT_COMPLEX      = 3'b101
} msg_route_t;
```

The `msg_route` data member stands for the 'rrr' message routing subfield in the TLP 'Type' field defined as `4'b10rrr` for TLP message headers.  Like the `data_present` field, this is an input to the constructor and has no get/set methods.  Its value is clearly reflected in the TLP Type which may be retrieved with the standard method `get_fmt_type()` contained in all classes that inherit from class `PacketHeader`:

```verilog
   virtual function tlp_fmt_type_t get_fmt_type();
      return this.fmt_type;
   endfunction
```

Note that the type returned for this function method, `tlp_fmt_type_t`, is 4 paragraphs prior.

The data member `requester_id` is used as an input to the constructor to set its value in the message header and can be read with the get method `get_requester_id()`.  There is no set method, so the requester ID must be set at creation time with the constructor and cannot be changed afterward.

The data member `msg_code` may be any of the codes defined in _Appendix F of the PCI Express Base Specification, Rev. 4.0 Version 1.0_.  There is one detail about this that should be noted: if the `msg_code` is set to be one of the Vendor-Defined Message codes of: 

```verilog
typedef enum bit [7:0] {
   VDM_TYPE0 = 8'h7E,
   VDM_TYPE1 = 8'h7F
} vdm_msg_type_t;
```

In the case where the `msg_code` is set to this value in a received packet, the `assign_fields()` method will assign the `packet_header_op` value `VDM` instead of `MSG`.  Here is the listing for the `assign_fields()` method to illustrate this:

```verilog
   virtual protected function void assign_fields();
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      {requester_id, tag[7:0], msg_code} = header_dw[1];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ((fmt_type == MSG0)  || (fmt_type == MSG1)  || (fmt_type == MSG2)  || (fmt_type == MSG3)  || 
          (fmt_type == MSG4)  || (fmt_type == MSG5)  ||
          (fmt_type == MSGD0) || (fmt_type == MSGD1) || (fmt_type == MSGD2) || (fmt_type == MSGD3) || 
          (fmt_type == MSGD4) || (fmt_type == MSGD5))
      begin
         if ((msg_code == VDM_TYPE0) || (msg_code == VDM_TYPE1))
         begin
            packet_header_op = VDM;
         end
         else
         begin
            packet_header_op = MSG;
         end
      end
      else
      begin
         packet_header_op = NULL;
      end
      if ((msg_code == VDM_TYPE0) || (msg_code == VDM_TYPE1))
      begin
         $display("WARNING: MSG TLP Object created with VDM MSG Code: %H", msg_code);
         $display("   This will work okay, just know that DW2 in the ");
         $display("   Header will be treated as a single 32-bit word.");
         $display("   Get Methods will work okay for either class.   ");
      end
      lower_msg = header_dw[2];
      upper_msg = header_dw[3];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, vf_active, vf, pf} = header_dw[5][23:0];
   endfunction
```

Note that when this happens, the `assign_fields()` method also prints out a warning message alerting the user that although the message looks like a VDM message, it wasn't created with a `PacketHeaderVDM` class object, so it won't have all the special methods to work with the VDM header fields contained in `PacketHeaderVDM`.  The `msg_code` field is set using the constructor and may be retrieved with the `get_msg_code()` method:

```verilog
   virtual function bit [7:0] get_msg_code();
      return this.msg_code;
   endfunction
```

The remaining two 32-bit double-word fields of `lower_msg` and `upper_msg` are set using the constructor and cannot be changed afterward.  These values can be read back in a few ways depending on what is required.  There are two get methods for these values called `get_lower_msg()` and `get_upper_msg()` -- both returning a `bit [31:0]` value for their respective fields.   Another method is to simply get the header double words and know that they are double words DW[2] and DW[3].  This is done by using the function method `get_header_words()` inherited from `PacketHeader`:

```verilog
   // Extract header values from object - Useful for packet comparison
   virtual function void get_header_words(
      ref bit [31:0] header_buf[]
   );
      for (int i = 0; i < header_buf.size(); i++)
      begin
         header_buf[i] = header_dw[i];
      end
   endfunction
```

Since the message packet might be using "ID Routing", DW[2] or the `lower_msg` might consist of a 16-bit 'Bus Number-Device Number-Function Number' (BDF) identification number (otherwise this field is reserved) as well as a 16-bit 'Vendor ID' field.  These fields can be fetched in this form using the function methods `get_pci_target_id()` and `get_vendor_id()`:

```verilog
   virtual function bit [15:0] get_pci_target_id();
      return this.lower_msg[15:0];
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.lower_msg[31:16];
   endfunction
```

#### <a id="packet_header_vendor_defined_message_class">Packet Header Vendor-Defined Message (VDM) Class</a>

`Class Name.......: PacketHeaderVDM`
`Class Inheritance: PacketHeader`
`Source File......: packet_class_pkg.sv`

Vendor-Defined Messages in OFS are enabled using the `PacketHeaderVDM` packet header class.  Specifically with OFS, the VDM format is used to to implement a Management Component Transport Protocol (MCTP).  MCTP is a protocol devised by the Distributed Management Task Force (DMTF) to support communications for control and management functions between intelligent hardware blocks.  MCTP establishes a communications message format and message exchange protocols.  

The VDM header format is shown below, as an excerpt from _Section 2.2.8.6 of the PCI Express Base Specification, Rev. 4.0 Version 1.0_ showing the fields require to support VDMs in general.

![PCIe Vendor-Defined Message Header Format](./readme_media/vdm_header_definition.png "PCIe Vendor-Defined Message Header Format")*Figure 2.2.8.1: PCIe Vendor-Defined Message Header Format* 

The extended MCTP packet header format that is implemented using the `PacketHeaderVDM` class is shown below, as an excerpt from _Section 6.1 of the Management Component Transport Protocol (MCTP) PCIe VDM Transport Binding Specification, Document DSP0238, 2021-03-02, Version 1.2.0_ showing the MCTP fields and header arrangement for a PCIe VDM TLP.

![MCTP Packet Header Format for PCIe VDM TLP](./readme_media/mctp_over_vdm_packet_format.png "MCTP Packet Header Format for PCIe VDM TLP")*Figure 2.2.8.1: MCTP Packet Header Format for PCIe VDM TLP* 

It might seem like a packet header class defining 'Vendor-Defined Messages' or VDMs would naturally be a derived class from `PacketHeaderMsg`, but this is not so.  VDMs are much more precisely defined as opposed to the general PCIe message TLPs that they are best served as a unique class unto themselves, only inheriting from the abstract base class `PacketHeader`.  There is a little duplication of data members between `PacketHeaderMsg` and `PacketHeaderVDM` but they rapidly diverge in practical ways such that there is little to no advantage using inheritance between these two message header classes.

This begins with the expanded data member list for VDMs in support of the MCTP protocol used in OFS:

```verilog
   // Data Members
   protected data_present_type_t data_present;
   protected vdm_msg_route_t msg_route;
   protected bit [15:0] requester_id;
   protected bit  [1:0] pad_length;
   protected bit  [3:0] mctp_vdm_code;
   protected bit  [7:0] msg_code;
   protected bit [15:0] pci_target_id;
   protected bit [15:0] vendor_id;
   protected bit  [3:0] mctp_header_version;
   protected bit  [7:0] destination_endpoint_id;
   protected bit  [7:0] source_endpoint_id;
   protected bit        som;
   protected bit        eom;
   protected bit  [1:0] packet_sequence_number;
   protected bit        tag_owner; // TO bit.
   protected bit  [2:0] msg_tag;
```

The first data member in the list above is a familiar one: `data_present`.  As with other classes, this bit determines whether or not the packet contains a payload.  Most or all MCTP communication will include a message payload, but this is not assumed with this class.  One interesting aspect of the payload is that it must be composed of an integral number of 32-bit double words.  If the message does not adhere to this, it is this class's job to help the VDM packet class to pad the payload with null 8'h00 bytes until this is achieved.  There will be other data members in this class to support this operation.  The use of this bit is similar in other respects to the class `PacketHeaderMsg`: this bit is an input to the constructor without any get/set methods and is used by the method `set_packet_fmt_type()` to determine the FMT/Type of the resulting TLP.  This member function is presented here:

```verilog
   virtual protected function void set_packet_fmt_type();
      if (data_present)
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSGD0) + int'(msg_route));
      end
      else
      begin
         this.fmt_type = tlp_fmt_type_t'(int'(MSG0) + int'(msg_route));
      end
      this.fmt = tlp_fmt_t'(fmt_type[7:5]);
      this.tlp_type = fmt_type[4:0];
      map_fields();
   endfunction
```

For completeness, the definition for the type `tlp_fmt_type_t` is presented here so that the above expressions may be understood:

```verilog
typedef enum bit [7:0] {
   MRD3       = 8'b000_0_0000,  // Covered in PacketHeaderPUMemReq Class
   CPL        = 8'b000_0_1010,  // Covered in PacketHeaderPUCompletion Class
   MRD4       = 8'b001_0_0000,  // Covered in PacketHeaderPUMemReq Class & PacketHeaderDMMemReq Class
   MSG0       = 8'b001_1_0000,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG1       = 8'b001_1_0001,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG2       = 8'b001_1_0010,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG3       = 8'b001_1_0011,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG4       = 8'b001_1_0100,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSG5       = 8'b001_1_0101,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MWR3       = 8'b010_0_0000,  // Covered in PacketHeaderPUMemReq Class
   CPLD       = 8'b010_0_1010,  // Covered in PacketHeaderPUCompletion Class & PacketHeaderDMCompletion Class
   FETCH_ADD3 = 8'b010_0_1100,  // Covered in PacketHeaderPUAtomic Class
   SWAP3      = 8'b010_0_1101,  // Covered in PacketHeaderPUAtomic Class
   CAS3       = 8'b010_0_1110,  // Covered in PacketHeaderPUAtomic Class
   MWR4       = 8'b011_0_0000,  // Covered in PacketHeaderPUMemReq Class & PacketHeaderDMMemReq Class
   FETCH_ADD4 = 8'b011_0_1100,  // Covered in PacketHeaderPUAtomic Class
   SWAP4      = 8'b011_0_1101,  // Covered in PacketHeaderPUAtomic Class
   CAS4       = 8'b011_0_1110,  // Covered in PacketHeaderPUAtomic Class
   MSGD0      = 8'b011_1_0000,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD1      = 8'b011_1_0001,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD2      = 8'b011_1_0010,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD3      = 8'b011_1_0011,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD4      = 8'b011_1_0100,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   MSGD5      = 8'b011_1_0101,  // Covered in PacketHeaderMsg Class & PacketHeaderVDM Class
   ERROR      = 8'b111_1_1111   // Fall-out Error Condition
} tlp_fmt_type_t;
```

The next data member, `msg_route` is another similar item that also exists in the `PacketHeaderMsg` class, but it has some important differences.  For one, the type of this variable is `vdm_msg_route_t`, _not_ `msg_route_t`.  This type is a bit more restricted for the proper use with MCTP messages and is defined as follows:

```verilog
typedef enum bit [2:0] {
   VDM_TO_ROOT_COMPLEX             = 3'b000,
   VDM_ROUTED_BY_ID                = 3'b010,
   VDM_BROADCAST_FROM_ROOT_COMPLEX = 3'b011
} vdm_msg_route_t;
```

The `msg_route` data member stands for the 'rrr' message routing subfield in the TLP 'Type' field defined as `4'b10rrr` for TLP message headers.  Like the `data_present` field, this is an input to the constructor and has no get/set methods.  Its value is clearly reflected in the TLP Type which may be retrieved with the standard method `get_fmt_type()` contained in all classes that inherit from class `PacketHeader`:

Like the `PacketHeaderMsg` class, the data member `requester_id` is used as an input to the constructor to set its value in the message header and can be read with the get method `get_requester_id()`.  There is no set method, so the requester ID must be set at creation time with the constructor and cannot be changed afterward.

The next data member in the list above is one that has already been mentioned: `pad_length`.  As previously noted, the payload of MCTP messages must be an integral number of 32-bit double words, otherwise the payload must be padded with a number of 8'h00 bytes.  This data member keeps track of how many pad bytes have been added to the payload so that they may be stripped off later.  The `pad_length` has get/set methods so that when the packet's payload has been added or changed, this value may be updated:

```verilog
   virtual function bit [1:0] get_pad_length();
      return this.pad_length;
   endfunction


   virtual function void set_pad_length(input bit [1:0] pad_length);
      this.pad_length = pad_length;
      map_fields();
   endfunction
```

The data member `mctp_vdm_code` contains the message field value defined in the MCTP specification.  For the MCTP messages supported by this class, this value is set in the constructor to be a static zero: `4'b0000`.  However, there _are_ get/set methods for this field in case this value needs to be set to another value for use with other VDM message formats.  Here are those two methods:

```verilog
   virtual function bit [3:0] get_mctp_vdm_code();
      return this.mctp_vdm_code;
   endfunction


   virtual function void set_mctp_vdm_code(input bit [3:0] vdm_code);
      this.mctp_vdm_code = vdm_code;
      map_fields();
   endfunction
```

The data member `msg_code` may be set to any of the codes defined in _Appendix F of the PCI Express Base Specification, Rev. 4.0 Version 1.0_, however the intended use with this class is to restrict `msg_code` to only the valid Vendor-Defined Message codes of:

```verilog
typedef enum bit [7:0] {
   VDM_TYPE0 = 8'h7E,
   VDM_TYPE1 = 8'h7F
} vdm_msg_type_t;
```

If `msg_code` is set to values different from `VDM_TYPE0` and `VDM_TYPE1` in a received packet, the `assign_fields()` method will assign the `packet_header_op` value to `MSG` instead of `VDM`.  Here is the listing for the `assign_fields()` method to illustrate this behavior:

```verilog
   virtual protected function void assign_fields();
      {fmt_type, tag[9], tc, tag[8], attr[2], ln, th, td, ep, attr[1:0], at, length_dw} = header_dw[0];
      //{requester_id, tag[7:0], msg_code} = header_dw[1];
      requester_id = header_dw[1][31:16];
      {pad_length, mctp_vdm_code, msg_code} = header_dw[1][13:0];
      fmt = tlp_fmt_t'(fmt_type[7:5]);
      tlp_type = fmt_type[4:0];
      if ((fmt_type == MSG0)  || (fmt_type == MSG1)  || (fmt_type == MSG2)  || (fmt_type == MSG3)  || 
          (fmt_type == MSG4)  || (fmt_type == MSG5)  ||
          (fmt_type == MSGD0) || (fmt_type == MSGD1) || (fmt_type == MSGD2) || (fmt_type == MSGD3) || 
          (fmt_type == MSGD4) || (fmt_type == MSGD5))
      begin
         if ((msg_code == VDM_TYPE0) || (msg_code == VDM_TYPE1))
         begin
            packet_header_op = VDM;
         end
         else
         begin
            packet_header_op = MSG;
         end
      end
      else
      begin
         packet_header_op = NULL;
      end
      if ((msg_code != VDM_TYPE0) && (msg_code != VDM_TYPE1))
      begin
         $display("WARNING: VDM TLP Object created with MSG Code: %H", msg_code);
         $display("   This will work okay, just know that DW2 in the ");
         $display("   Header will be treated as two 16-bit fields    ");
         $display("   instead of a single 32-bit field.              ");
         $display("   Get Methods will work okay for either class.   ");
      end
      {pci_target_id, vendor_id} = header_dw[2];
      //upper_msg = header_dw[3];
      {mctp_header_version, destination_endpoint_id, source_endpoint_id, som, eom, packet_sequence_number, tag_owner, msg_tag} = header_dw[3][27:0];
      {prefix_present, prefix_type, prefix} = header_dw[4][29:0];
      {slot, bar, vf_active, vf, pf} = header_dw[5][23:0];
   endfunction
```

Note that when this happens, the `assign_fields()` method also prints out a warning message alerting the user that although the message looks like a MSG message, it wasn't created with a `PacketHeaderMsg` class object, so all of the special methods in the `PacketHeaderVDM` class would have to be used with caution.  The `msg_code` field is set using the constructor and may be retrieved with the `get_msg_code()` method:

```verilog
   virtual function bit [7:0] get_msg_code();
      return this.msg_code;
   endfunction
```

The next data member, `pci_target_id`, is used by the VDM/MCTP header is using "ID Routing" or messages.  If so, then the `pci_target_id` is set to the 16-bit 'Bus Number-Device Number-Function Number' (BDF) identification number.  Otherwise, this field is reserved.  This value is set in the constructor as an input and has no set method, so once an object is created, the `pci_target_id` cannot be changed.  However, this value may be read using two different get methods to retain some compatibility with the class `PacketHeaderMsg`:

```verilog
   virtual function bit [31:0] get_lower_msg();
      return {pci_target_id, vendor_id};
   endfunction


   virtual function bit [15:0] get_pci_target_id();
      return this.pci_target_id;
   endfunction
```

The data member `vendor_id` operates similarly to `pci_target_id`.  This value is set in the constructor and has no set method, so once an object has been created, the `vendor_id` cannot be changed.  Reading this value after the constructor, however, may be accomplished with two methods:

```verilog
   virtual function bit [31:0] get_lower_msg();
      return {pci_target_id, vendor_id};
   endfunction


   virtual function bit [15:0] get_vendor_id();
      return this.vendor_id;
   endfunction
```

Note that with MCTP messages, the `vendor_id` field should be set to the value of `16'h1AB4`, which is the Vendor ID corresponding to the Distributed Management Task Force (DMTF), the organization that governs the MCTP specification.

The data member `mctp_header_version` is used as part of the MCTP-specific header format as shown above.  This variable is initialized to the currently correct value of `4'b0001` in the constructor, but this data member also has get/set methods to change this value as needed.  Here is the listing for these two methods:

```verilog
   virtual function bit [3:0] get_mctp_header_version();
      return this.mctp_header_version;
   endfunction


   virtual function void set_mctp_header_version(input bit [3:0] header_version);
      this.mctp_header_version = header_version;
      map_fields();
   endfunction
```

The data members `destination_endpoint_id` and `source_endpoint_id` are used specifically in the MCTP protocol.  The following is a summary from the _Sections 3.2.25 and 3.2.26 of the Management Component Transport Protocol Base Specification, Document DSP0236, 2014-12-03, Version: 1.2.1_: An MCTP endpoint is a communications terminus or origin of MCTP packets or messages.  These ends of the communication link exchange information using the MCTP transport protocol and execute MCTP control commands.  This includes MCTP management controllers and management devices.  The endpoint IDs are logical addresses used to route MCTP messages to a specific MCTP endpoint.  The ID is a numeric handle (logical address) that uniquely identifies a particular MCTP endpint within a system.  Endpoint IDs are unique among MCTP endpoints that make up an MCTP communications network within a system.  The endpoint IDs are only unique within a particular MCTP network.  This means that they can be duplicated, reused, or overlap with ID values used in different MCTP networks.  

The `destination_endpoint_id` and `source_endpoint_id` variables are initialized in the constructor to both be `8'h00`, but have both get and set methods for management:

```verilog
   virtual function bit [7:0] get_mctp_destination_endpoint_id();
      return this.destination_endpoint_id;
   endfunction


   virtual function void set_mctp_destination_endpoint_id(bit [7:0] destination_endpoint_id);
      this.destination_endpoint_id = destination_endpoint_id;
   endfunction


   virtual function bit [7:0] get_mctp_source_endpoint_id();
      return this.source_endpoint_id;
   endfunction


   virtual function void set_mctp_source_endpoint_id(bit [7:0] source_endpoint_id);
      this.source_endpoint_id = source_endpoint_id;
   endfunction
```

The `som` and `eom` bits tell the user whether the current MCTP packet is the 'start of a message' (SOM) or the 'end of a message' (EOM).  Currently, the constructor initializes both bits to ones.  This means that the start and end of a message is contained in one packet, meaning that the message is completely contained within the single packet's payload.  This is an okay default since this is what happens in most cases, but longer messages may require different settings than this default.  To enable different settings from the default set in the constructor, both bits have the usual get/set methods to work with them.  Here is their source code:

```verilog
   virtual function bit get_mctp_som();
      return this.som;
   endfunction


   virtual function void set_mctp_som(input bit som);
      this.som = som;
      map_fields();
   endfunction


   virtual function bit get_mctp_eom();
      return this.eom;
   endfunction


   virtual function void set_mctp_eom(input bit eom);
      this.eom = eom;
      map_fields();
   endfunction
```

The next data member also helps with multi-VDM/MCTP message packets: `packet_sequence_number`.  This value is a small sequence counter to keep the VDM/MCTP message packets spanning a single message in their order.  Since the `PacketHeaderVDM` class defaults to one-message-per-packet, this value is set to `2'b00` in the constructor, but there are get/set methods for this variable so that it can be managed for multi-packet messages:

```verilog
   virtual function bit [1:0] get_mctp_packet_sequence_number();
      return this.packet_sequence_number;
   endfunction


   virtual function void set_mctp_packet_sequence_number(input bit [1:0] psn);
      this.packet_sequence_number = psn;
      map_fields();
   endfunction
```

The `tag_owner` or 'to' bit is the next data member in the class used by the `PacketHeaderVDM` packet header class to support the VDM/MCTP messages.  The following bit description comes from the document _Management Component Transport Protocol Base Specification, Document: DSP0236, Date: 2014-12-03, Version: 1.2.1, page 26_.  The `tag_owner` bit identifies whether the message tag was originated by the endpoint that is the source of the message or by the endpoint that is the destination of the message.  The Message Tag field is generated and tracked independently for each value of the Tag Owner bit.  MCTP message types may overlay this bit with addtional meaning, for example using it to differentiate between "request" messages and "response" messages.  This bit should be set to a `1'b1` to indicate that the source of the message originated the message tag.  This bit is set to a `1'b0` in the constructor so that the originator is not assumed to be the source of the message tag.  Get/Set methods are supplied to change the `tag_owner` setting from this default:

```verilog
   virtual function bit get_mctp_tag_owner();
      return this.tag_owner;
   endfunction


   virtual function void set_mctp_tag_owner(input bit tag_owner);
      this.tag_owner = tag_owner ;
      map_fields();
   endfunction
```

The last data member for the `PacketHeaderVDM` class is the `msg_tag`.  The `msg_tag` Message Tag field is a small 3-bit message tag used with the MCTP messaging protocol.  The following field description comes from the document _Management Component Transport Protocol Base Specification, Document: DSP0236, Date: 2014-12-03, Version: 1.2.1, page 26_.  The Message Tag, along with the Source Endpoint IDs and the Tag Owner bit identifiesa unique message at the MCTP transport level. Whether other elements, such as portions of the MCTP Message Data field, are also used for uniquely identifying instances or tracking retries of a message is dependent on the message type.  A source endpoint is allowed to interleave packets from multiple messages to the same destination endpoint concurrently, provided that each of the messages has a unique message tag.  For messages that are split up into multiple packets, the Tag Owner (TO) and Message Tag bits remain the same for all packets from the SOM through the EOM.

The `PacketHeaderVDM` packet header class sets the `msg_tag` to a default of `3'b000` in its constructor and provides the following get/set methods to work with the `msg_tag` field:

```verilog
   virtual function bit [2:0] get_mctp_message_tag();
      return this.msg_tag;
   endfunction


   virtual function void set_mctp_message_tag(input bit [2:0] message_tag);
      this.msg_tag = message_tag;
      map_fields();
   endfunction
```

### <a id="packet_classes">Packet Classes</a>


#### <a id="packet_abstract_base_class">Packet Abstract Base Class</a>


#### <a id="packet_unknown_class">Packet Unknown Class</a>


#### <a id="packet_power_user_memory_request_class">Packet Power User Memory Request Class</a>


#### <a id="packet_power_user_atomic_request_class">Packet Power User Atomic Request Class</a>


#### <a id="packet_power_user_completion_class">Packet Power User Completion Class</a>


#### <a id="packet_data_mover_memory_request_class">Packet Data Mover Memory Request Class</a>


#### <a id="packet_data_mover_completion_class">Packet Data Mover Completion Class</a>


#### <a id="packet_power_user_message_class">Packet Power User Message Class</a>


#### <a id="packet_power_user_vendor_defined_message_class">Packet Power User Vendor-Defined Message (VDM) Class</a>


## <a id="tag_manager_class_package">Tag Manager Class Package</a>


### <a id="tag_manager_class">Tag Manager Class</a>


## <a id="pfvf_status_class_package">PF/VF Status Class Package</a>


### <a id="pfvf_routing_class">PF/VF Routing Class</a>


## <a id="packet_delay_class_package">Packet Delay Class Package</a>


### <a id="packet_delay_class">Packet Delay Class</a>


### <a id="packet_gap_delay_class">Packet Gap Delay Class</a>


### <a id="packet_delay_queue_class">Packet Delay Queue Class</a>


### <a id="packet_gap_delay_queue_class">Packet Gap Delay Queue Class</a>


## <a id="host_transaction_class_package">Host Transaction Class Package</a>


### <a id="transaction_abstract_base_class">Transaction Abstract Base Class</a>


### <a id="read_transaction_class">Read Transaction Class</a>


### <a id="write_transaction_class">Write Transaction Class</a>


### <a id="write_transaction_class">Atomic Transaction Class</a>


### <a id="send_message_transaction_class">Send Message Transaction Class</a>


### <a id="send_vendor_defined_message_transaction_class">Send Vendor-Defined Message (VDM) Transaction Class</a>


## <a id="host_memory_class_package">Host Memory Class Package</a>


### <a id="memory_access_class">Memory Access Class</a>


### <a id="memory_entry_class">Memory Entry Class</a>


### <a id="host_memory_class">Host Memory Class</a>


## <a id="host_axis_receive_class_package">Host AXI-ST Receive Class Package</a>


### <a id="host_axis_receive_class">Host AXI-ST Receive Class</a>


## <a id="host_axis_send_class_package">Host AXI-ST Send Class Package</a>


### <a id="host_axis_send_class">Host AXI-ST Send Class</a>


## <a id="base_and_concrete_classes">Base and Concrete Class Implementations</a>


### <a id="pcie_function_level_reset">PCIe Function-Level Reset</a>


#### <a id="host_flr_class_package">Host FLR Class Package</a>


##### <a id="host_flr_event_class">Host FLR Event Class</a>


##### <a id="host_flr_manager_class">Host FLR Manager Class</a>


#### <a id="host_flr_top">Host FLR Top</a>


##### <a id="host_flr_manager_concrete_class">Host FLR Manager Concrete Class</a>


### <a id="host_bus_functional_model">Host Bus Functional Model (BFM)</a>


#### <a id="host_bus_functional_model_class_package">Host Bus Functional Model (BFM) Class Package</a>


##### <a id="host_bus_functional_model_abstract_base_class">Host Bus Functional Model (BFM) Abstract Base Class</a>


#### <a id="host_bus_functional_model_top">Host Bus Functional Model (BFM) Top</a>


##### <a id="host_bus_functional_model_concrete_class">Host Bus Functional Model (BFM) Concrete Class</a>


##### <a id="packet_delay_queue_for_tx_req_axi_s_interface_concrete_class">Packet Delay Queue for TX_REQ AXI-ST Interface Concrete Class</a>


##### <a id="packet_gap_delay_queue_for_rx_req_axi_s_interface_concrete_class">Packet Gap Delay Queue for RX_REQ AXI-ST Interface Concrete Class</a>



### Evaluation Scripts (***eval\_scripts***)
   - Contains resources to report and setup development environment.
### External Tools (***external***)
   - Contains the software repositories needed for OFS/OPAE development and integration. 
   - Lightweight virtual environment containing the required Python packages needed for this repo and its tools.
### IP Subsystems (***ipss***)
   - Contains the code and supporting files that define or set up the IP subsystems contained in the FPGA Interface Manager (FIM)
### Licensing for Quartus (***license***)
   - Contains the license setup software for the version of Quartus used for this distribution/release.
### OFS Common Content Directory (**Link to top-level directory _ofs-common_**)
   - Contains the scripts, source code, and verification environment resources that are common to all of the repositories.
   - This directory is referenced via a link within each of the FPGA-Specific repositories.
### Simulation
   - Contains the testbenches and supporting code for all of the unit test simulations.
      - Bus Functional Model code is contained here.
      - Scripts are included for automating a myriad of tasks.
      - All of the individual unit tests and their supporting code is also located here.
### FPGA Interface Module (FIM) Source code (***src***)
   - This directory contains all of the structural and behavioral code for the FIM.
   - Also included are scripts for generating the AXI buses for module interconnect.
   - Top-level RTL for synthesis is located in this directory.
   - Accelerated Functional Unit (AFU) infrastructure code is contained in this directory.
### FPGA Synthesis
   - This directory contains all of the scripts, settings, and setup files for running synthesis on the FIM.
### OFSS Configuration Tool (***tools***)
   - This directory contains the shell and Python scripts that form the OFSS configuration tool.

   Please see the following file for more information on this block

* [OFSS Configuration Tool README](tools/ofss_config/README.md)

### Verification (UVM) (***verification***)
   - This directory contains all of the scripts, testbenches, and test cases for the supported UVM tests for the FIM.
   - **NOTE:** UVM resources are currently not available in this release due to difficulties in open-sourcing some components.  It is hoped that this will be included in future releases.
