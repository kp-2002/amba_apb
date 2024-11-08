class apb_rd_txn extends apb_seq_item;
	`uvm_object_utils(apb_rd_txn)

	constraint read_only {prst_n == 1'b1;
                        psel   == 1'b1;
			                  pwrite == 1'b0;}

	function new(string name = "apb_rd_txn"); 
        	super.new(name);
	endfunction : new

endclass : apb_rd_txn
