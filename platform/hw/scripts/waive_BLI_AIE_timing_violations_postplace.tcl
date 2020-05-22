set_property IS_LOC_FIXED 1 [get_cells -hier -filter "REF_NAME=~FD* && LOC=~BLI_*"]
set_false_path -from [get_cells -hier -filter "REF_NAME=~FD* && LOC=~BLI_*"] -to [get_cells -hier -filter "REF_NAME=~AIE_PL_*"]
set_false_path -from [get_cells -hier -filter "REF_NAME=~AIE_PL_*"] -to [get_cells -hier -filter "REF_NAME=~FD* && LOC=~BLI_*"]
