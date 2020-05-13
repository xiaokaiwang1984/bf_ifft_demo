`timescale 1ns / 1ps

module dma_rx
(
 input  wire        srstn,
 input  wire        clk_dma,
 input  wire        start_rx_dma,

 input  wire        m_axi_dma_trdy,
 output wire        m_axi_dma_tvld,
 output wire [63:0]	m_axi_dma_tdat,

 output wire        iffta_dma_axi_trdy,
 input  wire        iffta_dma_axi_tvld,
 input  wire [63:0] iffta_dma_axi_tdat,
 input  wire        iffta_ram_rdy,

 output wire        ifftb_dma_axi_trdy,
 input  wire        ifftb_dma_axi_tvld,
 input  wire [63:0] ifftb_dma_axi_tdat,
 input  wire        ifftb_ram_rdy
);

reg [1:0] sel;
reg [1:0] state;

reg [12:0] counter_a;
reg        done_a;

reg [12:0] counter_b;
reg        done_b;

assign iffta_dma_axi_trdy = m_axi_dma_trdy & (~sel[0]) & sel[1];
assign ifftb_dma_axi_trdy = m_axi_dma_trdy & sel[0] & sel[1];

assign m_axi_dma_tvld = (sel[0])?ifftb_dma_axi_tvld & sel[1]:iffta_dma_axi_tvld & sel[1];
assign m_axi_dma_tdat = (sel[0])?ifftb_dma_axi_tdat:iffta_dma_axi_tdat;

always@(posedge clk_dma)
begin
  if(~srstn)
    begin
      counter_a <= 13'b0;
	  done_a    <= 1'b0;
	end
  else
    begin
	  if(iffta_dma_axi_trdy & iffta_dma_axi_tvld)
	    counter_a <= counter_a + 1'b1;
		
	  if(iffta_dma_axi_trdy && iffta_dma_axi_tvld && (counter_a == 13'b1111111111111))
	    done_a <= 1'b1;
	end
end

always@(posedge clk_dma)
begin
  if(~srstn)
    begin
      counter_b <= 13'b0;
	  done_b    <= 1'b0;
	end
  else
    begin
	  if(ifftb_dma_axi_trdy & ifftb_dma_axi_tvld)
	    counter_b <= counter_b + 1'b1;
		
	  if(ifftb_dma_axi_trdy && ifftb_dma_axi_tvld && (counter_b == 13'b1111111111111))
	    done_b <= 1'b1;
	end
end

always@(posedge clk_dma)
begin
  if(~srstn)
    begin
	  sel   <= 2'b00;
	  state <= 2'b11;
	end
  else
    begin
	  sel <= 2'b00;

	  case(state)
	    2'b11:
		  begin
		    if(iffta_ram_rdy & ifftb_ram_rdy)
			  state <= 2'b00;
		  end
		2'b00:if(start_rx_dma) state <= 2'b01;
		2'b01:
		   begin
		     sel <= 2'b10;
			 if(done_a)
			   begin
			     state <= 2'b10;
				 sel   <= 2'b00;
			   end
		   end
		2'b10:
		  begin
		    sel <= 2'b11;
			if(done_b)
			  begin
			    state <= 2'b11;
				sel   <= 1'b00;
			  end
		  end
		default:state <= 2'b11;
	  endcase
	end
end

endmodule