
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maindecoder_tb is
end;

architecture behavior of maindecoder_tb is
    component maindecoder
        port (
            op       : in std_logic_vector(5 downto 0);
            memtoreg : out std_logic;
            memwrite : out std_logic;
            branch   : out std_logic;
            alusrc   : out std_logic;
            regdst   : out std_logic;
            regwrite : out std_logic;
            jump     : out std_logic;
            aluop    : out std_logic_vector(1 downto 0)
        );
    end component;

    signal op : std_logic_vector(5 downto 0);
    signal aluop       : std_logic_vector(1 downto 0);
    signal memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump : std_logic;

begin
    maindec : maindecoder port map(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, aluop);
    process begin
        op <= "000000";
        wait for 10 ns;
        assert regwrite     = '1' report "Error with regwrite";
        assert regdst       = '1' report "Error with regdst";
        assert alusrc       = '0' report "Error with alusrc";
        assert branch       = '0' report "Error with branch";
        assert memwrite     = '0' report "Error with memwrite";
        assert memtoreg     = '0' report "Error with memtoreg";
        assert jump         = '0' report "Error with jump";
        assert aluop        = "10" report "Error with aluop";

        op <= "100011";
        wait for 10 ns;
        assert regwrite     = '1' report "Error with regwrite";
        assert regdst       = '0' report "Error with regdst";
        assert alusrc       = '1' report "Error with alusrc";
        assert branch       = '0' report "Error with branch";
        assert memwrite     = '0' report "Error with memwrite";
        assert memtoreg     = '1' report "Error with memtoreg";
        assert jump         = '0' report "Error with jump";
        assert aluop        = "00" report "Error with aluop";
        
        op <= "101011";
        wait for 10 ns;
        assert regwrite     = '0' report "Error with regwrite";
        assert regdst       = '0' report "Error with regdst";
        assert alusrc       = '1' report "Error with alusrc";
        assert branch       = '0' report "Error with branch";
        assert memwrite     = '1' report "Error with memwrite";
        assert memtoreg     = '0' report "Error with memtoreg";
        assert jump         = '0' report "Error with jump";
        assert aluop        = "00" report "Error with aluop";

        op <= "000100";
        wait for 10 ns;
        assert regwrite     = '0' report "Error with regwrite";
        assert regdst       = '0' report "Error with regdst";
        assert alusrc       = '0' report "Error with alusrc";
        assert branch       = '1' report "Error with branch";
        assert memwrite     = '0' report "Error with memwrite";
        assert memtoreg     = '0' report "Error with memtoreg";
        assert jump         = '0' report "Error with jump";
        assert aluop        = "00" report "Error with aluop";

        op <= "001000";
        wait for 10 ns;
        assert regwrite     = '1' report "Error with regwrite";
        assert regdst       = '0' report "Error with regdst";
        assert alusrc       = '1' report "Error with alusrc";
        assert branch       = '0' report "Error with branch";
        assert memwrite     = '0' report "Error with memwrite";
        assert memtoreg     = '0' report "Error with memtoreg";
        assert jump         = '0' report "Error with jump";
        assert aluop        = "00" report "Error with aluop";
        wait for 10 ns;

        op <= "000010";
        wait for 10 ns;
        assert regwrite     = '0' report "Error with regwrite";
        assert regdst       = '0' report "Error with regdst";
        assert alusrc       = '0' report "Error with alusrc";
        assert branch       = '0' report "Error with branch";
        assert memwrite     = '0' report "Error with memwrite";
        assert memtoreg     = '0' report "Error with memtoreg";
        assert jump         = '1' report "Error with jump";
        assert aluop        = "00" report "Error with aluop";

        wait;
    end process;
end;
