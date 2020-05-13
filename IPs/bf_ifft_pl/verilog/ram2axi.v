`timescale 1ns / 1ps

module ram2axi #
(
 parameter MEMORY_INIT_FILE = "din0.mem",
 parameter NUM_OF_SYMBOL    = 14,
 parameter DEPTH_OF_SYMBOL  = 13104,//13104 for data,8736 for coeff,
 parameter ADDR_WIDTH       = 14,
 parameter DATA_WIDTH       = 64,
 parameter MEMORY_SIZE      = DATA_WIDTH*(2**ADDR_WIDTH)
)
(
 input  wire                    srstn,

 input  wire                    clk_dma,
 output reg                     dma_axi_trdy,
 input  wire                    dma_axi_tvld,
 input  wire[DATA_WIDTH - 1:0]  dma_axi_tdat,
 output reg                     ram_rdy,

 input  wire                    clk,
 input  wire                    start_pulse,
 output wire                    bf_stream,

 input  wire                    pl2aie_axi_trdy,
 output reg                     pl2aie_axi_tvld,
 output reg [DATA_WIDTH - 1:0]  pl2aie_axi_tdat
);

/////////////////////
reg                    ram_rdy_clkdma_p0;
reg                    ram_rdy_clkdma_p1;
wire                   pr_full;
reg                    wen_fifo_p0;
reg [DATA_WIDTH - 1:0] din_fifo_p0;
reg                    wen_fifo;
reg [DATA_WIDTH - 1:0] din_fifo;
wire                   dv_fifo_wire;
wire[DATA_WIDTH - 1:0] dout_fifo_wire;
reg                    wea_p0;
reg[ADDR_WIDTH - 1:0]  w_addr_p0;
reg[DATA_WIDTH - 1:0]  w_data_p0;
reg                    wea;
reg[ADDR_WIDTH - 1:0]  w_addr;
reg[DATA_WIDTH - 1:0]  w_data;
reg                    ram_rdy_clk;

//RAM read state machine
reg [2:0]              state;
reg [ADDR_WIDTH - 1:0] counter;
reg                    read_start;
reg                    reach_last_symbol;

reg                    bf_stream_on;
reg [7:0]              symbol_cnt;
reg [3:0]              reset_cnt;

reg [3:0]              read_start_d;
reg [ADDR_WIDTH - 1:0] addra_pipe;
reg [ADDR_WIDTH - 1:0] addra;
wire[DATA_WIDTH - 1:0] douta;

reg                    wren_fifo_p;
reg [DATA_WIDTH - 1:0] w_din_p;
reg                    wren_fifo;
reg [DATA_WIDTH - 1:0] w_din;

wire                   prog_full;

wire                   pl2aie_axi_tvld_wire;
wire[DATA_WIDTH - 1:0] pl2aie_axi_tdat_wire;


////////////////////////////////////

reg	    srstn_clk;
reg	    srstn_pl1;
reg	    srstn_pl2;



always @ (posedge clk)
	begin
	srstn_pl1	<=srstn	;
	srstn_pl2	<=srstn_pl1	;
	srstn_clk	<=srstn_pl2	;
	end

////////////////////////////////////
always@(posedge clk_dma)
begin
  if(~srstn)
    begin
	  dma_axi_trdy <= 1'b0;
	  wen_fifo_p0  <= 1'b0;
	  din_fifo_p0  <= {DATA_WIDTH{1'b0}};
	  wen_fifo     <= 1'b0;
	  din_fifo     <= {DATA_WIDTH{1'b0}};
	  
	  ram_rdy_clkdma_p0 <= 1'b0;
	  ram_rdy_clkdma_p1 <= 1'b0;
	  ram_rdy           <= 1'b0;
	end
  else
    begin
	  dma_axi_trdy <= ~pr_full;
	  wen_fifo_p0  <= dma_axi_trdy & dma_axi_tvld;
	  din_fifo_p0  <= dma_axi_tdat;
	  
	  wen_fifo     <= wen_fifo_p0;
	  din_fifo     <= din_fifo_p0;
	  
	  ram_rdy_clkdma_p0 <= ram_rdy_clk;
	  ram_rdy_clkdma_p1 <= ram_rdy_clkdma_p0;
	  ram_rdy           <= ram_rdy_clkdma_p1;
	end
end


async_fifo #
(
 .FIFO_DEPTH  (32),
 .WFIFO_WIDTH (64),
 .RFIFO_WIDTH (64)
) addr_insta
(
 .rst           (~srstn),
 .wr_clk        (clk_dma),
 .wr_en         (wen_fifo),
 .din           (din_fifo),
 .rd_clk        (clk),
 .rd_en         (1'b1),
 .data_valid    (dv_fifo_wire),
 .dout          (dout_fifo_wire),
 .empty         (),
 .full          (),
 .almost_empty  (),
 .almost_full   (),
 .overflow      (),
 .underflow     (),
 .prog_full     (pr_full),
 .prog_empty    ()
);

always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  wea_p0    <= 1'b0;
	  w_addr_p0 <= {ADDR_WIDTH{1'b1}};
	  w_data_p0 <= {DATA_WIDTH{1'b0}};
	  
	  wea       <= 1'b0;
	  w_addr    <= {ADDR_WIDTH{1'b0}};
	  w_data    <= {DATA_WIDTH{1'b0}};
	  
	  ram_rdy_clk <= 1'b0;
	end
  else
    begin
	  wea_p0 <= 1'b0;
	  if(dv_fifo_wire)
	    begin
		  wea_p0 <= 1'b1;
		  w_addr_p0 <= w_addr_p0 + 1'b1;
		end
      w_data_p0 <= dout_fifo_wire;
	  
	  wea    <= wea_p0;
	  w_addr <= w_addr_p0;
	  w_data <= w_data_p0;
	  
	  if(w_addr_p0 == DEPTH_OF_SYMBOL - 1)
	    ram_rdy_clk <= 1'b1;
	end
end

////////RAM READ State Machine
always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  state             <= 3'b000;//idle state
	  counter           <= {ADDR_WIDTH{1'b0}};
	  read_start        <= 1'b0;
	  reach_last_symbol <= 1'b0;

	  bf_stream_on      <= 1'b0;
	  symbol_cnt        <= 8'b0;
	  reset_cnt         <= 4'b0;
	end
  else
    begin
	  read_start <= 1'b0;

	  case(state)
	    3'b000://idle
		  begin
		    if(start_pulse)
			  begin
			    state             <= 3'b001;//read

				counter           <= {ADDR_WIDTH{1'b0}};
				read_start        <= 1'b1;
				reach_last_symbol <= 1'b0;
				
				bf_stream_on      <= 1'b1;
				symbol_cnt        <= 8'b0;
			  end
		  end
		3'b001://read
		  begin
			if(~prog_full)
			  begin
			    counter    <= counter + 1'b1;
				read_start <= 1'b1;
			  
			    if(counter[13:0] == DEPTH_OF_SYMBOL-3)
				  begin
				    state <= 3'b010;//reach last-1
					
					if(symbol_cnt == NUM_OF_SYMBOL -1)
					  reach_last_symbol <= 1'b1;
				  end
			  end
		  end
		3'b010://last - 1
		  begin
			if(~prog_full)
			  begin
			    counter <= counter + 1'b1;

			    if(reach_last_symbol)
				  state <= 3'b100;//last and end
				else
				  state <= 3'b011;//last

				read_start <= 1'b1;
			  end
		  end
		3'b011://last
		  begin
			if(~prog_full)
			  begin
			    //counter    <= counter + 1'b1;//
			    counter    <= {ADDR_WIDTH{1'b0}};
			    state      <= 3'b001;//read
				read_start <= 1'b1;
				
				symbol_cnt <= symbol_cnt + 1'b1;
			  end
		  end
		3'b100://last and end
		  begin
		    reset_cnt    <= 4'b0;
			state        <= 3'b101;
			bf_stream_on <= 1'b0;

		  end
		3'b101://wait fifo empty
		  begin
		    reset_cnt <= reset_cnt + 1'b1;
		    if(reset_cnt == 4'b1111)
			  begin
			    state <= 3'b110;
			  end
		  end
		3'b110://wait for new start pulse
		  begin
			if(start_pulse)
			  begin
			    state             <= 3'b001;//read

				counter           <= {ADDR_WIDTH{1'b0}};
				reach_last_symbol <= 1'b0;
				read_start        <= 1'b1;

				bf_stream_on      <= 1'b1;
				symbol_cnt        <= 8'b0;
			  end
		  end
		default:
		  begin
		    state        <= 3'b000;//idle
            bf_stream_on <= 1'b0;
		  end
	  endcase
	end
end

////
assign bf_stream = bf_stream_on;


always@(posedge clk)
begin
  if(~srstn_clk)
    begin
      read_start_d <= 4'b0;
      addra_pipe   <= {ADDR_WIDTH{1'b0}};
	  addra        <= {ADDR_WIDTH{1'b0}};

	  wren_fifo_p  <= 1'b0;
	  w_din_p      <= {DATA_WIDTH{1'b0}};

      wren_fifo    <= 1'b0;
      w_din        <= {DATA_WIDTH{1'b0}};
	end
  else
    begin
	  read_start_d[0]   <= read_start;
	  read_start_d[3:1] <= read_start_d[2:0];
	  addra_pipe        <= counter;
      addra             <= addra_pipe;

	  wren_fifo_p       <= read_start_d[3];
	  w_din_p           <= douta;

      wren_fifo         <= wren_fifo_p;
      w_din             <= w_din_p;
	end
end

uram_sdp #
(
 .MEMORY_INIT_FILE(MEMORY_INIT_FILE),
 .ADDR_WIDTH      (ADDR_WIDTH),
 .DATA_WIDTH      (DATA_WIDTH),
 .MEMORY_SIZE     (MEMORY_SIZE)
) spram_u
(
 .clk     (clk),
 .rst     (~srstn_clk),
 .mem_ena (1'b1),
 .wea     (wea),
 .w_addr  (w_addr),
 .w_data  (w_data),
 .r_addr  (addra),
 .r_data  (douta)
);

sync_fifo #
(
// .FIFO_DEPTH(16),
 .FIFO_DEPTH(32),
 .FIFO_WIDTH(64)
) fifo_inst
(
 .rst           (~srstn_clk),
 .wr_clk        (clk),
 .wr_en         (wren_fifo),
 .din           (w_din),
 .rd_en         (pl2aie_axi_trdy),
 .data_valid    (pl2aie_axi_tvld_wire),
 .dout          (pl2aie_axi_tdat_wire),
 .empty         (),
 .full          (),
 .almost_empty  (),
 .almost_full   (),
 .overflow      (),
 .underflow     (),
 .prog_full     (prog_full),
 .prog_empty    ()
);

always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  pl2aie_axi_tvld <= 1'b0;
	  pl2aie_axi_tdat <= {DATA_WIDTH{1'b0}};
	end
  else
    begin
	  if(pl2aie_axi_trdy)
	    begin
	      pl2aie_axi_tvld <= pl2aie_axi_tvld_wire;
	      pl2aie_axi_tdat <= pl2aie_axi_tdat_wire;
		end
	end
end

endmodule
