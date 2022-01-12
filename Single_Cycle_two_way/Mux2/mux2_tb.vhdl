library ieee;
use ieee.std_logic_1164.all;

entity mux2_tb is
end mux2_tb;

architecture test of mux2_tb is

    component mux2 is
        generic(w: integer := 8);
        port(
            d0: in std_logic_vector(w-1 downto 0);
            d1: in std_logic_vector(w-1 downto 0);
            s: in std_logic;
            y: out std_logic_vector(w-1 downto 0)
        );
    end component;

    signal d0, d1, y : std_logic_vector(31 downto 0);
    signal s : std_logic;

begin
    mux : mux2
    generic map(w => 32)
    port map(d0 => d0, d1 => d1, s => s, y => y);

    process begin
        d0 <= x"55555555";
        d1 <= x"11111111";
        s  <= '0';
        assert y /= x"55555555" report "error"; 
        wait for 10 ns;
        s  <= '1';
        assert y /= x"11111111" report "error";
        wait for 10 ns;

        wait;
    end process;
end;