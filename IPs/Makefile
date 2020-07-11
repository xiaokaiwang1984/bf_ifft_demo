all:./iprepo/bf_ifft_pl


./iprepo/bf_ifft_pl:
	cd bf_ifft_pl;vivado -mode batch -source ./scripts/rtlpacker_v2.tcl

clean:
	rm -rf iprepo ./bf_ifft_pl/vivado* ./bf_ifft_pl/rtlpackaging
