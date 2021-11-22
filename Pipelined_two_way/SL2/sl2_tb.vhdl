library ieee;
use ieee.std_logic_1164.all;

entity sl2_tb is
end sl2_tb;

architecture test of sl2_tb is

    component sl2 is
        port(
            a: in std_logic_vector(31 downto 0);
            y: out std_logic_vector(31 downto 0)
        );
    end component;

    signal a, y : std_logic_vector(31 downto 0);

begin
    sl : sl2 port map(a, y);

    process begin
        a <= x"00000001";
        wait for 10 ns;
        assert y = x"00000004" report "error";
        wait for 10 ns;

        wait;
    end process;
end;