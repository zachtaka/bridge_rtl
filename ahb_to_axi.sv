import ahb_pkg::*;
// import axi_pkg::*;


module ahb_to_axi #(
		   parameter AHB_DATA_WIDTH=64,
		   parameter AHB_ADDRESS_WIDTH=32,
		   parameter int TIDW = 1,
		   parameter int AW  = 32,
		   parameter int DW  = 64,
		   parameter int USERW  = 1

		)
		(
		// AHB slave interface
			// Inputs
			input logic HCLK,
			input logic [AHB_ADDRESS_WIDTH-1:0] HADDR,
			input logic [AHB_DATA_WIDTH-1:0] HWDATA,
			input logic HWRITE,
			input logic [2:0] HSIZE,HBURST,
			input logic [1:0] HTRANS,
			input logic HRESETn,
			// Outputs
			output logic HREADY,
			output logic [AHB_DATA_WIDTH-1:0] HRDATA,
			output logic HRESP,
			output logic HEXOKAY,
		   


		// AXI master interface
		    // AW (Write Address) 
		    output logic[TIDW-1:0]           axi_aw_id_o,    // AWID
		    output logic[AW-1:0]              axi_aw_addr_o,  // AWADDR
		    output logic[7:0]                     axi_aw_len_o,   // AWLEN
		    output logic[2:0]                     axi_aw_size_o,  // AWSIZE
		    output logic[1:0]                     axi_aw_burst_o, // AWBURST
		    output logic[1:0]                     axi_aw_lock_o,  // AWLOCK / 2-bit always for AMBA==3 compliance, but MSB is always tied to zero (no locked support) 
		    output logic[3:0]                     axi_aw_cache_o, // AWCACHE
		    output logic[2:0]                     axi_aw_prot_o,  // AWPROT
		    output logic[3:0]                     axi_aw_qos_o,   // AWQOS
		    output logic[3:0]                     axi_aw_region_o,// AWREGION
		    output logic[USERW-1:0]        axi_aw_user_o,  // AWUSER
		    output logic                            axi_aw_valid_o, // AWVALID
		    input logic                              axi_aw_ready_i, // AWREADY
		    // W (Write Data) channel
		    output  logic[TIDW-1:0]                    axi_w_id_o,     // WID / driven only under AMBA==3 mode (AXI4 does not support write interleaving, so there's no WID signal)
		    output  logic[DW-1:0]                       axi_w_data_o,   // WDATA
		    output  logic[DW/8-1:0]                    axi_w_strb_o,   // WSTRB
	 	    output  logic                                    axi_w_last_o,   // WLAST
	  	    output  logic[USERW-1:0]                axi_w_user_o,   // WUSER / tied to zero
		    output  logic                                    axi_w_valid_o,  // WVALID
		    input logic                                       axi_w_ready_i,  // WREADY
		    // B (Write Response) channel 
		    input logic[TIDW-1:0]                     axi_b_id_i,     // BID
		    input logic[1:0]                               axi_b_resp_i,   // BRESP
		    input logic[USERW-1:0]                 axi_b_user_i,   // BUSER
		    input logic                                     axi_b_valid_i,  // BVALID
		    output logic                                   axi_b_ready_o,  // BREADY
		    // AR (Read Address) 
		    output logic[TIDW-1:0]                     axi_ar_id_o,    // ARID
		    output logic[AW-1:0]                        axi_ar_addr_o,  // ARADDR
		    output logic[7:0]                               axi_ar_len_o,   // ARLEN
		    output logic[2:0]                               axi_ar_size_o,  // ARSIZE
		    output logic[1:0]                               axi_ar_burst_o, // ARBURST
		    output logic[1:0]                               axi_ar_lock_o,  // ARLOCK / 2-bit always for AMBA==3 compliance, but MSB is always tied to zero (no locked support)
		    output logic[3:0]                               axi_ar_cache_o, // ARCACHE
		    output logic[2:0]                               axi_ar_prot_o,  // ARPROT
		    output logic[3:0]                               axi_ar_qos_o,   // ARQOS
		    output logic[3:0]                               axi_ar_region_o,// ARREGION
		    output logic[USERW-1:0]                 axi_ar_user_o,  // ARUSER
		    output logic                                     axi_ar_valid_o, // ARVALID
		    input logic                                       axi_ar_ready_i, // ARREADY
		    // R (Read Data) 
		    input logic[TIDW-1:0]                      axi_r_id_i,     // RID
		    input logic[DW-1:0]                         axi_r_data_i,   // RDATA
		    input logic[1:0]                                axi_r_resp_i,   // RRESP
		    input logic                                      axi_r_last_i,   // RLAST
		    input logic[USERW-1:0]                  axi_r_user_i,   // RUSER
		    input logic                                      axi_r_valid_i,  // RVALID
		    output  logic                                   axi_r_ready_o   // RREADY
		);


