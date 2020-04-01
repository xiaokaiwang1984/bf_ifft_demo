/*  (c) Copyright 2014 - 2019 Xilinx, Inc. All rights reserved.
   
    This file contains confidential and proprietary information
    of Xilinx, Inc. and is protected under U.S. and
    international copyright and other intellectual property
    laws.
   
    DISCLAIMER
    This disclaimer is not a license and does not grant any
    rights to the materials distributed herewith. Except as
    otherwise provided in a valid license issued to you by
    Xilinx, and to the maximum extent permitted by applicable
    law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
    WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
    AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
    BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
    INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
    (2) Xilinx shall not be liable (whether in contract or tort,
    including negligence, or under any other theory of
    liability) for any loss or damage of any kind or nature
    related to, arising under or in connection with these
    materials, including for any direct, or any indirect,
    special, incidental, or consequential loss or damage
    (including loss of data, profits, goodwill, or any type of
    loss or damage suffered as a result of any action brought
    by a third party) even if such damage or loss was
    reasonably foreseeable or Xilinx had been advised of the
    possibility of the same.
   
    CRITICAL APPLICATIONS
    Xilinx products are not designed or intended to be fail-
    safe, or for use in any application requiring fail-safe
    performance, such as life-support or safety devices or
    systems, Class III medical devices, nuclear facilities,
    applications related to the deployment of airbags, or any
    other applications that could lead to death, personal
    injury, or severe property or environmental damage
    (individually and collectively, "Critical
    Applications"). Customer assumes the sole risk and
    liability of any use of Xilinx products in Critical
    Applications, subject only to applicable laws and
    regulations governing limitations on product liability.
   
    THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
    PART OF THIS FILE AT ALL TIMES.                       */

#include "test_dl8a.h"

PLIO *attr_i_d0 = new PLIO("d0", plio_64_bits, "data/din0.txt");
PLIO *attr_i_d1 = new PLIO("d1", plio_64_bits, "data/din1.txt");
PLIO *attr_i_d2 = new PLIO("d2", plio_64_bits, "data/din2.txt");
PLIO *attr_i_d3 = new PLIO("d3", plio_64_bits, "data/din3.txt");

PLIO *attr_i_c0 = new PLIO("c0", plio_64_bits, "data/coeff00.txt");
PLIO *attr_i_c1 = new PLIO("c1", plio_64_bits, "data/coeff01.txt");
PLIO *attr_i_c2 = new PLIO("c2", plio_64_bits, "data/coeff02.txt");
PLIO *attr_i_c3 = new PLIO("c3", plio_64_bits, "data/coeff03.txt");

PLIO *attr_i_ifi0a = new PLIO("ifi0a", plio_64_bits, "data/ifft_in00.txt");
PLIO *attr_i_ifi0b = new PLIO("ifi0b", plio_64_bits, "data/ifft_in01.txt");

PLIO *attr_o_bf0   = new PLIO("bfo0",  plio_64_bits, "data/out0.txt");
PLIO *attr_o_ifo0a = new PLIO("ifo0a", plio_64_bits, "data/ifft_out00.txt");
PLIO *attr_o_ifo0b = new PLIO("ifo0b", plio_64_bits, "data/ifft_out01.txt");



testcase::sim_platform platform(
   attr_i_d0,   attr_i_d1,  attr_i_d2,   attr_i_d3,
	attr_i_c0,   attr_i_c1,  attr_i_c2,   attr_i_c3,
	attr_i_ifi0a, attr_i_ifi0b,
	attr_o_bf0,
	attr_o_ifo0a, attr_o_ifo0b
);

testcase::TEST_DL8A dut;

//--------------- Beamforming ------------------
connect<> netd0(platform.src[0], dut.din[0]);
connect<> netd1(platform.src[1], dut.din[1]);
connect<> netd2(platform.src[2], dut.din[2]);
connect<> netd3(platform.src[3], dut.din[3]);
connect<> netc0(platform.src[4], dut.cin[0]);
connect<> netc1(platform.src[5], dut.cin[1]);
connect<> netc2(platform.src[6], dut.cin[2]);
connect<> netc3(platform.src[7], dut.cin[3]);
//
connect<> netbfout10a(dut.bfout,  platform.sink[ 0]);

//--------------- IFFT -------------------------
connect<> i00(platform.src[8] , dut.ifftin[0]  );
connect<> i01(platform.src[9] , dut.ifftin[1]  );
connect<> y00(dut.ifftout[0],   platform.sink[1]);
connect<> y01(dut.ifftout[1],   platform.sink[2]);
//-----------------------------------------------



int main(void) {
	dut.init();
    dut.run() ;
	dut.end() ;
    return 0 ;
}

