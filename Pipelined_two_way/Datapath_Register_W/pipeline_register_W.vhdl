-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_register_W is
    port (
        clk       : in std_logic;
		Enable     : in std_logic;
		Clear      : in std_logic;
        AluoutM   : in std_logic_vector(31 downto 0);
        ReaddataM : in std_logic_vector(31 downto 0);
        RegWriteM : in std_logic;
        MemToRegM : in std_logic;
        WriteRegM : in std_logic_vector(4 downto 0);
        AluoutW   : out std_logic_vector(31 downto 0);
        ReadDataW : out std_logic_vector(31 downto 0);
        RegWriteW : out std_logic;
        MemToRegW : out std_logic;
        WriteRegW : out std_logic_vector(4 downto 0)
    );
end;

architecture behavior of pipeline_register_W is
    type ramtype is array (1 downto 0) of std_logic_vector(31 downto 0);
    signal mem      : ramtype;
    signal regWrite : std_logic;
    signal memToReg : std_logic;
    signal writeReg : std_logic_vector(4 downto 0);
begin
    process (clk) begin
        if rising_edge(clk) and Enable = '1' then
			-- only clear regWrite so nothing will be stored in a register
			if Clear = '1' then
				regWrite <= '0';
			else
				mem(0)   <= AluoutM; --speichere AluoutM an index 0
				mem(1)   <= ReaddataM; --speichere ReaddataM an index 0
				regWrite <= RegWriteM;
				memToReg <= MemToRegM;
				writeReg <= WriteRegM;
			end if;
        end if;
    end process;

    AluoutW   <= mem(0);
    ReadDataW <= mem(1);
    RegWriteW <= regWrite;
    MemToRegW <= memToReg;
    WriteRegW <= writeReg;

end;