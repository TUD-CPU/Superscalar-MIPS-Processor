-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity datapath is
    port (
        clk           : in std_logic;
        reset         : in std_logic;
        ForwardAE     : in std_logic_vector(1 downto 0);
        ForwardBE     : in std_logic_vector(1 downto 0);
		ForwardAD     : in std_logic;
		ForwardBD     : in std_logic;
        StallF        : in std_logic;
        StallD        : in std_logic;
        FlushE        : in std_logic;
        MemToRegD     : in std_logic;
        ALUSrcD       : in std_logic;
        RegDstD       : in std_logic;
        RegWriteD     : in std_logic;
        jump          : in std_logic;
        MemWriteD     : in std_logic;
        BranchD       : in std_logic;
        ALUControlD   : in std_logic_vector(2 downto 0);
        OpD           : out std_logic_vector(5 downto 0);
        FunctD        : out std_logic_vector(5 downto 0);
        RsE_out       : buffer std_logic_vector(4 downto 0);
        RtE_out       : buffer std_logic_vector(4 downto 0);
        RsD_out       : buffer std_logic_vector(4 downto 0);
        RtD_out       : buffer std_logic_vector(4 downto 0);
		RegWriteE_out : buffer std_logic;
        RegWriteM_out : buffer std_logic;
        RegWriteW_out : buffer std_logic;
        MemtoRegE_out : buffer std_logic;
		MemtoRegM_out : buffer std_logic;
		WriteRegE_out : buffer std_logic_vector(4 downto 0);
        WriteRegM_out : buffer std_logic_vector(4 downto 0);
        WriteRegW_out : buffer std_logic_vector(4 downto 0);
		InstrD_out    : buffer std_logic_vector(31 downto 0)
    );
end;

