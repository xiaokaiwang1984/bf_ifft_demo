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
#ifndef __IFFT_1024PT_GRAPH_H__
#define __IFFT_1024PT_GRAPH_H__
#include <cardano.h>

#include "fft_params.h"
#include "fft_bufs.h"

using namespace cardano ;

class ifft_1024pt_a_graph: public graph {
   
    public:
        parameter ifft_buf1;
        parameter ifft_buf2;
        parameter ifft_lut1;
        parameter ifft_lut2;
        kernel ifft;
        port<input> in;
        port<output> out;

    ifft_1024pt_a_graph() {

        // Create IFFT kernels
        ifft = kernel::create(ifft_1024pt_dit_a);

		source(ifft) = "ifft_1024pt_dit_a.c";
		runtime<ratio>(ifft) = 0.8 ;

        //Call Init function to set_rnd and set_sat
        initialization_function(ifft) = "ifft_1024pt_dit_a_init";

        // Make twiddle factor LUTs
        ifft_lut1 = parameter::array(fft_lut_tw512);
        ifft_lut2 = parameter::array(fft_lut_tw256);
        connect<>(ifft_lut1, ifft);
        connect<>(ifft_lut2, ifft);
        
        // Temporary buffers for IFFT stages
        ifft_buf1 = parameter::array(ifft_1024_tmp1);
        ifft_buf2 = parameter::array(ifft_1024_tmp2);
        connect<>(ifft_buf1, ifft);
        connect<>(ifft_buf2, ifft);

        // Make connections
        connect<window<IFFT1024_INPUT_SAMPLES*4, IFFT1024_INPUT_MARGIN*4> >   (in, ifft.in[0]) ;
        connect<window<IFFT1024_OUTPUT_SAMPLES*4> >(ifft.out[0], out) ;
    };

};


class ifft_1024pt_b_graph : public graph {
   // private:
     //   parameter ifft_buf1;
      //  parameter ifft_buf2;
      //  parameter ifft_lut1;
      //  parameter ifft_lut2;

    public:
        parameter ifft_buf1;
        parameter ifft_buf2;
        parameter ifft_lut1;
        parameter ifft_lut2;
		port<input> ifftsizesel;
        kernel ifft;
		//port<input> cfg;
        port<input> in;
        port<output> out;

    ifft_1024pt_b_graph() {

        // Create IFFT kernels
        ifft = kernel::create(ifft_1024pt_dit_b) ;

		source(ifft) = "ifft_1024pt_dit_b.c";
		runtime<ratio>(ifft) = 0.8 ;
		
        //Call Init function to set_rnd and set_sat
        initialization_function(ifft) = "ifft_1024pt_dit_b_init";

        // Make twiddle factor LUTs
        ifft_lut1 = parameter::array(fft_lut_tw512);
        ifft_lut2 = parameter::array(fft_lut_tw256);
        connect<>(ifft_lut1, ifft);
        connect<>(ifft_lut2, ifft);
        
        // Temporary buffers for IFFT stages
        ifft_buf1 = parameter::array(ifft_1024_tmp1);
        ifft_buf2 = parameter::array(ifft_1024_tmp2);
        connect<>(ifft_buf1, ifft);
        connect<>(ifft_buf2, ifft);

        // Make connections
		//connect<stream>(cfg, ifft.in[1]);
        connect<window<IFFT1024_INPUT_SAMPLES*4, IFFT1024_INPUT_MARGIN*4> >   (in, ifft.in[0]) ;
        connect<window<IFFT1024_OUTPUT_SAMPLES*4> >(ifft.out[0], out) ;
		connect<stream>   (ifftsizesel, ifft.in[1]) ;
		//connect<parameter>(ifftsizesel, async(ifft.in[1]));

    };

};


class ifft_1024pt_c_graph : public graph {
   // private:
     //   parameter ifft_buf1;
      //  parameter ifft_buf2;
      //  parameter ifft_lut1;
      //  parameter ifft_lut2;

    public:
        parameter ifft_buf1;
        parameter ifft_buf2;
        parameter ifft_lut1;
        parameter ifft_lut2;
		port<input> ifftsizesel;
        kernel ifft;
		//port<input> cfg;
        port<input> in;
        port<output> out;

    ifft_1024pt_c_graph() {

        // Create IFFT kernels
        ifft = kernel::create(ifft_1024pt_dit_c) ;

        source(ifft) = "ifft_1024pt_dit_c.c";
		runtime<ratio>(ifft) = 0.8 ;
		
        //Call Init function to set_rnd and set_sat
        initialization_function(ifft) = "ifft_1024pt_dit_c_init";

        // Make twiddle factor LUTs
        ifft_lut1 = parameter::array(fft_lut_tw512);
        ifft_lut2 = parameter::array(fft_lut_tw256);
        connect<>(ifft_lut1, ifft);
        connect<>(ifft_lut2, ifft);
        
        // Temporary buffers for IFFT stages
        ifft_buf1 = parameter::array(ifft_1024_tmp1);
        ifft_buf2 = parameter::array(ifft_1024_tmp2);
        connect<>(ifft_buf1, ifft);
        connect<>(ifft_buf2, ifft);

        // Make connections
		//connect<stream>(cfg, ifft.in[1]);
        connect<window<IFFT1024_INPUT_SAMPLES*4, IFFT1024_INPUT_MARGIN*4> >   (in, ifft.in[0]) ;
        connect<window<IFFT1024_OUTPUT_SAMPLES*4> >(ifft.out[0], out) ;
		
		//connect<parameter>(ifftsizesel, async(ifft.in[1]));
		connect<stream>   (ifftsizesel, ifft.in[1]);

    };

};


