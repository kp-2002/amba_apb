//Author: Kaivalyae Panicker <kaivalyaep22@gmail.com>
//Date  : 09.11.2024
//Description: This is a UVM based driver with an apb master interface 
//that can be used to drive sequences for rtl verification purposes.  
//It can be integrated into UVM test environments to verify any 
//IP block that has apb slave interfaces.

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

class apb_drv extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_drv)

	virtual apb_if     vif;
	virtual apb_if.DRV vif_drv;
	
	function new(string name, uvm_component parent);
		super.new(name, parent); 
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//`uvm_info("INFO", "In build phase of driver", UVM_LOW)
		if(! uvm_config_db #(virtual apb_if)::get(this, "*", "apb_if", vif))
			`uvm_fatal("FATAL","Failed to get virtual interface.  Have you set it?")
		vif_drv = vif;
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		//`uvm_info("INFO", "In run phase of driver", UVM_LOW)
        vif_drv.drv_cb.psel <= 1'b0;
        @(vif_drv.drv_cb);
        vif_drv.drv_cb.prst_n  <= 1'b0;
        vif_drv.drv_cb.paddr   <= $random;
        vif_drv.drv_cb.psel    <= $random;
        vif_drv.drv_cb.penable <= 1'b0;
        vif_drv.drv_cb.pwrite  <= $random;
        vif_drv.drv_cb.pwdata  <= $random;
	    `uvm_info("INFO",{"Reset asserted"},UVM_HIGH)
        @(vif_drv.drv_cb);
        @(vif_drv.drv_cb);
        vif_drv.drv_cb.psel    <= 1'b0;
        vif_drv.drv_cb.prst_n  <= 1'b1;
	    `uvm_info("INFO",{"Reset deasserted"},UVM_HIGH)
        @(vif_drv.drv_cb);  
		forever begin
			seq_item_port.get_next_item(req);
			drive_to_dut(req);	
			seq_item_port.item_done();
		end
	endtask : run_phase

	task drive_to_dut(apb_seq_item data2dut_pkt);        
        if(data2dut_pkt.psel) begin            
            vif_drv.drv_cb.prst_n  <= data2dut_pkt.prst_n;
            vif_drv.drv_cb.paddr   <= data2dut_pkt.paddr;
            vif_drv.drv_cb.psel    <= data2dut_pkt.psel;
            vif_drv.drv_cb.penable <= 1'b0;
            vif_drv.drv_cb.pwrite  <= data2dut_pkt.pwrite;
            vif_drv.drv_cb.pwdata  <= data2dut_pkt.pwdata;
	        @(vif_drv.drv_cb);
            vif_drv.drv_cb.penable <= 1'b1;
           `uvm_info("INFO",{"Driven item to DUT :",data2dut_pkt.convert2string()},UVM_HIGH)
            wait(vif_drv.drv_cb.pready);
            @(vif_drv.drv_cb);
            vif_drv.drv_cb.psel    <= 1'b0;
            vif_drv.drv_cb.penable <= 1'b0;
            @(vif_drv.drv_cb);
        end
    endtask : drive_to_dut

endclass : apb_drv
