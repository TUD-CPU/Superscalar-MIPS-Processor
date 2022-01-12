library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity equal is
	generic(w: integer := 32);
    port (
        RD1D: in std_logic_vector(w-1 downto 0);
        RD2D: in std_logic_vector(w-1 downto 0);
        EqualD: out std_logic
    );
end;

architecture behavior of equal is
begin
	process (RD1D, RD2D) begin
		if(to_integer(unsigned(RD1D)) = to_integer(unsigned(RD2D))) then
		EqualD <= '1';
		else
		EqualD <= '0';
		end if;
	end process;
end;