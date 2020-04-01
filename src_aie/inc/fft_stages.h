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


#ifndef __FFT_STAGES_H__
#define __FFT_STAGES_H__	

//#include <cardano.h>
//typdef unsigned short umod_t 

// -------------------------------------------------------------
// Radix 2
// -------------------------------------------------------------
//radix2 16bit to 32bit
INLINE_DECL void stage0_radix2_up_dit( cint16_t * restrict x, 
                                    cint16_t * restrict tw, 
                                    unsigned int n, unsigned int r, unsigned int shift, 
                                    cint32_t * restrict y )
{
	set_rdx(2);
	const int upsft = FFT_UPSHIFT1;

	v4cint32 * restrict po1 = (v4cint32 * restrict) y; 
	v4cint32 * restrict po2 = (v4cint32 * restrict) (y+n/2); 
	v8cint16 * restrict pi1 = (v8cint16 * restrict) x;
	v8cint16 * restrict pi2 = (v8cint16 * restrict) (x+  r); 
	v8cint16 * restrict px1 = (v8cint16 * restrict) (x+  r); 
	v8cint16 * restrict px2 = (v8cint16 * restrict) (x+2*r); 
	v8cint16 * restrict ptw = (v8cint16 * restrict) tw;

	int zoffs = 0x00000000;   
	umod_t cnt1 = 0, cnt2 = 0;

	for (unsigned int j = 0; j < n/16; ++j)
		chess_prepare_for_pipelining
		chess_loop_range(1,)
	{
		v8cint16 chess_storage(WD) xbuf = *pi1;  

		v16cint16 ybuf = undef_v16cint16();
		ybuf = upd_w(ybuf, 0, *pi2); 

		v8cint16 zbuf = *ptw;

		v8cacc48 chess_storage(bm1) o0 = mac8(ups(xbuf,upsft), ybuf,0,0x76543210, zbuf,0,zoffs);
		*po1++ = lsrs(ext_lo(o0),shift);
		*po1++ = lsrs(ext_hi(o0),shift);
		v8cacc48 chess_storage(bm0) o1 = msc8(ups(xbuf,upsft), ybuf,0,0x76543210, zbuf,0,zoffs); 


		*po2++ = lsrs(ext_lo(o1),shift);
		*po2++ = lsrs(ext_hi(o1),shift);    

		pi1   = fft_data_incr(pi1,r/8,px1,cnt1);
		pi2   = fft_data_incr(pi2,r/8,px2,cnt2); 
		ptw   = fft_twiddle_incr(ptw,cnt2,3);
		zoffs = fft_zoffs(cnt1,3,1,1);
	}
}

//radix2 32bit to 32bit
INLINE_DECL void stage0_radix2_dit( cint32_t * restrict x, 
                                    cint16_t * restrict tw, 
                                    unsigned int n, unsigned int r, unsigned int shift, 
                                    cint32_t * restrict y, bool inv )
{
  set_rdx(2);

  v4cint32 * restrict po1 = (v4cint32 * restrict) y;
  v4cint32 * restrict po2 = (v4cint32 * restrict) (y + n/2); 
  v4cint32 * restrict pi1 = (v4cint32 * restrict) x;  
  v4cint32 * restrict pi2 = (v4cint32 * restrict) (x+r);  
  v4cint32 * restrict px1 = (v4cint32 * restrict) (x+r);  
  v4cint32 * restrict px2 = (v4cint32 * restrict) (x+2*r);  
  v8cint16 * restrict ptw = (v8cint16 * restrict) tw;
  
  umod_t cnt1 = 0, cnt2 = 0;

  for (unsigned int j = 0; j < n/8; ++j)
    chess_prepare_for_pipelining
    chess_loop_range(1,)
  {
    v8cint32 chess_storage(XA) xbuf = undef_v8cint32();
    xbuf = upd_w(xbuf, 0, pi1[0]);
    xbuf = upd_w(xbuf, 1, pi2[0]);
    
    int zoffs = fft_zoffs(cnt2,3,1,0);    

    v8cacc48 o = butterfly_dit(xbuf,undef_v8cint32(),0x3210,0x7654,ptw[0],0,zoffs,inv,15);
    *po1++ = lsrs(ext_lo(o),shift);
    *po2++ = lsrs(ext_hi(o),shift);     
    
    pi1   = fft_data_incr(pi1,r/4,px1,cnt1);
    pi2   = fft_data_incr(pi2,r/4,px2,cnt2); 
    ptw   = fft_twiddle_incr(ptw,cnt1,3);
  }
}

