-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity aludec is
  port(
    funct: in std_logic_vector(5 downto 0);
    aluop: in std_logic_vector(1 downto 0);
    alucontrol: out std_logic_vector(3 downto 0)
  );
end;

architecture behavior of aludec is
begin
  process(funct, aluop) begin
    case aluop is
            when "00"     => alucontrol <= "0010"; -- add (for lw/sw/addi/lui)
            when "01"     => alucontrol <= "0110"; -- sub (for beq)
            when "11"     => alucontrol <= "0100"; -- xor (for xori)
            when others   => case funct is          -- rtype
            when "100000" => alucontrol <= "0010"; -- add
            when "100010" => alucontrol <= "0110"; -- sub
            when "100100" => alucontrol <= "0000"; -- and
            when "100101" => alucontrol <= "0001"; -- or
            when "100111" => alucontrol <= "0101"; -- nor
            when "100110" => alucontrol <= "0100"; -- xor
            when "000000" => alucontrol <= "1000"; -- sll
            when "000010" => alucontrol <= "1001"; -- srl
            when "000011" => alucontrol <= "1010"; -- sra
            when "101010" => alucontrol <= "1111"; -- slt
            when others   => alucontrol <= "----"; -- wrong entry in funct
      end case;
    end case;
  end process;
end;
