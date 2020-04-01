-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor: Xilinx
-- \   \   \/    Version: 1.0
--  \   \        Filename: $RCSfile: BRAM_DPWR.vhd,v $
--  /   /        Date Last Modified: $Date: 2016/02/25 13:26:08 $
-- /___/   /\    Date Created: 2016/02/15
-- \   \  /  \
--  \___\/\___\
--
-- Device  : All
-- Library : 
-- Purpose : To infer dual port simple block RAM
-------------------------------------------------------------------------------
--
--  (c) Copyright 2009 Xilinx, Inc. All rights reserved.
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Entity BRAM_DPWR is
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
End BRAM_DPWR; 

architecture rtl of BRAM_DPWR is
 
	type ram_type is array (ADDMAX downto 0) of std_logic_vector (DWIDTH-1 downto 0); 
	signal ram : ram_type; 
	
	signal raddr_r : std_logic_vector(AWIDTH-1 downto 0); 
	signal rdata_s : std_logic_vector(DWIDTH-1 downto 0); 

--attribute block_ram : boolean; 
--attribute block_ram of ram : signal is TRUE; 

begin 

	------------------------------------------
	--  Block Memory
	------------------------------------------
	process (clk) 
	begin 
		if (clk'event and clk = '1') then 
			if (we = '1') then 
				ram(conv_integer(waddr)) <= wdata; 
			end if;
			
			-- slow logic to ensure timing
			raddr_r <= raddr;
			rdata_s <= ram(conv_integer(raddr_r));
			rdata   <= rdata_s; 
			
		end if;
	end process;

end rtl;
