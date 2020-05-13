`timescale 1ns / 1ps

module axi2ram #
(
 parameter ADDR_WIDTH       = 13,
 parameter DATA_WIDTH       = 64,
 parameter MEMORY_SIZE      = DATA_WIDTH*(2**ADDR_WIDTH)
)
(
 input  wire                    srstn,
 input  wire                    clk,
 input  wire                    we,
 input  wire[ADDR_WIDTH - 1:0]  w_addr,
 input  wire[DATA_WIDTH - 1:0]  w_data,

 input  wire                    clk_dma,
 input  wire                    dma_axi_trdy,
 output reg                     dma_axi_tvld,
 output reg [DATA_WIDTH - 1:0]  dma_axi_tdat,
 output reg                     ram_rdy
);

reg  [1:0]               state;
reg                      write_enable;
reg                      read_enable;

reg  [1:0]               rd_state;
reg                      read_start;
reg  [ADDR_WIDTH - 1:0]  counter;

reg  [2:0]               read_start_d;
reg  [ADDR_WIDTH - 1:0]  ra_addr;
wire [DATA_WIDTH - 1:0]  ra_data_wire;
reg                      wr_en_p;
reg  [DATA_WIDTH - 1:0]  din_p;
reg                      wr_en;
reg  [DATA_WIDTH - 1:0]  din;
reg                      ram_rdy_clk;

wire                    pr_full;
wire                    dma_axi_tvld_wire;
wire [DATA_WIDTH - 1:0] dma_axi_tdat_wire;
reg                     ram_rdy_clkdma_p0;
reg                     ram_rdy_clkdma_p1;


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

always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  state        <= 2'b00;
      write_enable <= 1'b0;
	  read_enable  <= 1'b0;

	  ram_rdy_clk   <= 1'b0;
	end
  else
    begin
      case(state)
	    2'b00:
		  begin 
		    state        <= 2'b01;
			write_enable <= 1'b1;
		  end
		2'b01:
		  begin
		    if(w_addr == {ADDR_WIDTH{1'b1}})
			  begin
			    state        <= 2'b10;
				write_enable <= 1'b0;
				ram_rdy_clk  <= 1'b1;
			  end
		  end
		2'b10:
		  begin
		    read_enable  <= 1'b1;
			 if(counter == {ADDR_WIDTH{1'b1}})
            begin
			     read_enable  <= 1'b0;
              state        <= 2'b11;
            end
		  end
      2'b11:
        begin
          write_enable <= 1'b0;
          read_enable  <= 1'b0;
        end
		default:
		  begin
	        state        <= 2'b11;
           write_enable <= 1'b0;
	        read_enable  <= 1'b0;
		  end
	  endcase
	end
end

always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  rd_state   <= 1'b00;//idle;
	  read_start <= 1'b0;
	  counter    <= {ADDR_WIDTH{1'b0}};
	end
  else
    begin
	  read_start <= 1'b0;
	  
	  case(rd_state)
	    2'b00:
		  begin
		    if(read_enable)
			  begin
			    rd_state   <= 1'b01;//read
				read_start <= 1'b1;
				counter    <= {ADDR_WIDTH{1'b0}};
			  end
		  end
		2'b01:
		  begin
		    if(~pr_full)
			  begin
			    counter    <= counter + 1'b1;
				read_start <= 1'b1;
				
				if(counter == {ADDR_WIDTH{1'b1}})
				  begin
				    rd_state   <= 2'b10;
					read_start <= 1'b0;
				  end
			  end
		  end
		2'b10:rd_state <= 2'b00;
		default:rd_state <= 2'b00;
	  endcase
	end
end

uram_sdp #
(
 .MEMORY_INIT_FILE("none"),
 .ADDR_WIDTH      (ADDR_WIDTH),
 .DATA_WIDTH      (DATA_WIDTH),
 .MEMORY_SIZE     (MEMORY_SIZE)
) spram_inst
(
 .clk     (clk),
 .rst     (~srstn_clk),
 .mem_ena (1'b1),
 .wea     (we & write_enable),
 .w_addr  (w_addr),
 .w_data  (w_data),
 .r_addr  (ra_addr),
 .r_data  (ra_data_wire)
);

always@(posedge clk)
begin
  if(~srstn_clk)
    begin
	  read_start_d  <= 3'b0;
	  ra_addr       <= {ADDR_WIDTH{1'b0}};
	  wr_en_p       <= 1'b0;
	  din_p         <= {DATA_WIDTH{1'b0}};
	  wr_en         <= 1'b0;
	  din           <= {DATA_WIDTH{1'b0}};
	end
  else
    begin
	  read_start_d[0]   <= read_start;
	  read_start_d[2:1] <= read_start_d[1:0];
	  ra_addr           <= counter;
	  
	  wr_en_p           <= read_start_d[2];
	  din_p             <= ra_data_wire;
	  
	  wr_en             <= wr_en_p;
	  din               <= din_p;
	end
end

async_fifo #
(
 .FIFO_DEPTH (32),
 .WFIFO_WIDTH (64),
 .RFIFO_WIDTH (64)
) addr_insta
(
 .rst           (~srstn_clk),
 .wr_clk        (clk),///
 .wr_en         (wr_en),
 .din           (din),
 .rd_clk        (clk_dma),
 .rd_en         (dma_axi_trdy),
 .data_valid    (dma_axi_tvld_wire),
 .dout          (dma_axi_tdat_wire),///
 .empty         (),
 .full          (),
 .almost_empty  (),
 .almost_full   (),
 .overflow      (),
 .underflow     (),
 .prog_full     (pr_full),
 .prog_empty    ()
);

always@(posedge clk_dma)
begin
  if(~srstn)
    begin
	  dma_axi_tvld <= 1'b0;
	  dma_axi_tdat <= {DATA_WIDTH{1'b0}};
	  
	  ram_rdy_clkdma_p0 <= 1'b0;
	  ram_rdy_clkdma_p1 <= 1'b0;
	  ram_rdy           <= 1'b0;
	end
  else
    begin
	  if(dma_axi_trdy)
	    begin
	      dma_axi_tvld <= dma_axi_tvld_wire;
	      dma_axi_tdat <= dma_axi_tdat_wire;
		end
	
	  ram_rdy_clkdma_p0 <= ram_rdy_clk;
	  ram_rdy_clkdma_p1 <= ram_rdy_clkdma_p0;
	  ram_rdy           <= ram_rdy_clkdma_p1;
	end
end

endmodule
