
export BUILD=2020.2_SAM_daily_latest
export BUILD2=2020.2_SAM
export XILINX_LOC=/proj/xbuilds/$BUILD/installs/lin64/Vitis/$BUILD2
export CARDANO_ROOT=$XILINX_LOC/cardano
export LM_LICENSE_FILE=2100@aiengine
#a/proj/xbuilds/2020.2_SAM_daily_latest/installs/lin64/Vitis/2020.2_SAM/cardano/


export sim=xsim

# Update path with CARDANO_ROOT
export PATH=$CARDANO_ROOT/bin:$XILINX_LOC/bin:$PATH
 
# Setup PLATFORM_REPO_PATHS
export PLATFORM_REPO_PATHS=/proj/xbuilds/$BUILD/internal_platforms
 
# Source XRT, VITIS, and Cardano
source $CARDANO_ROOT/scripts/cardano_env.sh
source $XILINX_LOC/settings64.sh
 
OSDIST=`lsb_release -i |awk -F: '{print tolower($2)}' | tr -d ' \t'`
OSREL=`lsb_release -r |awk -F: '{print tolower($2)}' |tr -d ' \t'`
 
if [[ $OSDIST == "centos" ]] || [[ $OSDIST == "redhat"* ]]; then
source /proj/xbuilds/$BUILD/xbb/xrt/packages/xrt-2.1.0-centos/opt/xilinx/xrt/setup.sh
fi
 
if [[ $OSDIST == "ubuntu" ]]; then
#dir=xrt-2.1.0-ubuntu${OSREL/./}
dir=x86_64/xrt-2.8.308_ubuntu_${OSREL}
#/proj/xbuilds/2020.1_released/xbb/xrt/packages/x86_64/xrt-2.6.655_ubuntu_18.04/opt/xilinx/xrt/setup.sh
source /proj/xbuilds/$BUILD/xbb/xrt/packages/${dir}/opt/xilinx/xrt/setup.sh
fi
 
if [ ! -f ~/.Xilinx/Vivado/Vivado_init.tcl ]; then
echo "Vivado_init.tcl does not exist, creating it."
touch ~/.Xilinx/Vivado/Vivado_init.tcl
fi
 
if [ ! -f ~/.Xilinx/HLS_init.tcl ]; then
echo "HLS_init.tcl does not exist, creating it."
touch ~/.Xilinx/HLS_init.tcl
fi
 
 
if [ ! `grep -q "enable_beta_device" ~/.Xilinx/Vivado/Vivado_init.tcl && echo $?` ]; then
echo "enable_beta_device xcvc*" >> ~/.Xilinx/Vivado/Vivado_init.tcl
else
echo "Beta device found!"
fi
 
if [ ! `grep -q "enable_beta_device"* ~/.Xilinx/HLS_init.tcl && echo $?` ]; then
echo "enable_beta_device xcvc*" >> ~/.Xilinx/HLS_init.tcl
else
echo "Beta device found!"
fi

#source /proj/petalinux/2019.2/petalinux-v2019.2_daily_latest/tool/petalinux-v2019.2-final/settings.sh 
source /proj/petalinux/$BUILD2/petalinux-v${BUILD2}_daily_latest/tool/petalinux-v${BUILD2}_EA2-final/settings.sh
#/proj/petalinux/2020.1/petalinux-v2020.1_daily_latest/tool/petalinux-v2020.1-final/settings.sh
export BSP_FILE=/proj/petalinux/released/Petalinux-v2020.2_SAM/petalinux-v2020.2_SAM_0711_1/bsp/release/xilinx-vck190-es1-v2020.2_SAM-final.bsp

echo $BUILD
echo $BUILD2
echo $sim
echo $BSP_FILE





