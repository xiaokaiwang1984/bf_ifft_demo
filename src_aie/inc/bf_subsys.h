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

#ifndef __BF_SUBSYS_H__
#define __BF_SUBSYS_H__

#include <cardano.h>
#include "include.h"
#include "bf_kernels.h"

using namespace cardano ;


//-------------------------------------
//  Downlink Beamforming
//-------------------------------------
template <int xoff, int yoff> 
class me_bf32L8A : public graph {
private:
  kernel core[4] ;
public:
  port<input> din[4];
  port<input> cin[4];
  port<output> dout;
  
  me_bf32L8A() {
  
	// Create kernels
	core[0] = kernel::create(bf8x8_first) ;
	core[3] = kernel::create(bf8x8_last)  ;
	for(unsigned i=1;i<3;i++) core[i] = kernel::create(bf8x8_mid);
  
	// Define init functions
	initialization_function(core[3]) = "bf8x8_last_init";

	// Make connections for data
	for(unsigned i=0;i<4;i++){
		connect<stream> (din[i], core[i].in[1]);
		connect<window<BF_IN_COEF_BLOCK_SIZE> > (cin[i], core[i].in[0]);
	}
		
	for(unsigned i=1;i<4;i++) connect<cascade>(core[i-1].out[0], core[i].in[2]);
      
    // output bus
    connect<stream> (core[3].out[0], dout);
   
	// Define runtime 
	for(unsigned i=0;i<4;i++) runtime<ratio>(core[i])=0.8;


	// Attach source and header files
	source(core[0])  = "kernels/bf8x8_first.cc" ;
	source(core[3])  = "kernels/bf8x8_last.cc" ;
	for(unsigned i=1;i<3;i++) source(core[i]) = "kernels/bf8x8_mid.cc" ;
	
	for(int i=0;i<4;i++){
		location<kernel>(core[i])=tile(xoff+(yoff&1)*3+(1-(yoff&1)*2)*i, yoff);
		location<stack>(core[i]) =bank(xoff+(yoff&1)*3+(1-(yoff&1)*2)*i, yoff, 2);
		location<buffer>(core[i].in[0])  = {bank(xoff+(yoff&1)*3+(1-(yoff&1)*2)*i, yoff, 0),    bank(xoff+(yoff&1)*3+(1-(yoff&1)*2)*i, yoff, 1)};
	}
	
		

  } ; 

};  // end of Beamforming




//-------------------------------------
//  Uplink Beamforming
//-------------------------------------
template <int xoff, int yoff> 
class me_bf64A8L : public graph {
private:
  kernel core[8] ;
public:
  port<input> din[8];
  port<input> cin[8];
  port<output> dout;
  
  me_bf64A8L() {
  
	// Create kernels
	core[0] = kernel::create(bf8x8_first);
	core[7] = kernel::create(bf8x8_last) ;
	for(unsigned i=1;i<7;i++) core[i] = kernel::create(bf8x8_mid) ;
	
  
	// Define init functions
	initialization_function(core[7]) = "bf8x8_last_init";

	// Make connections for data
	for(unsigned i=0;i<8;i++){
		connect<stream> (din[i], core[i].in[1]);
		connect<window<BF_IN_COEF_BLOCK_SIZE> > (cin[i], core[i].in[0]);
	}
		
	for(unsigned i=1;i<8;i++) connect<cascade>(core[i-1].out[0], core[i].in[2]);
      
    // output bus
    connect<stream> (core[7].out[0], dout);
   
	// Define runtime 
	for(unsigned i=0;i<8;i++) runtime<ratio>(core[i])=0.8;

	// Attach source and header files
	source(core[0])  = "kernels/bf8x8_first.cc" ;
	source(core[7])  = "kernels/bf8x8_last.cc" ;
	for(unsigned i=1;i<7;i++) source(core[i]) = "kernels/bf8x8_mid.cc" ;
	
	//for(unsigned i=0;i<8;i++) utilization(core[i].in[0])=0.5;
	
	for(int i=0;i<8;i++){
		location<kernel>(core[i])=tile(xoff+(yoff&1)*7+(1-(yoff&1)*2)*i, yoff);
		location<stack>(core[i]) =bank(xoff+(yoff&1)*7+(1-(yoff&1)*2)*i, yoff, 2);
		location<buffer>(core[i].in[0])  = {bank(xoff+(yoff&1)*7+(1-(yoff&1)*2)*i, yoff, 0),    bank(xoff+(yoff&1)*7+(1-(yoff&1)*2)*i, yoff, 1)};
	}
	
   
  }; 

} ;  // end of Beamforming



#endif //__BF_SUBSYS_H__
