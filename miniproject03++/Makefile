filename = top
pcf_file = ../common/iceBlinkPico.pcf

# List all Verilog source files you need
verilog_srcs = top.sv sine_gen.sv memory_quarter.sv

build:
	yosys -p "read_verilog -sv $(verilog_srcs); synth_ice40 -top top -json $(filename).json"
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

sim:
	iverilog -g2012 -o tb_top.vvp $(verilog_srcs) tb_top.sv
	vvp tb_top.vvp
	gtkwave tb_top.vcd

clean:
	del /f /q top.json top.asc top.bin tb_top.vvp tb_top.vcd 2>nul || exit 0

