library ieee;
use ieee.std_logic_1164.all;

entity pipeline_register_E is
    port (
        clk         : in std_logic;
		Enable      : in std_logic;
        Clear       : in std_logic;
        RD1         : in std_logic_vector(31 downto 0);
        RD2         : in std_logic_vector(31 downto 0);
        RsD         : in std_logic_vector(4 downto 0);
        RtD         : in std_logic_vector(4 downto 0);
        RdD         : in std_logic_vector(4 downto 0);
        SignImmD    : in std_logic_vector(31 downto 0);
        RegWriteD   : in std_logic;
        MemToRegD   : in std_logic;
        MemWriteD   : in std_logic;
        ALUControlD : in std_logic_vector(2 downto 0);
        ALUSrcD     : in std_logic;
        RegDstD     : in std_logic;
        RD1E        : out std_logic_vector(31 downto 0);
        RD2E        : out std_logic_vector(31 downto 0);
        RsE         : out std_logic_vector(4 downto 0);
        RtE         : out std_logic_vector(4 downto 0);
        RdE         : out std_logic_vector(4 downto 0);
        SignImmE    : out std_logic_vector(31 downto 0);
        RegWriteE   : out std_logic;
        MemToRegE   : out std_logic;
        MemWriteE   : out std_logic;
        ALUControlE : out std_logic_vector(2 downto 0);
        ALUSrcE     : out std_logic;
        RegDstE     : out std_logic
    );
end;

architecture structure of pipeline_register_E is
    type ramtype_32 is array (2 downto 0) of std_logic_vector(31 downto 0);
    type ramtype_5 is array (2 downto 0) of std_logic_vector(4 downto 0);
    type ramtype_3 is array (0 downto 0) of std_logic_vector(2 downto 0);
    type ramtype_1 is array (6 downto 0) of std_logic;
    signal mem_32 : ramtype_32;
    signal mem_5  : ramtype_5;
    signal mem_3  : ramtype_3;
    signal mem_1  : ramtype_1;
begin
    process (clk) begin
        if rising_edge(clk) and Enable = '1' then
			if Clear = '1' then
				mem_1(0) <= '0';
				mem_1(2) <= '0';

				mem_5(0) <= "00000";
				mem_5(1) <= "00000";
				mem_5(2) <= "00000";
			else
				mem_1(0) <= RegWriteD;
				mem_1(1) <= MemToRegD;
				mem_1(2) <= MemWriteD;
				mem_1(4) <= ALUSrcD;
				mem_1(5) <= RegDstD;

				mem_3(0)  <= ALUControlD;
				mem_32(0) <= RD1;
				mem_32(1) <= RD2;
				mem_5(0)  <= RtD;
				mem_5(1)  <= RdD;
				mem_5(2)  <= RsD;
				mem_32(2) <= SignImmD;
			end if;
        end if;
        
    end process;

    RegWriteE <= mem_1(0);
    MemToRegE <= mem_1(1);
    MemWriteE <= mem_1(2);
    ALUSrcE   <= mem_1(4);
    RegDstE   <= mem_1(5);

    ALUControlE <= mem_3(0);
    RD1E        <= mem_32(0);
    RD2E        <= mem_32(1);
    RtE         <= mem_5(0);
    RdE         <= mem_5(1);
    RsE         <= mem_5(2);
    SignImmE    <= mem_32(2);

end;