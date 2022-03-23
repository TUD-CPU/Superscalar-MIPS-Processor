-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port (
    clk: in std_logic;
    we3: in std_logic;
	we6: in std_logic;
    a1: in std_logic_vector(4 downto 0);
    a2: in std_logic_vector(4 downto 0);
    a3: in std_logic_vector(4 downto 0);
	a4: in std_logic_vector(4 downto 0);
    a5: in std_logic_vector(4 downto 0);
    a6: in std_logic_vector(4 downto 0);
    wd3: in std_logic_vector(31 downto 0);
	wd6: in std_logic_vector(31 downto 0);
    rd1: buffer std_logic_vector(31 downto 0);
    rd2: buffer std_logic_vector(31 downto 0);
	rd3: buffer std_logic_vector(31 downto 0);
    rd4: buffer std_logic_vector(31 downto 0)
  );
end;

architecture behavior of regfile is
  type ramtype is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal mem: ramtype;
begin
  process(clk) begin
    if rising_edge(clk) then
      if we3 = '1' then mem(to_integer(unsigned(a3))) <= wd3;
	  end if;
	  if we6 = '1' then mem(to_integer(unsigned(a6))) <= wd6;
      end if;
    end if;
  end process;
  
  rd1 <= x"00000000" when to_integer(unsigned(a1)) = 0 else mem(to_integer(unsigned(a1)));
  rd2 <= x"00000000" when to_integer(unsigned(a2)) = 0 else mem(to_integer(unsigned(a2)));
  
  rd3 <= x"00000000" when to_integer(unsigned(a4)) = 0 else mem(to_integer(unsigned(a4)));
  rd4 <= x"00000000" when to_integer(unsigned(a5)) = 0 else mem(to_integer(unsigned(a5)));
  
end;
