library ieee;
use ieee.std_logic_1164.all;

entity pipeline_register_D_tb is
end pipeline_register_D_tb;

architecture test of pipeline_register_D_tb is

    component pipeline_register_D
        port (
            clk      : in std_logic;
            InstrF    : in std_logic_vector(31 downto 0);
            PCPlus4  : in std_logic_vector(31 downto 0);
            InstrD   : out std_logic_vector(31 downto 0);
            PCPlus4D : out std_logic_vector(31 downto 0)
        );
    end component;

    signal clk                              : std_logic;
    signal InstrF, InstrD, PCPlus4, PCPlus4D : std_logic_vector(31 downto 0);
begin
    reg : pipeline_register_D port map(clk => clk, InstrF => InstrF, PCPlus4 => PCPlus4, InstrD => InstrD, PCPlus4D => PCPlus4D);
    process begin
        clk     <= '0';
        InstrF   <= x"11001100";
        PCPlus4 <= x"11001100";
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk     <= '0';
        InstrF   <= x"00000000";
        PCPlus4 <= x"00000000";
        wait for 10 ns;

        wait;
    end process;
end;