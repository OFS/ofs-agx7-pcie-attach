// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: MIT

`ifndef RAL_AC_MSIX
`define RAL_AC_MSIX

import uvm_pkg::*;

class ral_reg_ac_msix_MSIX_ADDR0 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR0");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR0)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR0


class ral_reg_ac_msix_MSIX_CTLDAT0 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT0");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT0)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT0


class ral_reg_ac_msix_MSIX_ADDR1 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR1");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR1)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR1


class ral_reg_ac_msix_MSIX_CTLDAT1 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT1");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT1)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT1


class ral_reg_ac_msix_MSIX_ADDR2 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR2");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR2)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR2


class ral_reg_ac_msix_MSIX_CTLDAT2 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT2");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT2)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT2


class ral_reg_ac_msix_MSIX_ADDR3 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR3");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR3)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR3


class ral_reg_ac_msix_MSIX_CTLDAT3 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT3");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT3)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT3


class ral_reg_ac_msix_MSIX_ADDR4 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR4");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR4)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR4


class ral_reg_ac_msix_MSIX_CTLDAT4 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT4");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT4)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT4


class ral_reg_ac_msix_MSIX_ADDR5 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR5");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR5)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR5


class ral_reg_ac_msix_MSIX_CTLDAT5 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT5");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT5)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT5


class ral_reg_ac_msix_MSIX_ADDR6 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR6");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR6)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR6


class ral_reg_ac_msix_MSIX_CTLDAT6 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT6");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT6)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT6


class ral_reg_ac_msix_MSIX_ADDR7 extends uvm_reg;
	rand uvm_reg_field MsgAddrUpp;
	rand uvm_reg_field MsgAddrLow;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgAddrUpp_value : coverpoint MsgAddrUpp.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgAddrLow_value : coverpoint MsgAddrLow.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_ADDR7");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgAddrUpp = uvm_reg_field::type_id::create("MsgAddrUpp",,get_full_name());
      this.MsgAddrUpp.configure(this, 32, 32, "RW", 0, 32'h0, 1, 0, 1);
      this.MsgAddrLow = uvm_reg_field::type_id::create("MsgAddrLow",,get_full_name());
      this.MsgAddrLow.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_ADDR7)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_ADDR7


class ral_reg_ac_msix_MSIX_CTLDAT7 extends uvm_reg;
	rand uvm_reg_field MsgControl;
	rand uvm_reg_field MsgData;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsgControl_value : coverpoint MsgControl.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
		MsgData_value : coverpoint MsgData.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_CTLDAT7");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.MsgControl = uvm_reg_field::type_id::create("MsgControl",,get_full_name());
      this.MsgControl.configure(this, 32, 32, "RW", 0, 32'h1, 1, 0, 1);
      this.MsgData = uvm_reg_field::type_id::create("MsgData",,get_full_name());
      this.MsgData.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_CTLDAT7)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_CTLDAT7


