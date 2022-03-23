ghdl -s adder.vhdl
ghdl -a adder.vhdl
ghdl -e adder
ghdl -r adder --vcd=testbench.vcd

ghdl -s alu.vhdl
ghdl -a alu.vhdl
ghdl -e alu
ghdl -r alu --vcd=testbench.vcd

ghdl -s mux2.vhdl
ghdl -a mux2.vhdl
ghdl -e mux2
ghdl -r mux2 --vcd=testbench.vcd

ghdl -s mux4.vhdl
ghdl -a mux4.vhdl
ghdl -e mux4
ghdl -r mux4 --vcd=testbench.vcd

ghdl -s regfile.vhdl
ghdl -a regfile.vhdl
ghdl -e regfile
ghdl -r regfile --vcd=testbench.vcd

ghdl -s signext.vhdl
ghdl -a signext.vhdl
ghdl -e signext
ghdl -r signext --vcd=testbench.vcd

ghdl -s sl2.vhdl
ghdl -a sl2.vhdl
ghdl -e sl2
ghdl -r sl2 --vcd=testbench.vcd

ghdl -s sl16.vhdl
ghdl -a sl16.vhdl
ghdl -e sl16
ghdl -r sl16 --vcd=testbench.vcd

ghdl -s syncresff.vhdl
ghdl -a syncresff.vhdl
ghdl -e syncresff
ghdl -r syncresff --vcd=testbench.vcd

ghdl -s aludec.vhdl
ghdl -a aludec.vhdl
ghdl -e aludec
ghdl -r aludec --vcd=testbench.vcd

ghdl -s maindec.vhdl
ghdl -a maindec.vhdl
ghdl -e maindec
ghdl -r maindec --vcd=testbench.vcd

ghdl -s controller.vhdl
ghdl -a controller.vhdl
ghdl -e controller
ghdl -r controller --vcd=testbench.vcd


ghdl -s data_memory.vhdl
ghdl -a data_memory.vhdl
ghdl -e data_memory
ghdl -r data_memory --vcd=testbench.vcd

ghdl -s instr_mem.vhdl
ghdl -a instr_mem.vhdl
ghdl -e instr_mem
ghdl -r instr_mem --vcd=testbench.vcd

ghdl -s execution_unit.vhdl
ghdl -a execution_unit.vhdl
ghdl -e execution_unit
ghdl -r execution_unit --vcd=testbench.vcd

ghdl -s hazard_unit.vhdl
ghdl -a hazard_unit.vhdl
ghdl -e hazard_unit
ghdl -r hazard_unit --vcd=testbench.vcd

ghdl -s mips.vhdl
ghdl -a mips.vhdl
ghdl -e mips
ghdl -r mips --vcd=testbench.vcd