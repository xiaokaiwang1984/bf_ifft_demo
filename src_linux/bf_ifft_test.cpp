#include <fstream>
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <xparameters.h>


#ifdef XRT_LD_AIE

#include "xrt.h"
#include "experimental/xrt_aie.h"
#include <vector>
#endif

using namespace std ;

extern "C"
  {
	#include <errno.h>
	#include <sys/wait.h>
	#include <fcntl.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <sys/mman.h>
	#include <unistd.h>

  }


#ifdef XRT_LD_AIE


static std::vector<char>
 load_xclbin(xclDeviceHandle device, const std::string& fnm)
 {
   if (fnm.empty())
     throw std::runtime_error("No xclbin speified");

   //load bit stream
   std::ifstream stream(fnm);
   stream.seekg(0,stream.end);
   size_t size = stream.tellg();
   stream.seekg(0,stream.beg);

   std::vector<char> header(size);
   stream.read(header.data(),size);

   auto top = reinterpret_cast<const axlf*>(header.data());
   char *xcb = (char*)top;
   printf("xcb is %s\n", xcb);
   if (xclLoadXclBin(device, top))
     throw std::runtime_error("Bitstream download failed");
   return header;
}
#endif


int pmem_wr (unsigned long long int address, unsigned int wr_data ) {

	char cmd [50];
	sprintf(cmd, "devmem 0x%x 32 0x%08x", address, wr_data);

	system(cmd);

	
	return 0;
}


unsigned int pmem_rd (unsigned long long int address ){
	char cmd [50];
	char result [50];
	unsigned int result_value;
	FILE *fp;
	printf("reading address:0x%x\r\n",address);
	
	sprintf(cmd, "devmem 0x%x", address);
	
	fp = popen(cmd, "r");
	if(NULL == fp)
	{
		perror("popen failed! \n");
		exit(1);
	}

	
	while(fgets(result, 50, fp) != NULL)
	{
		if('\n' == result[strlen(result)-1])
		{
			result[strlen(result)-1] = '\0';
		}
//		printf("command[%s] outputs[%s]\r\n", cmd, result);
	}
	
	sscanf(result,"%x",&result_value);
	
	return result_value;
	
	

}

int tx_dma (int dma_lgth) {
	pmem_wr(XPAR_AXI_DMA_0_BASEADDR,1); 				//enable
	pmem_wr(XPAR_AXI_DMA_0_BASEADDR + 0x18,0x40000000); //ddr address
	pmem_wr(XPAR_AXI_DMA_0_BASEADDR + 0x1c,0);			//ddr address msb
	pmem_wr(XPAR_AXI_DMA_0_BASEADDR + 0x28,dma_lgth);	//ddr address msb

	return 0;
}


int rx_dma (int dma_lgth) {
	pmem_wr(XPAR_AXI_DMA_2_BASEADDR + 0x30,1); 			//enable
	pmem_wr(XPAR_AXI_DMA_2_BASEADDR + 0x48,0x40000000); //ddr address
	pmem_wr(XPAR_AXI_DMA_2_BASEADDR + 0x4c,0);			//ddr address msb
	pmem_wr(XPAR_AXI_DMA_2_BASEADDR + 0x58,dma_lgth);	//ddr address msb

	pmem_wr(XPAR_GPIO_0_BASEADDR,0x5); //start rx_dma
	return 0;
}

int check_rdy (int rdy_mask) {
	usleep(100);
	int i;
	for (i=0;i<0x1ff;i++) {
//		printf("GPIO data 0x%x......\n\r",pmem_rd(XPAR_GPIO_0_BASEADDR+0x8));
		if ((pmem_rd(XPAR_GPIO_0_BASEADDR+0x8)&rdy_mask)==rdy_mask) {
			printf("Task finished sucessfully!......\n\r");
			return 1;	
			}
		usleep(1000);
	}
	
	printf("checking ready status finish timeout......\n\r");
	exit(1);
}

