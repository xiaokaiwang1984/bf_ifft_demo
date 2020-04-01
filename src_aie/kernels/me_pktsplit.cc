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

#ifdef CHESSDE
void me_pktsplit(output_window_cint16  * restrict outa, output_window_cint16  * restrict outb,
	output_window_cint16  * restrict outc, output_window_cint16  * restrict outd)
#else
void me_pktsplit(input_stream_cint16  *x_input0, input_stream_cint16  *x_input1, 
	output_window_cint16  * restrict outa, output_window_cint16  * restrict outb,
	output_window_cint16  * restrict outc, output_window_cint16  * restrict outd,
	output_stream_cint16  * fftsize)
#endif
{

	v16cint16 da, db;
	v16int16 coe = upd_elem(null_v16int16(), 0, 1);
	
	// fill up da buffer
	da = upd_v(upd_v(undef_v16cint16(), 0, getc_wss(0)), 2, getc_wss(1));
	da = upd_v(upd_v(da, 1, getc_wss(0)), 3, getc_wss(1));
	
	for(unsigned int i=0;i<(1024/8)-1;i++)
		chess_prepare_for_pipelining
	{
		
		window_writeincr(outa, srs(mul4(da, 0, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		window_writeincr(outc, srs(mul4(da, 1, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		db = upd_v(upd_v(undef_v16cint16(), 0, getc_wss(0)), 2, getc_wss(1));
		window_writeincr(outb, srs(mul4(da, 8, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		window_writeincr(outd, srs(mul4(da, 9, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		db = upd_v(upd_v(db, 1, getc_wss(0)), 3, getc_wss(1));

		window_writeincr(outa, srs(mul4(db, 0, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		window_writeincr(outc, srs(mul4(db, 1, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		da = upd_v(upd_v(undef_v16cint16(), 0, getc_wss(0)), 2, getc_wss(1));
		window_writeincr(outb, srs(mul4(db, 8, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		window_writeincr(outd, srs(mul4(db, 9, 0x6420, 1, coe, 0, 0x0000, 1), 0));
		da = upd_v(upd_v(da, 1, getc_wss(0)), 3, getc_wss(1));
	
	}
	
	window_writeincr(outa, srs(mul4(da, 0, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	window_writeincr(outc, srs(mul4(da, 1, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	db = upd_v(upd_v(db, 0, getc_wss(0)), 2, getc_wss(1));
	window_writeincr(outb, srs(mul4(da, 8, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	window_writeincr(outd, srs(mul4(da, 9, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	db = upd_v(upd_v(db, 1, getc_wss(0)), 3, getc_wss(1));

	window_writeincr(outa, srs(mul4(db, 0, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	window_writeincr(outc, srs(mul4(db, 1, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	window_writeincr(outb, srs(mul4(db, 8, 0x6420, 1, coe, 0, 0x0000, 1), 0));
	window_writeincr(outd, srs(mul4(db, 9, 0x6420, 1, coe, 0, 0x0000, 1), 0));

	// output fft size
	put_wms(0, getc_wss(0));
	getc_wss(1);

  
}// end of function


