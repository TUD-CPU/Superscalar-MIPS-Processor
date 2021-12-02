-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity aludecoder is
    port (
        funct       : in std_logic_vector(5 downto 0);
        aluop       : in std_logic_vector(1 downto 0);
        AluControlE : out std_logic_vector(2 downto 0)
    );
end;

architecture behavior of aludecoder is
begin
    process (funct, aluop) begin
        case aluop is
            when "00"     => AluControlE <= "010"; -- add (for lw/sw/addi)
            when "01"     => AluControlE <= "110"; -- sub (for beq)
            when others   => case funct is
            when "100000" => AluControlE <= "010"; -- add
            when "100010" => AluControlE <= "110"; -- sub
            when "100100" => AluControlE <= "000"; -- and
            when "100101" => AluControlE <= "001"; -- or
            when "101010" => AluControlE <= "111"; -- slt
            when others   => AluControlE <= "---"; -- wrong entry in funct
        end case;
    end case;
end process;
end;