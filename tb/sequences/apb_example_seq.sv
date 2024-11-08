class apb_example_seq extends uvm_sequence #(apb_seq_item);

	`uvm_object_utils(apb_seq)

	function new(string name = "apb_seq");
		super.new(name); 
	endfunction : new

	logic[ADDR_WIDTH-1:0] addr_list[$];

	task body();
    	repeat(10) begin
		      req = apb_wr_txn::type_id::create("req");
		      start_item(req);
		      assert(req.randomize());
			    addr_list.push_back(req.paddr);
		      finish_item(req);
		  end
		  repeat(10) begin
		      req = apb_rd_txn::type_id::create("req");
		      start_item(req);
		      assert(req.randomize());
			    req.paddr = addr_list.pop_front();
		      finish_item(req);
		  end
	endtask : body

endclass : apb_example_seq
