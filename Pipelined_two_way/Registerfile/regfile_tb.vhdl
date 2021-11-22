library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_tb is
end regfile_tb;

architecture test of regfile_tb is
  component regfile
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
  end component;

  signal clk, we3, we6 : std_logic;
  signal a1, a2, a3, a4, a5, a6 : std_logic_vector(4 downto 0);
  signal wd3, wd6, rd1, rd2, rd3, rd4 : std_logic_vector(31 downto 0);

begin

  reg: regfile port map(clk=>clk,
                        we3=>we3,
						we6=>we6,
						a1=>a1,
						a2=>a2,
						a3=>a3,
						a4=>a4,
						a5=>a5,
						a6=>a6,
						wd3=>wd3,
						wd6=>wd6,
						rd1=>rd1,
						rd2=>rd2,
						rd3=>rd3,
						rd4=>rd4);

  process begin
    -- write 2 to reg 1 and 4 to reg 3
    clk <= '0';
    we3 <= '1';
	we6 <= '1';
    wd3 <= x"00000002";
    wd6 <= x"00000004";
    a3 <= "00001";
    a6 <= "00011";
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
	-- write 6 to reg 2 and 8 to reg 4
    clk <= '0';
    we3 <= '1';
	we6 <= '1';
    wd3 <= x"00000006";
    wd6 <= x"00000008";
    a3 <= "00010";
    a6 <= "00100";
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
	-- read register 1,3,4,2 from a1,a2,a4,a5
    clk <= '0';
	we3 <= '0';
	we6 <= '0';
    a1 <= "00001";
    a2 <= "00011";
    a4 <= "00100";
    a5 <= "00010";
    wait for 10 ns;
	assert rd1 = x"00000002" report "Writing/Reading register 1 failed for a1";
	assert rd2 = x"00000004" report "Writing/Reading register 3 failed for a2";
    assert rd3 = x"00000008" report "Writing/Reading register 3 failed for a4";
	assert rd4 = x"00000006" report "Writing/Reading register 1 failed for a5";
    clk <= '1';
    wait for 10 ns;

    assert false report "End of test";
    wait;
  end process;

end test;