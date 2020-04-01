
connect

targets -set -filter {name =~ "Cortex-A72 #0"}
rst -proc

dow -force main.elf

con
exit