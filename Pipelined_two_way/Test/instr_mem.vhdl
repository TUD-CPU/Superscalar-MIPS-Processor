library ieee;use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
	port (
		pc1: in std_logic_vector(31 downto 0);
		pc2: in std_logic_vector(31 downto 0);
		instr1: out std_logic_vector(31 downto 0);
		instr2: out std_logic_vector(31 downto 0)
	);
end;

architecture behavior of instr_mem is
	type ramtype is array (255 downto 0) of std_logic_vector(31 downto 0);
	signal mem: ramtype;
begin

	mem(0)	<= "00100000000000010000100001101110";	--addi $1 $0 2158   
	mem(1)	<= "00100000000000110000000000000000";	--addi $3 $0 0
	mem(2)	<= "00100000000001110000000000000001";	--addi $7 $0 1
--	.Loop
	mem(3)	<= "00010000001001110000000000001001";	--beq $1 $7 .End
	mem(4)	<= "00000000001001110011000000100100";	--and $6 $1 $7
	mem(5)	<= "00100000011000110000000000000001";	--addi $3 $3 1
	mem(6)	<= "00010000110000000000000000000100";	--beq $6 $0 .Divide
--	.Mul3+1
	mem(7)	<= "00000000001000010001000000100000";	--add $2 $1 $1
	mem(8)	<= "00000000010000010001000000100000";	--add $2 $2 $1
	mem(9)	<= "00000000010001110000100000100000";	--add $1 $2 $7
	mem(10)	<= "00001000000000000000000000000011";	--j .Loop
--	.Divide
	mem(11)	<= "00000000001000000000100001000011";	--sra $1 $1 1
	mem(12)	<= "00001000000000000000000000000011";	--j .Loop
--	.End
	mem(13)	<= "10101100000000110000000000000000";	--sw $3 0($0)
	mem(14)	<= "10001100000000110000000000000000";	--lw $3 0($0)
	mem(15)	<= "11111111111111111111111111111111";	--exit

	process(pc1, pc2) begin
		instr1 <= mem(to_integer(unsigned(pc1(31 downto 2))));
		instr2 <= mem(to_integer(unsigned(pc2(31 downto 2))));

	end process;
end;
