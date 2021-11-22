-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity execution_unit is
    port (
        clk           : in std_logic;
		instrF        : in std_logic_vector(31 downto 0);
		PCplusF       : in std_logic_vector(31 downto 0);
		ClearD2       : in std_logic;
		StallD        : in std_logic;
		EqualAD       : in std_logic_vector(31 downto 0);
		EqualBD       : in std_logic_vector(31 downto 0);
		RD1D          : in std_logic_vector(31 downto 0);
		RD2D          : in std_logic_vector(31 downto 0);
		StallE        : in std_logic;
		FlushE        : in std_logic;
		SrcAE         : in std_logic_vector(31 downto 0);
		WriteDataE    : in std_logic_vector(31 downto 0);
		StallM        : in std_logic;
		FlushM        : in std_logic;
		ReadDataM     : in std_logic_vector(31 downto 0);
		FlushW        : in std_logic;
		BranchD_out   : out std_logic;
		JumpD_out     : out std_logic;
		ClearD_out    : out std_logic;
		PCsrcD_out    : out std_logic;
		PCnextbrD     : out std_logic_vector(31 downto 0);
		RsD_out       : out std_logic_vector(4 downto 0);
        RtD_out       : out std_logic_vector(4 downto 0);
		RegWriteE_out : out std_logic;
        MemtoRegE_out : out std_logic;
		RD1E          : out std_logic_vector(31 downto 0);
		RD2E          : out std_logic_vector(31 downto 0);
		RsE           : out std_logic_vector(4 downto 0);
        RtE_out       : out std_logic_vector(4 downto 0);
		WriteRegE_out : out std_logic_vector(4 downto 0);
		RegWriteM_out : out std_logic;
		MemToRegM_out : out std_logic;
		MemWriteM     : out std_logic;
		ALUOutM_out   : out std_logic_vector(31 downto 0);
		WriteDataM    : out std_logic_vector(31 downto 0);
		WriteRegM_out : out std_logic_vector(4 downto 0);
        RegWriteW     : out std_logic;
		ResultW       : out std_logic_vector(31 downto 0);
		WriteRegW     : out std_logic_vector(4 downto 0);
		InstrD_out    : out std_logic_vector(31 downto 0)
    );
end;

