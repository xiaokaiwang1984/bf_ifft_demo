

for i in `seq 0 49`
	do		
	for j in `seq 0 7`
		do
			 if [ -d ../src_aie/Work/aie/${i}_${j} ];
			 then 
				 
				 mkdir -p package/Work/aie/${i}_${j}/Release
				 cp ../src_aie/Work/aie/${i}_${j}/Release/${i}_${j} ./package/Work/aie/${i}_${j}/Release/ 
			 fi
		done
	done
