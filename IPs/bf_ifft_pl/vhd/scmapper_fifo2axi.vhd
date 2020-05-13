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


entity scmapper_fifo2axi is
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
end scmapper_fifo2axi;

architecture rtl of scmapper_fifo2axi is

	--------------------------------------------------------------
	-- Signal Declaration
	--------------------------------------------------------------
	signal s_tvld : std_logic;
	signal s_re   : std_logic;
	signal s_re_d1: std_logic;
	signal rcnt   : std_logic_vector(3 downto 0);
	signal wcnt   : std_logic_vector(3 downto 0);
	
	signal dcntr  : std_logic_vector(3 downto 0);
	signal dcntw  : std_logic_vector(3 downto 0);
	
	signal we_d1  : std_logic;
	signal s_af   : std_logic;
		
	type ram_type is array (15 downto 0) of std_logic_vector (63 downto 0); 
	signal ram : ram_type; 

begin

	-----------------------------------------------
	-- dealing with interface
	-----------------------------------------------
	axi_tvld <= '0' when (srstn='0') or (dcntr=0) else '1';
	-----------------------------------------------
	s_re <= '0' when (srstn='0') or (dcntr=0) else axi_trdy;
	-----------------------------------------------
	axi_tdat <= ram(conv_integer(rcnt));
	-----------------------------------------------
	fifo_af <= s_af;
	-----------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then

			------------------------
			--if (srstn='0') or (dcntr=0) then
			--	s_tvld <= '0';
			--else
			--	s_tvld <= '1';
			--end if;
			
			------------------------
			if (srstn='0') then
				dcntr <= (others=>'0');
			elsif (s_re='1') and (we_d1='0') then
				dcntr <= dcntr-1;
			elsif (s_re='0') and (we_d1='1') then
				dcntr <= dcntr+1;
			end if;
			------------------------
			
			
			
			s_re_d1 <= s_re;
			------------------------
			if (srstn='0') then
				dcntw <= (others=>'0');
			elsif (s_re_d1='1') and (fifo_we='0') then
				dcntw <= dcntw-1;
			elsif (s_re_d1='0') and (fifo_we='1') then
				dcntw <= dcntw+1;
			end if;
			------------------------
			
			
			
			------------------------
			if (srstn='0') then
				rcnt <= (others=>'0');
			elsif (s_re='1') then
				rcnt <= rcnt+1;
			end if;
			------------------------
			
			------------------------
			if (srstn='0') then
				wcnt <= (others=>'0');
			elsif (fifo_we='1') then
				wcnt <= wcnt+1;
			end if;
			------------------------
			
			
			------------------------
			if (fifo_we = '1') then 
				ram(conv_integer(wcnt)) <= fifo_wd; 
			end if;
			------------------------
			we_d1 <= fifo_we;
			------------------------
			
			----------------------------
			-- generate almost full
			----------------------------
			if (srstn='0') or (dcntw(3 downto 2)=0) then
				s_af <= '0';
			elsif dcntw(3)='1' then
				s_af <= '1';
			end if;
			-----------------------------

		end if;
	end process;
	-----------------------------
	
end architecture rtl;
