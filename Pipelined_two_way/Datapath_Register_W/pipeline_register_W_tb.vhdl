library ieee;
use ieee.std_logic_1164.all;

entity pipeline_register_W_tb is
end pipeline_register_W_tb;

architecture test of pipeline_register_W_tb is

    component pipeline_register_W
        port (
            clk: in std_logic;
            AluoutM: in std_logic_vector(31 downto 0);
            ReaddataM: in std_logic_vector(31 downto 0);
            RegWriteM: in std_logic;
            MemToRegM: in std_logic;
            WriteRegM: in std_logic_vector(4 downto 0);
            AluoutW: out std_logic_vector(31 downto 0);
            ReaddataW: out std_logic_vector(31 downto 0);
            RegWriteW: out std_logic;
            MemToRegW: out std_logic;
            WriteRegW: out std_logic_vector(4 downto 0)
        );
    end component;

    signal clk, RegWriteM, RegWriteW, MemToRegM, MemToRegW: std_logic;
    signal AluoutM, AluoutW, ReaddataM, ReaddataW: std_logic_vector(31 downto 0);
    signal WriteRegM, WriteRegW: std_logic_vector(4 downto 0);
  
  
begin
    reg : pipeline_register_W port map(clk => clk, AluoutM => AluoutM, ReaddataM => ReaddataM, RegWriteM => RegWriteM, MemToRegM => MemToRegM,
                                        WriteRegM => WriteRegM, AluoutW => AluoutW, ReaddataW => ReaddataW, RegWriteW => RegWriteW,
                                        MemToRegW => MemToRegW, WriteRegW => WriteRegW);
    process begin
        clk <= '0';
        AluoutM <= x"11001100";
        ReaddataM <= x"11001100";
        RegWriteM <= '1';
        MemToRegM <= '1';
        WriteRegM <= "10100";
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        AluoutM <= x"00000000";
        ReaddataM <= x"00000000";
        RegWriteM <= '0';
        MemToRegM <= '0';
        WriteRegM <= "00000";
        wait for 10 ns;
        
        wait;
    end process;
end;
