#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
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



int main()
{
	int i;

	Xil_DCacheDisable();

	init_platform();

  	sleep(1);
	printf("- \n");
	printf("Beginning test\n");



	printf("Releasing reset\n");
	Xil_Out32(XPAR_GPIO_0_BASEADDR , 0x1);


	printf("Enabling PL data transmitting\n");
	Xil_Out32(XPAR_GPIO_0_BASEADDR , 0x3);
	Xil_Out32(XPAR_GPIO_0_BASEADDR , 0x1);

	
	
	/*
	//MM2S DMA
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_CR, 1)	  		; //control
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_SA, 0x10000)	; //MM addresss
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_SA_MSB, 0)	  	;
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + DMA_M2S_LGTH, 13104*8)	; //size 13104 din 8736 cin 64bit
	*/
	
	
	cleanup_platform();


}
