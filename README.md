9/11/2020 added v2_0 platform to support DFX feature
The process to run testings on hardware

# Build everything
$make hw_linux PFM_VER=v2_0

# Program BOOT.BIN which generated with Petalinux image
$xsdb
$ta 1 
$device program BOOT.BIN

# Program partial PDI Under U-BOOT 
setenv serverip 192.168.1.11
setenv  ipaddr 192.168.1.10


tftpb 0x10000000 bf_ifft_dfx/partial.pdi

## Hold the PL into reset
mw 0xF1260330 0xF 1
md 0xF1260330 

## Load the partial PDI, the length need to be updated accordingly
fpga load 0 0x10000000 0x30d510

## Release PL from reset

mw 0xF1260330 0xE 1
md 0xF1260330 

## Testing DMA peripheral is accessable
mw 0xa4200018 0x11223344
md 0xa4200018

## Get Linux kernel and bootup
tftpb 0x10000000 bf_ifft_dfx/image.ub
bootm 


# set up IP on Petalinux
$ifconfig eth0 192.168.1.10


# send files to board

$cd src_linux
$make send

# run tests Under Petalinux
$./bf_ifft_test_xrt.exe aie_only.xclbin
```

root@xilinx-vck190-es1-2020_2_SAM_EA2:~# ./bf_ifft_test_xrt.exe aie_only.xclbin
aie status before initilization...
aie.12_0 control:0x2
aie.12_0 status :0x2
AIE itili[  139.583997] [drm] Pid 596 opened device
zation through XRT...
aie status after initilization ...
aie.12_0 control:0x2
aie.12_0 status :0x2
AIE re[  139.597267] [drm] Finding PDI section header
loading through XRT...
xcb is x[  139.597270] [drm] Section PDI details:
clbin2
[  139.604300] [drm]   offset = 0x1f0
[216619.435990]Loading PDI from DDR
[216619.829653]Monolithic/Master Device
[216623.497121]4.25240 ms: PDI initialization time
[216628.8609]+++++++Loading Image No: 0x0, Name: , Id: 0x00000000
[216633.898731]+++++++Loading Prtn No: 0x0
[216638.336978] 4.402187 ms for PrtnNum: 0, Size: 338736 Bytes
[216643.393759]+++++++Loading Prtn No: 0x1
[216647.573943] 4.143856 ms for PrtnNum: 1, Size: 4960 Bytes
[216652.713565]+++++++Loading Prtn No: 0x2
[216656.640946] 3.890578 ms for PrtnNum: 2, Size: 352 Bytes
[216661.995015]Subsystem PDI Load: Done
[  139.610816] [drm]   size = 0x54240
[  139.661106] [drm] FPGA Manager load DONE
[  139.667344] [drm] Finding IP_LAYOUT section header
[  139.671262] [drm] AXLF section IP_LAYOUT header not found
[  139.676052] [drm] Finding DEBUG_IP_LAYOUT section header
[  139.681450] [drm] AXLF section DEBUG_IP_LAYOUT header not found
[  139.686756] [drm] Finding CONNECTIVITY section header
[  139.692675] [drm] AXLF section CONNECTIVITY header not found
[  139.697720] [drm] Finding MEM_TOPOLOGY section header
[  139.703373] [drm] AXLF section MEM_TOPOLOGY header not found
aie status after reloading...
aie.12_0 control:0x1
aie.12_0 status :0x201
./data/din0.txt loaded sucessfully and data length: 0x6660 x32bit
./data/din0_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/din1.txt loaded sucessfully and data length: 0x6660 x32bit
./data/din1_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/din2.txt loaded sucessfully and data length: 0x6660 x32bit
./data/din2_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/din3.txt loaded sucessfully and data length: 0x6660 x32bit
./data/din3_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/coeff00.txt loaded sucessfully and data length: 0x4440 x32bit
./data/coeff00_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/coeff01.txt loaded sucessfully and data length: 0x4440 x32bit
./data/coeff01_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/coeff02.txt loaded sucessfully and data length: 0x4440 x32bit
./data/coeff02_hex.txt file dumped sucessfully
Task finished sucessfully!......
./data/coeff03.txt loaded sucessfully and data length: 0x4440 x32bit
./data/coeff03_hex.txt file dumped sucessfully
Task finished sucessfully!......
Starting PL sending data and coef to AIE.......
Task finished sucessfully!......
./data/ifft_gold00.txt loaded sucessfully and data length: 0x4000 x32bit
./data/ifft_gold00_hex.txt file dumped sucessfully
./data/ifft_rec00.txt file dumped sucessfully
./data/ifft_rec00_hex.txt file dumped sucessfully
Verifying total:0x4000 x32bits between buff_1 addr:0x0b6e0412 and buff_2 addr::0x0b6e0412
########################################################
Total:0x4000 x32bits Data compared and data matched!    #
########################################################
./data/ifft_gold01.txt loaded sucessfully and data length: 0x4000 x32bit
./data/ifft_gold01_hex.txt file dumped sucessfully
./data/ifft_rec01.txt file dumped sucessfully
./data/ifft_rec01_hex.txt file dumped sucessfully
Verifying total:0x4000 x32bits between buff_1 addr:0xf837fdef an[  139.708447] [drm] zocl_xclbin_read_axlf 5d5a4cc5-8c58-4a47-8b32-239759aed4a8 ret: 0
d buff_2 addr::0xf837fdef
###[  140.539321] [drm] Pid 596 closed device
#####################################################
Total:0x4000 x32bits Data compared and data matched!    #
########################################################
########################################################
Test sucessfully!!!   #
Ifft data compared with gloden reference without error #
########################################################

```