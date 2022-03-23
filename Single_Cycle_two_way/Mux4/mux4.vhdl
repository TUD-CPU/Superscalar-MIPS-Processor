-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity mux4 is
    generic (w : integer := 8);
    port (
        d0 : in std_logic_vector(w - 1 downto 0);
        d1 : in std_logic_vector(w - 1 downto 0);
        d2 : in std_logic_vector(w - 1 downto 0);
        d3 : in std_logic_vector(w - 1 downto 0);
        s  : in std_logic_vector(1 downto 0);
        y  : out std_logic_vector(w - 1 downto 0)
    );
end;

architecture behavior of mux4 is
begin
    process (s, d0, d1, d2, d3) begin
        case s is
        when "00"   => y   <= d0;
        when "01"   => y   <= d1;
        when "10"   => y   <= d2;
        when others => y <= d3;
        end case;
    end process;
end;