///////++++++++++++++++++++++
////// Encoding stuff
///////++++++++++++++++++++++

// state encoding
state_t state;
assign state = state_t'(HTRANS);
// burst encoding
burst_t burst_type;
assign burst_type = burst_t'(HBURST);
// size encoding
size_t size;
assign size = size_t'(HSIZE);
// HRESP encoding
response_t response;
assign response = response_t'(HRESP);

///////++++++++++++++++++++++
////// END OF - Encoding stuff
///////++++++++++++++++++++++

// input logic [AHB_ADDRESS_WIDTH-1:0] HADDR,  done
// 		    input logic [AHB_DATA_WIDTH-1:0] HWDATA, done
// 		    input logic HWRITE,
// 		    input logic [2:0] HSIZE, done
// 		    input logic [2:0] HBURST, done
// 		    input logic [1:0] HTRANS,



///////++++++++++++++++++++++
////// Write Transfers (SINGLE)
///////++++++++++++++++++++++


assign axi_w_ack = axi_w_valid_o & axi_w_ready_i;
assign axi_aw_ack = axi_aw_valid_o & axi_aw_ready_i;

// HREADY
logic axi_write_ack;
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		 HREADY<=1'b1;
	end else begin
		if( (state == NONSEQ || state==SEQ) && HREADY==1'b1) begin
			HREADY<=0;
		end 
		if(axi_write_ack==1'b1) begin
			HREADY<=1'b1;
		end 
	end
end

// pending_write
logic pending_write;
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		 pending_write<=0;
	end else begin
		if(HREADY==1'b1 && (state!==IDLE && state!==BUSY)  && HWRITE==1'b1) begin
			pending_write<=1'b1;
		end 
		if(axi_write_ack==1'b1) begin
			pending_write<=0;
		end
	end
end




// axi write ack and axi_b_ready_o
always_comb begin 
	if(axi_b_resp_i==2'b00 && axi_b_valid_i==1'b1) begin
		axi_write_ack=1'b1;
	end else begin 
		axi_write_ack=0;
	end
end
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		axi_b_ready_o <= 1'b1;
	end else begin
		axi_b_ready_o <= 1'b1;
	end
end

// AWBURST - HBURST
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(~HRESETn) begin
		axi_aw_burst_o <= 0;
	end else begin
		if( HREADY==1'b1 && (state!==IDLE && state!==BUSY)  && HWRITE==1'b1 ) begin //geniki sinthiki pou kanw sample ta AW simata
			if(burst_type==SINGLE ) begin
				axi_aw_burst_o<=2'b01; // axi_burst=INCR
			end if(burst_type==INCR || burst_type==INCR4 ||burst_type==INCR8 || burst_type==INCR16 ) begin
				axi_aw_burst_o<=2'b01; // axi_burst=INCR
			end else begin 
				axi_aw_burst_o<=0;
			end
		end
	end
end




 // AWSIZE - HSIZE
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		axi_aw_size_o<=0;
	end else begin
		if(HREADY==1'b1 && (state!==IDLE && state!==BUSY)  && HWRITE==1'b1) begin
			if(burst_type==SINGLE ) begin
				axi_aw_size_o<=HSIZE;
			end else begin // if(burst_type==INCR)
				axi_aw_size_o<=HSIZE;
			end
			if (axi_write_ack==1'b1) begin 
				axi_aw_size_o<=0;
			end
		end
	end
end


// AWLEN - HBURST
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		axi_aw_len_o<=0;
	end else begin
		if(HREADY==1'b1 && (state!==IDLE && state!==BUSY)  && HWRITE==1'b1) begin
			if(burst_type==SINGLE) begin
				axi_aw_len_o<=0;
			end else begin // if(burst_type==INCR)
				axi_aw_len_o<=0;
			end 
		end
	end
end


// AWADDR / AWVALID - HADDR (katevazw to valid sto AWREADY)
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		axi_aw_addr_o<=0;
		axi_aw_valid_o<= 0;
	end else begin
		if(HREADY==1'b1 && (state!==IDLE && state!==BUSY)  && HWRITE==1'b1) begin
			if(burst_type==SINGLE) begin
				axi_aw_addr_o<=HADDR;
				axi_aw_valid_o<= 1'b1;
			end else begin // if(burst_type==INCR)
				axi_aw_addr_o<=HADDR;
				axi_aw_valid_o<= 1'b1;
			end
		end
		if(axi_aw_ack==1'b1) begin
			axi_aw_addr_o<=0;
			axi_aw_valid_o<= 0;
		end
	end
end

// WDATA / WVALID - HWDATA   --WREADY
logic write_data_phase;
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(~HRESETn) begin
		write_data_phase<=0;
	end else begin
		 if(HREADY==1'b1 && (state!==IDLE && state!==BUSY)  && HWRITE==1'b1) begin
			write_data_phase<=1'b1;
		end else begin
			write_data_phase<=0;
		end
	end
end
integer data_bus_bytes;
assign data_bus_bytes = AHB_DATA_WIDTH / 8;
always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		axi_w_data_o <= 'bx;
		axi_w_valid_o<= 0;
		axi_w_last_o<= 0;
		axi_w_strb_o<= 0;
	end else begin
		if(write_data_phase==1'b1) begin
			axi_w_data_o<=HWDATA;
			axi_w_valid_o<= 1'b1;
			axi_w_last_o<= 1'b1; //epeidi pros to paron ola ta kanw single, auto einai swsto
			axi_w_strb_o<=w_strobes(axi_aw_addr_o,axi_aw_size_o);  // na to ftiaksw properly se function
		end 
		if(axi_w_ack==1'b1) begin
			axi_w_data_o <= 'bx;
			axi_w_valid_o<= 0;
			axi_w_last_o<= 0;
			axi_w_strb_o<= 0;
		end
	end
end

// HRESP
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(~HRESETn) begin
		HRESP <= 0;
	end else begin
		HRESP <= 0; //always okay
	end
end



///////++++++++++++++++++++++
////// END - Write Transfers
///////++++++++++++++++++++++
integer cycle_counter;
integer ahb2axi_file;
initial begin 
	ahb2axi_file = $fopen("C:/Users/haris/Desktop/Verilog/bridge_rtl/ahb2axi_file.txt", "w") ;
end

always_ff @(posedge HCLK or negedge HRESETn) begin 
	if(~HRESETn) begin
		cycle_counter <= 0;
	end else begin
		cycle_counter <= cycle_counter + 1;
		// $fwrite(ahb2axi_file,"cycle_counter=%0d \tHADDR=%h \tHWDATA=%h \tHWRITE=%b \tHSIZE=%s \tHBURST=%s \tHTRANS=%s \n",cycle_counter,HADDR,HWDATA,HWRITE,size,burst_type,state);
		// $fwrite(ahb2axi_file,"\t\tWADDR=%h \tAWVALID=%b \tAWLEN=%0d \tAWSIZE=%b \tWDATA=%h \tWVALID=%b \tAWBURST=%b  \n\n",axi_aw_addr_o,axi_aw_valid_o, axi_aw_len_o,axi_aw_size_o,axi_w_data_o,axi_w_valid_o,axi_aw_burst_o);

		$fwrite(ahb2axi_file,"cycle_counter=%0d\n",cycle_counter);
		$fwrite(ahb2axi_file,"\tHRESETn=%b\n \tHBURST=%s\n \tHSIZE=%s\n \tHTRANS=%s\n \tHADDR=%h\n \tHREADY=%b\n \tHWRITE=%b\n \tHWDATA=%h\n \tHRESP=%h\n \taxi_aw_burst_o=%0d\n \taxi_aw_size_o=%0d\n \taxi_aw_len_o=%0d\n \taxi_aw_addr_o=%h\n \taxi_aw_valid_o=%b\n \taxi_aw_ready_i=%b\n \taxi_aw_ack=%b\n \taxi_w_data_o=%h\n \taxi_w_valid_o=%b\n \taxi_w_ready_i=%b\n \taxi_w_strb_o=%b\n \taxi_w_last_o=%b\n \taxi_b_ready_o=%b\n \taxi_b_valid_i=%b\n \taxi_b_resp_i=%b\n \tpending_write=%b\n",
					    HRESETn,burst_to_string(HBURST),size_to_string(HSIZE),trans_to_string(HTRANS),HADDR,HREADY,HWRITE,HWDATA,HRESP,axi_aw_burst_o,axi_aw_size_o,axi_aw_len_o,axi_aw_addr_o,axi_aw_valid_o,axi_aw_ready_i,axi_aw_ack,axi_w_data_o,axi_w_valid_o,axi_w_ready_i,axi_w_strb_o,axi_w_last_o,axi_b_ready_o,axi_b_valid_i,axi_b_resp_i,pending_write);
		$fwrite(ahb2axi_file,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
	end
end




///////++++++++++++++++++++++
////// Set other signals zero
///////++++++++++++++++++++++
always_comb begin 
	// AW (Write Address) 
	axi_aw_id_o=0;    // AWID
	// axi_aw_lock_o=  // AWLOCK / 2-bit always for AMBA==3 compliance= but MSB is always tied to zero (no locked support) 
	// axi_aw_cache_o= // AWCACHE
	// axi_aw_prot_o=  // AWPROT
	// axi_aw_qos_o=   // AWQOS
	// axi_aw_region_o=// AWREGION
	// axi_aw_user_o=  // AWUSER
	// // W (Write Data) channel
	// axi_w_id_o=     // WID / driven only under AMBA==3 mode (AXI4 does not support write interleaving= so there's no WID signal)
	
	// axi_w_user_o=   // WUSER / tied to zero
	// AR (Read Address) 
	// axi_ar_id_o=    // ARID
	axi_ar_addr_o= 0; // ARADDR
	axi_ar_len_o= 0;  // ARLEN
	axi_ar_size_o= 0; // ARSIZE
	axi_ar_burst_o= 0;// ARBURST
	// axi_ar_lock_o=  // ARLOCK / 2-bit always for AMBA==3 compliance= but MSB is always tied to zero (no locked support)
	// axi_ar_cache_o= // ARCACHE
	// axi_ar_prot_o=  // ARPROT
	// axi_ar_qos_o=   // ARQOS
	// axi_ar_region_o=// ARREGION
	// axi_ar_user_o=  // ARUSER
	axi_ar_valid_o=0; // ARVALID
	// R (Read Data) 
	axi_r_ready_o=1;   // RREADY
end








///////++++++++++++++++++++++
////// END - Set other signals zero
///////++++++++++++++++++++++



endmodule // ahb_to_axi