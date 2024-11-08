class apb_wr_txn extends apb_seq_item;
	`uvm_object_utils(apb_wr_txn)

	constraint write_only {prst_n == 1'b1;
                         psel   == 1'b1;
			                   pwrite == 1'b1;}

	function new(string name = "apb_wr_txn"); 
        	super.new(name);
	endfunction : new
.
endclass : apb_wr_txn