class ifft_1024pt_d_graph : public graph {
   // private:
     //   parameter ifft_buf1;
      //  parameter ifft_buf2;
      //  parameter ifft_lut1;
      //  parameter ifft_lut2;

    public:
        parameter ifft_buf1;
        parameter ifft_buf2;
        parameter ifft_lut1;
        parameter ifft_lut2;
		port<input> ifftsizesel;
        kernel ifft;
		//port<input> cfg;
        port<input> in;
        port<output> out;

    ifft_1024pt_d_graph() {

        // Create IFFT kernels
        ifft = kernel::create(ifft_1024pt_dit_d) ;

        source(ifft) = "ifft_1024pt_dit_d.c";
		runtime<ratio>(ifft) = 0.8 ;

        //Call Init function to set_rnd and set_sat
        initialization_function(ifft) = "ifft_1024pt_dit_d_init";

        // Make twiddle factor LUTs
        ifft_lut1 = parameter::array(fft_lut_tw512);
        ifft_lut2 = parameter::array(fft_lut_tw256);
        connect<>(ifft_lut1, ifft);
        connect<>(ifft_lut2, ifft);
        
        // Temporary buffers for IFFT stages
        ifft_buf1 = parameter::array(ifft_1024_tmp1);
        ifft_buf2 = parameter::array(ifft_1024_tmp2);
        connect<>(ifft_buf1, ifft);
        connect<>(ifft_buf2, ifft);

        // Make connections
		//connect<stream>(cfg, ifft.in[1]);
        connect<window<IFFT1024_INPUT_SAMPLES*4, IFFT1024_INPUT_MARGIN*4> >   (in, ifft.in[0]) ;
        connect<window<IFFT1024_OUTPUT_SAMPLES*4> >(ifft.out[0], out) ;
		
		//connect<parameter>(ifftsizesel, async(ifft.in[1]));
		connect<stream>   (ifftsizesel, ifft.in[1]);

    };

};




class ifft_last_graph : public graph {

    public:
        kernel  core;
		port<input> ifftsizesel;
        port<input> in[4];
        port<output> out[2];

    ifft_last_graph() {

        core = kernel::create(ifft_4096pt_last);

		source(core) = "ifft_4096pt_last.c";
		runtime<ratio>(core) = 0.8 ;

        //Call Init function to set_rnd and set_sat
        initialization_function(core) = "ifft_4096pt_last_init";

		connect<window<IFFT1024_OUTPUT_SAMPLES*4>>(in[0], core.in[0]);
		connect<window<IFFT1024_OUTPUT_SAMPLES*4>>(in[1], core.in[1]);
		connect<window<IFFT1024_OUTPUT_SAMPLES*4>>(in[2], core.in[2]);
		connect<window<IFFT1024_OUTPUT_SAMPLES*4>>(in[3], core.in[3]);
		
		connect<stream>   (ifftsizesel, core.in[4]);

		//connect<stream>(cfg, core.in[4]);
		connect<stream>(core.out[0], out[0]);
		connect<stream>(core.out[1], out[1]);
		
		//connect<parameter>(ifftsizesel, async(core.in[4]));
    };

};




class ifft_pktsplit_graph : public graph {

    public:
		//kernel  plsrc;
        kernel  core;
        port<input> in[2];
        port<output> out[4];
		port<output> ifftsizesel;

    ifft_pktsplit_graph() {


		//plsrc = cardano::kernel::create(plsrc_scmapper_aiet);
		//cardano::fabric<cardano::fpga>(plsrc);
		//cardano::source(plsrc) = "plsrc_scmapper_aiet.cc";

        core = kernel::create(me_pktsplit);

		source(core) = "me_pktsplit.cc";
		runtime<ratio>(core) = 0.8 ;
		
		//for (int i=0;i<4;i++) connect<stream>(in[i],   plsrc.in[i]);
		//for (int i=0;i<2;i++) connect<stream>(plsrc.out[i],   core.in[i]);
		for (int i=0;i<2;i++) connect<stream>(in[i],   core.in[i]);
		for (int i=0;i<4;i++) connect<window<1024*4>>(core.out[i], out[i]);
		
		connect<stream>(core.out[4], ifftsizesel);
		
    };

};
#endif /* __IFFT_1024PT_GRAPH_H__ */
