-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port (
    a          : in std_logic_vector(31 downto 0);
    b          : in std_logic_vector(31 downto 0);
    shamt      : in std_logic_vector(4 downto 0);
    alucontrol : in std_logic_vector(3 downto 0);
    result     : buffer std_logic_vector(31 downto 0);
    zero       : out std_logic
  );
end;

architecture behavior of alu is

--signal result33 : std_logic_vector(32 downto 0);

begin
    process (a, b, alucontrol)
    begin case alucontrol is
        when "0000" => result <= a and b;
        when "0001" => result <= a or b;
        when "0101" => result <= a nor b;
        when "0100" => result <= a xor b;
		when "1000" => result <= std_logic_vector(shift_left ( unsigned(a), to_integer(unsigned(shamt)) ) );  -- sll
		when "1001" => result <= std_logic_vector(shift_right( unsigned(a), to_integer(unsigned(shamt)) ) );  -- srl
		when "1010" => result <= std_logic_vector(shift_right(   signed(a), to_integer(unsigned(shamt)) ) );  -- sra
        when "0010" => result <= std_logic_vector(unsigned(a) + unsigned(b));
        when "0110" => result <= std_logic_vector(unsigned(a) - unsigned(b));
        when "1111" =>
        if (a < b) then
        result <= x"00000001";
        else
        result <= x"00000000";
        end if;
        when others => null;
    end case;
end process;
zero <= '1' when result = x"00000000" else '0';
end;