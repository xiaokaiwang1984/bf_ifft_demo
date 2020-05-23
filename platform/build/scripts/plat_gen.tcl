set platform_name [lindex $argv 0]
puts "Creating platform: \"$platform_name\""

set xsa_file [lindex $argv 1]
puts "using xsa path: \"$xsa_file\""

set output_path [lindex $argv 2]
puts "with output path: \"$output_path\""

set OUTPUT platform_repo
set SW_COMP ./sw_components/


platform create -name $platform_name -desc " A platform targetting VCK190 for demonstration purpose with a Linux, AI Engine and a Standalone domain" -hw $xsa_file -out $output_path -no-boot-bsp
domain create -name aiengine -os aie_runtime -proc {ai_engine}
domain config -pmcqemu-args $SW_COMP/src/qemu/aie/pmc_args.txt
domain config -qemu-args $SW_COMP/src/qemu/aie/qemu_args.txt
domain config -qemu-data $SW_COMP/src/boot

## Create the Linux domain
domain create -name xrt -proc psv_cortexa72 -os linux -image $SW_COMP/src/a72/xrt/image
domain config -boot $SW_COMP/src/boot
domain config -bif $SW_COMP/src/a72/xrt/linux.bif
domain config -pmcqemu-args $SW_COMP/src/qemu/lnx/pmc_args.txt
domain config -qemu-args $SW_COMP/src/qemu/lnx/qemu_args.txt
domain config -qemu-data $SW_COMP/src/boot

### Create the Standalone domain 
domain create -name standalone_domain -os standalone -proc psv_cortexa72_0

platform generate

