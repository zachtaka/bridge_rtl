import ahb_pkg::*;
module ahb_m_v2 
	#( parameter AHB_DATA_WIDTH = 64,
	    parameter AHB_ADDRESS_WIDTH = 32,
	    parameter Hclock=10,
	    parameter GEN_RATE=50,
	    parameter max_undefined_length = 25)
	(   // Inputs
	    input logic HREADY,
	    input logic HRESP,
	    input logic [AHB_DATA_WIDTH-1:0] HRDATA,
	    // Outputs
	    output logic [AHB_ADDRESS_WIDTH-1:0] HADDR,
	    output logic [AHB_DATA_WIDTH-1:0] HWDATA,
	    output logic HWRITE,
	    output logic [2:0] HSIZE,
	    output logic [2:0] HBURST,
	    output logic [1:0] HTRANS,
	    output logic HCLK=0,
	    output logic HRESETn);


///////++++++++++++++++++++++
////// Encoding stuff
///////++++++++++++++++++++++
integer data_bus_bytes;
assign data_bus_bytes = AHB_DATA_WIDTH/8;
int local_cycle_counter;
logic [63:0] number_bytes,upper_byte_lane,lower_byte_lane;
logic [AHB_DATA_WIDTH-1:0]data,data_buffer;
logic  [AHB_ADDRESS_WIDTH-1:0] aligned_address,next_address;
// state encoding
state_t state;
// assign HTRANS  = state_t'(state);

// burst encoding
burst_t burst_type;
// assign HBURST = burst_t'(burst_type);

// size encoding
size_t size;
// assign HSIZE = size_t'(size);

// HRESP encoding
response_t response;
// assign response = response_t'(HRESP);

///////++++++++++++++++++++++
////// END OF - Encoding stuff
///////++++++++++++++++++++++

// AHB MBs
mailbox address_mail  = new();
mailbox write_data_mail  = new();
mailbox write_mail  = new();
mailbox size_mail  = new();
mailbox burst_mail  = new();
mailbox trans_mail  = new();
mailbox undef_incr_len_mail  = new();
// Helpfull MBs
mailbox wdata_mail = new();


// ahb_transaction ahb_transaction;
logic sucess,sucess2;
logic  [AHB_ADDRESS_WIDTH-1:0] address;
int result_file;
int cycle_counter;
logic [63:0] trans_random_var,gen_random_var,size_random_var,write_random_var;
logic [AHB_ADDRESS_WIDTH-1:0] addr_random_var;
int z;
initial begin 
	result_file = $fopen("C:/Users/haris/Desktop/Verilog/bridge_rtl/results_v2.txt", "w") ;
	HCLK=0;
	HRESETn=1'b0;
	#(Hclock*3)
	HRESETn=1'b1;
	z=0;

	// INCR_t(4,'h0,4,1);
	// INCR_t(4,'h0,4,1);
	// SINGLE_t(8,4,1);
	// IDLE_t;
	while ( z<1000) begin
		gen_random_var = $urandom_range(0,99);
		trans_random_var = $urandom_range(0,4);
		sucess = std::randomize(size_random_var) with { size_random_var inside {1,2,4,8};};
		sucess2 = std::randomize(addr_random_var) with { addr_random_var%size_random_var==0; addr_random_var>=0 && addr_random_var<=20;};
		$display("addr_random_var=%h",addr_random_var);
		// size_random_var = $urandom_range(0,3);
		// write_random_var = $urandom_range(0,1);// mexri na ginoun ta read 
		write_random_var = 1'b1; // mexri na ginoun ta read 
		// INCR_t(4,addr_random_var,size_random_var,1);

		// INCR_t(4,addr_random_var,size_random_var,1);
		if (gen_random_var<GEN_RATE && sucess==1'b1 && sucess2==1'b1) begin
			if (trans_random_var==0) begin // INCR4
				INCR_t(4,addr_random_var,size_random_var,write_random_var);
			end else if (trans_random_var==1) begin // INCR8
				INCR_t(8,addr_random_var,size_random_var,write_random_var);
			end else if (trans_random_var==2) begin // INCR16
				INCR_t(16,addr_random_var,size_random_var,write_random_var);
			end else if (trans_random_var==3) begin // SINGLE
				SINGLE_t(addr_random_var,size_random_var,write_random_var);
			end else if (trans_random_var==4) begin //INCR
				INCR_t($urandom_range(max_undefined_length,17),addr_random_var,size_random_var,write_random_var);
			end
		end else begin
			IDLE_t;
		end
		z++;
	end






