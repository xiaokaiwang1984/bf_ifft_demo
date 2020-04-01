-------------------------------------------------------------------------------
--
--  (c) Copyright 2018 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity scmapper is
port(
	clk      : IN  STD_LOGIC;
	srstn    : IN  STD_LOGIC;
	start    : IN  STD_LOGIC;
	axi_trdy : OUT STD_LOGIC;
	axi_tvld : IN  STD_LOGIC;
	axi_tdat : IN  STD_LOGIC_VECTOR(63 downto 0);
	y0_trdy  : IN  STD_LOGIC;
	y0_tvld  : OUT STD_LOGIC;
	y0_tdat  : OUT STD_LOGIC_VECTOR(63 downto 0);
	y1_trdy  : IN  STD_LOGIC;
	y1_tvld  : OUT STD_LOGIC;
	y1_tdat  : OUT STD_LOGIC_VECTOR(63 downto 0)
);
end scmapper;

architecture rtl of scmapper is

	signal buf_we   :  std_logic_vector(3  downto 0);
	signal buf_wa   :  std_logic_vector(12 downto 0);
	signal buf_wd   :  std_logic_vector(63 downto 0);
	signal rd_start :  STD_LOGIC;
	signal rd_done  :  STD_LOGIC_VECTOR(1 downto 0);
	
	signal buf_ra0  : std_logic_vector(12  downto 0);
	signal buf_rd0  : std_logic_vector(127 downto 0);
	signal fifo_af0 : std_logic;
	signal fifo_we0 : std_logic;
	signal fifo_wd0 : std_logic_vector(63  downto 0);
	
	signal buf_ra1  : std_logic_vector(12  downto 0);
	signal buf_rd1  : std_logic_vector(127 downto 0);
	signal fifo_af1 : std_logic;
	signal fifo_we1 : std_logic;
	signal fifo_wd1 : std_logic_vector(63 downto 0);
	


	
	--------------------------------------------------------------
	Component scmapper_axi2uram
	port(
		clk      : IN  STD_LOGIC;
		srstn    : IN  STD_LOGIC;
		start    : IN  STD_LOGIC;
		axi_tvld : IN  STD_LOGIC;
		axi_tdat : IN  STD_LOGIC_VECTOR(63 downto 0);
		axi_trdy : OUT STD_LOGIC;
		buf_we   : OUT STD_LOGIC_VECTOR(3  downto 0);
		buf_wa   : OUT STD_LOGIC_VECTOR(12 downto 0);
		buf_wd   : OUT STD_LOGIC_VECTOR(63 downto 0);
		rd_start : OUT STD_LOGIC;
		rd_done  : IN  STD_LOGIC_VECTOR(1 downto 0)
	);
	end Component;
	--------------------------------------------------------------
	Component scmapper_uram2fifo
	port(
		clk      : IN  STD_LOGIC;
		srstn    : IN  STD_LOGIC;
		start    : IN  STD_LOGIC;
		buf_ra   : OUT STD_LOGIC_VECTOR(12  downto 0);
		buf_rd   : IN  STD_LOGIC_VECTOR(127 downto 0);
		fifo_af  : IN  STD_LOGIC;
		fifo_we  : OUT STD_LOGIC;
		fifo_wd  : OUT STD_LOGIC_VECTOR(63 downto 0);
		done     : OUT STD_LOGIC
	);
	end Component;
	--------------------------------------------------------------
	Component scmapper_fifo2axi
	port(
		clk      : IN  STD_LOGIC;
		srstn    : IN  STD_LOGIC;
		fifo_af  : OUT STD_LOGIC;
		fifo_we  : IN  STD_LOGIC;
		fifo_wd  : IN  STD_LOGIC_VECTOR(63 downto 0);
		axi_trdy : IN  STD_LOGIC;
		axi_tvld : OUT STD_LOGIC;
		axi_tdat : OUT STD_LOGIC_VECTOR(63 downto 0)
	);
	end Component;
	--------------------------------------------------------------
	
	--------------------------------------------------------------
	Component BRAM_DPWR
	generic (
		AWIDTH : INTEGER := 9;
		ADDMAX   : INTEGER := 511;
		DWIDTH : INTEGER := 32); 
	port (
		clk : in std_logic; 
		we  : in std_logic; 
		waddr : in std_logic_vector(AWIDTH-1 downto 0); 
		wdata : in  std_logic_vector(DWIDTH-1 downto 0); 
		raddr : in std_logic_vector(AWIDTH-1 downto 0); 
		rdata : out std_logic_vector(DWIDTH-1 downto 0));
	End Component; 


