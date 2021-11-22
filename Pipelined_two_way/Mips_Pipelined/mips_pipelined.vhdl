-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity mips_pipelined is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        instrD1_out : out std_logic_vector(31 downto 0);
        instrD2_out : out std_logic_vector(31 downto 0)
    );
end;

architecture structure of mips_pipelined is

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
	
	component instr_mem is
	port (
		pc1: in std_logic_vector(31 downto 0);
		pc2: in std_logic_vector(31 downto 0);
		instr1: out std_logic_vector(31 downto 0);
		instr2: out std_logic_vector(31 downto 0)
	);
	end component;
	
	component mux2 is
    generic(w: integer := 8);
    port(
        d0: in std_logic_vector(w-1 downto 0);
        d1: in std_logic_vector(w-1 downto 0);
        s: in std_logic;
        y: out std_logic_vector(w-1 downto 0)
    );
	end component;
	
	component regfile is
	  port (
		clk: in std_logic;
		we3: in std_logic;
		we6: in std_logic;
		a1: in std_logic_vector(4 downto 0);
		a2: in std_logic_vector(4 downto 0);
		a3: in std_logic_vector(4 downto 0);
		a4: in std_logic_vector(4 downto 0);
		a5: in std_logic_vector(4 downto 0);
		a6: in std_logic_vector(4 downto 0);
		wd3: in std_logic_vector(31 downto 0);
		wd6: in std_logic_vector(31 downto 0);
		rd1: buffer std_logic_vector(31 downto 0);
		rd2: buffer std_logic_vector(31 downto 0);
		rd3: buffer std_logic_vector(31 downto 0);
		rd4: buffer std_logic_vector(31 downto 0)
	  );
	end component;
	
	component execution_unit is
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
	end component;
	
	component Forwarding_Unit is
    port (
		RD1D1       : in std_logic_vector(31 downto 0);
		RD2D1       : in std_logic_vector(31 downto 0);
		RD1E1       : in std_logic_vector(31 downto 0);
		RD2E1       : in std_logic_vector(31 downto 0);
        RsE1        : in std_logic_vector(4 downto 0);
        RtE1        : in std_logic_vector(4 downto 0);
        RsD1        : in std_logic_vector(4 downto 0);
        RtD1        : in std_logic_vector(4 downto 0);
		RegWriteE1  : in std_logic;
        RegWriteM1  : in std_logic;
        RegWriteW1  : in std_logic;
		WriteRegE1  : in std_logic_vector(4 downto 0);
        WriteRegM1  : in std_logic_vector(4 downto 0);
        WriteRegW1  : in std_logic_vector(4 downto 0);
        ALUOutM1    : in std_logic_vector(31 downto 0);
        ResultW1    : in std_logic_vector(31 downto 0);
		
		RD1D2       : in std_logic_vector(31 downto 0);
		RD2D2       : in std_logic_vector(31 downto 0);
		RD1E2       : in std_logic_vector(31 downto 0);
		RD2E2       : in std_logic_vector(31 downto 0);
		RsE2        : in std_logic_vector(4 downto 0);
        RtE2        : in std_logic_vector(4 downto 0);
        RsD2        : in std_logic_vector(4 downto 0);
        RtD2        : in std_logic_vector(4 downto 0);
		RegWriteE2  : in std_logic;
        RegWriteM2  : in std_logic;
        RegWriteW2  : in std_logic;
		WriteRegE2  : in std_logic_vector(4 downto 0);
        WriteRegM2  : in std_logic_vector(4 downto 0);
        WriteRegW2  : in std_logic_vector(4 downto 0);
        ALUOutM2    : in std_logic_vector(31 downto 0);
        ResultW2    : in std_logic_vector(31 downto 0);
		
		EqualAD1    : out std_logic_vector(31 downto 0);
		EqualBD1    : out std_logic_vector(31 downto 0);
        SrcAE1      : out std_logic_vector(31 downto 0);
        WriteDataE1 : out std_logic_vector(31 downto 0);		
		
		EqualAD2    : out std_logic_vector(31 downto 0);
		EqualBD2    : out std_logic_vector(31 downto 0);
        SrcAE2      : out std_logic_vector(31 downto 0);
        WriteDataE2 : out std_logic_vector(31 downto 0)
    );
	end component;
	
	component Fetch_Unit is
    port (
		clk          : in std_logic;
		reset        : in std_logic;
		StallF       : in std_logic;
		Stall2       : in std_logic;
		JumpD1       : in std_logic;
		PCsrcD1      : in std_logic;
		JumpD2       : in std_logic;
		PCsrcD2      : in std_logic;
		PC1          : in std_logic_vector(31 downto 0);
		PC2          : in std_logic_vector(31 downto 0);
        PC_out       : out std_logic_vector(31 downto 0);
        PCplus4_out  : out std_logic_vector(31 downto 0);
        PCplus8_out  : out std_logic_vector(31 downto 0)
    );
	end component;
	
	component Hazard_Unit is
    port (
		InstrF1    : in std_logic_vector(31 downto 0);
		InstrF2    : in std_logic_vector(31 downto 0);
        RsE1       : in std_logic_vector(4 downto 0);
        RtE1       : in std_logic_vector(4 downto 0);
        RsD1       : in std_logic_vector(4 downto 0);
        RtD1       : in std_logic_vector(4 downto 0);
		RegWriteE1 : in std_logic;
        MemtoRegE1 : in std_logic;
		MemtoRegM1 : in std_logic;
		MemWriteM1 : in std_logic;
		ALUOutM1   : in std_logic_vector(31 downto 0);
		WriteRegE1 : in std_logic_vector(4 downto 0);
        WriteRegM1 : in std_logic_vector(4 downto 0);
		BranchD1   : in std_logic;
		RsE2       : in std_logic_vector(4 downto 0);
		RtE2       : in std_logic_vector(4 downto 0);
        RsD2       : in std_logic_vector(4 downto 0);
        RtD2       : in std_logic_vector(4 downto 0);
		RegWriteE2 : in std_logic;
        MemtoRegE2 : in std_logic;
		MemtoRegM2 : in std_logic;
		MemWriteM2 : in std_logic;
		ALUOutM2   : in std_logic_vector(31 downto 0);
		WriteRegE2 : in std_logic_vector(4 downto 0);
        WriteRegM2 : in std_logic_vector(4 downto 0);
		BranchD2   : in std_logic;
		StallF     : out std_logic;
        StallD1    : out std_logic;
        StallE1    : out std_logic;
        FlushE1    : out std_logic;
        FlushM1    : out std_logic;
        StallD2    : out std_logic;
        StallE2    : out std_logic;
        StallM2    : out std_logic;
        FlushE2    : out std_logic;
		FlushM2    : out std_logic;
        FlushW2    : out std_logic;
		Stall2     : out std_logic
    );
	end component;
	
    signal StallF, StallD1, StallE1, StallM1, FlushE1, FlushM1, FlushW1, StallD2, StallE2, StallM2, FlushE2, FlushM2, FlushW2, Stall2, not_clk : std_logic;
    signal JumpD1, JumpD2, PCsrcD1, PCsrcD2, RegWriteE1, RegWriteE2, MemtoRegE1, MemtoRegE2, RegWriteM1, RegWriteM2 : std_logic;
    signal BranchD1, BranchD2, MemToRegM1, MemToRegM2, MemWriteM1, MemWriteM2, RegWriteW1, RegWriteW2, ClearD1, ClearD2: std_logic;
    signal RsD1, RsD2, RtD1, RtD2, RsE1, RsE2, RtE1, RtE2, WriteRegE1, WriteRegE2, WriteRegM1, WriteRegM2, WriteRegW1, WriteRegW2 : std_logic_vector(4 downto 0);
    signal PC, PCplus4, PCplus8 : std_logic_vector(31 downto 0);
    signal instrF1, instrF2, instr2, InstrD1, InstrD2: std_logic_vector(31 downto 0);
    signal EqualAD1, EqualBD1, EqualAD2, EqualBD2: std_logic_vector(31 downto 0);
    signal RD1D1, RD2D1, RD1D2, RD2D2, RD1E1, RD2E1, RD1E2, RD2E2: std_logic_vector(31 downto 0);
    signal SrcAE1, SrcAE2, WriteDataE1, WriteDataE2, ReadDataM1, ReadDataM2: std_logic_vector(31 downto 0);
    signal PCnextD1, PCnextD2 : std_logic_vector(31 downto 0);
    signal ALUOutM1, ALUOutM2, WriteDataM1, WriteDataM2, ResultW1, ResultW2 : std_logic_vector(31 downto 0);
