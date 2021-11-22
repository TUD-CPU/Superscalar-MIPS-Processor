ghdl -s adder.vhdl
ghdl -a adder.vhdl
ghdl -e adder
ghdl -r adder --vcd=testbench.vcd

ghdl -s alu.vhdl
ghdl -a alu.vhdl
ghdl -e alu
ghdl -r alu --vcd=testbench.vcd

ghdl -s equal.vhdl
ghdl -a equal.vhdl
ghdl -e equal
ghdl -r equal --vcd=testbench.vcd

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

ghdl -s syncresff.vhdl
ghdl -a syncresff.vhdl
ghdl -e syncresff
ghdl -r syncresff --vcd=testbench.vcd

ghdl -s pipeline_register_D.vhdl
ghdl -a pipeline_register_D.vhdl
ghdl -e pipeline_register_D
ghdl -r pipeline_register_D --vcd=testbench.vcd

ghdl -s pipeline_register_E.vhdl
ghdl -a pipeline_register_E.vhdl
ghdl -e pipeline_register_E
ghdl -r pipeline_register_E --vcd=testbench.vcd

ghdl -s pipeline_register_M.vhdl
ghdl -a pipeline_register_M.vhdl
ghdl -e pipeline_register_M
ghdl -r pipeline_register_M --vcd=testbench.vcd

ghdl -s pipeline_register_W.vhdl
ghdl -a pipeline_register_W.vhdl
ghdl -e pipeline_register_W
ghdl -r pipeline_register_W --vcd=testbench.vcd


ghdl -s aludecoder.vhdl
ghdl -a aludecoder.vhdl
ghdl -e aludecoder
ghdl -r aludecoder --vcd=testbench.vcd

ghdl -s maindecoder.vhdl
ghdl -a maindecoder.vhdl
ghdl -e maindecoder
ghdl -r maindecoder --vcd=testbench.vcd

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

ghdl -s Hazard_Unit.vhdl
ghdl -a Hazard_Unit.vhdl
ghdl -e Hazard_Unit
ghdl -r Hazard_Unit --vcd=testbench.vcd

ghdl -s Fetch_Unit.vhdl
ghdl -a Fetch_Unit.vhdl
ghdl -e Fetch_Unit
ghdl -r Fetch_Unit --vcd=testbench.vcd

ghdl -s Forwarding_Unit.vhdl
ghdl -a Forwarding_Unit.vhdl
ghdl -e Forwarding_Unit
ghdl -r Forwarding_Unit --vcd=testbench.vcd

ghdl -s mips_pipelined.vhdl
ghdl -a mips_pipelined.vhdl
ghdl -e mips_pipelined
ghdl -r mips_pipelined --vcd=testbench.vcd