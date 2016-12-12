package ahb_pkg;

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






endpackage : ahb_pkg