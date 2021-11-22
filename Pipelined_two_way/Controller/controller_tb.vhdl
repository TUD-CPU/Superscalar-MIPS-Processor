
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_tb is
end;

architecture behavior of controller_tb is
    component controller
        port (
            op          : in std_logic_vector(5 downto 0);
            funct       : in std_logic_vector(5 downto 0);
            RegWriteD   : out std_logic;
            MemToRegD   : out std_logic;
            MemWriteD   : out std_logic;
            BranchD     : out std_logic;
            AluControlD : out std_logic_vector(2 downto 0);
            AluSrcD     : out std_logic;
            RegDstD     : out std_logic;
            JumpD       : out std_logic
        );
    end component;

    signal op, funct : std_logic_vector(5 downto 0);
    signal AluControlD : std_logic_vector(2 downto 0);
    signal RegWriteD, MemToRegD, MemWriteD, BranchD, AluSrcD, RegDstD, JumpD : std_logic;

begin
    con : controller port map(op, funct, RegWriteD, MemToRegD, MemWriteD, BranchD, AluControlD, AluSrcD, RegDstD, JumpD);
    process begin


        op <= "000000";
        wait for 10 ns;
        assert RegWriteD = '1' report "Error with RegWriteD";
        assert MemWriteD = '0' report "Error with MemWriteD";
        assert BranchD = '0' report "Error with BranchD";
        assert AluSrcD = '0' report "Error with AluSrcD";
        assert RegDstD = '1' report "Error with RegDstD";
        assert JumpD = '0' report "Error with JumpD";

        op <= "100011";
        wait for 10 ns;
        assert RegWriteD = '1' report "Error with RegWriteD";
        assert MemWriteD = '0' report "Error with MemWriteD";
        assert BranchD = '0' report "Error with BranchD";
        assert AluSrcD = '1' report "Error with AluSrcD";
        assert RegDstD = '0' report "Error with RegDstD";
        assert JumpD = '0' report "Error with JumpD";

        op <= "101011";
        wait for 10 ns;
        assert RegWriteD = '0' report "Error with RegWriteD";
        assert MemWriteD = '1' report "Error with MemWriteD";
        assert BranchD = '0' report "Error with BranchD";
        assert AluSrcD = '1' report "Error with AluSrcD";
        assert RegDstD = '0' report "Error with RegDstD";
        assert JumpD = '0' report "Error with JumpD";

        op <= "000100";
        wait for 10 ns;
        assert RegWriteD = '0' report "Error with RegWriteD";
        assert MemWriteD = '0' report "Error with MemWriteD";
        assert BranchD = '1' report "Error with BranchD";
        assert AluSrcD = '0' report "Error with AluSrcD";
        assert RegDstD = '0' report "Error with RegDstD";
        assert JumpD = '0' report "Error with JumpD";

        op <= "001000";
        wait for 10 ns;
        assert RegWriteD = '1' report "Error with RegWriteD";
        assert MemWriteD = '0' report "Error with MemWriteD";
        assert BranchD = '0' report "Error with BranchD";
        assert AluSrcD = '1' report "Error with AluSrcD";
        assert RegDstD = '0' report "Error with RegDstD";
        assert JumpD = '0' report "Error with JumpD";

        op <= "000010";
        wait for 10 ns;
        assert RegWriteD = '0' report "Error with RegWriteD";
        assert MemWriteD = '0' report "Error with MemWriteD";
        assert BranchD = '0' report "Error with BranchD";
        assert AluSrcD = '0' report "Error with AluSrcD";
        assert RegDstD = '0' report "Error with RegDstD";
        assert JumpD = '1' report "Error with JumpD";

        op <= "000000";
        funct <= "100000";
        wait for 10 ns;
        assert AluControlD = "010" report "Error with JumpD";

        funct <= "100010";
        wait for 10 ns;
        assert AluControlD = "110" report "Error with JumpD";

        funct <= "100100";
        wait for 10 ns;
        assert AluControlD = "000" report "Error with JumpD";

        funct <= "100101";
        wait for 10 ns;
        assert AluControlD = "001" report "Error with JumpD";

        funct <= "101010";
        wait for 10 ns;
        assert AluControlD = "111" report "Error with JumpD";

        wait;
    end process;
end;
