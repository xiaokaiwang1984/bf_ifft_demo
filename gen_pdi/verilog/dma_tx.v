`timescale 1ns / 1ps

module dma_tx
(
 input  wire        srstn,
 input  wire        clk_dma,

 output wire        s_axi_dma_trdy,
 input  wire        s_axi_dma_tvld,
 input  wire [63:0] s_axi_dma_tdat,
 
 input  wire        din0_dma_axi_trdy,
 output wire        din0_dma_axi_tvld,
 output wire[63:0]  din0_dma_axi_tdat,
 input  wire        din0_dma_ram_rdy,

 input  wire        din1_dma_axi_trdy,
 output wire        din1_dma_axi_tvld,
 output wire[63:0]  din1_dma_axi_tdat,
 input  wire        din1_dma_ram_rdy,

 input  wire        din2_dma_axi_trdy,
 output wire        din2_dma_axi_tvld,
 output wire[63:0]  din2_dma_axi_tdat,
 input  wire        din2_dma_ram_rdy,

 input  wire        din3_dma_axi_trdy,
 output wire        din3_dma_axi_tvld,
 output wire[63:0]  din3_dma_axi_tdat,
 input  wire        din3_dma_ram_rdy,

 input  wire        cin0_dma_axi_trdy,
 output wire        cin0_dma_axi_tvld,
 output wire[63:0]  cin0_dma_axi_tdat,
 input  wire        cin0_dma_ram_rdy,

 input  wire        cin1_dma_axi_trdy,
 output wire        cin1_dma_axi_tvld,
 output wire[63:0]  cin1_dma_axi_tdat,
 input  wire        cin1_dma_ram_rdy,

 input  wire        cin2_dma_axi_trdy,
 output wire        cin2_dma_axi_tvld,
 output wire[63:0]  cin2_dma_axi_tdat,
 input  wire        cin2_dma_ram_rdy,

 input  wire        cin3_dma_axi_trdy,
 output wire        cin3_dma_axi_tvld,
 output wire[63:0]  cin3_dma_axi_tdat,
 input  wire        cin3_dma_ram_rdy
);

reg [3:0] state;
reg [7:0] sel;

always@(posedge clk_dma)
begin
  if(~srstn)
    begin
	  sel   <= 8'b0;

	  state <= 4'b1111;
	end
  else
    begin
	  sel <= 8'b0;
	  
      case(state)
	    4'b1111:
		  begin
		    if(~(din0_dma_ram_rdy|din1_dma_ram_rdy|din2_dma_ram_rdy|din3_dma_ram_rdy|cin0_dma_ram_rdy|cin1_dma_ram_rdy|cin2_dma_ram_rdy|cin3_dma_ram_rdy))
			  state <= 4'b0000;
		  end
		4'b0000:
		  begin
		    if(din0_dma_ram_rdy)
			  state <= 4'b0001;

			sel[0] <= 1'b1;
		  end
		4'b0001:
		  begin
		    if(din1_dma_ram_rdy)
			  state <= 4'b0010;

			sel[1] <= 1'b1;
		  end
		4'b0010:
		  begin
		    if(din2_dma_ram_rdy)
			  state <= 4'b0011;

			sel[2] <= 1'b1;
		  end
		4'b0011:
		  begin
		    if(din3_dma_ram_rdy)
			  state <= 4'b0100;

			sel[3] <= 1'b1;
		  end
		4'b0100:
		  begin
		    if(cin0_dma_ram_rdy)
			  state <= 4'b0101;

			sel[4] <= 1'b1;
		  end
		4'b0101:
		  begin
		    if(cin1_dma_ram_rdy)
			  state <= 4'b0110;

			sel[5] <= 1'b1;
		  end
		4'b0110:
		  begin
		    if(cin2_dma_ram_rdy)
			  state <= 4'b0111;

			sel[6] <= 1'b1;
		  end
		4'b0111:
		  begin
		    if(cin3_dma_ram_rdy)
			  state <= 4'b1111;

			sel[7] <= 1'b1;
		  end
		default:
		  begin
		    state <= 4'b1111;
		  end
	  endcase
	end
end

assign s_axi_dma_trdy = din0_dma_axi_trdy & sel[0] | din1_dma_axi_trdy & sel[1] | din2_dma_axi_trdy & sel[2] | din3_dma_axi_trdy & sel[3] | cin0_dma_axi_trdy & sel[4] | cin1_dma_axi_trdy & sel[5] | cin2_dma_axi_trdy & sel[6] | cin3_dma_axi_trdy & sel[7];

assign din0_dma_axi_tvld = sel[0] & s_axi_dma_tvld;
assign din0_dma_axi_tdat = s_axi_dma_tdat;

assign din1_dma_axi_tvld = sel[1] & s_axi_dma_tvld;
assign din1_dma_axi_tdat = s_axi_dma_tdat;

assign din2_dma_axi_tvld = sel[2] & s_axi_dma_tvld;
assign din2_dma_axi_tdat = s_axi_dma_tdat;

assign din3_dma_axi_tvld = sel[3] & s_axi_dma_tvld;
assign din3_dma_axi_tdat = s_axi_dma_tdat;

assign cin0_dma_axi_tvld = sel[4] & s_axi_dma_tvld;
assign cin0_dma_axi_tdat = s_axi_dma_tdat;

assign cin1_dma_axi_tvld = sel[5] & s_axi_dma_tvld;
assign cin1_dma_axi_tdat = s_axi_dma_tdat;

assign cin2_dma_axi_tvld = sel[6] & s_axi_dma_tvld;
assign cin2_dma_axi_tdat = s_axi_dma_tdat;

assign cin3_dma_axi_tvld = sel[7] & s_axi_dma_tvld;
assign cin3_dma_axi_tdat = s_axi_dma_tdat;

endmodule