ghdl -a init.vhd 
ghdl -a adder_tree.vhd
ghdl -a mac.vhd
ghdl -a testbench/mac_tb.vhd
ghdl -e mac_tb
ghdl -r mac_tb --vcd=mac_tb.vcd
pause