begin
    
	not_clk <= not clk;
	registerfile : regfile port map(clk => not_clk,
									we3 => RegWriteW1,
									we6 => RegWriteW2,
									a1 => InstrD1(25 downto 21),
									a2 => InstrD1(20 downto 16),
									a3 => WriteRegW1,
									a4 => InstrD2(25 downto 21),
									a5 => InstrD2(20 downto 16),
									a6 => WriteRegW2,
									wd3 => ResultW1,
									wd6 => ResultW2,
									rd1 => RD1D1,
									rd2 => RD2D1,
									rd3 => RD1D2,
									rd4 => RD2D2 );
									
	fetch : Fetch_Unit port map(clk => clk,
								reset => reset,
								StallF => StallF,
								Stall2 => Stall2,
								JumpD1 => JumpD1,
								PCsrcD1 => PCsrcD1,
								JumpD2 => JumpD2,
								PCsrcD2 => PCsrcD2,
								PC1 => PCnextD1,
								PC2 => PCnextD2,
								PC_out => PC,
								PCplus4_out => PCplus4,
								PCplus8_out => PCplus8);
								
    forwarding : Forwarding_Unit port map(  RD1D1 => RD1D1,
											RD2D1 => RD2D1,
											RD1E1 => RD1E1,
											RD2E1 => RD2E1,
											RsE1 => RsE1,
											RtE1 => RtE1,
											RsD1 => RsD1,
											RtD1 => RtD1,
											RegWriteE1 => RegWriteE1,
											RegWriteM1 => RegWriteM1,
											RegWriteW1 => RegWriteW1,
											WriteRegE1 => WriteRegE1,
											WriteRegM1 => WriteRegM1,
											WriteRegW1 => WriteRegW1,
											ALUOutM1 => ALUOutM1,
											ResultW1 => ResultW1,
											RD1D2 => RD1D2,
											RD2D2 => RD2D2,
											RD1E2 => RD1E2,
											RD2E2 => RD2E2,
											RsE2 => RsE2,
											RtE2 => RtE2,
											RsD2 => RsD2,
											RtD2 => RtD2,
											RegWriteE2 => RegWriteE2,
											RegWriteM2 => RegWriteM2,
											RegWriteW2 => RegWriteW2,
											WriteRegE2 => WriteRegE2,
											WriteRegM2 => WriteRegM2,
											WriteRegW2 => WriteRegW2,
											ALUOutM2 => ALUOutM2,
											ResultW2 => ResultW2,
											EqualAD1 => EqualAD1,
											EqualBD1 => EqualBD1,
											SrcAE1 => SrcAE1,
											WriteDataE1 => WriteDataE1,									
											EqualAD2 => EqualAD2,
											EqualBD2 => EqualBD2,
											SrcAE2 => SrcAE2,
											WriteDataE2 => WriteDataE2 );
										
	hazardUnit : Hazard_Unit port map( InstrF1 => InstrF1,
										InstrF2 => InstrF2,
										RsE1 => RsE1,
										RtE1 => RtE1,
										RsD1 => RsD1,
										RtD1 => RtD1,
										RegWriteE1 => RegWriteE1,
										MemtoRegE1 => MemtoRegE1,
										MemtoRegM1 => MemtoRegM1,
										MemWriteM1 => MemWriteM1,
										ALUOutM1 => ALUOutM1,
										WriteRegE1 => WriteRegE1,
										WriteRegM1 => WriteRegM1,
										BranchD1 => BranchD1,
										RsE2 => RsE2,
										RtE2 => RtE2,
										RsD2 => RsD2,
										RtD2 => RtD2,
										RegWriteE2 => RegWriteE2,
										MemtoRegE2 => MemtoRegE2,
										MemtoRegM2 => MemtoRegM2,
										MemWriteM2 => MemWriteM2,
										ALUOutM2 => ALUOutM2,
										WriteRegE2 => WriteRegE2,
										WriteRegM2 => WriteRegM2,
										BranchD2 => BranchD2,
										StallF => StallF,
										StallD1 => StallD1,
										StallE1 => StallE1,
										FlushE1 => FlushE1,
										FlushM1 => FlushM1,
										StallD2 => StallD2,
										StallE2 => StallE2,
										StallM2 => StallM2,
										FlushE2 => FlushE2,
										FlushM2 => FlushM2,
										FlushW2 => FlushW2,
										Stall2 => Stall2 );
										
	data_mem : data_memory generic map(size => 1024)
							  port map( clk => clk,
										addr1 => ALUOutM1,
										addr2 => ALUOutM2,
										data_in1 => WriteDataM1,
										data_in2 => WriteDataM2,
										memwrite1 => MemWriteM1,
										memwrite2 => MemWriteM2,
										data_out1 => ReadDataM1,
										data_out2 => ReadDataM2 );
	
	instruction_mem : instr_mem port map( pc1 => PC,
										pc2 => PCplus4,
										instr1 => InstrF1,
										instr2 => Instr2 );
	
	execution_unit1 : execution_unit port map(  clk => clk,
												instrF => instrF1,
												PCplusF => PCplus4,
												ClearD2 => ClearD2,
												StallD => StallD1,
												EqualAD => EqualAD1,
												EqualBD => EqualBD1,
												RD1D => RD1D1,
												RD2D => RD2D1,
												StallE => StallE1,
												FlushE => FlushE1,
												SrcAE => SrcAE1,
												WriteDataE => WriteDataE1,
												StallM => StallM1,
												FlushM => FlushM1,
												ReadDataM => ReadDataM1,
												FlushW => FlushW1,
												BranchD_out => BranchD1,
												JumpD_out => JumpD1,
												ClearD_out => ClearD1,
												PCsrcD_out => PCsrcD1,
												PCnextbrD => PCnextD1,
												RsD_out => RsD1,
												RtD_out => RtD1,
												RegWriteE_out => RegWriteE1,
												MemtoRegE_out => MemtoRegE1,
												RD1E => RD1E1,
												RD2E => RD2E1,
												RsE => RsE1,
												RtE_out => RtE1,
												WriteRegE_out => WriteRegE1,
												RegWriteM_out => RegWriteM1,
												MemToRegM_out => MemToRegM1,
												MemWriteM => MemWriteM1,
												ALUOutM_out => ALUOutM1,
												WriteDataM => WriteDataM1,
												WriteRegM_out => WriteRegM1,
												RegWriteW => RegWriteW1,
												ResultW => ResultW1,
												WriteRegW => WriteRegW1,
												InstrD_out => InstrD1);
												
	execution_unit2 : execution_unit port map(  clk => clk,
												instrF => instrF2,
												PCplusF => PCplus8,
												ClearD2 => ClearD1,
												StallD => StallD2,
												EqualAD => EqualAD2,
												EqualBD => EqualBD2,
												RD1D => RD1D2,
												RD2D => RD2D2,
												StallE => StallE2,
												FlushE => FlushE2,
												SrcAE => SrcAE2,
												WriteDataE => WriteDataE2,
												StallM => StallM2,
												FlushM => FlushM2,
												ReadDataM => ReadDataM2,
												FlushW => FlushW2,
												BranchD_out => BranchD2,
												JumpD_out => JumpD2,
												ClearD_out => ClearD2,
												PCsrcD_out => PCsrcD2,
												PCnextbrD => PCnextD2,
												RsD_out => RsD2,
												RtD_out => RtD2,
												RegWriteE_out => RegWriteE2,
												MemtoRegE_out => MemtoRegE2,
												RD1E => RD1E2,
												RD2E => RD2E2,
												RsE => RsE2,
												RtE_out => RtE2,
												WriteRegE_out => WriteRegE2,
												RegWriteM_out => RegWriteM2,
												MemToRegM_out => MemToRegM2,
												MemWriteM => MemWriteM2,
												ALUOutM_out => ALUOutM2,
												WriteDataM => WriteDataM2,
												WriteRegM_out => WriteRegM2,
												RegWriteW => RegWriteW2,
												ResultW => ResultW2,
												WriteRegW => WriteRegW2,
												InstrD_out => InstrD2 );
												
	-- mux to choose between instr2 and no instr in case of stalling the second execution unit
	stallMux : mux2 generic map(w => 32)
					port    map(d0 => Instr2,
								d1 => x"00000000",
								s => Stall2,
								y => InstrF2);
					
	-- always activate pipeline register M in execution unit 1
	StallM1 <= '0';
	
	-- output InstrD for testbench
	instrD1_out <= InstrD1;
	instrD2_out <= InstrD2;
	
end;