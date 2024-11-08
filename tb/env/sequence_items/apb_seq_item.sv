class apb_seq_item extends uvm_sequence_item;
	`uvm_object_utils(apb_seq_item)

  rand  logic                  prst_n;
	randc logic [ADDR_WIDTH-1:0] paddr;
	rand  logic                  psel;
  rand  logic                  pwrite;
	randc logic [DATA_WIDTH-1:0] pwdata;
	      logic [DATA_WIDTH-1:0] prdata;

	function new(string name = "apb_seq_item"); 
        	super.new(name);
	endfunction : new

	function string convert2string();
		return $sformatf("prst_n = %b, paddr = %h, psel = %b, pwrite = %b, pwdata = %h, prdata = %h",
        prst_n, paddr, psel, pwrite, pwdata, prdata);
	endfunction : convert2string

	function void do_copy(uvm_object rhs);
		apb_seq_item temp;
		super.do_copy(rhs);
		assert($cast(temp, rhs));
		this.prst_n  = temp.prst_n;
		this.paddr   = temp.paddr;
		this.psel    = temp.psel;
       	this.pwrite  = temp.pwrite;
		this.pwdata  = temp.pwdata;
		this.prdata  = temp.prdata;
	endfunction : do_copy 

endclass : apb_seq_item
