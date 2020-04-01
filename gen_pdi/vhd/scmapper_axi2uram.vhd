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


entity scmapper_axi2uram is
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
end scmapper_axi2uram;

architecture rtl of scmapper_axi2uram is


	--------------------------------------------------------------
	--
	--------------------------------------------------------------
	type cst_type is (IDLE, INIT, STRT, AXIS, RLCK, RSTA);
	signal cst: cst_type;
	
	signal init_done : STD_LOGIC;
	signal axis_done : STD_LOGIC;
	signal rlck_done : STD_LOGIC;
	signal cnt_init  : STD_LOGIC_VECTOR(12 downto 0);

	signal s_buf_we_axi: std_logic_vector(3  downto 0);
	signal s_buf_wa_axi: std_logic_vector(12 downto 0);
	signal s_buf_wd_axi: std_logic_vector(63 downto 0);

	signal s_rd_done_d0 : std_logic;
	signal s_rd_done_d1 : std_logic;
	signal s_rd_done    : std_logic;
	
	--signal rcnt    : std_logic_vector(1 downto 0);
	signal s_rdy   : std_logic;
	signal cnt_axi : std_logic_vector(13 downto 0);
	
	signal s_rd_start : std_logic;
	--signal shftcnt    : std_logic_vector(4 downto 0);
	
	
	signal s_buf_we_axi_pre : std_logic;
	signal rd_busy : std_logic;
	--signal s_rd_ready : std_logic;

	
begin

	-----------------------------------------
	-- State Machine
	-----------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
			if(srstn='0') then
				cst <= IDLE;
			else
				case(cst) is
				when IDLE =>
					cst <= INIT;
				when INIT =>
					if(init_done='1') then
						cst <= STRT;
					end if;
				when STRT =>
					if (start='1') then
						cst <= AXIS;
					end if;
				when AXIS =>
					if axis_done='1' then
						cst <= RLCK;
					end if;
				when RLCK =>
					if rd_busy='0' then
						cst <= RSTA;
					end if;
				when RSTA =>
					cst <= STRT;
				when others =>
					cst <= IDLE;
				end case;
			end if;
		end if;
	end process;	
	

	-----------------------------------------------
	-- initialize the memory (8K cycles)
	-----------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
		
			-- counter ----------
			if not (cst=INIT) then
				cnt_init <= (others=>'0');
			else
				cnt_init <= cnt_init+1;
			end if;
			
			
			-- get useful info from cnt ----
			if cnt_init(12 downto 1)=4095 then
				init_done <= '1';
			else
				init_done <= '0';
			end if;
			
			
			---------------------------------------
			-- Muxing the buffer interface
			---------------------------------------
			if (cst=INIT) then
				buf_wa <= cnt_init;
				buf_we <= (others=>'1');
				buf_wd <= (others=>'0');
			else
				buf_wa <= s_buf_wa_axi;
				buf_we <= s_buf_we_axi;
				buf_wd <= s_buf_wd_axi;
			end if;
			---------------------------------------
			
			
			s_rd_done_d0   <= rd_done(0) and rd_done(1);
			s_rd_done_d1   <= s_rd_done_d0;
			s_rd_done      <= s_rd_done_d0 and (not s_rd_done_d1);
			
		end if;
	end process;
	---------------------------------------------------

	
	-----------------------------------------------
	-- axi write processor
	-----------------------------------------------
	-- 273 RBs x 12 subcarriers x 8 antennas / 2 samples per cycle = 13104
	axis_done <= axi_tvld when (cnt_axi=13103) else '0';
	-----------------------------------------------
	axi_trdy <= s_rdy;
	-----------------------------------------------
	s_buf_we_axi_pre <= axi_tvld and s_rdy;
	-------------------------------------	
	process(clk)
	begin
		if rising_edge(clk) then
		
			-- counter for buf write ----------
			if not (cst=AXIS) then
				cnt_axi <= (others=>'0');
			elsif (axi_tvld='1') and (s_rdy='1') then
				cnt_axi <= cnt_axi+1;
			end if;
			-------------------------------------
			if (srstn='0') then
				s_rdy <= '0';
			elsif (cst=AXIS) and (axis_done='0') then
				s_rdy <= '1';
			else
				s_rdy <= '0';
			end if;
			-------------------------------------


			if (cst=RSTA) then
				s_rd_start <= '1';
			else
				s_rd_start <= '0';
			end if;
			
			rd_start <= s_rd_start;
			
			
			-----------------------------------
			if (srstn='0') then
				rd_busy <= '0';
			elsif (s_rd_start='1') then
				rd_busy <= '1';
			elsif s_rd_done='1' then
				rd_busy <= '0';
			end if;
			-----------------------------------
			
			-------------------------------------
			if srstn='0' then
				s_buf_wa_axi(s_buf_wa_axi'left) <= '0';
			elsif (s_rd_start='1') then
				s_buf_wa_axi(s_buf_wa_axi'left) <= not s_buf_wa_axi(s_buf_wa_axi'left);
			end if;
			-------------------------------------
			s_buf_we_axi(0) <= s_buf_we_axi_pre and (    cnt_axi(3)) and (not cnt_axi(2));
			s_buf_we_axi(1) <= s_buf_we_axi_pre and (    cnt_axi(3)) and (    cnt_axi(2));
			s_buf_we_axi(2) <= s_buf_we_axi_pre and (not cnt_axi(3)) and (not cnt_axi(2));
			s_buf_we_axi(3) <= s_buf_we_axi_pre and (not cnt_axi(3)) and (    cnt_axi(2));
			-------------------------------------
			s_buf_wd_axi <= axi_tdat;
			-------------------------------------
			-- first carrier should be written to
			-- 4096 - (273 x 12 /2) = 2458 = 614 x 4 + 2
			--------------------------------------
			if cnt_axi(3)='0' then
				s_buf_wa_axi(s_buf_wa_axi'left-1 downto 2) <= cnt_axi(cnt_axi'left downto 4)+614;
			else
				s_buf_wa_axi(s_buf_wa_axi'left-1 downto 2) <= cnt_axi(cnt_axi'left downto 4)+615;
			end if;
			s_buf_wa_axi(1 downto 0) <= cnt_axi(1 downto 0);
			-------------------------------------
			
		end if;
	end process;
	---------------------------------------------------
	
	
	
	
	
	

end architecture rtl;