INLINE_DECL void stage1_radix2_dit ( cint32_t * restrict x, 
                                     cint16_t * restrict tw, 
                                     unsigned int n, unsigned int shift, 
                                     cint32_t * restrict y, bool inv)
{
  set_rdx(2);

  v4cint32 * restrict po1 = (v4cint32 * restrict) y;
  v4cint32 * restrict po2 = (v4cint32 * restrict) (y + n/2);  
  v4cint32 * restrict pi1 = (v4cint32 * restrict) x;  
  v4cint32 * restrict pi2 = (v4cint32 * restrict) (x+4);  
  v4cint32 * restrict px1 = (v4cint32 * restrict) (x+4);  
  v8cint16 * restrict ptw = (v8cint16 * restrict) tw;
     
  int zoffs = 0x1100;
  umod_t cnt = 0;

  for (unsigned int j = 0; j < n/8; ++j)
    chess_prepare_for_pipelining
    chess_loop_range(1,)
  {
    v8cint32 chess_storage(xa) xbuf = undef_v8cint32();
    xbuf = upd_w(xbuf,0,pi1[0]);
    xbuf = upd_w(xbuf,1,pi2[0]);
    
    v8cacc48 o = butterfly_dit(xbuf,undef_v8cint32(),0x5410,0x7632,ptw[0],0,zoffs,inv,15);
    *po1++ = lsrs(ext_lo(o),shift);
    *po2++ = lsrs(ext_hi(o),shift); 
        
    pi1   = fft_data_incr(pi1,1,px1,cnt);    
    pi2  += 2;
    ptw   = fft_twiddle_incr(ptw,cnt,2);    
    zoffs = fft_zoffs(cnt,2,1,0);    
  }
}

//radix2 32bit to 16bit
INLINE_DECL void stage2_radix2_down_dit ( cint32_t * x, 
                                     cint16_t * tw,
                                     unsigned int n, unsigned int output_shift, 
                                     cint16_t * restrict y, bool inv)
{
  v4cint16 * restrict po1 = (v4cint16 *) y;
  v4cint16 * restrict po2 = (v4cint16 *) (y + n/2);  
  v4cint32 * restrict pi  = (v4cint32 *) x;  
  v4cint16 * ptw = (v4cint16 *) tw;

  for (unsigned int j = 0; j < n/8; ++j)
    chess_prepare_for_pipelining    
    chess_loop_range(1,)
  {
    v8cint32 xbuf = undef_v8cint32();
    xbuf = upd_w(xbuf,0,*pi++);
    xbuf = upd_w(xbuf,1,*pi++);
    
    v8cint16 zbuf = undef_v8cint16();
    zbuf = upd_v(zbuf,0,*ptw++);

    v8cacc48 o = butterfly_dit(xbuf,undef_v8cint32(),0x6420,0x7531,zbuf,0,0x3210,inv,15);
    *po1++ = srs(ext_lo(o),output_shift);
    *po2++ = srs(ext_hi(o),output_shift);      
  }
}

