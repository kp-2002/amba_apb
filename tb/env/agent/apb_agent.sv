class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
	
	apb_drv  apb_drv_h;
	apb_mon  apb_mon_h;
	apb_seqr apb_seqr_h;

	function new(string name, uvm_component parent);
		super.new(name, parent); 
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//`uvm_info("INFO", "In build phase of agent", UVM_LOW)
		apb_drv_h  = apb_drv::type_id::create("apb_drv_h", this);
		apb_mon_h  = apb_mon::type_id::create("apb_mon_h", this);
		apb_seqr_h = apb_seqr::type_id::create("apb_seqr_h", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		//`uvm_info("INFO", "In connect phase of agent", UVM_LOW)
		apb_drv_h.seq_item_port.connect(apb_seqr_h.seq_item_export);
	endfunction : connect_phase	
	
endclass : apb_agent
