-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee; use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signext_tb is
end;

architecture test of signext_tb is

  component signext
    port(
      a: in std_logic_vector(15 downto 0);
      aext: out std_logic_vector(31 downto 0)
    );
  end component;

  signal a : std_logic_vector(15 downto 0);
  signal aext : std_logic_vector(31 downto 0);

begin
  sig: signext port map(a=>a, aext=>aext);

  process begin
    a <= x"0001";
    wait for 10 ns;
    a <= x"f101";
    wait for 10 ns;
    wait;
  end process;
end;
