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

#ifndef __IFFT_SUBSYS_H__
#define __IFFT_SUBSYS_H__

#include <cardano.h>
#include "ifft_1024pt_graph.h"
#include "transform_kernels.h"

using namespace cardano ;

//-------------------------------------
//  4K IFFT
//-------------------------------------
template <int xoff, int yoff>
class me_ifft4k_3x2: public graph{
  
public:

	port<input>  in[2];
	port<output> out[2];	

	ifft_1024pt_a_graph kiffta;		
	ifft_1024pt_b_graph kifftb;		
	ifft_1024pt_c_graph kifftc;		
	ifft_1024pt_d_graph kifftd;
	ifft_last_graph     kifftz;
	ifft_pktsplit_graph pktsp;
	
    me_ifft4k_3x2(){
		
		connect<>(in[0],   pktsp.in[0]);
		connect<>(in[1],   pktsp.in[1]);
		
		connect<>(pktsp.out[0],   kiffta.in);
		connect<>(pktsp.out[1],   kifftb.in);
		connect<>(pktsp.out[2],   kifftc.in);
		connect<>(pktsp.out[3],   kifftd.in);
		
		connect<>(pktsp.ifftsizesel, kifftz.ifftsizesel);
		connect<>(pktsp.ifftsizesel, kifftb.ifftsizesel);
		connect<>(pktsp.ifftsizesel, kifftc.ifftsizesel);
		connect<>(pktsp.ifftsizesel, kifftd.ifftsizesel);
		
		connect<window<1024*4>>(kiffta.out, kifftz.in[0]);
		connect<window<1024*4>>(kifftb.out, kifftz.in[1]);
		connect<window<1024*4>>(kifftc.out, kifftz.in[2]);
		connect<window<1024*4>>(kifftd.out, kifftz.in[3]);
		
		connect<stream>(kifftz.out[0], out[0]);
		connect<stream>(kifftz.out[1], out[1]);
		
		//location<buffer>(kiffta.ifft.out[0]) =  location<buffer>(kiffta.ifft.in[0]);
		location<buffer>(kifftb.ifft.out[0]) =  location<buffer>(kifftb.ifft.in[0]);
		location<buffer>(kifftc.ifft.out[0]) =  location<buffer>(kifftc.ifft.in[0]);
		location<buffer>(kifftd.ifft.out[0]) =  location<buffer>(kifftd.ifft.in[0]);
		
		
		location<buffer>(kiffta.ifft_lut2)   =  location<buffer>(kiffta.ifft_lut1);
		location<buffer>(kifftb.ifft_lut2)   =  location<buffer>(kifftb.ifft_lut1);
		location<buffer>(kifftc.ifft_lut2)   =  location<buffer>(kifftc.ifft_lut1);
		location<buffer>(kifftd.ifft_lut2)   =  location<buffer>(kifftd.ifft_lut1);
		
		
		//------------- location constraints -------------------
		location<kernel>(pktsp.core)        =  tile(xoff+1-(yoff&1), yoff+2);
		location<stack>(pktsp.core)         =  bank(xoff+(yoff&1),    yoff+2,  3);
		location<buffer>(pktsp.core.out[0]) =  {bank(xoff+1-(yoff&1), yoff+2, 2),  bank(xoff+1-(yoff&1), yoff+2, 3)};
		
		location<kernel>(kifftz.core)        =  tile(xoff+(yoff&1), yoff+1);
		location<stack>(kifftz.core)         =  bank(xoff+(yoff&1), yoff,  3);
		                                                 
                                                       
		location<kernel>(kiffta.ifft)        =  tile(xoff+(yoff&1), yoff);
		location<stack> (kiffta.ifft)        =  bank(xoff+(yoff&1), yoff, 2);
		location<buffer>(kiffta.ifft_lut1)   =  bank(xoff+(yoff&1), yoff, 2);
		location<buffer>(kiffta.ifft_buf1)   =  bank(xoff+(yoff&1), yoff, 0);
		location<buffer>(kiffta.ifft_buf2)   =  bank(xoff+(yoff&1), yoff, 1);
		//location<buffer>(kiffta.ifft.in[0])  = {bank(xoff+(yoff&1), yoff+1, 0),  bank(xoff+(yoff&1), yoff+1, 1)};
		location<buffer>(kiffta.ifft.out[0]) = {bank(xoff+(yoff&1), yoff+1, 0),  bank(xoff+(yoff&1), yoff+1, 1)};
		
        //
		location<kernel>(kifftb.ifft)        =  tile(xoff+(yoff&1), yoff+2);
		location<stack> (kifftb.ifft)        =  bank(xoff+(yoff&1), yoff+2, 2);
		location<buffer>(kifftb.ifft_lut1)   =  bank(xoff+(yoff&1), yoff+2, 2);
		location<buffer>(kifftb.ifft_buf1)   =  bank(xoff+(yoff&1), yoff+1, 2);
		location<buffer>(kifftb.ifft_buf2)   =  bank(xoff+(yoff&1), yoff+1, 3);
		location<buffer>(kifftb.ifft.in[0])  = {bank(xoff+(yoff&1), yoff+2, 0),  bank(xoff+(yoff&1), yoff+2,  1)};
		//
		location<kernel>(kifftc.ifft)        =  tile(xoff+1-(yoff&1),  yoff);
		location<stack> (kifftc.ifft)        =  bank(xoff+1-(yoff&1),  yoff, 2);
		location<buffer>(kifftc.ifft_lut1)   =  bank(xoff+1-(yoff&1),  yoff, 2);
		location<buffer>(kifftc.ifft_buf1)   =  bank(xoff+1-(yoff&1),  yoff, 0);
		location<buffer>(kifftc.ifft_buf2)   =  bank(xoff+1-(yoff&1),  yoff, 1);
		location<buffer>(kifftc.ifft.in[0])  = {bank(xoff+1-(yoff&1),  yoff+1, 0),  bank(xoff+1-(yoff&1), yoff+1,  1)};
		//
		location<kernel>(kifftd.ifft)        =  tile(xoff+1-(yoff&1),  yoff+1);
		location<stack> (kifftd.ifft)        =  bank(xoff+1-(yoff&1),  yoff, 3);
		location<buffer>(kifftd.ifft_lut1)   =  bank(xoff+1-(yoff&1),  yoff, 3);
		location<buffer>(kifftd.ifft_buf1)   =  bank(xoff+1-(yoff&1),  yoff+2, 0);
		location<buffer>(kifftd.ifft_buf2)   =  bank(xoff+1-(yoff&1),  yoff+2, 1);
		location<buffer>(kifftd.ifft.in[0])  = {bank(xoff+1-(yoff&1),  yoff+1, 2),  bank(xoff+1-(yoff&1), yoff+1, 3)};
		
    };
};
	
	




#endif //__IFFT_SUBSYS_H__