begin

	
	-------------------------------------------
	-- 2 URAMs for one phase of IFFT
	-------------------------------------------
	URAM0: BRAM_DPWR	generic map(AWIDTH=>13, ADDMAX=>8192, DWIDTH=>64) port map(clk =>clk, we=>buf_we(0), waddr=>buf_wa, wdata=>buf_wd, raddr=>buf_ra0, rdata=>buf_rd0(63  downto 0));
	URAM1: BRAM_DPWR	generic map(AWIDTH=>13, ADDMAX=>8192, DWIDTH=>64) port map(clk =>clk, we=>buf_we(2), waddr=>buf_wa, wdata=>buf_wd, raddr=>buf_ra0, rdata=>buf_rd0(127 downto 64));
	URAM2: BRAM_DPWR	generic map(AWIDTH=>13, ADDMAX=>8192, DWIDTH=>64) port map(clk =>clk, we=>buf_we(1), waddr=>buf_wa, wdata=>buf_wd, raddr=>buf_ra1, rdata=>buf_rd1(63  downto 0));
	URAM3: BRAM_DPWR	generic map(AWIDTH=>13, ADDMAX=>8192, DWIDTH=>64) port map(clk =>clk, we=>buf_we(3), waddr=>buf_wa, wdata=>buf_wd, raddr=>buf_ra1, rdata=>buf_rd1(127 downto 64));
	
	
	-------------------------------------------
	-- Write interface driven by one AXI
	-------------------------------------------
	AXI2URAM: scmapper_axi2uram
	port map(
		clk      =>  clk      ,
		srstn    =>  srstn    ,
		start    =>  start    ,
		axi_tvld =>  axi_tvld  ,
		axi_tdat =>  axi_tdat  ,
		axi_trdy =>  axi_trdy  ,
		buf_we   =>  buf_we    ,
		buf_wa   =>  buf_wa    ,
		buf_wd   =>  buf_wd    ,
		rd_start =>  rd_start  ,
		rd_done  =>  rd_done 
	);
	-------------------------------------------
	-- Need 4 instances of URAM->FIFO
	-------------------------------------------
	URAM2FIFO0: scmapper_uram2fifo port map(clk=>clk,srstn=>srstn,start=>rd_start,buf_ra=>buf_ra0, buf_rd=>buf_rd0,	fifo_af=>fifo_af0, fifo_we=>fifo_we0, fifo_wd=>fifo_wd0, done=>rd_done(0));
	URAM2FIFO1: scmapper_uram2fifo port map(clk=>clk,srstn=>srstn,start=>rd_start,buf_ra=>buf_ra1, buf_rd=>buf_rd1,	fifo_af=>fifo_af1, fifo_we=>fifo_we1, fifo_wd=>fifo_wd1, done=>rd_done(1));
	-------------------------------------------
	-- Need 4 instances of FIFO->AXI
	-------------------------------------------
	FIFO2AXI0: scmapper_fifo2axi port map(clk=>clk,srstn=>srstn,fifo_af=>fifo_af0,fifo_we=>fifo_we0,fifo_wd=>fifo_wd0,axi_trdy=>y0_trdy, axi_tvld=>y0_tvld, axi_tdat=>y0_tdat);
	FIFO2AXI1: scmapper_fifo2axi port map(clk=>clk,srstn=>srstn,fifo_af=>fifo_af1,fifo_we=>fifo_we1,fifo_wd=>fifo_wd1,axi_trdy=>y1_trdy, axi_tvld=>y1_tvld, axi_tdat=>y1_tdat);
	--------------------------------------------------------------
	

end architecture rtl;