architecture structure of datapath is
    component alu
        port (
            a          : in std_logic_vector(31 downto 0);
            b          : in std_logic_vector(31 downto 0);
            alucontrol : in std_logic_vector(2 downto 0);
            result     : buffer std_logic_vector(31 downto 0);
            zero       : out std_logic
        );
    end component;
	
	component equal is
		generic(w: integer := 32);
		port (
			RD1D: in std_logic_vector(w-1 downto 0);
			RD2D: in std_logic_vector(w-1 downto 0);
			EqualD: out std_logic
		);
	end component;

    component regfile
        port (
            clk : in std_logic;
            we3 : in std_logic;
            a1  : in std_logic_vector(4 downto 0);
            a2  : in std_logic_vector(4 downto 0);
            a3  : in std_logic_vector(4 downto 0);
            wd3 : in std_logic_vector(31 downto 0);
            rd1 : buffer std_logic_vector(31 downto 0);
            rd2 : buffer std_logic_vector(31 downto 0)
        );
    end component;

    component adder
        port (
            a : in std_logic_vector(31 downto 0);
            b : in std_logic_vector(31 downto 0);
            y : out std_logic_vector(31 downto 0)
        );
    end component;

    component sl2
        port (
            a : in std_logic_vector(31 downto 0);
            y : out std_logic_vector(31 downto 0)
        );
    end component;

    component signext
        port (
            a    : in std_logic_vector(15 downto 0);
            aext : out std_logic_vector(31 downto 0)
        );
    end component;

    component syncresff
        port (
            clk    : in std_logic;
            reset  : in std_logic;
            StallF : in std_logic;
            d      : in std_logic_vector(31 downto 0);
            q      : buffer std_logic_vector(31 downto 0)
        );
    end component;

    component mux2
        generic (w : integer := 8);
        port (
            d0 : in std_logic_vector(w - 1 downto 0);
            d1 : in std_logic_vector(w - 1 downto 0);
            s  : in std_logic;
            y  : out std_logic_vector(w - 1 downto 0)
        );
    end component;

    component data_memory is
        generic (size : integer := 63);
        port (
            clk      : in std_logic;
            addr     : in std_logic_vector(31 downto 0);
            data_in  : in std_logic_vector(31 downto 0);
            memwrite : in std_logic;
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component instr_mem is
        port (
            pc    : in std_logic_vector(31 downto 0);
            instr : out std_logic_vector(31 downto 0)
        );
    end component;

    component pipeline_register_D is
        port (
            clk      : in std_logic;
			StallD   : in std_logic;
			Clear    : in std_logic;
			InstrF    : in std_logic_vector(31 downto 0);
			PCPlus4  : in std_logic_vector(31 downto 0);
			InstrD   : out std_logic_vector(31 downto 0);
			PCPlus4D : out std_logic_vector(31 downto 0)
        );
    end component;

    component pipeline_register_E is
        port (
            clk         : in std_logic;
            RD1         : in std_logic_vector(31 downto 0);
            RD2         : in std_logic_vector(31 downto 0);
            RsD         : in std_logic_vector(4 downto 0);
            RtD         : in std_logic_vector(4 downto 0);
            RdD         : in std_logic_vector(4 downto 0);
            SignImmD : in std_logic_vector(31 downto 0);
            PCPlus4D    : in std_logic_vector(31 downto 0);
            RegWriteD   : in std_logic;
            MemToRegD   : in std_logic;
            MemWriteD   : in std_logic;
            FlushE      : in std_logic;
            ALUControlD : in std_logic_vector(2 downto 0);
            ALUSrcD     : in std_logic;
            RegDstD     : in std_logic;
            SrcAE       : out std_logic_vector(31 downto 0);
            WriteDataE  : out std_logic_vector(31 downto 0);
            RsE         : out std_logic_vector(4 downto 0);
            RtE         : out std_logic_vector(4 downto 0);
            RdE         : out std_logic_vector(4 downto 0);
            SignImmE    : out std_logic_vector(31 downto 0);
            PCPlus4E    : out std_logic_vector(31 downto 0);
            RegWriteE   : out std_logic;
            MemToRegE   : out std_logic;
            MemWriteE   : out std_logic;
            ALUControlE : out std_logic_vector(2 downto 0);
            ALUSrcE     : out std_logic;
            RegDstE     : out std_logic
        );
    end component;

    component pipeline_register_M is
        port (
            clk        : in std_logic;
            ALUOutE    : in std_logic_vector(31 downto 0);
            WriteDataE : in std_logic_vector(31 downto 0);
            WriteRegE  : in std_logic_vector(4 downto 0);
            RegWriteE  : in std_logic;
            MemToRegE  : in std_logic;
            MemWriteE  : in std_logic;

            ALUOutM    : out std_logic_vector(31 downto 0);
            WriteDataM : out std_logic_vector(31 downto 0);
            WriteRegM  : out std_logic_vector(4 downto 0);
            RegWriteM  : out std_logic;
            MemToRegM  : out std_logic;
            MemWriteM  : out std_logic
        );
    end component;

    component pipeline_register_W is
        port (
            clk       : in std_logic;
            AluoutM   : in std_logic_vector(31 downto 0);
            ReadDataM : in std_logic_vector(31 downto 0);
            RegWriteM : in std_logic;
            MemToRegM : in std_logic;
            WriteRegM : in std_logic_vector(4 downto 0);
            AluoutW   : out std_logic_vector(31 downto 0);
            ReadDataW : out std_logic_vector(31 downto 0);
            RegWriteW : out std_logic;
            MemToRegW : out std_logic;
            WriteRegW : out std_logic_vector(4 downto 0)
        );
    end component;

    component mux4 is
        generic (w : integer := 8);
        port (
            d0 : in std_logic_vector(w - 1 downto 0);
            d1 : in std_logic_vector(w - 1 downto 0);
            d2 : in std_logic_vector(w - 1 downto 0);
            d3 : in std_logic_vector(w - 1 downto 0);
            s  : in std_logic_vector(1 downto 0);
            y  : out std_logic_vector(w - 1 downto 0)
        );
    end component;

    --Fetch
    signal not_StallF, ClearD                           : std_logic;
    signal PC, PCF, PCPlus4F, InstrF, PCBranchF 		: std_logic_vector(31 downto 0);
    --Decode
    signal not_clk, not_StallD, EqualD, PCSrcD                             						  : std_logic;
    signal RtD, RdD, RsD                                    									  : std_logic_vector(4 downto 0);
    signal RD1, RD2, SignImmD, SignImmDsh, PCBranchD, PCPlus4D, InstrD, PCJumpD, EqualAD, EqualBD : std_logic_vector(31 downto 0);
    --Execute
    signal ZeroE, RegWriteE, MemWriteE, MemToRegE, ALUSrcE, RegDstE                                      		  : std_logic;
    signal ALUControlE                                                                                            : std_logic_vector(2 downto 0);
    signal WriteRegE, RdE, RtE, RsE                                                                               : std_logic_vector(4 downto 0);
    signal RD1E, RD2E, SrcAE, SrcBE, WriteDataE, SignImmE, PCPlus4E, ALUOutE									  : std_logic_vector(31 downto 0);
    --Memory
    signal MemToRegM, MemWriteM, RegWriteM 		: std_logic;
    signal WriteRegM                                    : std_logic_vector(4 downto 0);
    signal ALUOutM, WriteDataM, ReadDataM 				: std_logic_vector(31 downto 0);
    --Writeback
    signal MemToRegW, RegWriteW        : std_logic;
    signal WriteRegW                   : std_logic_vector(4 downto 0);
    signal AluoutW, ReadDataW, ResultW : std_logic_vector(31 downto 0);
    begin
    -- assigning the different parts of the instruction
    OpD <= InstrD(31 downto 26);

    FunctD <= InstrD(5 downto 0);

    RsD <= InstrD(25 downto 21);

    RtD <= InstrD(20 downto 16);

    RdD <= InstrD(15 downto 11);

    -- next pc logic
    PCJumpD <= PCPlus4D(31 downto 28) & InstrD(25 downto 0) & "00";

    -- pc register
    not_StallF <= not StallF;
    pcreg : syncresff port map(clk => clk, reset => reset, StallF => not_StallF, d => pc, q => PCF);

	--Equal
	equalt : equal generic map(32) port map(RD1D => EqualAD, RD2D => EqualBD, EqualD => EqualD);
	
	--Branch ForwardAD
	branchMuxA : mux2 generic map(32) port map(RD1, ALUOutM, ForwardAD, EqualAD);
	
	--Branch ForwardBD
	branchMuxB : mux2 generic map(32) port map(RD2, ALUOutM, ForwardBD, EqualBD);

    -- adder for pc+4
    pcadd1 : adder port map(PCF, x"00000004", PCPlus4F);

    -- shift left2
    immsh : sl2 port map(SignImmD, SignImmDsh);

    -- adder to add immediate to pc+4 as an option for branch
    pcadd2 : adder port map(PCPlus4D, SignImmDsh, PCBranchD);

    -- mux to chose between branch address or pc+4
    PCSrcD <= BranchD and EqualD;
    pcbrmux : mux2 generic map(32) port map(PCPlus4F, PCBranchD, PCSrcD, PCBranchF);

    -- chose signimmsh+pc+4 or jump address as next pc value
    pcmux : mux2 generic map(32) port map(PCBranchF, PCJumpD, jump, PC);

    -- invert clk
    not_clk <= not clk;

    -- register file logic
    rf : regfile port map(clk => not_clk, we3 => RegWriteW, a1 => InstrD(25 downto 21), a2 => InstrD(20 downto 16), a3 => WriteRegW, wd3 => ResultW, rd1 => RD1, rd2 => RD2);

    -- mux for deciding into which register (out of the two specified in the instruction) to write
    wrmux : mux2 generic map(5) port map(d0 => RtE, d1 => RdE, s => RegDstE, y => WriteRegE);

    -- chose to store value from alu or memory to register
    resmux : mux2 generic map(32) port map(AluoutW, ReadDataW, MemToRegW, ResultW);

    -- sign extender
    se : signext port map(InstrD(15 downto 0), SignImmD);

    -- chose rd2 or sign extended value (add immediate to a register or add two values in registers)
    srcbmux : mux2 generic map(32) port map(WriteDataE, SignImmE, ALUSrcE, SrcBE);

    -- alu
    mainalu : alu port map(SrcAE, SrcBE, ALUControlE, ALUOutE, ZeroE);

    --instruction memory
    instMem : instr_mem port map(PCF, InstrF);

    --data memory
    dataMem : data_memory generic map(8192) port map(clk, ALUOutM, WriteDataM, MemWriteM, ReadDataM);

    --Register:
    --Decode
    not_StallD <= not StallD;
    ClearD <= PCSrcD or jump;
    decode : pipeline_register_D port map(
		clk      => clk,
		StallD   => not_StallD,
		Clear    => ClearD,
		InstrF   => InstrF,
		PCPlus4  => PCPlus4F,
		InstrD   => InstrD,
		PCPlus4D => PCPlus4D);

    --Execute
    execute : pipeline_register_E port map(
        clk         => clk,
        RD1         => RD1,
        RD2         => RD2,
        RsD         => RsD,
        RtD         => RtD,
        RdD         => RdD,
        SignImmD    => SignImmD,
        PCPlus4D    => PCPlus4D,
        RegWriteD   => RegWriteD,
        MemToRegD   => MemToRegD,
        MemWriteD   => MemWriteD,
        FlushE      => FlushE,
        ALUControlD => ALUControlD,
        ALUSrcD     => ALUSrcD,
        RegDstD     => RegDstD,
        SrcAE       => RD1E,
        WriteDataE  => RD2E,
        RsE         => RsE,
        RtE         => RtE,
        RdE         => RdE,
        SignImmE    => SignImmE,
        PCPlus4E    => PCPlus4E,
        RegWriteE   => RegWriteE,
        MemWriteE   => MemWriteE,
        MemToRegE   => MemToRegE,
        ALUControlE => ALUControlE,
        ALUSrcE     => ALUSrcE,
        RegDstE     => RegDstE);

    --Memory
    memory : pipeline_register_M port map(
        clk        => clk,
        ALUOutE    => ALUOutE,
        WriteDataE => WriteDataE,
        WriteRegE  => WriteRegE,
        RegWriteE  => RegWriteE,
        MemToRegE  => MemToRegE,
        MemWriteE  => MemWriteE,
        ALUOutM    => ALUOutM,
        WriteDataM => WriteDataM,
        WriteRegM  => WriteRegM,
        RegWriteM  => RegWriteM,
        MemToRegM  => MemToRegM,
        MemWriteM  => MemWriteM);

    --Writeback
    writeback : pipeline_register_W port map(
        clk       => clk,
        AluoutM   => AluoutM,
        ReadDataM => ReadDataM,
        RegWriteM => RegWriteM,
        MemToRegM => MemToRegM,
        WriteRegM => WriteRegM,
        AluoutW   => AluoutW,
        ReadDataW => ReadDataW,
        RegWriteW => RegWriteW,
        MemToRegW => MemToRegW,
        WriteRegW => WriteRegW);
		
	
	--Regarding Hazard-Unit
	
	-- Outputs for hazard unit
	RegWriteE_out <= RegWriteE;
	RegWriteM_out <= RegWriteM;
	RegWriteW_out <= RegWriteW;
	WriteRegE_out <= WriteRegE;
	WriteRegM_out <= WriteRegM;
	WriteRegW_out <= WriteRegW;
	MemtoRegE_out <= MemtoRegE;
	MemToRegM_out <= MemToRegM;
	RtE_out       <= RtE;
	RsE_out       <= RsE;
	RtD_out       <= RtD;
	RsD_out       <= RsD;

    
    muxAE : mux4 generic map(w => 32) port map(d0 => RD1E, d1 => ResultW, d2 => ALUOutM, d3 => x"00000000", s => ForwardAE, y => SrcAE);

    muxBE : mux4 generic map(w => 32) port map(d0 => RD2E, d1 => ResultW, d2 => ALUOutM, d3 => x"00000000", s => ForwardBE, y => WriteDataE);
	
	--for finding the end of a program
    InstrD_out <= InstrD;
end;