-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity syncresff_tb is
end;

architecture test of syncresff_tb is
  component syncresff
    generic (w: integer);
    port (
      clk: in std_logic;
      reset: in std_logic;
      d: in std_logic_vector(w-1 downto 0);
      q: buffer std_logic_vector(w-1 downto 0)
    );
  end component;

  signal clk, reset : std_logic;
  signal d, q : std_logic_vector(4-1 downto 0);

begin

  pc: syncresff 
    port map(clk=>clk, reset=>reset, d=>d, q=>q);
    generic map(w=>4);

  process begin
    clk <= '0';
    reset <= '1';
    wait for 10 ns;
    reset <= '0';
    d <= "0001";
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;

    wait;
  end process;
end;
