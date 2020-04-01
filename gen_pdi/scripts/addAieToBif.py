import os
import sys

if len(sys.argv) != 4:
  print "\nError: Wrong number of arguments provided"
  print "Usage: python addAieToBif.py <input_bif> <output_bif> <path_to_kernel_Work>\n"
  exit()

#if len(sys.argv) != 
# open bdi file
name = sys.argv[1]
#name = "./aie_mem_25Core_v1.pdi.bif"
fi = open(name,"r")
oname = sys.argv[2]
#oname = "./aie_mem_25CoreWithAIE_v1.pdi.bif"
fo = open(oname, "w+")

# start reading file till 2 } are found
#path = "/wrk/xsjhdnobkup1/sreesan/aie/Proj/E/EVEREST_SMART/src/shared/synth/aie/board/mm_25Core_v1/mm_25Core_kernel/Work/"
path = sys.argv[3]
found = 0
for line in fi:
  if line.strip(): 
    print line
    if "}" in line:
      if found == 0:
        fo.write(line)
        found = 1
      elif found == 1:
        # Insert AIE related lines
        #fo.write("hellooo\n")
        d = path + "aie/"
        for o in os.listdir(d):
          if os.path.isdir(os.path.join(d,o)):
          #for root, dirs, files in os.walk(path, topdown=False):
          #for name in root:
            name = o
            cfn = d + name + "/Release/" + name
            fo.write("  partition\n")
            fo.write("  {\n")
            fo.write("   id=0x110\n")
            fo.write("   core=aie\n")
            fo.write("   file= "+ cfn + "\n")
            fo.write("  }\n")

        fo.write("  partition\n")
        fo.write("  {\n")
        fo.write("   id=0x1e\n")
        fo.write("   type=cdo\n")
        cdofn = path + "ps/cdo/aie_cdo.bin"
        fo.write("   file= "+ cdofn + "\n")
        fo.write("  }\n")

        fo.write(line)
        found = 0
    #if not line.strip(): 
    else:
      if found == 1:
        found = 0
      fo.write(line)
