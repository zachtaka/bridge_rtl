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
   	
   	if (local_cycle_counter==1) begin
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
   	
   	if (local_cycle_counter==1) begin
   		upper_bytelane = ( aligned_address+(number_bytes-1)-(start_address/data_bus_bytes)*data_bus_bytes);
   	end else begin 
   		upper_bytelane=lower_byte_lane+number_bytes-1;;
   	end
   
endfunction



endpackage : ahb_pkg