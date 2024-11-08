//Author: Kaivalyae Panicker <kaivalyaep22@gmail.com>
//Date  : 09.11.2024
//Description: This is a UVM based sequencer that passes apb
//sequences on to a driver, that drives them to a slave interface
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

class apb_seqr extends uvm_sequencer #(apb_seq_item);
  `uvm_component_utils(apb_seqr)
	
	function new(string name, uvm_component parent);
		super.new(name, parent); 
	endfunction : new

endclass : apb_seqr