// -------------------------------------------------------------
// Radix 4
// -------------------------------------------------------------
INLINE_DECL void stage0_radix4_up_dit ( cint16_t * restrict x, 
                                     cint16_t * restrict tw1, 
                                     cint16_t * restrict tw2,
                                     unsigned int n, unsigned int r, unsigned int shift,
                                     cint32_t * restrict y, bool inv )
{  
	set_rdx(4);

    	uint8_t upsft = FFT_UPSHIFT1;

	v4cint32 * restrict po   = (v4cint32 * restrict) y;
	v4cint16 chess_storage(DM_bankA)* restrict pi0  = (v4cint16 chess_storage(DM_bankA)* restrict) x;
	v4cint16 chess_storage(DM_bankA)* restrict pi1  = (v4cint16 chess_storage(DM_bankA)* restrict) (x+1*r);
	v4cint16 * restrict px0  = (v4cint16 * restrict) (x+1*r);
	v4cint16 * restrict px1  = (v4cint16 * restrict) (x+2*r);
	v8cint16 * restrict ptw1 = (v8cint16 * restrict) tw1;
	v8cint16 * restrict ptw2 = (v8cint16 * restrict) tw2;

	int zoffs1 = 0x00000000;
	int zoffs2 = 0x00000000;

	umod_t cnt0 = 0, cnt1 = 0;
	umod_t cnt1d = 0;

	int chess_storage(cs3) poff2 = 2*r/4;

	v8cint16 chess_storage(WD1) xbuf  = undef_v8cint16();
	v8cint16 chess_storage(WD0) init_buf  = undef_v8cint16();

	v8cint32 chess_storage(XB) ybuf  = undef_v8cint32();
	uint8_t shft = chess_copy(FFT_SHIFT1); //CRVO-1460


	for (unsigned int j = 0; j < n/16; ++j)
		chess_prepare_for_pipelining
		chess_loop_range(1,)
	{     
		zoffs1 = fft_zoffs(cnt1,3,1,1);  
		zoffs2 = fft_zoffs(cnt1d,3,1,0);    

		xbuf      = upd_v(xbuf    , 1, pi1[poff2]); 
		xbuf      = upd_v(xbuf    , 0, pi0[poff2]); 
		init_buf  = upd_v(init_buf, 1, *pi1); 
		init_buf  = upd_v(init_buf, 0, *pi0);
		  
		pi1 = (v4cint16 chess_storage(DM_bankA)*) fft_data_incr( (v4cint16 *)pi1,r/4,px1,cnt1); 
		pi0 = (v4cint16 chess_storage(DM_bankA)*) fft_data_incr( (v4cint16 *)pi0,r/4,px0,cnt0); 

		v8cint16 chess_storage(wc0) zbuf1 = ptw1[0]; 
		v8cint16 chess_storage(wc1) zbuf2 = ptw2[0]; 
		 

		v8cacc48 a0 = mac8(ups(init_buf, upsft), upd_w(undef_v16cint16(),1,xbuf) ,8,0x76543210,zbuf1,0,zoffs1);    
		v8cacc48 a1 = msc8(ups(init_buf, upsft), upd_w(undef_v16cint16(),1,xbuf) ,8,0x76543210,zbuf1,0,zoffs1);    

		ybuf = upd_w(ybuf, 0, lsrs(ext_lo(a0),shft));
		ybuf = upd_w(ybuf, 1, lsrs(ext_hi(a0),shft));

		v8cacc48 o0 = butterfly_dit(undef_v8cint32(),ybuf,0xBA98,0xFEDC,zbuf2,0,zoffs2,inv,15);

		ybuf = upd_w(ybuf, 0, lsrs(ext_lo(a1),shft));
		ybuf = upd_w(ybuf, 1, lsrs(ext_hi(a1),shft));  

		v8cacc48 o1 = butterfly_dit_minj(undef_v8cint32(),ybuf,0xBA98,0xFEDC,zbuf2,0,zoffs2,inv,15);

		po[0] = lsrs(ext_lo(o0),shift); po +=   n/16;
		po[0] = lsrs(ext_lo(o1),shift); po +=   n/16;
		po[0] = lsrs(ext_hi(o0),shift); po +=   n/16;
		po[0] = lsrs(ext_hi(o1),shift); po += -(3*(int)(n/16)-1);     
		  
		ptw1 = fft_twiddle_incr(ptw1,cnt1, 3);

		cnt1d  = fft_mod_delay(cnt1);     
		ptw2 = fft_twiddle_incr(ptw2,cnt1d,3); 
	}
}

