library ieee;
use ieee.std_logic_1164.all;

entity equal_tb is
end equal_tb;

architecture test of equal_tb is

    component equal is
		generic(w: integer := 32);
		port (
			RD1D: in std_logic_vector(w-1 downto 0);
			RD2D: in std_logic_vector(w-1 downto 0);
			EqualD: out std_logic
		);
	end component;

    signal RD1D, RD2D: std_logic_vector(31 downto 0);
    signal EqualD: std_logic;

begin
    equalt : equal
    generic map(w => 32)
    port map(RD1D => RD1D, RD2D => RD2D, EqualD => EqualD);

    process begin
        RD1D <= x"00000000";
        RD2D <= x"00000000";
        wait for 10 ns;
		RD1D <= x"00001000";
        RD2D <= x"00000000";
        wait for 10 ns;
        RD1D <= x"00000002";
        RD2D <= x"00000006";
        wait for 10 ns;

        wait;
    end process;
end;