
connect
after 50
targets -set -filter {name =~ "Cortex-A72 #0"}
rst -proc
after 1000
dow -force -data system.dtb 0x1000
dow -force u-boot.elf
dow -force bl31.elf
dow -force -data image.ub 0x10000000
con
exit