architecture structure of execution_unit is

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
	
	
	component controller is
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

    component mux2
        generic (w : integer := 8);
        port (
            d0 : in std_logic_vector(w - 1 downto 0);
            d1 : in std_logic_vector(w - 1 downto 0);
            s  : in std_logic;
            y  : out std_logic_vector(w - 1 downto 0)
        );
    end component;

    component pipeline_register_D is
        port (
            clk      : in std_logic;
			Enable   : in std_logic;
			Clear    : in std_logic;
			InstrF   : in std_logic_vector(31 downto 0);
			PCPlus4  : in std_logic_vector(31 downto 0);
			InstrD   : out std_logic_vector(31 downto 0);
			PCPlus4D : out std_logic_vector(31 downto 0)
        );
    end component;

    component pipeline_register_E is
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
    end component;

    component pipeline_register_M is
        port (
            clk        : in std_logic;
			Enable     : in std_logic;
			Clear      : in std_logic;
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
			Clear     : in std_logic;
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


	-- Signals
	
    -- Decode
	signal not_StallD, ClearD, ClearD_in, PCSrcD                                     : std_logic;
    signal RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD, JumpD, BranchD, EqualD : std_logic;
	signal ALUControlD                                    							 : std_logic_vector(2 downto 0);
    signal RsD, RtD, RdD                                    						 : std_logic_vector(4 downto 0);
    signal InstrD, PCPlusD, SignImmD, SignImmDsh, PCBranchD, PCJumpD                 : std_logic_vector(31 downto 0);
	
    -- Execute
	signal not_StallE, ZeroE                                 : std_logic;
    signal RegWriteE, MemToRegE, MemWriteE, ALUSrcE, RegDstE : std_logic;
    signal ALUControlE                                       : std_logic_vector(2 downto 0);
    signal WriteRegE, RtE, RdE                               : std_logic_vector(4 downto 0);
    signal SrcBE, SignImmE, ALUOutE		                     : std_logic_vector(31 downto 0);
	
    -- Memory
	signal not_StallM                      : std_logic;
    signal RegWriteM, MemToRegM            : std_logic;
    signal WriteRegM                       : std_logic_vector(4 downto 0);
    signal ALUOutM                         : std_logic_vector(31 downto 0);
	
    -- Writeback
    signal MemToRegW          : std_logic;
    signal AluoutW, ReadDataW : std_logic_vector(31 downto 0);
	
	
    begin
    -- assigning the different parts of the instruction

    RsD <= InstrD(25 downto 21);

    RtD <= InstrD(20 downto 16);

    RdD <= InstrD(15 downto 11);

	-- controller
	control : controller port map(op => InstrD(31 downto 26),
								  funct => InstrD(5 downto 0),
								  RegWriteD => RegWriteD,
								  MemToRegD => MemToRegD,
								  MemWriteD => MemWriteD,
								  BranchD => BranchD,
								  AluControlD => AluControlD,
								  AluSrcD => AluSrcD,
								  RegDstD => RegDstD,
								  JumpD => JumpD);
								  
	-- sign extender
    se : signext port map(InstrD(15 downto 0), SignImmD);
	
	-- shift left2
    immsh : sl2 port map(SignImmD, SignImmDsh);
	
	-- adder to add immediate to pc+4 as an option for branch
    pcadd2 : adder port map(PCPlusD, SignImmDsh, PCBranchD);
	
    -- next pc for jump
    PCJumpD <= PCPlusD(31 downto 28) & InstrD(25 downto 0) & "00";

	--Equal
	equalt : equal generic map(32) port map(RD1D => EqualAD, RD2D => EqualBD, EqualD => EqualD);
	PCSrcD <= BranchD and EqualD;

    -- choose branch or jump address as next pc value
    pcmux : mux2 generic map(32) port map(PCBranchD, PCJumpD, JumpD, PCnextbrD);

    -- mux for deciding into which register (out of the two specified in the instruction) to write
    wrmux : mux2 generic map(5) port map(d0 => RtE, d1 => RdE, s => RegDstE, y => WriteRegE);
	
	-- chose rd2 or sign extended value (add immediate to a register or add two values in registers)
    srcbmux : mux2 generic map(32) port map(WriteDataE, SignImmE, ALUSrcE, SrcBE);
	
	-- alu
    mainalu : alu port map(SrcAE, SrcBE, ALUControlE, ALUOutE, ZeroE);

	-- chose to store value from alu or memory to register
    resmux : mux2 generic map(32) port map(AluoutW, ReadDataW, MemToRegW, ResultW);

	
    --Register:
    --Decode
	
    not_StallD <= not StallD;
    ClearD <= PCSrcD or JumpD;
	ClearD_in <= ClearD or ClearD2;
    decode : pipeline_register_D port map(
		clk      => clk,
		Enable   => not_StallD,
		Clear    => ClearD_in,
		InstrF   => InstrF,
		PCPlus4  => PCPlusF,
		InstrD   => InstrD,
		PCPlus4D => PCPlusD);

    --Execute
	not_StallE <= not StallE;
    execute : pipeline_register_E port map(
        clk         => clk,
		Enable      => not_StallE,
		Clear       => FlushE,
        RD1         => RD1D,
        RD2         => RD2D,
        RsD         => RsD,
        RtD         => RtD,
        RdD         => RdD,
        SignImmD    => SignImmD,
        RegWriteD   => RegWriteD,
        MemToRegD   => MemToRegD,
        MemWriteD   => MemWriteD,
        ALUControlD => ALUControlD,
        ALUSrcD     => ALUSrcD,
        RegDstD     => RegDstD,
        RD1E        => RD1E,
        RD2E        => RD2E,
        RsE         => RsE,
        RtE         => RtE,
        RdE         => RdE,
        SignImmE    => SignImmE,
        RegWriteE   => RegWriteE,
        MemWriteE   => MemWriteE,
        MemToRegE   => MemToRegE,
        ALUControlE => ALUControlE,
        ALUSrcE     => ALUSrcE,
        RegDstE     => RegDstE);

    --Memory
	not_StallM <= not StallM;
    memory : pipeline_register_M port map(
        clk        => clk,
		Enable     => not_StallM,
		Clear      => FlushM,
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
		Clear     => FlushW,
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
		
	
	-- Hazard-Unit and Forwarding-Unit
	
	-- Outputs for hazard unit
	PCsrcD_out    <= PCsrcD;
	JumpD_out     <= JumpD;
	BranchD_out   <= BranchD;
	ClearD_out    <= ClearD;
	ALUOutM_out   <= AluoutM;
	RegWriteE_out <= RegWriteE;
	RegWriteM_out <= RegWriteM;
	WriteRegE_out <= WriteRegE;
	WriteRegM_out <= WriteRegM;
	MemtoRegE_out <= MemtoRegE;
	MemToRegM_out <= MemToRegM;
	RtE_out       <= RtE;
	RtD_out       <= RtD;
	RsD_out       <= RsD;
	InstrD_out    <= InstrD;
	
end;