int ld_data (string file_name, unsigned int* ddr_buff) {
	string line;
	char const *line_data;
	int data_0,data_1,data_2,data_3;
	int buff_pointer =0;
	int data_combined; 
	
  	ifstream myfile (file_name);
	
  	if (myfile.is_open())
  		{
    	while ( getline (myfile,line) )
    		{
      		//cout << line << '\n';
			line_data =line.data();
			sscanf(line_data,"%d %d %d %d",&data_0, &data_1, &data_2, &data_3);
			data_combined = (data_1)*0x10000 + (data_0&0xffff);
			*(ddr_buff + buff_pointer)=data_combined;
//			printf("0x%08x\n\r",data_combined);
			buff_pointer++;
			
			data_combined = (data_3)*0x10000 + (data_2&0xffff);
			*(ddr_buff + buff_pointer)=data_combined;
//			printf("0x%08x\n\r",data_combined);
			buff_pointer++;
//			printf("0x%04x 0x%04x 0x%04x 0x%04x \r\n",data_0&0xffff, data_1&0xffff, data_2&0xffff, data_3&0xffff);
		
    		}
    		myfile.close();
  		}
  	else 
		cout << "Unable to open file"; 
	
	printf("%s loaded sucessfully and data length: 0x%x x32bit \r\n",file_name.data(),buff_pointer); 
	return (buff_pointer);

}

void dp_data (string file_name, unsigned int* ddr_buff, int data_lgth_32b) {
	ofstream myfile (file_name);
	char line_data [50];
	int i;
	signed short data_0,data_1,data_2,data_3;
	
	if (myfile.is_open())
  	{
		for (i=0;i<data_lgth_32b;i=i+2)
		{
			data_0=((*(ddr_buff+i))&0xffff);
			data_1=(((*(ddr_buff+i))>>16)&0xffff);
			data_2=((*(ddr_buff+i+1))&0xffff);
			data_3=(((*(ddr_buff+i+1))>>16)&0xffff);
				
			sprintf(line_data,"%d %d %d %d",data_0,data_1,data_2,data_3);
			myfile << line_data <<"\n";
		}
		printf("%s file dumped sucessfully \n\r",file_name.data());
		myfile.close();
  	}
  	else 
		cout << "Unable to open file";
}


void dp_data_hex (string file_name, unsigned int* ddr_buff, int data_lgth_32b) {
	ofstream myfile (file_name);
	char line_data [50];
	int i;
	signed short data_0,data_1,data_2,data_3;
	
	if (myfile.is_open())
  	{
		for (i=0;i<data_lgth_32b;i=i+2)
		{
			data_0=((*(ddr_buff+i))&0xffff);
			data_1=(((*(ddr_buff+i))>>16)&0xffff);
			data_2=((*(ddr_buff+i+1))&0xffff);
			data_3=(((*(ddr_buff+i+1))>>16)&0xffff);
				
			sprintf(line_data,"%04x %04x %04x %04x",data_0&0xffff,data_1&0xffff,data_2&0xffff,data_3&0xffff);
			myfile << line_data <<"\n";
		}
		printf("%s file dumped sucessfully \n\r",file_name.data());
		myfile.close();
  	}
  	else 
		cout << "Unable to open file";
}

void verify_data (unsigned int* ddr_buff1, unsigned int* ddr_buff2, int data_lgth) {

	int i;
	printf("Verifying total:0x%0x x32bits between buff_1 addr:0x%08x and buff_2 addr::0x%08x \n\r",data_lgth,*(ddr_buff1+i),*(ddr_buff2+i));
	
	for (i=0;i<data_lgth;i=i+1)
	{
		if (*(ddr_buff1+i)!=*(ddr_buff2+i))
		{
			printf("data mismatch found-addr:0x%08x Received:0x%08x | Golden:0x%08x \n\r",i*4,*(ddr_buff1+i),*(ddr_buff2+i));
			exit(1);
		} else {
//			printf("addr:0x%08x Received:0x%08x | Golden:0x%08x \n\r",i*4,*(ddr_buff1+i),*(ddr_buff2+i));
				
		}
	}
		
	printf("########################################################\n\r");
	printf("Total:0x%0x x32bits Data compared and data matched!    #\n\r",i);
	printf("########################################################\n\r");		 

}


void start_pl() {
	pmem_wr(XPAR_GPIO_0_BASEADDR,0x3);
	pmem_wr(XPAR_GPIO_0_BASEADDR,0x1);
	printf("Starting PL sending data and coef to AIE....... \r\n");
}


void initialize ( ) {

	//reset PL
	pmem_wr(XPAR_GPIO_0_BASEADDR,0x0);
	pmem_wr(XPAR_GPIO_0_BASEADDR,0x1);
	
	//reset DMA
	pmem_wr(XPAR_AXI_DMA_0_BASEADDR,0x4);
	pmem_wr(XPAR_AXI_DMA_2_BASEADDR + 0x30 ,0x4);
	
}



void* init_buff (unsigned int addr_base) {
	
//	int pagesize = sysconf(_SC_PAGE_SIZE);
//    printf("page size:0x%x\n\r",pagesize);

    int fd = open("/dev/mem", (O_RDWR | O_SYNC));
    void* mem = mmap(NULL, 0x1000000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, addr_base);
        
	return mem;
}






