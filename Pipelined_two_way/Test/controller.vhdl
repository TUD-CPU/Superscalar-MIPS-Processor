-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity controller is
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
end;

architecture structure of controller is
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

    component aludecoder
        port (
            funct       : in std_logic_vector(5 downto 0);
            aluop       : in std_logic_vector(1 downto 0);
            AluControlE : out std_logic_vector(2 downto 0)
        );
    end component;

    signal aluop : std_logic_vector(1 downto 0);

begin
    md : maindecoder port map(op, MemToRegD, MemWriteD, BranchD, AluSrcD, RegDstD, RegWriteD, JumpD, aluop);
    ad : aludecoder port map(funct, aluop, AluControlD);
end;