class ral_reg_ac_msix_MSIX_PBA extends uvm_reg;
	rand uvm_reg_field Reserved7;
	uvm_reg_field MsixPba;

	covergroup cg_vals ();
		option.per_instance = 1;
		MsixPba_value : coverpoint MsixPba.value { //Added by script default bin
			bins default_value= { 'h0 };
			option.weight = 1;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_PBA");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved7 = uvm_reg_field::type_id::create("Reserved7",,get_full_name());
      this.Reserved7.configure(this, 1, 7, "WO", 0, 1'h000000000, 1, 0, 0);
      this.MsixPba = uvm_reg_field::type_id::create("MsixPba",,get_full_name());
      this.MsixPba.configure(this, 7, 0, "RO", 0, 7'h0, 1, 0, 0);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_PBA)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_PBA


class ral_reg_ac_msix_MSIX_COUNT_CSR extends uvm_reg;
	rand uvm_reg_field Reserved32;
	rand uvm_reg_field Read_Write;

	covergroup cg_vals ();
		option.per_instance = 1;
		Read_Write_value : coverpoint Read_Write.value {
			bins min = { 32'h0 };
			bins max = { 32'hFFFFFFFF };
			bins others = { [32'h1:32'hFFFFFFFE] };
			option.weight = 3;
		}
	endgroup : cg_vals

	function new(string name = "ac_msix_MSIX_COUNT_CSR");
		super.new(name, 64,build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
		if (has_coverage(UVM_CVR_FIELD_VALS))
			cg_vals = new();
	endfunction: new
   virtual function void build();
      this.Reserved32 = uvm_reg_field::type_id::create("Reserved32",,get_full_name());
      this.Reserved32.configure(this, 1, 32, "WO", 0, 1'h0, 1, 0, 1);
      this.Read_Write = uvm_reg_field::type_id::create("Read_Write",,get_full_name());
      this.Read_Write.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
   endfunction: build

	`uvm_object_utils(ral_reg_ac_msix_MSIX_COUNT_CSR)


	function void sample_values();
	   super.sample_values();
	   if (get_coverage(UVM_CVR_FIELD_VALS)) begin
	      if(cg_vals!=null) cg_vals.sample();
	   end
	endfunction
endclass : ral_reg_ac_msix_MSIX_COUNT_CSR


class ral_block_ac_msix extends uvm_reg_block;
	rand ral_reg_ac_msix_MSIX_ADDR0 MSIX_ADDR0;
	rand ral_reg_ac_msix_MSIX_CTLDAT0 MSIX_CTLDAT0;
	rand ral_reg_ac_msix_MSIX_ADDR1 MSIX_ADDR1;
	rand ral_reg_ac_msix_MSIX_CTLDAT1 MSIX_CTLDAT1;
	rand ral_reg_ac_msix_MSIX_ADDR2 MSIX_ADDR2;
	rand ral_reg_ac_msix_MSIX_CTLDAT2 MSIX_CTLDAT2;
	rand ral_reg_ac_msix_MSIX_ADDR3 MSIX_ADDR3;
	rand ral_reg_ac_msix_MSIX_CTLDAT3 MSIX_CTLDAT3;
	rand ral_reg_ac_msix_MSIX_ADDR4 MSIX_ADDR4;
	rand ral_reg_ac_msix_MSIX_CTLDAT4 MSIX_CTLDAT4;
	rand ral_reg_ac_msix_MSIX_ADDR5 MSIX_ADDR5;
	rand ral_reg_ac_msix_MSIX_CTLDAT5 MSIX_CTLDAT5;
	rand ral_reg_ac_msix_MSIX_ADDR6 MSIX_ADDR6;
	rand ral_reg_ac_msix_MSIX_CTLDAT6 MSIX_CTLDAT6;
	rand ral_reg_ac_msix_MSIX_ADDR7 MSIX_ADDR7;
	rand ral_reg_ac_msix_MSIX_CTLDAT7 MSIX_CTLDAT7;
	rand ral_reg_ac_msix_MSIX_PBA MSIX_PBA;
	rand ral_reg_ac_msix_MSIX_COUNT_CSR MSIX_COUNT_CSR;
	rand uvm_reg_field MSIX_ADDR0_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR0_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT0_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT0_MsgData;
	rand uvm_reg_field MSIX_ADDR1_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR1_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT1_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT1_MsgData;
	rand uvm_reg_field MSIX_ADDR2_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR2_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT2_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT2_MsgData;
	rand uvm_reg_field MSIX_ADDR3_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR3_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT3_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT3_MsgData;
	rand uvm_reg_field MSIX_ADDR4_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR4_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT4_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT4_MsgData;
	rand uvm_reg_field MSIX_ADDR5_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR5_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT5_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT5_MsgData;
	rand uvm_reg_field MSIX_ADDR6_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR6_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT6_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT6_MsgData;
	rand uvm_reg_field MSIX_ADDR7_MsgAddrUpp;
	rand uvm_reg_field MSIX_ADDR7_MsgAddrLow;
	rand uvm_reg_field MSIX_CTLDAT7_MsgControl;
	rand uvm_reg_field MSIX_CTLDAT7_MsgData;
	rand uvm_reg_field MSIX_PBA_Reserved7;
	rand uvm_reg_field Reserved7;
	uvm_reg_field MSIX_PBA_MsixPba;
	uvm_reg_field MsixPba;
	rand uvm_reg_field MSIX_COUNT_CSR_Reserved32;
	rand uvm_reg_field Reserved32;
	rand uvm_reg_field MSIX_COUNT_CSR_Read_Write;
	rand uvm_reg_field Read_Write;

	function new(string name = "ac_msix");
		super.new(name, build_coverage(UVM_CVR_FIELD_VALS));
		add_coverage(build_coverage(UVM_CVR_FIELD_VALS));
	endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 8, UVM_LITTLE_ENDIAN, 0);
      this.MSIX_ADDR0 = ral_reg_ac_msix_MSIX_ADDR0::type_id::create("MSIX_ADDR0",,get_full_name());
      this.MSIX_ADDR0.configure(this, null, "");
      this.MSIX_ADDR0.build();
      this.default_map.add_reg(this.MSIX_ADDR0, `UVM_REG_ADDR_WIDTH'h3000, "RW", 0);
		this.MSIX_ADDR0_MsgAddrUpp = this.MSIX_ADDR0.MsgAddrUpp;
		this.MSIX_ADDR0_MsgAddrLow = this.MSIX_ADDR0.MsgAddrLow;
      this.MSIX_CTLDAT0 = ral_reg_ac_msix_MSIX_CTLDAT0::type_id::create("MSIX_CTLDAT0",,get_full_name());
      this.MSIX_CTLDAT0.configure(this, null, "");
      this.MSIX_CTLDAT0.build();
      this.default_map.add_reg(this.MSIX_CTLDAT0, `UVM_REG_ADDR_WIDTH'h3008, "RW", 0);
		this.MSIX_CTLDAT0_MsgControl = this.MSIX_CTLDAT0.MsgControl;
		this.MSIX_CTLDAT0_MsgData = this.MSIX_CTLDAT0.MsgData;
      this.MSIX_ADDR1 = ral_reg_ac_msix_MSIX_ADDR1::type_id::create("MSIX_ADDR1",,get_full_name());
      this.MSIX_ADDR1.configure(this, null, "");
      this.MSIX_ADDR1.build();
      this.default_map.add_reg(this.MSIX_ADDR1, `UVM_REG_ADDR_WIDTH'h3010, "RW", 0);
		this.MSIX_ADDR1_MsgAddrUpp = this.MSIX_ADDR1.MsgAddrUpp;
		this.MSIX_ADDR1_MsgAddrLow = this.MSIX_ADDR1.MsgAddrLow;
      this.MSIX_CTLDAT1 = ral_reg_ac_msix_MSIX_CTLDAT1::type_id::create("MSIX_CTLDAT1",,get_full_name());
      this.MSIX_CTLDAT1.configure(this, null, "");
      this.MSIX_CTLDAT1.build();
      this.default_map.add_reg(this.MSIX_CTLDAT1, `UVM_REG_ADDR_WIDTH'h3018, "RW", 0);
		this.MSIX_CTLDAT1_MsgControl = this.MSIX_CTLDAT1.MsgControl;
		this.MSIX_CTLDAT1_MsgData = this.MSIX_CTLDAT1.MsgData;
      this.MSIX_ADDR2 = ral_reg_ac_msix_MSIX_ADDR2::type_id::create("MSIX_ADDR2",,get_full_name());
      this.MSIX_ADDR2.configure(this, null, "");
      this.MSIX_ADDR2.build();
      this.default_map.add_reg(this.MSIX_ADDR2, `UVM_REG_ADDR_WIDTH'h3020, "RW", 0);
		this.MSIX_ADDR2_MsgAddrUpp = this.MSIX_ADDR2.MsgAddrUpp;
		this.MSIX_ADDR2_MsgAddrLow = this.MSIX_ADDR2.MsgAddrLow;
      this.MSIX_CTLDAT2 = ral_reg_ac_msix_MSIX_CTLDAT2::type_id::create("MSIX_CTLDAT2",,get_full_name());
      this.MSIX_CTLDAT2.configure(this, null, "");
      this.MSIX_CTLDAT2.build();
      this.default_map.add_reg(this.MSIX_CTLDAT2, `UVM_REG_ADDR_WIDTH'h3028, "RW", 0);
		this.MSIX_CTLDAT2_MsgControl = this.MSIX_CTLDAT2.MsgControl;
		this.MSIX_CTLDAT2_MsgData = this.MSIX_CTLDAT2.MsgData;
      this.MSIX_ADDR3 = ral_reg_ac_msix_MSIX_ADDR3::type_id::create("MSIX_ADDR3",,get_full_name());
      this.MSIX_ADDR3.configure(this, null, "");
      this.MSIX_ADDR3.build();
      this.default_map.add_reg(this.MSIX_ADDR3, `UVM_REG_ADDR_WIDTH'h3030, "RW", 0);
		this.MSIX_ADDR3_MsgAddrUpp = this.MSIX_ADDR3.MsgAddrUpp;
		this.MSIX_ADDR3_MsgAddrLow = this.MSIX_ADDR3.MsgAddrLow;
      this.MSIX_CTLDAT3 = ral_reg_ac_msix_MSIX_CTLDAT3::type_id::create("MSIX_CTLDAT3",,get_full_name());
      this.MSIX_CTLDAT3.configure(this, null, "");
      this.MSIX_CTLDAT3.build();
      this.default_map.add_reg(this.MSIX_CTLDAT3, `UVM_REG_ADDR_WIDTH'h3038, "RW", 0);
		this.MSIX_CTLDAT3_MsgControl = this.MSIX_CTLDAT3.MsgControl;
		this.MSIX_CTLDAT3_MsgData = this.MSIX_CTLDAT3.MsgData;
      this.MSIX_ADDR4 = ral_reg_ac_msix_MSIX_ADDR4::type_id::create("MSIX_ADDR4",,get_full_name());
      this.MSIX_ADDR4.configure(this, null, "");
      this.MSIX_ADDR4.build();
      this.default_map.add_reg(this.MSIX_ADDR4, `UVM_REG_ADDR_WIDTH'h3040, "RW", 0);
		this.MSIX_ADDR4_MsgAddrUpp = this.MSIX_ADDR4.MsgAddrUpp;
		this.MSIX_ADDR4_MsgAddrLow = this.MSIX_ADDR4.MsgAddrLow;
      this.MSIX_CTLDAT4 = ral_reg_ac_msix_MSIX_CTLDAT4::type_id::create("MSIX_CTLDAT4",,get_full_name());
      this.MSIX_CTLDAT4.configure(this, null, "");
      this.MSIX_CTLDAT4.build();
      this.default_map.add_reg(this.MSIX_CTLDAT4, `UVM_REG_ADDR_WIDTH'h3048, "RW", 0);
		this.MSIX_CTLDAT4_MsgControl = this.MSIX_CTLDAT4.MsgControl;
		this.MSIX_CTLDAT4_MsgData = this.MSIX_CTLDAT4.MsgData;
      this.MSIX_ADDR5 = ral_reg_ac_msix_MSIX_ADDR5::type_id::create("MSIX_ADDR5",,get_full_name());
      this.MSIX_ADDR5.configure(this, null, "");
      this.MSIX_ADDR5.build();
      this.default_map.add_reg(this.MSIX_ADDR5, `UVM_REG_ADDR_WIDTH'h3050, "RW", 0);
		this.MSIX_ADDR5_MsgAddrUpp = this.MSIX_ADDR5.MsgAddrUpp;
		this.MSIX_ADDR5_MsgAddrLow = this.MSIX_ADDR5.MsgAddrLow;
      this.MSIX_CTLDAT5 = ral_reg_ac_msix_MSIX_CTLDAT5::type_id::create("MSIX_CTLDAT5",,get_full_name());
      this.MSIX_CTLDAT5.configure(this, null, "");
      this.MSIX_CTLDAT5.build();
      this.default_map.add_reg(this.MSIX_CTLDAT5, `UVM_REG_ADDR_WIDTH'h3058, "RW", 0);
		this.MSIX_CTLDAT5_MsgControl = this.MSIX_CTLDAT5.MsgControl;
		this.MSIX_CTLDAT5_MsgData = this.MSIX_CTLDAT5.MsgData;
      this.MSIX_ADDR6 = ral_reg_ac_msix_MSIX_ADDR6::type_id::create("MSIX_ADDR6",,get_full_name());
      this.MSIX_ADDR6.configure(this, null, "");
      this.MSIX_ADDR6.build();
      this.default_map.add_reg(this.MSIX_ADDR6, `UVM_REG_ADDR_WIDTH'h3060, "RW", 0);
		this.MSIX_ADDR6_MsgAddrUpp = this.MSIX_ADDR6.MsgAddrUpp;
		this.MSIX_ADDR6_MsgAddrLow = this.MSIX_ADDR6.MsgAddrLow;
      this.MSIX_CTLDAT6 = ral_reg_ac_msix_MSIX_CTLDAT6::type_id::create("MSIX_CTLDAT6",,get_full_name());
      this.MSIX_CTLDAT6.configure(this, null, "");
      this.MSIX_CTLDAT6.build();
      this.default_map.add_reg(this.MSIX_CTLDAT6, `UVM_REG_ADDR_WIDTH'h3068, "RW", 0);
		this.MSIX_CTLDAT6_MsgControl = this.MSIX_CTLDAT6.MsgControl;
		this.MSIX_CTLDAT6_MsgData = this.MSIX_CTLDAT6.MsgData;
      this.MSIX_ADDR7 = ral_reg_ac_msix_MSIX_ADDR7::type_id::create("MSIX_ADDR7",,get_full_name());
      this.MSIX_ADDR7.configure(this, null, "");
      this.MSIX_ADDR7.build();
      this.default_map.add_reg(this.MSIX_ADDR7, `UVM_REG_ADDR_WIDTH'h3070, "RW", 0);
		this.MSIX_ADDR7_MsgAddrUpp = this.MSIX_ADDR7.MsgAddrUpp;
		this.MSIX_ADDR7_MsgAddrLow = this.MSIX_ADDR7.MsgAddrLow;
      this.MSIX_CTLDAT7 = ral_reg_ac_msix_MSIX_CTLDAT7::type_id::create("MSIX_CTLDAT7",,get_full_name());
      this.MSIX_CTLDAT7.configure(this, null, "");
      this.MSIX_CTLDAT7.build();
      this.default_map.add_reg(this.MSIX_CTLDAT7, `UVM_REG_ADDR_WIDTH'h3078, "RW", 0);
		this.MSIX_CTLDAT7_MsgControl = this.MSIX_CTLDAT7.MsgControl;
		this.MSIX_CTLDAT7_MsgData = this.MSIX_CTLDAT7.MsgData;
      this.MSIX_PBA = ral_reg_ac_msix_MSIX_PBA::type_id::create("MSIX_PBA",,get_full_name());
      this.MSIX_PBA.configure(this, null, "");
      this.MSIX_PBA.build();
      this.default_map.add_reg(this.MSIX_PBA, `UVM_REG_ADDR_WIDTH'h2000, "RW", 0);
		this.MSIX_PBA_Reserved7 = this.MSIX_PBA.Reserved7;
		this.Reserved7 = this.MSIX_PBA.Reserved7;
		this.MSIX_PBA_MsixPba = this.MSIX_PBA.MsixPba;
		this.MsixPba = this.MSIX_PBA.MsixPba;
      this.MSIX_COUNT_CSR = ral_reg_ac_msix_MSIX_COUNT_CSR::type_id::create("MSIX_COUNT_CSR",,get_full_name());
      this.MSIX_COUNT_CSR.configure(this, null, "");
      this.MSIX_COUNT_CSR.build();
      this.default_map.add_reg(this.MSIX_COUNT_CSR, `UVM_REG_ADDR_WIDTH'h2008, "RW", 0);
		this.MSIX_COUNT_CSR_Reserved32 = this.MSIX_COUNT_CSR.Reserved32;
		this.Reserved32 = this.MSIX_COUNT_CSR.Reserved32;
		this.MSIX_COUNT_CSR_Read_Write = this.MSIX_COUNT_CSR.Read_Write;
		this.Read_Write = this.MSIX_COUNT_CSR.Read_Write;
	  uvm_config_db #(uvm_reg_block)::set(null,"","RegisterModel_Debug",this);
   endfunction : build

	`uvm_object_utils(ral_block_ac_msix)

endclass : ral_block_ac_msix



`endif
