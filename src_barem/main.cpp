//#include <stdio.h>
//#include <stdlib.h>
//#include <stdint.h>
#include <cstdio>
#include <unistd.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_cache.h"




#define DMA_M2S_CR 		0x0
#define DMA_M2S_SR 		0x4
#define DMA_M2S_SA		0x18
#define DMA_M2S_SA_MSB	0x1c
#define DMA_M2S_LGTH	0x28

#define DMA_S2M_CR 		0x30
#define DMA_S2M_SR 		0x34
#define DMA_S2M_SA		0x48
#define DMA_S2M_SA_MSB	0x4c
#define DMA_S2M_LGTH	0x58

//copied from AIE design



#include "test_dl8a.h"
#include "fft_com_inc.h"

 cint32_t fft_1024_tmp1[FFT1024_SIZE];
 cint32_t fft_1024_tmp2[FFT1024_SIZE];
 cint32_t fft_1200_tmp1[FFT1200_SIZE];
 cint32_t fft_1200_tmp2[FFT1200_SIZE];
 cint32_t fft_128_tmp1[FFT128_SIZE];
 cint32_t fft_128_tmp2[FFT128_SIZE];
 cint32_t fft_12_tmp1[FFT12_SIZE+4];
 cint32_t fft_12_tmp2[FFT12_SIZE+4];
 cint32_t fft_12_x128_tmp1[FFT12_X128_SIZE+4];
 cint32_t fft_12_x128_tmp2[FFT12_X128_SIZE+4];
 cint32_t fft_12_x128_16b_tmp1[FFT12_X128_16B_SIZE+4];
 cint32_t fft_12_x128_16b_tmp2[FFT12_X128_16B_SIZE+4];
 cint32_t fft_1536_tmp1[FFT1536_SIZE];
 cint32_t fft_1536_tmp2[FFT1536_SIZE];
 cint32_t fft_2048_tmp1[FFT2048_SIZE];
 cint32_t fft_2048_tmp2[FFT2048_SIZE];
 cint32_t fft_24_tmp1[FFT24_SIZE+8];
 cint32_t fft_24_tmp2[FFT24_SIZE+8];
 cint32_t fft_256_tmp1[FFT256_SIZE];
 cint32_t fft_256_tmp2[FFT256_SIZE];
 cint32_t fft_300_tmp1[FFT300_SIZE+4];
 cint32_t fft_300_tmp2[FFT300_SIZE+4];
 cint32_t fft_3072_tmp1[FFT3072_SIZE];
 cint32_t fft_3072_tmp2[FFT3072_SIZE];
 cint32_t fft_36_tmp1[FFT36_SIZE+12];
 cint32_t fft_36_tmp2[FFT36_SIZE+12];
 cint32_t fft_384_tmp1[FFT384_SIZE];
 cint32_t fft_384_tmp2[FFT384_SIZE];
 cint32_t fft_4096_tmp1[FFT4096_SIZE];
 cint32_t fft_4096_tmp2[FFT4096_SIZE];
 cint32_t fft_512_tmp1[FFT512_SIZE];
 cint32_t fft_512_tmp2[FFT512_SIZE];
 cint32_t fft_600_tmp1[FFT600_SIZE+8];
 cint32_t fft_600_tmp2[FFT600_SIZE+8];
 cint32_t fft_640_tmp1[FFT640_SIZE];
 cint32_t fft_640_tmp2[FFT640_SIZE];
 cint32_t fft_896_tmp1[FFT896_SIZE];
 cint32_t fft_896_tmp2[FFT896_SIZE];
 cint32_t ifft_1024_tmp1[IFFT1024_SIZE];
 cint32_t ifft_1024_tmp2[IFFT1024_SIZE];
 cint32_t ifft_1200_tmp1[IFFT1200_SIZE];
 cint32_t ifft_1200_tmp2[IFFT1200_SIZE];
 cint32_t ifft_128_tmp1[IFFT128_SIZE];
 cint32_t ifft_128_tmp2[IFFT128_SIZE];
 cint32_t ifft_12_tmp1[IFFT12_SIZE+4];
 cint32_t ifft_12_tmp2[IFFT12_SIZE+4];
 cint32_t ifft_12_x128_tmp1[IFFT12_X128_SIZE+4];
 cint32_t ifft_12_x128_tmp2[IFFT12_X128_SIZE+4];
 cint32_t ifft_12_x128_16b_tmp1[IFFT12_X128_16B_SIZE+4];
 cint32_t ifft_12_x128_16b_tmp2[IFFT12_X128_16B_SIZE+4];
 cint32_t ifft_1536_tmp1[IFFT1536_SIZE];
 cint32_t ifft_1536_tmp2[IFFT1536_SIZE];
 cint32_t ifft_2048_tmp1[IFFT2048_SIZE];
 cint32_t ifft_2048_tmp2[IFFT2048_SIZE];
 cint32_t ifft_24_tmp1[IFFT24_SIZE+8];
 cint32_t ifft_24_tmp2[IFFT24_SIZE+8];
 cint32_t ifft_256_tmp1[IFFT256_SIZE];
 cint32_t ifft_256_tmp2[IFFT256_SIZE];
 cint32_t ifft_300_tmp1[IFFT300_SIZE+4];
 cint32_t ifft_300_tmp2[IFFT300_SIZE+4];
 cint32_t ifft_3072_tmp1[IFFT3072_SIZE];
 cint32_t ifft_3072_tmp2[IFFT3072_SIZE];
 cint32_t ifft_36_tmp1[IFFT36_SIZE+12];
 cint32_t ifft_36_tmp2[IFFT36_SIZE+12];
 cint32_t ifft_384_tmp1[IFFT384_SIZE];
 cint32_t ifft_384_tmp2[IFFT384_SIZE];
 cint32_t ifft_4096_tmp1[IFFT4096_SIZE];
 cint32_t ifft_4096_tmp2[IFFT4096_SIZE];
 cint32_t ifft_512_tmp1[IFFT512_SIZE];
 cint32_t ifft_512_tmp2[IFFT512_SIZE];
 cint32_t ifft_600_tmp1[IFFT600_SIZE+8];
 cint32_t ifft_600_tmp2[IFFT600_SIZE+8];
 cint32_t ifft_640_tmp1[IFFT640_SIZE];
 cint32_t ifft_640_tmp2[IFFT640_SIZE];
 cint32_t ifft_896_tmp1[IFFT896_SIZE];
 cint32_t ifft_896_tmp2[IFFT896_SIZE];
 cint16_t fft_lut_tw150[FFT_150];
 cint16_t fft_lut_tw160[FFT_160];
 cint16_t fft_lut_tw192[FFT_192];
 cint16_t fft_lut_tw224[FFT_224];
 cint16_t fft_lut_tw256[FFT_256];
 cint16_t fft_lut_tw300[FFT_300];
 cint16_t fft_lut_tw320[FFT_320];
 cint16_t fft_lut_tw300o2[FFT_300];
 cint16_t fft_lut_tw300o4[FFT_300];
 cint16_t fft_lut_tw384[FFT_384];
 cint16_t fft_lut_tw448[FFT_448];
 cint16_t fft_lut_tw512[FFT_512];
 cint16_t fft_lut_tw600[FFT_600];
 cint16_t fft_lut_tw768[FFT_768];
 cint16_t fft_lut_tw1024[FFT_1024];
 cint16_t fft_lut_tw1536[FFT_1536];
 cint16_t fft_lut_tw2048[FFT_2048];


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


//copied from AIE design


int main()
{
	int i;

	Xil_DCacheDisable();

	init_platform();

  	sleep(1);
	printf("- \n");
	printf("Beginning test\n");

	
	dut.init();
	dut.run() ;

	//remove iolation reset with revertor
	printf("Releasing PL reset signal\n");
	Xil_Out32(0xF1260330, 0xf);
	Xil_Out32(0xF1260330, 0x0);
	

	printf("Releasing reset\n");
	Xil_Out32(XPAR_GPIO_0_BASEADDR , 0x1);


	printf("Enabling PL data transmitting\n");
	Xil_Out32(XPAR_GPIO_0_BASEADDR , 0x3);
	Xil_Out32(XPAR_GPIO_0_BASEADDR , 0x1);

	//avoid QEMU quit
	for (i=0;i<0xffffffff;i++)
		printf("Test is going \n");
	
	
	/*
	//MM2S DMA
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_CR, 1)	  		; //control
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_SA, 0x10000)	; //MM addresss
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_SA_MSB, 0)	  	;
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_LGTH, 13104*8)	; //size 13104 din 8736 cin 64bit
	*/
	

	dut.end() ;
	cleanup_platform();


}