end




///////++++++++++++++++++++++
////// Driver
///////++++++++++++++++++++++

integer length,burst_length;
logic write;
logic [2:0]burst,size_;
logic [1:0]state_;
logic [1:0]next_state_;
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(~HRESETn) begin
		HADDR<=0;
		HBURST<=0;
		HTRANS<=0;
		HSIZE<=0;
		HWRITE<=0;
	end else begin
		next_state_=trans_mail.try_peek(state_);
		if(HREADY==1'b1) begin
			pop_from_mail;
			HADDR<=address;
			HBURST<=burst;
			HTRANS<=state_;
			HSIZE<=size_;
			HWRITE<=write;
			length<=burst_length;
		end 
	end
end




// #f change to comb blocks


///////++++++++++++++++++++++
////// END - Driver
///////++++++++++++++++++++++

///////++++++++++++++++++++++
////// Data generator
///////++++++++++++++++++++++

// data phase
logic data_phase;
int tmp0;
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(~HRESETn) begin
		data_phase <= 0;
		tmp0<=0;
		HWDATA<=0;
	end else begin
		if(HREADY==1'b1 && (state_!==2'b00 && state_!==2'b01)  && HWRITE==1'b1) begin
			data_phase<=1'b1;
			wdata_mail.get(data);
			HWDATA<=data;
		end else begin 
			data_phase<=0;
			tmp0<=0;
			HWDATA<=0;
		end
	end
end




///////++++++++++++++++++++++
////// END - Data generator
///////++++++++++++++++++++++




///////++++++++++++++++++++++
////// File stuff
///////++++++++++++++++++++++

always_ff @(posedge HCLK or negedge HRESETn) begin : proc_
	if(~HRESETn) begin
		cycle_counter <= 0;
	end else begin
		cycle_counter <= cycle_counter+1;
		data_buffer<=data;
		if(HTRANS==2'b10) begin
			$fwrite(result_file,"\n");
		end
		// $fwrite(result_file,"@cycle_counter=%0d \tHTRANS=%b \tHBURST=%b \tHSIZE=%b \tburst_length=%0d \tHWRITE=%b \tHADDR=%h \tHWDATA=%h \tHRDATA=%h \tHREADY=%b \tHRESP=%s \tdata=%h \tdata_buffer=%h \t@local_cycle_counter=%0d \n",cycle_counter,state,HTRANS,HBURST,HSIZE,length,HWRITE,HADDR,HWDATA,HRDATA,HREADY,HRESP);
		$fwrite(result_file,"@cycle_counter=%0d \tHTRANS=%s \tHBURST=%s \tHSIZE=%s \tburst_length=%0d \tHWRITE=%b \tHADDR=%h \tHREADY=%b \tHWDATA=%h \tdata_phase=%b\n",
			cycle_counter,trans_to_string(HTRANS),burst_to_string(HBURST),size_to_string(HSIZE),burst_length,HWRITE,HADDR,HREADY,HWDATA,data_phase);
	end
end



// clock generator
always #(Hclock/2) HCLK= ~HCLK;

///////++++++++++++++++++++++
////// END - File stuff
///////++++++++++++++++++++++





///////++++++++++++++++++++++
////// My tasks
///////++++++++++++++++++++++
task INCR_t(
	input int number_of_beats,
	input [AHB_ADDRESS_WIDTH-1:0] start_address,
	input int size_in_bytes,
	input write_random_var
	);
	assign number_bytes = size_in_bytes;
	assign aligned_address = (start_address/number_bytes)*number_bytes;
	tmp0=0;

	for (int i = 0; i < number_of_beats; i++) begin
		if(i==0) begin
			burst_length=number_of_beats;
			// Set burst type
			if (number_of_beats==4) begin
				burst_type=INCR4;
				burst = 3'b011;
			end else if(number_of_beats==8) begin
				burst_type=INCR8;
				burst = 3'b101;
			end else if (number_of_beats==16) begin
				burst_type=INCR16;
				burst = 3'b111;
			end else begin
				burst_type=INCR;
				burst = 3'b001;
			end
			// Set size
			if (size_in_bytes==1) begin
				size=Byte;
				size_=3'b000;
			end else if (size_in_bytes==2) begin
				size=Halfword;
				size_=3'b001;
			end else if(size_in_bytes==4) begin
				size=Word;
				size_=3'b010;
			end else if (size_in_bytes==8) begin
				size=Doubleword;
				size_=3'b011;
			end
			write=write_random_var;
			state=NONSEQ;
			state_=2'b10;
			address=start_address;
		end else begin 
			state=SEQ;
			state_=2'b11;
			address=new_address(size_in_bytes,aligned_address,i);
		end

		put_to_mail;


		for (int k=0;k<AHB_DATA_WIDTH;k=k+8)begin

			if (i==0) begin //if first transfer
				lower_byte_lane = (start_address-(start_address/data_bus_bytes)*data_bus_bytes);
				upper_byte_lane = ( aligned_address+(number_bytes-1)-(start_address/data_bus_bytes)*data_bus_bytes);
			end else begin
				lower_byte_lane=new_address(size_in_bytes,aligned_address,i)-(new_address(size_in_bytes,aligned_address,i)/data_bus_bytes)*data_bus_bytes;
				upper_byte_lane=lower_byte_lane+number_bytes-1;
			end
			if ((k>=lower_byte_lane*8) && (k<=upper_byte_lane*8)) begin
				data[k+:8]=tmp0;
			end else begin
				data[k+:8]='bx;
			end
			tmp0=tmp0+1;
		end	
		wdata_mail.put(data);


	end

endtask : INCR_t


task SINGLE_t(			// %f merge with incr
	input [AHB_ADDRESS_WIDTH-1:0] start_address,
	input integer size_in_bytes,
	input write_random_var
	);

	// Set size
	if (size_in_bytes==1) begin
		size=Byte;
	end else if (size_in_bytes==2) begin
		size=Halfword;
	end else if(size_in_bytes==4) begin
		size=Word;
	end else if (size_in_bytes==8) begin
		size=Doubleword;
	end
	state_=2'b10; // NONSEQ
	address = start_address;
	burst = 3'b000; // SINGLE
	burst_length=1;
	write = write_random_var;
	put_to_mail;

	for (int k=0;k<AHB_DATA_WIDTH;k=k+8)begin

		lower_byte_lane = (start_address-(start_address/data_bus_bytes)*data_bus_bytes);
		upper_byte_lane = ( aligned_address+(number_bytes-1)-(start_address/data_bus_bytes)*data_bus_bytes);
			
		if ((k>=lower_byte_lane*8) && (k<=upper_byte_lane*8)) begin
			data[k+:8]=tmp0;
		end else begin
			data[k+:8]='bx;
		end
		tmp0=tmp0+1;
	end	

	wdata_mail.put(data);




endtask : SINGLE_t


task IDLE_t;
	
	state_=2'b00;
	address=0;
	write=0;
	burst = 3'b000; // SINGLE
	size_=3'b000;
	burst_length=0;

	put_to_mail;


endtask





task put_to_mail();
	burst_mail.put(burst);// burst_mail.put(burst_t'(burst_type));
	trans_mail.put(state_);// trans_mail.put(state_t'(state));
	address_mail.put(address);
	size_mail.put(size_);// size_mail.put(size_t'(size));
	write_mail.put(write);
	undef_incr_len_mail.put(burst_length);
endtask : put_to_mail


task pop_from_mail();
	burst_mail.get(burst);
	trans_mail.get(state_);		// #f try_get
	address_mail.get(address);
	size_mail.get(size_);
	write_mail.get(write);
	undef_incr_len_mail.get(burst_length);
endtask : pop_from_mail

endmodule // ahb_m_v2