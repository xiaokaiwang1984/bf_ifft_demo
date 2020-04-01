`timescale 1ns / 1ps

module scm_wrapper
(
 input wire         clk,
 input wire         srstn,
 input wire         start_level,

 output wire        bfo_axi_trdy,
 input  wire        bfo_axi_tvld,
 input  wire [63:0] bfo_axi_tdat,

 input  wire        ifia_axi_trdy,
 output wire        ifia_axi_tvld,
 output wire [63:0] ifia_axi_tdat,

 input  wire        ifib_axi_trdy,
 output wire        ifib_axi_tvld,
 output wire [63:0] ifib_axi_tdat
);

scmapper scm_u0
(
 .clk      (clk),
 .srstn    (srstn),
 .start    (start_level),
 .axi_trdy (bfo_axi_trdy),
 .axi_tvld (bfo_axi_tvld),
 .axi_tdat (bfo_axi_tdat),
 .y0_trdy  (ifia_axi_trdy),
 .y0_tvld  (ifia_axi_tvld),
 .y0_tdat  (ifia_axi_tdat),
 .y1_trdy  (ifib_axi_trdy),
 .y1_tvld  (ifib_axi_tvld),
 .y1_tdat  (ifib_axi_tdat)
);


endmodule
