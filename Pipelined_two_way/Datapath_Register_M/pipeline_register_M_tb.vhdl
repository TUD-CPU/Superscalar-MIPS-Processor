library ieee;
use ieee.std_logic_1164.all;

entity pipeline_register_M_tb is
end pipeline_register_M_tb;

architecture test of pipeline_register_M_tb is

    component pipeline_register_M is
        port (
            clk        : in std_logic;
            ALUOutE    : in std_logic_vector(31 downto 0);
            WriteDataE : in std_logic_vector(31 downto 0);
            WriteRegE  : in std_logic_vector(4 downto 0);
            RegWriteE  : in std_logic;
            MemToRegE  : in std_logic;
            MemWriteE  : in std_logic;

            ALUOutM    : out std_logic_vector(31 downto 0);
            WriteDataM : out std_logic_vector(31 downto 0);
            WriteRegM  : out std_logic_vector(4 downto 0);
            RegWriteM  : out std_logic;
            MemToRegM  : out std_logic;
            MemWriteM  : out std_logic
        );
    end component;

    signal clk, RegWriteE, MemToRegE, MemWriteE, RegWriteM, MemToRegM, MemWriteM : std_logic;
    signal WriteRegE, WriteRegM                                                                                  : std_logic_vector(4 downto 0);
    signal ALUOutE, WriteDataE, WriteBranchE, ALUOutM, WriteDataM, WriteBranchM            : std_logic_vector(31 downto 0);

begin
    pipeline_register_M_1 : pipeline_register_M port map(
        clk        => clk,
        ALUOutE    => ALUOutE,
        WriteDataE => WriteDataE,
        WriteRegE  => WriteRegE,
        RegWriteE  => RegWriteE,
        MemToRegE  => MemToRegE,
        MemWriteE  => MemWriteE,

        ALUOutM    => ALUOutM,
        WriteDataM => WriteDataM,
        WriteRegM  => WriteRegM,
        RegWriteM  => RegWriteM,
        MemToRegM  => MemToRegM,
        MemWriteM  => MemWriteM

    );

    process begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk       <= '0';
        ALUOutE   <= x"00001111";
        WriteRegE <= "00001";
        MemToRegE <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;

        wait;
    end process;
end;