INLINE_DECL void stage0_radix4_dit ( cint32_t * restrict x, 
                                     cint16_t * restrict tw1, 
                                     cint16_t * restrict tw2,
                                     unsigned int n, unsigned int r, unsigned int shift,
                                     cint32_t * restrict y, bool inv )
{  
	set_rdx(4);

	uint8_t sft = chess_copy(FFT_SHIFT1) ;	//MEAPPS 146. //const int sft = FFT_SHIFT1;
        v4cint32 * restrict po0  = (v4cint32 * restrict)  y;
        v4cint32 * restrict po1  = (v4cint32 * restrict) (y+n/2);
	v4cint32 * restrict pi0  = (v4cint32 * restrict) (x+0*r);
	v4cint32 * restrict pi1  = (v4cint32 * restrict) (x+1*r);
	v4cint32 * restrict pi3  = (v4cint32 * restrict) (x+3*r);
	v4cint32 * restrict px0  = (v4cint32 * restrict) (x+1*r);
	v4cint32 * restrict px1  = (v4cint32 * restrict) (x+2*r);
	v4cint32 * restrict px3  = (v4cint32 * restrict) (x+4*r);
	v8cint16 * restrict ptw1 = (v8cint16 * restrict) tw1;
	v8cint16 * restrict ptw2 = (v8cint16 * restrict) tw2; 

	umod_t cnt1  = 0, cnt2 = 0, cnt3 = 0;
	umod_t cnt3d = 0;

	v8cint32 chess_storage(XA) xbuf = undef_v8cint32();
	v8cint32 chess_storage(XD) ybuf = undef_v8cint32();

	int chess_storage(cs3) revert_offset=-(int)(r/4);

	for (unsigned int j = 0; j < n/16; ++j)
		chess_prepare_for_pipelining
		chess_loop_range(1,)
	{     
		xbuf  = upd_w(xbuf, 0, pi0[0]);
		xbuf  = upd_w(xbuf, 1, pi3[revert_offset]);  
		v8cint16 chess_storage(WC0) zbuf1 = ptw1[0];

		int zoffs1 = fft_zoffs(cnt2,3,1,0);    
		int zoffs2 = fft_zoffs(cnt3d,3,1,0);    

		v8cacc48 a0 = butterfly_dit(xbuf,undef_v8cint32(),0x3210,0x7654,zbuf1,0,zoffs1,inv,15);

		xbuf  = upd_w(xbuf, 1, pi1[0]);
		xbuf  = upd_w(xbuf, 0, pi3[0]);
		v8cint16 chess_storage(WC1) zbuf2 = ptw2[0];

		pi0  = fft_data_incr(pi0,r/4,px0,cnt1);    
		pi1  = fft_data_incr(pi1,r/4,px1,cnt2);    
		pi3  = fft_data_incr(pi3,r/4,px3,cnt3);    
		cnt3d= fft_mod_delay(cnt3);

		ptw1 = fft_twiddle_incr(ptw1,cnt1, 3);
		ptw2 = fft_twiddle_incr(ptw2,cnt3d,3);

		v8cacc48 a1 = butterfly_dit(xbuf,undef_v8cint32(),0x7654,0x3210,zbuf1,0,zoffs1,inv,15);

		ybuf = upd_w(ybuf, 0, lsrs(ext_lo(a0),sft));
		ybuf = upd_w(ybuf, 1, lsrs(ext_lo(a1),sft));   

		v8cacc48 o0 = butterfly_dit(ybuf,undef_v8cint32(),0x3210,0x7654,zbuf2,0,zoffs2,inv,15);

		ybuf = upd_w(ybuf, 0, lsrs(ext_hi(a0),sft));
		ybuf = upd_w(ybuf, 1, lsrs(ext_hi(a1),sft));   

		v8cacc48 o1 = butterfly_dit_minj(ybuf,undef_v8cint32(),0x3210,0x7654,zbuf2,0,zoffs2,inv,15);

		po0[0] = lsrs(ext_lo(o0),shift); po0 +=        n/16;
		po1[0] = lsrs(ext_hi(o0),shift); po1 +=        n/16; 
		po1[0] = lsrs(ext_hi(o1),shift); po1 += -(int)(n/16)+1;
		po0[0] = lsrs(ext_lo(o1),shift); po0 += -(int)(n/16)+1;  
   
	}
}

