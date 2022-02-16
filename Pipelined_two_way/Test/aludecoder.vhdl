-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity aludecoder is
    port (
        funct       : in std_logic_vector(5 downto 0);
        aluop       : in std_logic_vector(1 downto 0);
        AluControlE : out std_logic_vector(3 downto 0)
    );
end;

architecture behavior of aludecoder is
begin
    process (funct, aluop) begin
        case aluop is
            when "00"     => AluControlE <= "0010"; -- add (for lw/sw/addi/lui)
            when "01"     => AluControlE <= "0110"; -- sub (for beq)
            when "11"     => AluControlE <= "0100"; -- xor (for xori)
            when others   => case funct is          -- rtype
            when "100000" => AluControlE <= "0010"; -- add
            when "100010" => AluControlE <= "0110"; -- sub
            when "100100" => AluControlE <= "0000"; -- and
            when "100101" => AluControlE <= "0001"; -- or
            when "100111" => AluControlE <= "0101"; -- nor
            when "100110" => AluControlE <= "0100"; -- xor
            when "000000" => AluControlE <= "1000"; -- sll
            when "000010" => AluControlE <= "1001"; -- srl
            when "000011" => AluControlE <= "1010"; -- sra
            when "101010" => AluControlE <= "1111"; -- slt
            when others   => AluControlE <= "----"; -- wrong entry in funct
        end case;
    end case;
end process;
end;