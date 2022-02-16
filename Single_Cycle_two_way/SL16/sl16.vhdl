-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sl16 is
    port (
        a    : in std_logic_vector(15 downto 0);
        y    : out std_logic_vector(31 downto 0)
    );
end;

architecture behavior of sl16 is
begin
    y <= a & x"0000";
end;