import ahb_pkg::*;
// import axi_pkg::*;
`include "ahb_m.sv"
`include "ahb_to_axi.sv"

module wrapper;

// Parameter declarations
parameter AHB_DATA_WIDTH = 64;
parameter AHB_ADDRESS_WIDTH = 32;
parameter Hclock = 10;
parameter GEN_RATE=100;
parameter max_undefined_length=25;
// Signal declarations
logic HREADY;
logic [AHB_ADDRESS_WIDTH-1:0] HADDR;
logic [AHB_DATA_WIDTH-1:0] HWDATA,HRDATA;
logic HWRITE;
logic [2:0] HSIZE,HBURST;
logic [1:0] HTRANS;
logic HCLK,HRESETn;


logic [63:0] debug_file;
logic [63:0] cycle_counter;




integer now;
initial begin
	debug_file = $fopen("C:/Users/haris/Desktop/Verilog/bridge_rtl/debug_file.txt", "w") ;
	cycle_counter=0;
	now=0;
end


always @(posedge HCLK) begin
	cycle_counter<=cycle_counter+1;
	if (HTRANS==2'b10) begin //htrans == NONSEQ
		// $fwrite(debug_file,"\n");
	end
	// $fwrite(debug_file,"@cycle_counter=%0d \tHTRANS=%s \tHADDR=%h \tHWRITE=%h \tHBURST=%s \tHSIZE=%s \tHWDATA=%h \tHREADY=%b\n",cycle_counter,state,HADDR,HWRITE,burst_type,size,HWDATA,HREADY);

end
always @(posedge (HTRANS==2'b00) ) begin
	// $fwrite(debug_file,"\n");
end

logic fake_HREADY;
always_comb begin : proc_
	fake_HREADY=1'b1;
end


		// ahb_m #(
		// 	.AHB_DATA_WIDTH(AHB_DATA_WIDTH),
		// 	.AHB_ADDRESS_WIDTH(AHB_ADDRESS_WIDTH),
		// 	.Hclock(Hclock),
		// 	.GEN_RATE(GEN_RATE),
		// 	.max_undefined_length(max_undefined_length)
		// ) inst_ahb_m (
		// 	.HCLK    (HCLK),
		// 	.HRESETn (HRESETn),
		// 	.HADDR   (HADDR),
		// 	.HWDATA  (HWDATA),
		// 	.HRDATA  (HRDATA),
		// 	.HWRITE  (HWRITE),
		// 	.HSIZE   (HSIZE),
		// 	.HBURST  (HBURST),
		// 	.HTRANS  (HTRANS),
		// 	.HREADY  (fake_HREADY),
		// 	.HRESP   (HRESP)
		// );

	ahb_m_v2 #(
			.AHB_DATA_WIDTH(AHB_DATA_WIDTH),
			.AHB_ADDRESS_WIDTH(AHB_ADDRESS_WIDTH),
			.Hclock(Hclock),
			.GEN_RATE(GEN_RATE),
			.max_undefined_length(max_undefined_length)
		) inst_ahb_m_v2 (
			.HCLK    (HCLK),
			.HREADY  (HREADY),
			.HRESP   (HRESP),
			.HRDATA  (HRDATA),
			.HADDR   (HADDR),
			.HWDATA  (HWDATA),
			.HWRITE  (HWRITE),
			.HSIZE   (HSIZE),
			.HBURST  (HBURST),
			.HTRANS  (HTRANS),
			.HRESETn (HRESETn)
		);













// Signals declarations
localparam int TIDW                     = 1;
parameter int DW            = 64;  // Data bus width
parameter int AW            = 32;
parameter int USERW         = 1;
logic[TIDW-1:0]                          axi_aw_id;    // AWID
logic[AW-1:0]                            axi_aw_addr;  // AWADDR
logic[7:0]                               axi_aw_len;   // AWLEN
logic[2:0]                               axi_aw_size;  // AWSIZE
logic[1:0]                               axi_aw_burst; // AWBURST
logic[1:0]                               axi_aw_lock;  // AWLOCK / 2-bit always for AMBA==3 compliance; but MSB is always tied to zero (no locked support) 
logic[3:0]                               axi_aw_cache; // AWCACHE
logic[2:0]                               axi_aw_prot;  // AWPROT
logic[3:0]                               axi_aw_qos;   // AWQOS
logic[3:0]                               axi_aw_region;// AWREGION
logic[USERW-1:0]                 axi_aw_user;  // AWUSER
logic                                    axi_aw_valid; // AWVALID
logic                                    axi_aw_ready; // AWREADY
// W (Write Data) channel (NI -> Target)
logic[TIDW-1:0]                    axi_w_id;     // WID / driven only under AMBA==3 mode (AXI4 does not support write interleaving; so there's no WID signal)
logic[DW-1:0]                      axi_w_data;   // WDATA
logic[DW/8-1:0]                   axi_w_strb;   // WSTRB
logic                                    axi_w_last;   // WLAST
logic[USERW-1:0]                axi_w_user;   // WUSER / tied to zero
logic                                    axi_w_valid;  // WVALID
logic                                    axi_w_ready;  // WREADY
// B (Write Response) channel (Target -> NI)
logic[TIDW-1:0]                    axi_bd;     // BID
logic[1:0]                              axi_b_resp;   // BRESP
logic[USERW-1:0]                axi_b_user;   // BUSER
logic                                    axi_b_valid;  // BVALID
logic                                    axi_b_ready;  // BREADY
// AR (Read Address) channel (NI -> Target)
logic[TIDW-1:0]                       axi_ar_id;    // ARID
logic[AW-1:0]                         axi_ar_addr;  // ARADDR
logic[7:0]                               axi_ar_len;   // ARLEN
logic[2:0]                               axi_ar_size;  // ARSIZE
logic[1:0]                               axi_ar_burst; // ARBURST
logic[1:0]                               axi_ar_lock;  // ARLOCK / 2-bit always for AMBA==3 compliance; but MSB is always tied to zero (no locked support)
logic[3:0]                               axi_ar_cache; // ARCACHE
logic[2:0]                               axi_ar_prot;  // ARPROT
logic[3:0]                               axi_ar_qos;   // ARQOS
logic[3:0]                               axi_ar_region;// ARREGION
logic[USERW-1:0]                  axi_ar_user;  // ARUSER
logic                                    axi_ar_valid; // ARVALID
logic                                    axi_ar_ready; // ARREADY
// R (Read Data) channel (Target -> NI)
logic[TIDW-1:0]                    axi_r_id;     // RID
logic[DW-1:0]                       axi_r_data;   // RDATA
logic[1:0]                              axi_r_resp;   // RRESP
logic                                    axi_r_last;   // RLAST
logic[USERW-1:0]                axi_r_user;   // RUSER
logic                                    axi_r_valid;  // RVALID
logic                                    axi_r_ready;   // RREADY

	ahb_to_axi inst_ahb_to_axi
		(
			.HCLK            (HCLK),
			.HADDR           (HADDR),
			.HWDATA          (HWDATA),
			.HWRITE          (HWRITE),
			.HSIZE           (HSIZE),
			.HBURST          (HBURST),
			.HTRANS          (HTRANS),
			.HRESETn         (HRESETn),
			.HREADY          (HREADY),
			.HRDATA          (HRDATA),
			.HRESP           (HRESP),
			.HEXOKAY         (HEXOKAY),
			.axi_aw_id_o     (axi_aw_id),
			.axi_aw_addr_o   (axi_aw_addr),
			.axi_aw_len_o    (axi_aw_len),
			.axi_aw_size_o   (axi_aw_size),
			.axi_aw_burst_o  (axi_aw_burst),
			.axi_aw_lock_o   (axi_aw_lock),
			.axi_aw_cache_o  (axi_aw_cache),
			.axi_aw_prot_o   (axi_aw_prot),
			.axi_aw_qos_o    (axi_aw_qos),
			.axi_aw_region_o (axi_aw_region),
			.axi_aw_user_o   (axi_aw_user),
			.axi_aw_valid_o  (axi_aw_valid),
			.axi_aw_ready_i  (axi_aw_ready),
			.axi_w_id_o      (axi_w_id),
			.axi_w_data_o    (axi_w_data),
			.axi_w_strb_o    (axi_w_strb),
			.axi_w_last_o    (axi_w_last),
			.axi_w_user_o    (axi_w_user),
			.axi_w_valid_o   (axi_w_valid),
			.axi_w_ready_i   (axi_w_ready),
			.axi_b_id_i      (axi_b_id),
			.axi_b_resp_i    (axi_b_resp),
			.axi_b_user_i    (axi_b_user),
			.axi_b_valid_i   (axi_b_valid),
			.axi_b_ready_o   (axi_b_ready),
			.axi_ar_id_o     (axi_ar_id),
			.axi_ar_addr_o   (axi_ar_addr),
			.axi_ar_len_o    (axi_ar_len),
			.axi_ar_size_o   (axi_ar_size),
			.axi_ar_burst_o  (axi_ar_burst),
			.axi_ar_lock_o   (axi_ar_lock),
			.axi_ar_cache_o  (axi_ar_cache),
			.axi_ar_prot_o   (axi_ar_prot),
			.axi_ar_qos_o    (axi_ar_qos),
			.axi_ar_region_o (axi_ar_region),
			.axi_ar_user_o   (axi_ar_user),
			.axi_ar_valid_o  (axi_ar_valid),
			.axi_ar_ready_i  (axi_ar_ready),
			.axi_r_id_i      (axi_r_id),
			.axi_r_data_i    (axi_r_data),
			.axi_r_resp_i    (axi_r_resp),
			.axi_r_last_i    (axi_r_last),
			.axi_r_user_i    (axi_r_user),
			.axi_r_valid_i   (axi_r_valid),
			.axi_r_ready_o   (axi_r_ready)
		);




///////++++++++++++++++++++++
////// Dummy slave
///////++++++++++++++++++++++
always_ff @(posedge HCLK or negedge HRESETn) begin
	if(~HRESETn) begin
		axi_aw_ready<=0;
		axi_w_ready<=0;
	end else begin
		 if(axi_aw_valid==1'b1) begin
		 	axi_aw_ready<=1'b1;
		 end else begin 
		 	axi_aw_ready<=0;
		 end

		 if(axi_w_valid==1'b1) begin
		 	axi_w_ready<=1'b1;
		 	now<=cycle_counter;
		 end else begin 
		 	axi_w_ready<=0;
		 end
		 axi_b_resp<=0;
		 if(cycle_counter==now+3 && cycle_counter>3) begin
		 	axi_b_valid<=1'b1;
		 end else begin 
		 	axi_b_valid<=0;
		 end
	end
end
///////++++++++++++++++++++++
////// END - Dummy slave
///////++++++++++++++++++++++

// parameter int SERVE_RATE    = 100; // Rate at which Slave generates responses
// parameter int ERROR_RATE    = 0;  
// 			axi_slave_tb #(
// 			.DW(DW),
// 			.AW(AW),
// 			.SERVE_RATE(SERVE_RATE),
// 			.ERROR_RATE(ERROR_RATE),
// 			.USERW(USERW)
// 		) inst_axi_slave_tb (
// 			.clk             (clk),
// 			.rst             (rst),
// 			.axi_aw_id_i     (axi_aw_id),
// 			.axi_aw_addr_i   (axi_aw_addr),
// 			.axi_aw_len_i    (axi_aw_len),
// 			.axi_aw_size_i   (axi_aw_size),
// 			.axi_aw_burst_i  (axi_aw_burst),
// 			.axi_aw_lock_i   (axi_aw_lock),
// 			.axi_aw_cache_i  (axi_aw_cache),
// 			.axi_aw_prot_i   (axi_aw_prot),
// 			.axi_aw_qos_i    (axi_aw_qos),
// 			.axi_aw_region_i (axi_aw_region),
// 			.axi_aw_user_i   (axi_aw_user),
// 			.axi_aw_valid_i  (axi_aw_valid),
// 			.axi_aw_ready_o  (axi_aw_ready),
// 			.axi_w_id_i      (axi_w_id),
// 			.axi_w_data_i    (axi_w_data),
// 			.axi_w_strb_i    (axi_w_strb),
// 			.axi_w_last_i    (axi_w_last),
// 			.axi_w_user_i    (axi_w_user),
// 			.axi_w_valid_i   (axi_w_valid),
// 			.axi_w_ready_o   (axi_w_ready),
// 			.axi_b_id_o      (axi_b_id),
// 			.axi_b_resp_o    (axi_b_resp),
// 			.axi_b_user_o    (axi_b_user),
// 			.axi_b_valid_o   (axi_b_valid),
// 			.axi_b_ready_i   (axi_b_ready),
// 			.axi_ar_id_i     (axi_ar_id),
// 			.axi_ar_addr_i   (axi_ar_addr),
// 			.axi_ar_len_i    (axi_ar_len),
// 			.axi_ar_size_i   (axi_ar_size),
// 			.axi_ar_burst_i  (axi_ar_burst),
// 			.axi_ar_lock_i   (axi_ar_lock),
// 			.axi_ar_cache_i  (axi_ar_cache),
// 			.axi_ar_prot_i   (axi_ar_prot),
// 			.axi_ar_qos_i    (axi_ar_qos),
// 			.axi_ar_region_i (axi_ar_region),
// 			.axi_ar_user_i   (axi_ar_user),
// 			.axi_ar_valid_i  (axi_ar_valid),
// 			.axi_ar_ready_o  (axi_ar_ready),
// 			.axi_r_id_o      (axi_r_id),
// 			.axi_r_data_o    (axi_r_data),
// 			.axi_r_resp_o    (axi_r_resp),
// 			.axi_r_last_o    (axi_r_last),
// 			.axi_r_user_o    (axi_r_user),
// 			.axi_r_valid_o   (axi_r_valid),
// 			.axi_r_ready_i   (axi_r_ready)
// 		);



endmodule