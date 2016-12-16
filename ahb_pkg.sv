package ahb_pkg;
parameter AHB_DATA_WIDTH = 64;
parameter AHB_ADDRESS_WIDTH = 32;
// state encoding
typedef enum logic[1:0] {
	IDLE=2'b00,
	BUSY=2'b01,
	NONSEQ=2'b10,
	SEQ=2'b11} 
	state_t;
// typedef logic[1:0] state_t;

// burst encoding
typedef enum logic[2:0] {
	SINGLE=3'b000,
	INCR=3'b001,
	INCR4=3'b011,
	INCR8=3'b101,
	INCR16=3'b111,
	WRAP4=3'b010,
	WRAP8=3'b100,
	WRAP16=3'b110} 
	burst_t;
// typedef logic[2:0] burst_t;

// size encoding
typedef enum logic[2:0] {
	Byte=3'b000,
	Halfword=3'b001,
	Word=3'b010,
	Doubleword=3'b011,
	Fourword=3'b100,
	Eightword=3'b101} 
	size_t;
// typedef logic[2:0] size_t;

// HRESP encoding
typedef enum logic {
	OKAY=1'b0,
	ERROR=1'b1} 
	response_t;
// typedef logic[1:0] response_t;

function [AHB_ADDRESS_WIDTH-1:0] new_address(int size_in_bytes,
		logic[AHB_ADDRESS_WIDTH-1:0] aligned_address,
		int local_cycle_counter);
   

	new_address = aligned_address+(local_cycle_counter)*size_in_bytes;
   
endfunction

function int lower_bytelane(
		logic[AHB_ADDRESS_WIDTH-1:0] start_address,
		int data_bus_bytes,
		int local_cycle_counter,
		logic[AHB_ADDRESS_WIDTH-1:0] next_address
		);
   	
   	if (local_cycle_counter==0) begin
   		lower_bytelane = (start_address-(start_address/data_bus_bytes)*data_bus_bytes);
   	end else begin 
   		lower_bytelane=next_address-(next_address/data_bus_bytes)*data_bus_bytes;
   	end

   
endfunction

function int upper_bytelane(
		logic[AHB_ADDRESS_WIDTH-1:0] aligned_address,
		int number_bytes,
		logic[AHB_ADDRESS_WIDTH-1:0] start_address,
		int data_bus_bytes,
		int lower_byte_lane,
		int local_cycle_counter
		);
   	
   	if (local_cycle_counter==0) begin
   		upper_bytelane = ( aligned_address+(number_bytes-1)-(start_address/data_bus_bytes)*data_bus_bytes);
   	end else begin 
   		upper_bytelane=lower_byte_lane+number_bytes-1;;
   	end
   
endfunction

class ahb_transaction ;
	logic [AHB_ADDRESS_WIDTH-1:0] address;
	logic [AHB_DATA_WIDTH-1:0] write_data;
	logic write;
	logic [2:0] size;
	logic [2:0] burst;
	logic [1:0] trans;

function new(logic[AHB_ADDRESS_WIDTH-1:0] address_,logic [AHB_DATA_WIDTH-1:0] write_data_,logic write_,logic [2:0] size_,logic [2:0] burst_,logic [1:0] trans_);
        address     = address_;
        write_data = write_data_;
        write = write_;
        size  = size_;
        burst = burst_;
        trans = trans_;
endfunction

endclass : ahb_transaction

function string trans_to_string (
	logic [1:0] HTRANS
	);
	if(HTRANS==2'b00) begin
		trans_to_string= "IDLE";
	end else if(HTRANS==2'b01) begin
		trans_to_string="BUSY";
	end else if(HTRANS==2'b10) begin
		trans_to_string="NONSEQ";
	end else if(HTRANS==2'b11) begin
		trans_to_string="SEQ";
	end
endfunction

function string burst_to_string (
	logic [2:0] HBURST
	);
	if(HBURST==3'b000) begin
		burst_to_string= "SINGLE";
	end else if(HBURST==3'b001) begin
		burst_to_string="INCR";
	end else if(HBURST==3'b010) begin
		burst_to_string="WRAP4";
	end else if(HBURST==3'b011) begin
		burst_to_string="INCR4";
	end else if(HBURST==3'b100) begin
		burst_to_string="WRAP8";
	end else if(HBURST==3'b101) begin
		burst_to_string="INCR8";
	end else if(HBURST==3'b110) begin
		burst_to_string="WRAP16";
	end else if(HBURST==3'b111) begin
		burst_to_string="INCR16";
	end
endfunction

function string size_to_string (
	logic [2:0] HSIZE
	);
	if(HSIZE==3'b000) begin
		size_to_string= "Byte";
	end else if(HSIZE==3'b001) begin
		size_to_string="Halfword";
	end else if(HSIZE==3'b010) begin
		size_to_string="Word";
	end else if(HSIZE==3'b011) begin
		size_to_string="Doubleword";
	end else if(HSIZE==3'b100) begin
		size_to_string="4-wordline";
	end else if(HSIZE==3'b101) begin
		size_to_string="8-wordline";
	end
endfunction

function logic[(AHB_DATA_WIDTH/8)-1:0] w_strobes (
	logic[AHB_ADDRESS_WIDTH-1:0] address_buffer,
	logic[2:0] axi_aw_size_o
	);
	for (int i = 0; i < (AHB_DATA_WIDTH/8); i++) begin
		if(i>=address_buffer%(AHB_DATA_WIDTH/8) && i<=address_buffer%(AHB_DATA_WIDTH/8)+2**axi_aw_size_o-1) begin
			w_strobes[i] = 1'b1;
		end else begin 
			w_strobes[i] = 0;
		end
	end
	$display("w_strobes =%b",w_strobes);

endfunction

function string axi_burst_to_string (
	logic [1:0] axi_aw_burst_o
	);
	if(axi_aw_burst_o==2'b00) begin
		axi_burst_to_string= "FIXED";
	end else if(axi_aw_burst_o==2'b01) begin
		axi_burst_to_string="INCR";
	end else if(axi_aw_burst_o==2'b10) begin
		axi_burst_to_string="WRAP";
	end else if(axi_aw_burst_o==2'b11) begin
		axi_burst_to_string="RESERVEDS";
	end
endfunction

function string axi_size_to_string (
	logic [2:0] axi_aw_size_o
	);
	if(axi_aw_size_o==3'b000) begin
		axi_size_to_string= "1 byte";
	end else if(axi_aw_size_o==3'b001) begin
		axi_size_to_string="2 bytes";
	end else if(axi_aw_size_o==3'b010) begin
		axi_size_to_string="4 bytes";
	end else if(axi_aw_size_o==3'b011) begin
		axi_size_to_string="8 bytes";
	end else if(axi_aw_size_o==3'b100) begin
		axi_size_to_string="16 bytes";
	end else if(axi_aw_size_o==3'b101) begin
		axi_size_to_string="32 bytes";
	end else if(axi_aw_size_o==3'b110) begin
		axi_size_to_string="64 bytes";
	end else if(axi_aw_size_o==3'b111) begin
		axi_size_to_string="128 bytes";
	end
endfunction



endpackage : ahb_pkg