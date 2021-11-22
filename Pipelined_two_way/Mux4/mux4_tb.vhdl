library ieee;
use ieee.std_logic_1164.all;

entity mux4_tb is
end mux4_tb;

architecture test of mux4_tb is

    component mux4 is
        generic (w : integer := 8);
        port (
            d0 : in std_logic_vector(w - 1 downto 0);
            d1 : in std_logic_vector(w - 1 downto 0);
            d2 : in std_logic_vector(w - 1 downto 0);
            d3 : in std_logic_vector(w - 1 downto 0);
            s  : in std_logic_vector(1 downto 0);
            y  : out std_logic_vector(w - 1 downto 0)
        );
    end component;

    signal d0, d1, d2, d3, y : std_logic_vector(31 downto 0);
    signal s                 : std_logic_vector(1 downto 0);

begin
    mux : mux4
    generic map(w => 32)
    port map(d0 => d0, d1 => d1, d2 => d2, d3 => d3, s => s, y => y);

    process begin
        d0 <= x"55555555";
        d1 <= x"11111111";
        d2 <= x"FFFFFFFF";
        d3 <= x"AAAAAAAA";
        s  <= "00";
        wait for 10 ns;
        s <= "01";
        wait for 10 ns;
        d1 <= x"22222222";
        wait for 10 ns;
        s <= "10";
        wait for 10 ns;
        s <= "11";
        wait for 10 ns;

        wait;
    end process;
end;