INLINE_DECL void stage1_radix4_down_dit ( cint32_t * restrict x, 
										cint16_t * restrict tw1, cint16_t * restrict tw2, 
										unsigned int n, unsigned int shift, 
										output_window_cint16 * restrict outputcb, bool inv)
{
	uint8_t sft = chess_copy(FFT_SHIFT1);	//MEAPPS 146.	//const int sft = FFT_SHIFT1;
	output_window_cint16 * restrict po_wb  = (output_window_cint16 * restrict) outputcb;
	v4cint32 * restrict pi   = (v4cint32 * restrict) x;  
	v4cint16 * restrict ptw1 = (v4cint16 * restrict) tw1;
	v4cint16 * restrict ptw2 = (v4cint16 * restrict) tw2;
	
	for (unsigned int j = 0; j < n/16; ++j)
		chess_prepare_for_pipelining
		chess_loop_range(1,)
	{
		v8cint32 chess_storage(XA) xbuf = undef_v8cint32();
		xbuf = upd_w(xbuf, 0, *pi++);
		xbuf = upd_w(xbuf, 1, *pi++);   

		v8cint32 chess_storage(XB) ybuf = undef_v8cint32();
		ybuf = upd_w(ybuf, 0, *pi++);
		ybuf = upd_w(ybuf, 1, *pi++);

		v8cint16 zbuf1 = undef_v8cint16();
		zbuf1 = upd_v(zbuf1, 0, ptw1[j]);

		v8cacc48 a0 = butterfly_dit(xbuf,ybuf,0xC840,0xEA62,zbuf1,0,0x3210,inv,15);

		v8cint32 chess_storage(XD) ubuf = undef_v8cint32();
		ubuf = upd_w(ubuf, 0, lsrs(ext_lo(a0),sft));

		v8cacc48 a1 = butterfly_dit(xbuf,ybuf,0xD951,0xFB73,zbuf1,0,0x3210,inv,15);

		ubuf = upd_w(ubuf, 1, lsrs(ext_lo(a1),sft));

		v8cint16 zbuf2 = undef_v8cint16();
		zbuf2 = upd_v(zbuf2, 0, ptw2[j]);
			
		v8cacc48 o0 = butterfly_dit(ubuf,undef_v8cint32(),0x3210,0x7654,zbuf2,0,0x3210,inv,15);

		v8cint32 chess_storage(XD) vbuf = undef_v8cint32();
		vbuf = upd_w(vbuf, 0, lsrs(ext_hi(a0),sft));
		vbuf = upd_w(vbuf, 1, lsrs(ext_hi(a1),sft));

		v8cacc48 o1 = butterfly_dit_minj(vbuf,undef_v8cint32(),0x3210,0x7654,zbuf2,0,0x3210,inv,15);

		window_write(po_wb, srs(ext_lo(o0),shift)); window_incr(po_wb, 1*4*n/16);
		window_write(po_wb, srs(ext_lo(o1),shift)); window_incr(po_wb, 1*4*n/16);
		window_write(po_wb, srs(ext_hi(o0),shift)); window_incr(po_wb, 1*4*n/16);
		window_write(po_wb, srs(ext_hi(o1),shift)); window_decr(po_wb, 4*(3*n/16-1));

	}
}
INLINE_DECL void stage1_radix4_dit ( cint32_t * restrict x, cint16_t * restrict tw1, cint16_t * restrict tw2, unsigned int n, unsigned int shift, cint32_t * restrict y, bool inv )
{
  n += 15; //ceil rounding in combination with n/16
  
  v4cint32 * restrict po   = (v4cint32 * restrict) y;
  v4cint32 * restrict pi   = (v4cint32 * restrict) x;  
  v4cint16 * restrict ptw1 = (v4cint16 * restrict) tw1;
  v4cint16 * restrict ptw2 = (v4cint16 * restrict) tw2;
  uint8_t             shft = chess_copy(15); //CRVO-1460

  for (unsigned int j = 0; j < n/16; ++j)
    chess_prepare_for_pipelining
    chess_loop_range(1,)
  {
    v8cint32 chess_storage(XA) xbuf = undef_v8cint32();
    xbuf = upd_w(xbuf, 0, *pi++);
    xbuf = upd_w(xbuf, 1, *pi++);   
  
    v8cint32 chess_storage(XB) ybuf = undef_v8cint32();
    ybuf = upd_w(ybuf, 0, *pi++);
    ybuf = upd_w(ybuf, 1, *pi++);
    
    v8cint16 zbuf1 = undef_v8cint16();
    zbuf1 = upd_v(zbuf1, 0, ptw1[j]);
    
    v8cacc48 a0 = butterfly_dit(xbuf,ybuf,0xC840,0xEA62,zbuf1,0,0x3210,inv,15);

    v8cint32 chess_storage(XD) ubuf = undef_v8cint32();
    ubuf = upd_w(ubuf, 0, lsrs(ext_lo(a0),shft));

    v8cacc48 a1 = butterfly_dit(xbuf,ybuf,0xD951,0xFB73,zbuf1,0,0x3210,inv,15);
   
    ubuf = upd_w(ubuf, 1, lsrs(ext_lo(a1),shft));
    
    v8cint16 zbuf2 = undef_v8cint16();
    zbuf2 = upd_v(zbuf2, 0, ptw2[j]);
        
    v8cacc48 o0 = butterfly_dit(ubuf,undef_v8cint32(),0x3210,0x7654,zbuf2,0,0x3210,inv,15);

    v8cint32 chess_storage(XD) vbuf = undef_v8cint32();
    vbuf = upd_w(vbuf, 0, lsrs(ext_hi(a0),shft));
    vbuf = upd_w(vbuf, 1, lsrs(ext_hi(a1),shft));

    v8cacc48 o1 = butterfly_dit_minj(vbuf,undef_v8cint32(),0x3210,0x7654,zbuf2,0,0x3210,inv,15);

    po[0] = lsrs(ext_lo(o0),shift); po +=   n/16;
    po[0] = lsrs(ext_lo(o1),shift); po +=   n/16;
    po[0] = lsrs(ext_hi(o0),shift); po +=   n/16;
    po[0] = lsrs(ext_hi(o1),shift); po += -(3*(int)(n/16)-1); 
  }
}

