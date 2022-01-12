library ieee;
use ieee.std_logic_1164.all;

entity pipeline_register_E_tb is
end pipeline_register_E_tb;

architecture test of pipeline_register_E_tb is

    component pipeline_register_E is
        port (
            clk         : in std_logic;
            RD1         : in std_logic_vector(31 downto 0);
            RD2         : in std_logic_vector(31 downto 0);
            RtD         : in std_logic_vector(4 downto 0);
            RdD         : in std_logic_vector(4 downto 0);
            SignExtendD : in std_logic_vector(31 downto 0);
            PCPlus4D    : in std_logic_vector(31 downto 0);
            RegWriteD   : in std_logic;
            MemToRegD   : in std_logic;
            MemWriteD   : in std_logic;
            BranchD     : in std_logic;
            ALUControlD : in std_logic;
            ALUSrcD     : in std_logic;
            RegDstD     : in std_logic;
            SrcAE       : out std_logic_vector(31 downto 0);
            WriteDataE  : out std_logic_vector(31 downto 0);
            RtE         : out std_logic_vector(4 downto 0);
            RdE         : out std_logic_vector(4 downto 0);
            SignImmE    : out std_logic_vector(31 downto 0);
            PCPlus4E    : out std_logic_vector(31 downto 0);
            RegWriteE   : out std_logic;
            MemWriteE   : out std_logic;
            MemToRegE   : out std_logic;
            BranchE     : out std_logic;
            ALUControlE : out std_logic_vector(2 downto 0);
            ALUSrcE     : out std_logic;
            RegDstE     : out std_logic
        );
    end component;

    signal clk, RegWriteD, MemToRegD, MemWriteD, BranchD, ALUControlD, ALUSrcD, RegDstD, RegWriteE, MemWriteE, MemToRegE, BranchE, ALUSrcE, RegDstE : std_logic;
    signal ALUControlE                                                                                                                              : std_logic_vector(2 downto 0);
    signal RtD, RdD, RtE, RdE                                                                                                                       : std_logic_vector(4 downto 0);
    signal RD1, RD2, SignExtendD, PCPlus4D, SrcAE, WriteDataE, SignImmE, PCPlus4E                                                                   : std_logic_vector(31 downto 0);

begin
    pipeline_register_E_1 : pipeline_register_E port map(
        clk         => clk,
        RD1         => RD1,
        RD2         => RD2,
        RtD         => RtD,
        RdD         => RdD,
        SignExtendD => SignExtendD,
        PCPlus4D    => PCPlus4D,
        RegWriteD   => RegWriteD,
        MemToRegD   => MemToRegD,
        MemWriteD   => MemWriteD,
        BranchD     => BranchD,
        ALUControlD => ALUControlD,
        ALUSrcD     => ALUSrcD,
        RegDstD     => RegDstD,
        SrcAE       => SrcAE,
        WriteDataE  => WriteDataE,
        RtE         => RtE,
        RdE         => RdE,
        SignImmE    => SignImmE,
        PCPlus4E    => PCPlus4E,
        RegWriteE   => RegWriteE,
        MemWriteE   => MemWriteE,
        MemToRegE   => MemToRegE,
        BranchE     => BranchE,
        ALUControlE => ALUControlE,
        ALUSrcE     => ALUSrcE,
        RegDstE     => RegDstE);

    process begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk       <= '0';
        PCPlus4D  <= x"00001111";
        ALUSrcD   <= '1';
        BranchD   <= '1';
        MemToRegD <= '1';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;

        wait;
    end process;
end;