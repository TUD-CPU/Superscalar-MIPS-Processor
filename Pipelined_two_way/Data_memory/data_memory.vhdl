-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
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
end;

architecture behavior of data_memory is
  type ramtype is array (size downto 0) of std_logic_vector(31 downto 0);
  signal mem: ramtype;
begin
	
	  process(clk,addr1,addr2) begin
      if rising_edge(clk) then
        if memwrite1 = '1' then
			mem(to_integer(unsigned(addr1(31 downto 2)))) <= data_in1;
        end if;
		if memwrite2 = '1' then
			mem(to_integer(unsigned(addr2(31 downto 2)))) <= data_in2;
        end if;
      end if;
    end process;

    process(clk,addr1,addr2) begin
	  if to_integer(unsigned(addr1(31 downto 2))) < size then
	  data_out1 <= mem(to_integer(unsigned(addr1(31 downto 2))));
	  else
	    data_out1 <= x"00000000";
	  end if;
	  
	  if to_integer(unsigned(addr2(31 downto 2))) < size then
	  data_out2 <= mem(to_integer(unsigned(addr2(31 downto 2))));
	  else
	    data_out2 <= x"00000000";
	  end if;
	
  end process;
end;


