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

#include <cardano.h>
#include "include.h"


void bf8x8_last_init()
{
	set_rnd(rnd_sym_inf);
	set_sat();
};


#ifdef CHESSDE 
// function signature for chessde single core
void bf8x8_last(input_window_cint16  * restrict c_input)
#else
// function signature for Cardano graph
void bf8x8_last(input_window_cint16  * restrict c_input, input_stream_cint16  * x_input,
         input_stream_cacc48 * data_in, output_stream_cint16 * data_out)
#endif		 
{

	// buffer for coefficients
	v16cint16 bufa = undef_v16cint16();
	v16cint16 bufb = undef_v16cint16();
	
	// buffer for data
	v8cint16  dat  = undef_v8cint16();
	
	// accumulator registers
	v4cacc48 acca; // ant 0-3
	v4cacc48 accb; // ant 4-7
	v4cacc48 accc; // ant 0-3
	v4cacc48 accd; // ant 4-7
	
	
	// Loop Through the PRBs
	for (unsigned prbcnt=0; prbcnt<BF_NUM_PRBS; ++prbcnt)
	chess_unroll_loop(BF_NUM_PRBS)
	{
  
		//---------------------------------------
		// Every Loop Deals with Two Subcarriers
		//---------------------------------------
		for (unsigned i=0; i<(BF_PRB_SIZE*6); ++i)
		chess_prepare_for_pipelining
		{
	
			// layer 0/1/2/3
			bufa = upd_w(bufa, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufa = upd_w(bufa, 1, window_read_v8(c_input)); window_incr_v8(c_input, 1);	  
			
			dat = upd_v(dat, 0, READSS0);
			
			acca = mac4(READSCD,bufa, 0, 0x3210, 8, dat, 0,  0x0000, 1); 
			accb = mac4(READSCD,bufa, 4, 0x3210, 8, dat, 0,  0x0000, 1); 
			
			bufb = upd_w(bufb, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufb = upd_w(bufb, 1, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			
			acca = mac4(acca,   bufb, 0, 0x3210, 8, dat, 2,  0x0000, 1); 
			accb = mac4(accb,   bufb, 4, 0x3210, 8, dat, 2,  0x0000, 1); 
			
			bufa = upd_w(bufa, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufa = upd_w(bufa, 1, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			
			// layer 4/5/6/7
			dat = upd_v(dat, 1, READSS0);
			
			acca = mac4(acca, bufa, 0, 0x3210, 8, dat, 4,  0x0000, 1); 
			accb = mac4(accb, bufa, 4, 0x3210, 8, dat, 4,  0x0000, 1); 
			
			bufb = upd_w(bufb, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufb = upd_w(bufb, 1, window_read_v8(c_input)); window_decr_v8(c_input, 7);
			
			acca = mac4(acca, bufb, 0, 0x3210, 8, dat, 6,  0x0000, 1); put_wms(0, srs(acca, BF_SHFT));
			accb = mac4(accb, bufb, 4, 0x3210, 8, dat, 6,  0x0000, 1); put_wms(0, srs(accb, BF_SHFT));
			
			
			bufa = upd_w(bufa, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufa = upd_w(bufa, 1, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			
			// layer 0/1/2/3
			dat = upd_v(dat, 0, READSS0);
			
			accc = mac4(READSCD,bufa, 0, 0x3210, 8, dat, 0,  0x0000, 1); 
			accd = mac4(READSCD,bufa, 4, 0x3210, 8, dat, 0,  0x0000, 1); 
			
			bufb = upd_w(bufb, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufb = upd_w(bufb, 1, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			
			accc = mac4(accc,   bufb, 0, 0x3210, 8, dat, 2,  0x0000, 1); 
			accd = mac4(accd,   bufb, 4, 0x3210, 8, dat, 2,  0x0000, 1); 
			
			bufa = upd_w(bufa, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufa = upd_w(bufa, 1, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			
			// layer 4/5/6/7
			dat = upd_v(dat, 1, READSS0);
			
			accc = mac4(accc, bufa, 0, 0x3210, 8, dat, 4,  0x0000, 1); 
			accd = mac4(accd, bufa, 4, 0x3210, 8, dat, 4,  0x0000, 1); 
			
			bufb = upd_w(bufb, 0, window_read_v8(c_input)); window_incr_v8(c_input, 1);
			bufb = upd_w(bufb, 1, window_read_v8(c_input)); window_decr_v8(c_input, 7);
			
			accc = mac4(accc, bufb, 0, 0x3210, 8, dat, 6,  0x0000, 1); put_wms(0, srs(accc, BF_SHFT));
			accd = mac4(accd, bufb, 4, 0x3210, 8, dat, 6,  0x0000, 1); put_wms(0, srs(accd, BF_SHFT));
			
		}// end of loop for PRB
			
		// move the coefficient pointer to next PRB.
		window_incr_v8(c_input, 8);
		
	}// end of loop through PRBs
  
}// end of function
