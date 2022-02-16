
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end;

architecture behavior of alu_tb is
    component alu
        port(
        a: in std_logic_vector(31 downto 0);
        b: in std_logic_vector(31 downto 0);
        shamt: in std_logic_vector(4 downto 0);
        alucontrol: in std_logic_vector(3 downto 0);
        result: buffer std_logic_vector(31 downto 0);
        zero: out std_logic
        );
    end component;

    signal a, b, result : std_logic_vector(31 downto 0);
    signal shamt : std_logic_vector(4 downto 0);
    signal alucontrol : std_logic_vector(3 downto 0);
    signal zero : std_logic;


begin
    al : alu port map(a=>a, b=>b, shamt=>shamt, alucontrol=>alucontrol, result=>result, zero=>zero);
    process begin
        a <= x"00000009";
        b <= x"00000009";
		
        shamt <= "00100";
        alucontrol <= "1000";
        wait for 10 ns;
        alucontrol <= "1001";
        wait for 10 ns;
		alucontrol <= "1010";
        wait for 10 ns;
		alucontrol <= "0000";
        wait for 10 ns;
		alucontrol <= "0101";
        wait for 10 ns;
        alucontrol <= "0001";
        wait for 10 ns;
        alucontrol <= "0010";
        wait for 10 ns;
        alucontrol <= "0110";
        wait for 10 ns;
        alucontrol <= "0111";
        wait for 10 ns;
        wait;
    end process;
end;
