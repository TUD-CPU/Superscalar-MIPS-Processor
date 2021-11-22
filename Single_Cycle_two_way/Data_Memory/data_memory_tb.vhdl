library ieee;
use ieee.std_logic_1164.all;

entity data_memory_tb is
end data_memory_tb;

architecture test of data_memory_tb is

component data_memory is
  generic (size : Integer := 63);
  port (
    clk : in std_logic;
    addr1: in std_logic_vector(31 downto 0);
    addr2: in std_logic_vector(31 downto 0);
	data_in1: in std_logic_vector(31 downto 0);
	data_in2: in std_logic_vector(31 downto 0);
	memwrite1 : in std_logic;
	memwrite2 : in std_logic;
	data_out1: out std_logic_vector(31 downto 0);
	data_out2: out std_logic_vector(31 downto 0)
  );
end component;

  signal clk, memwrite1, memwrite2 : std_logic;
  signal addr1, addr2, data_in1, data_in2, data_out1, data_out2: std_logic_vector(31 downto 0);
  
begin

	data_mem : data_memory port map(clk => clk,
                                  	addr1 => addr1,
									addr2 => addr2,
									data_in1 => data_in1,
									data_in2 => data_in2,
									memwrite1 => memwrite1,
									memwrite2 => memwrite2,
									data_out1 => data_out1,
									data_out2 => data_out2);
	
  process begin
	-- initialisation
	clk <= '0';
	addr1 <= x"00000000";
	addr2 <= x"00000000";
    data_in1 <= x"00000000";
    data_in2 <= x"00000000";
    memwrite1 <= '0';
    memwrite2 <= '0';
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
	
	-- write C to 8 and 0A03070C to C
	clk <= '0';
	addr1 <= x"00000008";
	addr2 <= x"0000000C";
    data_in1 <= x"0000000C";
    data_in2 <= x"0A03070C";
    memwrite1 <= '1';
    memwrite2 <= '1';
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
	
	-- read from 8 and C
	clk <= '0';
	addr1 <= x"00000008";
	addr2 <= x"0000000C";
    data_in1 <= x"00000000";
    data_in2 <= x"00000000";
    memwrite1 <= '0';
    memwrite2 <= '0';
	wait for 1 ns;
	assert data_out1 = x"0000000C" report "Did not save/load address 8 correctly";
	assert data_out2 = x"0A03070C" report "Did not save/load address C correctly";
	wait for 10 ns;
	clk <= '1';
	wait for 10 ns;
	
	wait;
  end process;
end;
