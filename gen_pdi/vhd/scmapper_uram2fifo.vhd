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


entity scmapper_uram2fifo is
port(
	clk      : IN  STD_LOGIC;
	srstn    : IN  STD_LOGIC;
	start    : IN  STD_LOGIC;
	buf_ra   : OUT STD_LOGIC_VECTOR(12  downto 0);
	buf_rd   : IN  STD_LOGIC_VECTOR(127 downto 0);
	fifo_af  : IN  STD_LOGIC;
	fifo_we  : OUT STD_LOGIC;
	fifo_wd  : OUT STD_LOGIC_VECTOR(63  downto 0);
	done     : OUT STD_LOGIC
);
end scmapper_uram2fifo;

architecture rtl of scmapper_uram2fifo is


	type cst_type is (IDLE, HEAD, DATA, FLUSH, CHEK);
	signal cst, nst: cst_type;
	
	
	--------------------------------------------------------------
	signal cnt : std_logic_vector(9 downto 0); -- 0-1024 for each antenna
	signal seo : std_logic;
	signal fifo_we_shft : std_logic_vector(2 downto 0);
	signal head_done : std_logic;
	signal all_done  : std_logic;
	signal data_done : std_logic;
	signal s_fifo_we_head : std_logic;
	signal s_fifo_wd_head : std_logic_vector(fifo_wd'left downto 0);
	signal phaseid : std_logic_vector(2 downto 0);
	signal cnt_head : std_logic_vector(3 downto 0);
	signal flush_done : std_logic;
	signal flush_cnt  : std_logic_vector(2 downto 0);
	--------------------------------------------------------------
	
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
					if(start='1') then
						cst <= FLUSH;
					end if;
					nst <= DATA;
						
				when FLUSH =>
					if(flush_done='1') then
						cst <= nst;
					end if;

				when HEAD =>
					if head_done='1' then
						cst <= FLUSH;
					end if;
					nst <= CHEK;
				when DATA =>
					if data_done='1' then
						cst <= FLUSH;
					end if;
					nst<=HEAD;
				when CHEK =>
					if all_done='1' then
						cst <= IDLE;
					else
						cst <= DATA;
					end if;
				when others =>
					cst <= IDLE;
				end case;
			end if;
		end if;
	end process;	




	-----------------------------------------------
	-- initialize the memory (8K cycles)
	-----------------------------------------------
	buf_ra <= seo & cnt & phaseid(2 downto 1);
	-----------------------------------------------
	s_fifo_wd_head(s_fifo_wd_head'left downto 2) <= (others=>'0');
	-----------------------------------------------
	data_done <= not fifo_af when cnt=1023 else '0';
	-----------------------------------------------
	all_done <= phaseid(0) and phaseid(1) and phaseid(2);
	-----------------------------------------------
	flush_done <= flush_cnt(flush_cnt'left);
	-----------------------------------------------
	process(clk)
	begin
		if rising_edge(clk) then
		
			if srstn='0' then
				seo <= '1';
			elsif start='1' then
				seo <= not seo;
			end if;
			
			-----------------------------------
			if (srstn='0') or (start='1') then
				phaseid <= (others=>'0');
			elsif (cst=CHEK) then
				phaseid <= phaseid+1;
			end if;
			-----------------------------------
			if not (cst=HEAD) then
				cnt_head <= (others=>'0');
			else
				cnt_head <= cnt_head+1;
			end if;
			-----------------------------------
			if (cnt_head=1) or (cnt_head=2) then -- 2 writes for 128 bits
				s_fifo_we_head <= '1';
			else
				s_fifo_we_head <= '0';
			end if;
			-----------------------------------
			if (cnt_head=1) then
				s_fifo_wd_head(1 downto 0) <= "10";
			else
				s_fifo_wd_head(1 downto 0) <= (others=>'0');
			end if;
			-----------------------------------
			head_done <= cnt_head(3);
			-----------------------------------
		
		
			if (cst=FLUSH) and (fifo_af='0') then
				flush_cnt <= flush_cnt+1;
			else
				flush_cnt <= (others=>'0');
			end if;
		
		
			-- counter ----------
			if not (cst=DATA) then
				cnt <= (others=>'0');
			elsif (fifo_af='0') then
				cnt <= cnt+1;
			end if;
			--------------------
			
			-----------------------------
			-- derive signals from cnt
			-----------------------------
			if (cst=HEAD) then
				fifo_wd <= s_fifo_wd_head;
			elsif phaseid(0)='0' then
				fifo_wd <= buf_rd(95  downto 64) & buf_rd(31 downto 0);
			else
				fifo_wd <= buf_rd(127 downto 96) & buf_rd(63 downto 32);
			end if;
			-----------------------------
			if (cst=DATA) and (fifo_af='0') then
				fifo_we_shft(0) <= '1';
			else
				fifo_we_shft(0) <= '0';
			end if;
			-----------------------------
			
			-----------------------------
			fifo_we_shft(fifo_we_shft'left downto 1) <= fifo_we_shft(fifo_we_shft'left-1 downto 0);
			-----------------------------
			if (cst=HEAD) then
				fifo_we <= s_fifo_we_head;
			else
				fifo_we <= fifo_we_shft(fifo_we_shft'left);
			end if;

			
			---------------------------------
			-- done signal
			---------------------------------
			if (cst=IDLE) then
				done <= '1';
			else
				done <= '0';
			end if;

		end if;
	end process;
	---------------------------------------------------

	
	
end architecture rtl;