int main(int argc, char ** argv) {

	int data_lgth_32b;
	initialize();
	unsigned int * ddr_buff1 = (unsigned int *)init_buff(0x40000000);
	unsigned int * ddr_buff2 = (unsigned int *)init_buff(0x41000000);


#ifdef XRT_LD_AIE	

	//####AIE reset and loading##############
	auto dhdl = xclOpen(0, nullptr, XCL_QUIET);
//	auto dhdl = xclOpen(0, nullptr, XCL_INFO);
    xrtResetAIEArray(dhdl);						//RESET aie
	printf("aie has been reseted......\n\r");
	printf("aie.12_0 :0x%xn\r",pmem_rd(0x20006072004));
	printf("aie.13_0 :0x%xn\r",pmem_rd(0x20006872004));
	printf("aie.14_0 :0x%xn\r",pmem_rd(0x20007072004));
	printf("aie.15_0 :0x%xn\r",pmem_rd(0x20007872004));
	
    auto xclbin = load_xclbin(dhdl, argv[1]); 	//loading AIE image from xclbin

	
	printf("aie has been reloaded......\n\r");
	printf("aie.12_0 :0x%xn\r",pmem_rd(0x20006072004));
	printf("aie.13_0 :0x%xn\r",pmem_rd(0x20006872004));
	printf("aie.14_0 :0x%xn\r",pmem_rd(0x20007072004));
	printf("aie.15_0 :0x%xn\r",pmem_rd(0x20007872004));

#endif
	
	
	

	//####AIE reset and loading##############
	
	data_lgth_32b=ld_data("./data/din0.txt",ddr_buff1);
	dp_data_hex("./data/din0_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x40);
	
	data_lgth_32b=ld_data("./data/din1.txt",ddr_buff1);
	dp_data_hex("./data/din1_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x80);
	
	data_lgth_32b=ld_data("./data/din2.txt",ddr_buff1);
	dp_data_hex("./data/din2_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x100);
	
	data_lgth_32b=ld_data("./data/din3.txt",ddr_buff1);
	dp_data_hex("./data/din3_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x200);
	
	data_lgth_32b=ld_data("./data/coeff00.txt",ddr_buff1);
	dp_data_hex("./data/coeff00_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x04);
	
	data_lgth_32b=ld_data("./data/coeff01.txt",ddr_buff1);
	dp_data_hex("./data/coeff01_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x08);	
	
	data_lgth_32b=ld_data("./data/coeff02.txt",ddr_buff1);
	dp_data_hex("./data/coeff02_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x10);	
	
	data_lgth_32b=ld_data("./data/coeff03.txt",ddr_buff1);
	dp_data_hex("./data/coeff03_hex.txt",ddr_buff1,data_lgth_32b);
	tx_dma(data_lgth_32b*4); 
	check_rdy(0x20);	
	
	
	start_pl();
	check_rdy(0x3);
	

	data_lgth_32b=ld_data("./data/ifft_gold00.txt",ddr_buff2);
	dp_data_hex("./data/ifft_gold00_hex.txt",ddr_buff2,data_lgth_32b);
	
	rx_dma(data_lgth_32b*8);  //dma two buffer at once
	
	//will change to check DMA done
	usleep(100000);
	usleep(100000);
	usleep(100000);
	
	
	dp_data("./data/ifft_rec00.txt",ddr_buff1,data_lgth_32b);
	dp_data_hex("./data/ifft_rec00_hex.txt",ddr_buff1,data_lgth_32b);
	verify_data(ddr_buff1,ddr_buff2,data_lgth_32b);	
	
	
	//comparing the ifft_gold01.txt
	data_lgth_32b=ld_data("./data/ifft_gold01.txt",ddr_buff2);
	dp_data_hex("./data/ifft_gold01_hex.txt",ddr_buff2,data_lgth_32b);
	

	
	dp_data("./data/ifft_rec01.txt",(ddr_buff1+data_lgth_32b),data_lgth_32b);
	dp_data_hex("./data/ifft_rec01_hex.txt",(ddr_buff1+data_lgth_32b),data_lgth_32b);
	verify_data((ddr_buff1+data_lgth_32b),ddr_buff2,data_lgth_32b);	
	
	printf("########################################################\n\r");
	printf("Test sucessfully!!!   #\n\r");
	printf("Ifft data compared with gloden reference without error #\n\r");
	printf("########################################################\n\r");	

	return 0;
}
