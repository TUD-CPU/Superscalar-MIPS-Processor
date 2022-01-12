
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_tb is
end;

architecture behavior of adder_tb is
    component adder
        port (
            a : in std_logic_vector(31 downto 0);
            b : in std_logic_vector(31 downto 0);
            y : out std_logic_vector(31 downto 0)
        );
    end component;

    signal a, b, y : std_logic_vector(31 downto 0);


begin
    add : adder port map(a=>a, b=>b, y=>y);
    process begin
        a <= x"00000002";
        b <= x"00000001";
        wait for 10 ns;
        assert y = x"00000003" report "Calculation not correct";
        wait;
    end process;
end;
