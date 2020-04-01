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

void ifft_4096pt_last_init()
{
    set_rnd(rnd_sym_inf);
    set_sat();
};


#ifdef CHESSDE 
void ifft_4096pt_last(  
	int sizesel,     
    input_window_cint16 * restrict x0,
	input_window_cint16 * restrict x1,
	input_window_cint16 * restrict x2,
	input_window_cint16 * restrict x3
)
#else
void ifft_4096pt_last(       
    input_window_cint16 * restrict x0,
	input_window_cint16 * restrict x1,
	input_window_cint16 * restrict x2,
	input_window_cint16 * restrict x3,
	input_stream_cint16  *fftsel,
	output_stream_cint16 * ya,
	output_stream_cint16 * yb
)
#endif
{
	
	v32cint16 buff = undef_v32cint16();
	const static int16 chess_storage(%chess_alignof(v16int16)) twd[16] = {1, 1, 1, 1, -1, 1, -1, 0, 1, 0, -1, 0, 0, 1, 0, -1};
	v16int16 * coeff_ = (v16int16 *) twd;
	v16int16     coe  = *coeff_;		
	int sizesel = 3&ext_elem(as_v8int16(getc_wss(0)), 0);
	
	
	if (sizesel==0){
		
		for (unsigned l=0; l<(1024/4); ++l)
			chess_prepare_for_pipelining
		{	
			put_wms(0, window_readincr_v4(x0));
			put_wms(1, window_readincr_v4(x1));
				
		}
		
		for (unsigned l=0; l<(1024/4); ++l)
			chess_prepare_for_pipelining
		{

			put_wms(0, window_readincr_v4(x2));
			put_wms(1, window_readincr_v4(x3));
		}
		
		
	}else if (sizesel==1){
		
		
		for (unsigned l=0; l<(1024/16); ++l)
			chess_prepare_for_pipelining
		{
			v8cacc48 acc;
			buff = upd_w(buff, 0, window_readincr_v8(x0));
			buff = upd_w(buff, 1, window_readincr_v8(x1));
			
			acc = mul8(buff, 0, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));
			
			
			acc = mul8(buff, 4, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));	
			

			buff = upd_w(buff, 2, window_readincr_v8(x0));
			buff = upd_w(buff, 3, window_readincr_v8(x1));
			
			acc = mul8(buff, 16, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));
			
			
			acc = mul8(buff, 20, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));
			
			
		}

		for (unsigned l=0; l<(1024/16); ++l)
			chess_prepare_for_pipelining
		{
			v8cacc48 acc;
			buff = upd_w(buff, 0, window_readincr_v8(x2));
			buff = upd_w(buff, 1, window_readincr_v8(x3));
			
			acc = mul8(buff, 0, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));
			
			acc = mul8(buff, 4, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));

			buff = upd_w(buff, 2, window_readincr_v8(x2));
			buff = upd_w(buff, 3, window_readincr_v8(x3));
			
			acc = mul8(buff, 16, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));
			
			acc = mul8(buff, 20, 0x32103210, 8, coe, 1, 0x22220000, 1);
			put_wms(0, srs(ext_lo(acc), 0));
			put_wms(1, srs(ext_hi(acc), 0));
			
		}

		
	}else{
		
		buff = upd_v(buff, 0, window_readincr_v4(x0));
		buff = upd_v(buff, 1, window_readincr_v4(x1));
		buff = upd_v(buff, 2, window_readincr_v4(x2));
		buff = upd_v(buff, 3, window_readincr_v4(x3));	

	
		for (unsigned l=0; l<(1024/8); ++l)
			chess_prepare_for_pipelining
		{
			v4cacc48 acc;
			
			buff = upd_v(buff, 4, window_readincr_v4(x0));	
			acc = mul4(    buff, 0,  0x3210,  4,             coe,  0, 0x0000, 1); put_wms(0, srs(acc, 0)); 
			
			buff = upd_v(buff, 5, window_readincr_v4(x1));	
			acc = mul4(    buff, 0,  0x3210,  8, as_v8cint16(coe), 4, 0x0000, 1);
			
			buff = upd_v(buff, 6, window_readincr_v4(x2));
			acc = mac4(acc,buff, 4,  0x3210,  8, as_v8cint16(coe), 6, 0x0000, 1); put_wms(1, srs(acc, 0));
			buff = upd_v(buff, 7, window_readincr_v4(x3));
			
			
			buff = upd_v(buff, 0, window_readincr_v4(x0));	
			acc = mul4(    buff, 16, 0x3210,  4,             coe,  0, 0x0000, 1); put_wms(0, srs(acc, 0));
			buff = upd_v(buff, 1, window_readincr_v4(x1));
			acc = mul4(    buff, 16, 0x3210,  8, as_v8cint16(coe), 4, 0x0000, 1);			
			buff = upd_v(buff, 2, window_readincr_v4(x2));	
			acc = mac4(acc,buff, 20, 0x3210,  8, as_v8cint16(coe), 6, 0x0000, 1); put_wms(1, srs(acc, 0)); 
			buff = upd_v(buff, 3, window_readincr_v4(x3));

		}
		
		for (unsigned l=0; l<(1024/8); ++l)
			chess_prepare_for_pipelining
		{
			v4cacc48 acc;
			
			buff = upd_v(buff, 4, window_readincr_v4(x0));	
			acc = mul4(    buff, 0,  0x3210,  4,             coe,  3, 0x0000, 1); put_wms(0, srs(acc, 0)); 
			
			buff = upd_v(buff, 5, window_readincr_v4(x1));	
			acc = mul4(    buff, 0,  0x3210,  8, as_v8cint16(coe), 4, 0x0000, 1);
			
			buff = upd_v(buff, 6, window_readincr_v4(x2));
			acc = msc4(acc,buff, 4,  0x3210,  8, as_v8cint16(coe), 6, 0x0000, 1); put_wms(1, srs(acc, 0));
			buff = upd_v(buff, 7, window_readincr_v4(x3));
			
			
			buff = upd_v(buff, 0, window_readincr_v4(x0));	
			acc = mul4(    buff, 16, 0x3210,  4,             coe,  3, 0x0000, 1); put_wms(0, srs(acc, 0));
			
			buff = upd_v(buff, 1, window_readincr_v4(x1));
			acc = mul4(    buff, 16, 0x3210,  8, as_v8cint16(coe), 4, 0x0000, 1);			
			
			buff = upd_v(buff, 2, window_readincr_v4(x2));	
			acc = msc4(acc,buff, 20, 0x3210,  8, as_v8cint16(coe), 6, 0x0000, 1); put_wms(1, srs(acc, 0)); 
			buff = upd_v(buff, 3, window_readincr_v4(x3));

		}
		
		
	}
	
	
}