INLINE_DECL void twiddle_phase_rotation( cint32_t * restrict x, int phaseidx, unsigned int shift, output_window_cint16 * restrict outputcb)
{
	v4cint32 * restrict pi   = (v4cint32 * restrict) x;  
	v8cacc48 chess_storage(bm0) acc0a;
	v8cacc48 chess_storage(bm1) acc0b; 
	v8cint32 chess_storage(xa)  xbuf = undef_v8cint32();
	v8cint16 chess_storage(wc1) dds_rough = null_v8cint16() ;
	v16cint16 twdbuf = undef_v16cint16();
	uint32_t phstp = 0;
	uint32_t phase = phaseidx<<20;  // 2^32 is 2 pi, divide by 4096, it is 2^20
	
	for(unsigned char k=0; k<8;k++){twdbuf=shft_elem(twdbuf, sincos(phstp)); phstp+=phase;}
	phase=0;
	
	
	for (unsigned int j = 0; j < 1024/16; ++j)
		chess_prepare_for_pipelining
		chess_unroll_loop(4)
	{
		// calculate sin/cos values and save it to dds_out
        dds_rough = shft_elem(dds_rough, sincos(phase)); phase+=phstp; 
        dds_rough = shft_elem(dds_rough, sincos(phase)); phase+=phstp; 
		
		// multiply refined and coarse DDS values
		acc0a = mul8(twdbuf, 0, 0x01234567, dds_rough, 1, 0x00000000);
		acc0b = mul8(twdbuf, 0, 0x01234567, dds_rough, 0, 0x00000000);
		
		// dot-multiply with the data
		v8cint16 chess_storage(wc0) twd = srs(acc0a,15);
		xbuf = upd_w(xbuf, 0, *pi++); window_writeincr(outputcb, srs(mul4(xbuf, 0, 0x3210, twd, 0, 0x3210), shift));
		xbuf = upd_w(xbuf, 1, *pi++); window_writeincr(outputcb, srs(mul4(xbuf, 4, 0x3210, twd, 4, 0x3210), shift));
		twd = srs(acc0b,15);
		xbuf = upd_w(xbuf, 0, *pi++); window_writeincr(outputcb, srs(mul4(xbuf, 0, 0x3210, twd, 0, 0x3210), shift));
		xbuf = upd_w(xbuf, 1, *pi++); window_writeincr(outputcb, srs(mul4(xbuf, 4, 0x3210, twd, 4, 0x3210), shift));
	}
}



#endif // __FFT_STAGES_H__

