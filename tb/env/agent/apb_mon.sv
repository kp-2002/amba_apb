//Author: Kaivalyae Panicker <kaivalyaep22@gmail.com>
//Date  : 09.11.2024
//Description: This is a UVM based monitor with an apb master interface 
//that can be used to monitor sequences on an apb slave interface for 
//rtl verification purposes.  It can be integrated into UVM test environments
//to verify any IP block that has apb slave interfaces.

/*
 * Copyright 2024 Kaivalyae Panicker

 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at

 *  http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

class apb_mon extends uvm_monitor;
  `uvm_component_utils(apbmon)

	uvm_analysis_port #(apb_seq_item) mon_ap;
	virtual apb_if     vif;
	virtual apb_if.MON vif_mon;
	apb_seq_item data2sb_pkt;
	
	function new(string name, uvm_component parent);
		super.new(name, parent); 
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//`uvm_info("INFO", "In build phase of input monitor", UVM_LOW)
		if(! uvm_config_db #(virtual apb_if)::get(this, "*", "apb_if", vif))
			`uvm_fatal("FATAL","Failed to get virtual interface.  Have you set it?")
		vif_mon = vif;
		mon_ap = new("mon_ap", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		//`uvm_info("INFO", "In run phase of monitor", UVM_LOW)
		forever 
			monitor();
	endtask : run_phase

	task monitor();
		@(vif_mon.mon_cb);
		data2sb_pkt = apb_seq_item::type_id::create("data2sb_pkt");
		if(~vif_mon.mon_cb.prst_n) begin
            //@(vif_mon.mon_cb);
			      data2sb_pkt.prst_n = vif_mon.mon_cb.prst_n;
			      data2sb_pkt.paddr  = vif_mon.mon_cb.paddr;
            data2sb_pkt.psel   = vif_mon.mon_cb.psel;
            data2sb_pkt.pwrite = vif_mon.mon_cb.pwrite;
			      data2sb_pkt.pwdata = vif_mon.mon_cb.pwdata;
			      data2sb_pkt.prdata = vif_mon.mon_cb.prdata;
			      @(vif_mon.mon_cb);
            @(vif_mon.mon_cb);
			      `uvm_info("INFO",{"Received item from DUT :",data2sb_pkt.convert2string()},UVM_HIGH)
			      mon_ap.write(data2sb_pkt);
		end
		else if(vif_mon.mon_cb.psel) begin
            if(vif_mon.mon_cb.pwrite) begin
			          data2sb_pkt.prst_n = vif_mon.mon_cb.prst_n;
			          data2sb_pkt.paddr  = vif_mon.mon_cb.paddr;
                data2sb_pkt.psel   = vif_mon.mon_cb.psel;
                data2sb_pkt.pwrite = vif_mon.mon_cb.pwrite;
			          data2sb_pkt.pwdata = vif_mon.mon_cb.pwdata;
			          data2sb_pkt.prdata = vif_mon.mon_cb.prdata;
                wait(vif_mon.mon_cb.pready);
                @(vif_mon.mon_cb);
                @(vif_mon.mon_cb);
			          `uvm_info("INFO",{"Received item from DUT :",data2sb_pkt.convert2string()},UVM_HIGH)
			          mon_ap.write(data2sb_pkt);
            end
		    else begin
                data2sb_pkt.prst_n = vif_mon.mon_cb.prst_n;
			          data2sb_pkt.paddr  = vif_mon.mon_cb.paddr;
                data2sb_pkt.psel   = vif_mon.mon_cb.psel;
                data2sb_pkt.pwrite = vif_mon.mon_cb.pwrite;
			          data2sb_pkt.pwdata = vif_mon.mon_cb.pwdata;			    
                wait(vif_mon.mon_cb.pready);
			          data2sb_pkt.prdata = vif_mon.mon_cb.prdata;
                @(vif_mon.mon_cb);                
                @(vif_mon.mon_cb);
			          `uvm_info("INFO",{"Received item from DUT :",data2sb_pkt.convert2string()},UVM_HIGH)
			          mon_ap.write(data2sb_pkt);
            end
		end
	endtask : monitor

endclass : apb_mon
