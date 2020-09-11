`timescale 1ns / 1ps

module bf_ifft_pl
(
 ///////////////////////////////////////
 ////////// GPIO ports
 ///////////////////////////////////////
 (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk_dma CLK" *)
 (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF dma_tx:dma_rx" *)
 input wire         clk_dma,

 output wire[9:0]   gpio_output,
 input  wire[2:0]   gpio_input,
 /////////////////////////////////////////////////////
 //// DMA tx
 /////////////////////////////////////////////////////
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dma_tx TREADY" *)
 output wire        s_axi_dma_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dma_tx TVALID" *)
 input  wire        s_axi_dma_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dma_tx TDATA" *)
 input  wire [63:0] s_axi_dma_tdat,

 ////////////////////////////////////////////////////
 ///// DMA rx
 ////////////////////////////////////////////////////
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dma_rx TREADY" *)
 input  wire        m_axi_dma_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dma_rx TVALID" *)
 output wire        m_axi_dma_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 dma_rx TDATA" *)
 output wire [63:0]	m_axi_dma_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk_aie CLK" *)
 (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF din0:din1:din2:din3:cin0:cin1:cin2:cin3:bfo:ifia:ifib:ifoa:ifob,ASSOCIATED_RESET resetn_aie" *)
 input wire         clk,
 //BF stimulas
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din0 TREADY" *)
 input  wire        din0_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din0 TVALID" *)
 output wire        din0_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din0 TDATA" *)
 output wire [63:0]	din0_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din1 TREADY" *)
 input  wire        din1_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din1 TVALID" *)
 output wire        din1_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din1 TDATA" *)
 output wire [63:0]	din1_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din2 TREADY" *)
 input  wire        din2_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din2 TVALID" *)
 output wire        din2_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din2 TDATA" *)
 output wire [63:0]	din2_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din3 TREADY" *)
 input  wire        din3_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din3 TVALID" *)
 output wire        din3_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 din3 TDATA" *)
 output wire [63:0]	din3_axi_tdat,

 //BF coeff input
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin0 TREADY" *)
 input  wire        cin0_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin0 TVALID" *)
 output wire        cin0_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin0 TDATA" *)
 output wire [63:0]	cin0_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin1 TREADY" *)
 input  wire        cin1_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin1 TVALID" *)
 output wire        cin1_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin1 TDATA" *)
 output wire [63:0]	cin1_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin2 TREADY" *)
 input  wire        cin2_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin2 TVALID" *)
 output wire        cin2_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin2 TDATA" *)
 output wire [63:0]	cin2_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin3 TREADY" *)
 input  wire        cin3_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin3 TVALID" *)
 output wire        cin3_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 cin3 TDATA" *)
 output wire [63:0]	cin3_axi_tdat,

 //BF output
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bfo TREADY" *)
 output wire        bfo_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bfo TVALID" *)
 input  wire        bfo_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 bfo TDATA" *)
 input  wire [63:0] bfo_axi_tdat,

 //////////////////////////////////
 //FFT stimulas
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifia TREADY" *)
 input  wire        ifia_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifia TVALID" *)
 output wire        ifia_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifia TDATA" *)
 output wire [63:0] ifia_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifib TREADY" *)
 input  wire        ifib_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifib TVALID" *)
 output wire        ifib_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifib TDATA" *)
 output wire [63:0] ifib_axi_tdat,

 //AIE output of FFT kernel
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifoa TREADY" *)
 output wire        ifoa_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifoa TVALID" *)
 input  wire        ifoa_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifoa TDATA" *)
 input  wire [63:0] ifoa_axi_tdat,

 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifob TREADY" *)
 output wire        ifob_axi_trdy,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifob TVALID" *)
 input  wire        ifob_axi_tvld,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ifob TDATA" *)
 input  wire [63:0] ifob_axi_tdat,

(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 resetn_aie RST" *)
(* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
 input resetn_aie,
 ////////////////////////////////////////
 //Chip Scope of FFT output
 ////////////////////////////////////////
 input wire         clk_scope,
 output reg [15:0]  scope_rdy_vld,

 output reg         scope_a_axi_valid,
 output reg [127:0] scope_a_axi_data,

 output reg         scope_b_axi_valid,
 output reg [127:0] scope_b_axi_data,

 output reg         start_aie
);

//////////////////////////////////
///control signals
//////////////////////////////////
wire       srstn;
wire       startpio;
wire       start_rx_dma;

////////////////////////////////////
////////// Press Button
////////////////////////////////////
reg        startpio_p0;
reg        startpio_p1;
////////////////////////////////////
reg [1:0]  state;
reg        start_pulse;
reg        start_level;

reg        start_pulse_d;
reg        start_level_d;
reg [1:0]  state_d;
reg [9:0]  delay_cnt;

wire[7:0]  bf_stream;
/////////////////////////////////////////////////
///////////  DMA TX splitter
/////////////////////////////////////////////////
wire        din0_dma_axi_trdy;
wire        din0_dma_axi_tvld;
wire[63:0]  din0_dma_axi_tdat;
wire        din0_dma_ram_rdy;

wire        din1_dma_axi_trdy;
wire        din1_dma_axi_tvld;
wire[63:0]  din1_dma_axi_tdat;
wire        din1_dma_ram_rdy;

wire        din2_dma_axi_trdy;
wire        din2_dma_axi_tvld;
wire[63:0]  din2_dma_axi_tdat;
wire        din2_dma_ram_rdy;

wire        din3_dma_axi_trdy;
wire        din3_dma_axi_tvld;
wire[63:0]  din3_dma_axi_tdat;
wire        din3_dma_ram_rdy;

wire        cin0_dma_axi_trdy;
wire        cin0_dma_axi_tvld;
wire[63:0]  cin0_dma_axi_tdat;
wire        cin0_dma_ram_rdy;

wire        cin1_dma_axi_trdy;
wire        cin1_dma_axi_tvld;
wire[63:0]  cin1_dma_axi_tdat;
wire        cin1_dma_ram_rdy;

wire        cin2_dma_axi_trdy;
wire        cin2_dma_axi_tvld;
wire[63:0]  cin2_dma_axi_tdat;
wire        cin2_dma_ram_rdy;

wire        cin3_dma_axi_trdy;
wire        cin3_dma_axi_tvld;
wire[63:0]  cin3_dma_axi_tdat;
wire        cin3_dma_ram_rdy;
//////////////////////////////////////////////
////  DMA aggregator
//////////////////////////////////////////////
wire         iffta_dma_axi_trdy;
wire         iffta_dma_axi_tvld;
wire [63:0]  iffta_dma_axi_tdat;
wire         iffta_ram_rdy;

wire         ifftb_dma_axi_trdy;
wire         ifftb_dma_axi_tvld;
wire [63:0]  ifftb_dma_axi_tdat;
wire         ifftb_ram_rdy;

////////////////////////////////////////////////
///buffer ifft output from AIE 
////////////////////////////////////////////////
reg        wea_p0;
reg [12:0] wa_addr_p0;
reg [63:0] wa_data_p0;

reg        web_p0;
reg [12:0] wb_addr_p0;
reg [63:0] wb_data_p0;

reg        wea_p1;
reg [12:0] wa_addr_p1;
reg [63:0] wa_data_p1;

reg        web_p1;
reg [12:0] wb_addr_p1;
reg [63:0] wb_data_p1;


reg         start_level_to_245;

reg  [7:0]  scope_rdy_vld_p0;
reg  [7:0]  scope_rdy_vld_p1;
wire [15:0] scope_rdy_vld_wire;

wire        scope_a_axi_valid_wire;
wire[127:0] scope_a_axi_data_wire;

wire        scope_b_axi_valid_wire;
wire[127:0] scope_b_axi_data_wire;

////////////////////////////////////////////////////
assign srstn        = gpio_input[0];
assign startpio     = gpio_input[1];
assign start_rx_dma = gpio_input[2];

assign gpio_output  = {din3_dma_ram_rdy,din2_dma_ram_rdy,din1_dma_ram_rdy,din0_dma_ram_rdy,cin3_dma_ram_rdy,cin2_dma_ram_rdy,cin1_dma_ram_rdy,cin0_dma_ram_rdy,ifftb_ram_rdy,iffta_ram_rdy};

reg	    srstn_clk =1'b0;
reg	    srstn_pl1 =1'b0;
reg	    srstn_pl2 =1'b0;



always @ (posedge clk)
	begin
	srstn_pl1	<=gpio_input[0]	;
	srstn_pl2	<=srstn_pl1	;
	srstn_clk	<=srstn_pl2	;
	end



////////////////////////////////////////////////////////////////////////
////// DMA TX
////////////////////////////////////////////////////////////////////////
dma_tx dmatx_inst
(
 .srstn             (srstn),
 .clk_dma           (clk_dma),

 .s_axi_dma_trdy    (s_axi_dma_trdy),
 .s_axi_dma_tvld    (s_axi_dma_tvld),
 .s_axi_dma_tdat    (s_axi_dma_tdat),
 
 .din0_dma_axi_trdy (din0_dma_axi_trdy),
 .din0_dma_axi_tvld (din0_dma_axi_tvld),
 .din0_dma_axi_tdat (din0_dma_axi_tdat),
 .din0_dma_ram_rdy  (din0_dma_ram_rdy),

 .din1_dma_axi_trdy (din1_dma_axi_trdy),
 .din1_dma_axi_tvld (din1_dma_axi_tvld),
 .din1_dma_axi_tdat (din1_dma_axi_tdat),
 .din1_dma_ram_rdy  (din1_dma_ram_rdy),

 .din2_dma_axi_trdy (din2_dma_axi_trdy),
 .din2_dma_axi_tvld (din2_dma_axi_tvld),
 .din2_dma_axi_tdat (din2_dma_axi_tdat),
 .din2_dma_ram_rdy  (din2_dma_ram_rdy),

 .din3_dma_axi_trdy (din3_dma_axi_trdy),
 .din3_dma_axi_tvld (din3_dma_axi_tvld),
 .din3_dma_axi_tdat (din3_dma_axi_tdat),
 .din3_dma_ram_rdy  (din3_dma_ram_rdy),

 .cin0_dma_axi_trdy (cin0_dma_axi_trdy),
 .cin0_dma_axi_tvld (cin0_dma_axi_tvld),
 .cin0_dma_axi_tdat (cin0_dma_axi_tdat),
 .cin0_dma_ram_rdy  (cin0_dma_ram_rdy),

 .cin1_dma_axi_trdy (cin1_dma_axi_trdy),
 .cin1_dma_axi_tvld (cin1_dma_axi_tvld),
 .cin1_dma_axi_tdat (cin1_dma_axi_tdat),
 .cin1_dma_ram_rdy  (cin1_dma_ram_rdy),

 .cin2_dma_axi_trdy (cin2_dma_axi_trdy),
 .cin2_dma_axi_tvld (cin2_dma_axi_tvld),
 .cin2_dma_axi_tdat (cin2_dma_axi_tdat),
 .cin2_dma_ram_rdy  (cin2_dma_ram_rdy),

 .cin3_dma_axi_trdy (cin3_dma_axi_trdy),
 .cin3_dma_axi_tvld (cin3_dma_axi_tvld),
 .cin3_dma_axi_tdat (cin3_dma_axi_tdat),
 .cin3_dma_ram_rdy  (cin3_dma_ram_rdy)
);

////////////////////////////////////////////////
////////////////
////////////////////////////////////////////////
dma_rx dmarx_inst
(
 .srstn              (srstn),
 .clk_dma            (clk_dma),
 .start_rx_dma       (start_rx_dma),

 .m_axi_dma_trdy     (m_axi_dma_trdy),
 .m_axi_dma_tvld     (m_axi_dma_tvld),
 .m_axi_dma_tdat     (m_axi_dma_tdat),

 .iffta_dma_axi_trdy (iffta_dma_axi_trdy),
 .iffta_dma_axi_tvld (iffta_dma_axi_tvld),
 .iffta_dma_axi_tdat (iffta_dma_axi_tdat),
 .iffta_ram_rdy      (iffta_ram_rdy),

 .ifftb_dma_axi_trdy (ifftb_dma_axi_trdy),
 .ifftb_dma_axi_tvld (ifftb_dma_axi_tvld),
 .ifftb_dma_axi_tdat (ifftb_dma_axi_tdat),
 .ifftb_ram_rdy      (ifftb_ram_rdy)
);

/////////////////////////////////////////////
always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  startpio_p0 <= 1'b1;
	  startpio_p1 <= 1'b1;
	  
	  state       <= 2'b00;
	  
	  start_pulse <= 1'b0;
	  start_level <= 1'b0;
	end
  else
    begin
	  startpio_p0 <= ~startpio;
	  startpio_p1 <= startpio_p0;
	  
	  start_pulse <= 1'b0;

	  case(state)
	    2'b00://reset state
		  begin
		    if(~startpio_p0 & startpio_p1)//press button
			  begin
			    state <= 2'b01;
			  end
		  end
		2'b01://zero one state
		  begin
		    if(startpio_p0 & ~startpio_p1)//release button
			  begin
			    state       <= 2'b10;
				start_pulse <= 1'b1;
				start_level <= 1'b1;
			  end
		  end
		2'b10://one zero state
		  begin
		    state <= 2'b11;
		  end
		2'b11:
		  begin
		    if(~startpio_p0 & startpio_p1)//press button
			  begin
			    state       <= 2'b01;
				start_level <= 1'b0;
			  end
		  end
		default:
		  begin
		    state <= 2'b00;
		  end
	  endcase
	end
end

///start pulse for data stream
always@(posedge clk)
begin
  if(~srstn_clk)
    begin
      state_d       <= 2'b00;
      delay_cnt     <= 10'b0;
      start_pulse_d <= 1'b0;
	  start_level_d <= 1'b0;
    end
  else
    begin
      start_pulse_d <= 1'b0;

      case(state_d)
        2'b00://idle state
          begin
            if(start_pulse)
              begin
                delay_cnt <= 10'b0;
                state_d   <= 2'b01;
              end
          end
        2'b01://counting state
          begin
            delay_cnt <= delay_cnt + 1'b1;

            if(delay_cnt == 10'd669)
              state_d <= 2'b10;
          end
         2'b10://pulse state
           begin
             start_pulse_d <= 1'b1;
			 start_level_d <= 1'b1;
             state_d       <= 2'b00;
           end
         default:
           begin
             state_d <= 2'b00;
           end
      endcase
    end
end


ram2axi #
(
 .MEMORY_INIT_FILE ("din0.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (13104),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) din0_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (din0_dma_axi_trdy),
 .dma_axi_tvld    (din0_dma_axi_tvld),
 .dma_axi_tdat    (din0_dma_axi_tdat),
 .ram_rdy         (din0_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse_d),
 .bf_stream       (bf_stream[0]),

 .pl2aie_axi_trdy (din0_axi_trdy),
 .pl2aie_axi_tvld (din0_axi_tvld),
 .pl2aie_axi_tdat (din0_axi_tdat)
);

ram2axi #
(
 .MEMORY_INIT_FILE ("din1.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (13104),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) din1_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (din1_dma_axi_trdy),
 .dma_axi_tvld    (din1_dma_axi_tvld),
 .dma_axi_tdat    (din1_dma_axi_tdat),
 .ram_rdy         (din1_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse_d),
 .bf_stream       (bf_stream[1]),

 .pl2aie_axi_trdy (din1_axi_trdy),
 .pl2aie_axi_tvld (din1_axi_tvld),
 .pl2aie_axi_tdat (din1_axi_tdat)
);

ram2axi #
(
 .MEMORY_INIT_FILE ("din2.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (13104),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) din2_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (din2_dma_axi_trdy),
 .dma_axi_tvld    (din2_dma_axi_tvld),
 .dma_axi_tdat    (din2_dma_axi_tdat),
 .ram_rdy         (din2_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse_d),
 .bf_stream       (bf_stream[2]),

 .pl2aie_axi_trdy (din2_axi_trdy),
 .pl2aie_axi_tvld (din2_axi_tvld),
 .pl2aie_axi_tdat (din2_axi_tdat)
);

ram2axi #
(
 .MEMORY_INIT_FILE ("din3.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (13104),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) din3_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (din3_dma_axi_trdy),
 .dma_axi_tvld    (din3_dma_axi_tvld),
 .dma_axi_tdat    (din3_dma_axi_tdat),
 .ram_rdy         (din3_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse_d),
 .bf_stream       (bf_stream[3]),

 .pl2aie_axi_trdy (din3_axi_trdy),
 .pl2aie_axi_tvld (din3_axi_tvld),
 .pl2aie_axi_tdat (din3_axi_tdat)
);

///////////////////////////////////////////////////////
ram2axi #
(
 .MEMORY_INIT_FILE ("coeff00.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (8736),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) cin0_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (cin0_dma_axi_trdy),
 .dma_axi_tvld    (cin0_dma_axi_tvld),
 .dma_axi_tdat    (cin0_dma_axi_tdat),
 .ram_rdy         (cin0_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse),
 .bf_stream       (bf_stream[4]),

 .pl2aie_axi_trdy (cin0_axi_trdy),
 .pl2aie_axi_tvld (cin0_axi_tvld),
 .pl2aie_axi_tdat (cin0_axi_tdat)
);

ram2axi #
(
 .MEMORY_INIT_FILE ("coeff01.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (8736),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) cin1_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (cin1_dma_axi_trdy),
 .dma_axi_tvld    (cin1_dma_axi_tvld),
 .dma_axi_tdat    (cin1_dma_axi_tdat),
 .ram_rdy         (cin1_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse),
 .bf_stream       (bf_stream[5]),

 .pl2aie_axi_trdy (cin1_axi_trdy),
 .pl2aie_axi_tvld (cin1_axi_tvld),
 .pl2aie_axi_tdat (cin1_axi_tdat)
);


ram2axi #
(
 .MEMORY_INIT_FILE ("coeff02.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (8736),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) cin2_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (cin2_dma_axi_trdy),
 .dma_axi_tvld    (cin2_dma_axi_tvld),
 .dma_axi_tdat    (cin2_dma_axi_tdat),
 .ram_rdy         (cin2_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse),
 .bf_stream       (bf_stream[6]),

 .pl2aie_axi_trdy (cin2_axi_trdy),
 .pl2aie_axi_tvld (cin2_axi_tvld),
 .pl2aie_axi_tdat (cin2_axi_tdat)
);

ram2axi #
(
 .MEMORY_INIT_FILE ("coeff03.mem"),
 .NUM_OF_SYMBOL    (14),
 .DEPTH_OF_SYMBOL  (8736),//13104 for data,8736 for coeff,
 .ADDR_WIDTH       (14),
 .DATA_WIDTH       (64),
 .MEMORY_SIZE      (64*(2**14))
) cin3_inst
(
 .srstn           (srstn),

 .clk_dma         (clk_dma),
 .dma_axi_trdy    (cin3_dma_axi_trdy),
 .dma_axi_tvld    (cin3_dma_axi_tvld),
 .dma_axi_tdat    (cin3_dma_axi_tdat),
 .ram_rdy         (cin3_dma_ram_rdy),

 .clk             (clk),
 .start_pulse     (start_pulse),
 .bf_stream       (bf_stream[7]),

 .pl2aie_axi_trdy (cin3_axi_trdy),
 .pl2aie_axi_tvld (cin3_axi_tvld),
 .pl2aie_axi_tdat (cin3_axi_tdat)
);

///////////////////////////////////////////////////////
//  Subcarrier Mapping
///////////////////////////////////////////////////////
scm_wrapper scm_inst
(
 .clk             (clk),
 .srstn           (srstn_clk),
 .start_level     (start_level),

 .bfo_axi_trdy    (bfo_axi_trdy),
 .bfo_axi_tvld    (bfo_axi_tvld),
 .bfo_axi_tdat    (bfo_axi_tdat),

 .ifia_axi_trdy   (ifia_axi_trdy),
 .ifia_axi_tvld   (ifia_axi_tvld),
 .ifia_axi_tdat   (ifia_axi_tdat),

 .ifib_axi_trdy   (ifib_axi_trdy),
 .ifib_axi_tvld   (ifib_axi_tvld),
 .ifib_axi_tdat   (ifib_axi_tdat)
);

//////////////////////////////////////////////////////////
/////////////ifft output buffer 
//////////////////////////////////////////////////////////
assign ifoa_axi_trdy = start_level;
assign ifob_axi_trdy = start_level;

always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  wea_p0     <= 1'b0;
	  wa_addr_p0 <= 13'b0;
	  wa_data_p0 <= 64'b0;
	  
	  web_p0     <= 1'b0;
	  wb_addr_p0 <= 13'b0;
	  wb_data_p0 <= 64'b0;

	  wea_p1     <= 1'b0;
	  wa_addr_p1 <= 13'b0;
	  wa_data_p1 <= 64'b0;
	  
	  web_p1     <= 1'b0;
	  wb_addr_p1 <= 13'b0;
	  wb_data_p1 <= 64'b0;	  
	end
  else
    begin
	  wea_p0      <= ifoa_axi_trdy & ifoa_axi_tvld;
	  if(ifoa_axi_trdy & ifoa_axi_tvld)
	    wa_addr_p0 <= wa_addr_p0 + 1'b1;
	  wa_data_p0  <= ifoa_axi_tdat;
	  
	  web_p0      <= ifob_axi_trdy & ifob_axi_tvld;
	  if(ifob_axi_trdy & ifob_axi_tvld)
	    wb_addr_p0 <= wb_addr_p0 + 1'b1;
	  wb_data_p0  <= ifob_axi_tdat;
	  
	  wea_p1      <= wea_p0;
     if(wea_p0)
	    wa_addr_p1  <= wa_addr_p0 - 1'b1;
	  wa_data_p1  <= wa_data_p0;

	  web_p1      <= web_p0;
     if(web_p0)
	    wb_addr_p1  <= wb_addr_p0 - 1'b1;
	  wb_data_p1  <= wb_data_p0;
	end
end

axi2ram #
(
 .ADDR_WIDTH(13),
 .DATA_WIDTH(64),
 .MEMORY_SIZE(64*(2**13))
) ifft_a_inst
(
 .srstn         (srstn),
 .clk           (clk),
 .we            (wea_p1),
 .w_addr        (wa_addr_p1),
 .w_data        (wa_data_p1),

 .clk_dma       (clk_dma),
 .dma_axi_trdy  (iffta_dma_axi_trdy),
 .dma_axi_tvld  (iffta_dma_axi_tvld),
 .dma_axi_tdat  (iffta_dma_axi_tdat),
 .ram_rdy       (iffta_ram_rdy)
);


axi2ram #
(
 .ADDR_WIDTH(13),
 .DATA_WIDTH(64),
 .MEMORY_SIZE(64*(2**13))
) ifft_b_inst
(
 .srstn         (srstn),
 .clk           (clk),
 .we            (web_p1),
 .w_addr        (wb_addr_p1),
 .w_data        (wb_data_p1),

 .clk_dma       (clk_dma),
 .dma_axi_trdy  (ifftb_dma_axi_trdy),
 .dma_axi_tvld  (ifftb_dma_axi_tvld),
 .dma_axi_tdat  (ifftb_dma_axi_tdat),
 .ram_rdy       (ifftb_ram_rdy)
);
//////////////////////////////////////////////////////
//// scope interface
//////////////////////////////////////////////////////
async_fifo #
(
 .FIFO_DEPTH  (32),
 .WFIFO_WIDTH (64),
 .RFIFO_WIDTH (128)
) buswidth_fifo_inst0
(
 .rst           (~srstn),
 .wr_clk        (clk),///
 .wr_en         (wea_p1),
 .din           (wa_data_p1),
 .rd_clk        (clk_scope),
 .rd_en         (1'b1),
 .data_valid    (scope_a_axi_valid_wire),
 .dout          (scope_a_axi_data_wire),///
 .empty         (),
 .full          (),
 .almost_empty  (),
 .almost_full   (),
 .overflow      (),
 .underflow     (),
 .prog_full     (),
 .prog_empty    ()
);

async_fifo #
(
 .FIFO_DEPTH  (32),
 .WFIFO_WIDTH (64),
 .RFIFO_WIDTH (128)
) buswidth_fifo_inst1
(
 .rst           (~srstn),
 .wr_clk        (clk),///
 .wr_en         (web_p1),
 .din           (wb_data_p1),
 .rd_clk        (clk_scope),
 .rd_en         (1'b1),
 .data_valid    (scope_b_axi_valid_wire),
 .dout          (scope_b_axi_data_wire),///
 .empty         (),
 .full          (),
 .almost_empty  (),
 .almost_full   (),
 .overflow      (),
 .underflow     (),
 .prog_full     (),
 .prog_empty    ()
);

async_fifo #
(
 .FIFO_DEPTH  (32),
 .WFIFO_WIDTH (8),
 .RFIFO_WIDTH (16)
) rdy_vld_inst
(
 .rst           (~srstn),
 .wr_clk        (clk),///
 .wr_en         (1'b1),
 .din           (scope_rdy_vld_p1),
 .rd_clk        (clk_scope),
 .rd_en         (1'b1),
 .data_valid    (),
 .dout          (scope_rdy_vld_wire),///
 .empty         (),
 .full          (),
 .almost_empty  (),
 .almost_full   (),
 .overflow      (),
 .underflow     (),
 .prog_full     (),
 .prog_empty    ()
);


//generate chip scope output
always@(posedge clk)
begin
  if(~srstn_clk)
    begin
      scope_rdy_vld_p0 <= 8'b0;
      scope_rdy_vld_p1 <= 8'b0;
	end
  else
    begin
      scope_rdy_vld_p0[0] <= ifia_axi_trdy;
      scope_rdy_vld_p0[1] <= ifia_axi_tvld;
      scope_rdy_vld_p0[2] <= ifib_axi_trdy;
      scope_rdy_vld_p0[3] <= ifib_axi_tvld;
      scope_rdy_vld_p0[4] <= ifoa_axi_tvld;
      scope_rdy_vld_p0[5] <= ifob_axi_tvld;
      scope_rdy_vld_p0[6] <= bfo_axi_trdy;
      scope_rdy_vld_p0[7] <= bfo_axi_tvld;

      scope_rdy_vld_p1    <= scope_rdy_vld_p0;
	end
end

always@(posedge clk_scope)
begin
  if(~srstn)
    begin
      scope_rdy_vld        <= 16'b0;
	  //
	  scope_a_axi_valid    <= 1'b0;
	  scope_a_axi_data     <= 128'b0;
	  
	  scope_b_axi_valid    <= 1'b0;
	  scope_b_axi_data     <= 128'b0;

      start_level_to_245   <= 1'b0;
      start_aie            <= 1'b0;
    end
  else
    begin
	  scope_rdy_vld     <= scope_rdy_vld_wire;
	
      scope_a_axi_valid <= scope_a_axi_valid_wire;
      scope_a_axi_data  <= scope_a_axi_data_wire;

      scope_b_axi_valid <= scope_b_axi_valid_wire;
      scope_b_axi_data  <= scope_b_axi_data_wire;

      start_level_to_245 <= | bf_stream;
      start_aie          <= start_level_to_245;
    end
end



endmodule
