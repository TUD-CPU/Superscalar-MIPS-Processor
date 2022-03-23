import sys
import argparse

ports_fwd = ""
ports_dm = ""
ports_im = ""
ports_fetch = ""
ports_reg = ""
ports_haz = ""

def main():

	parser = argparse.ArgumentParser(description='Generate vhdl files for a pipelined superscalar MIPS processor.')
	parser.add_argument("-eu", "--executionunits", help="the number of execution units", type=int, default=2)
	parser.add_argument("-dm", "--datamemory", help="the size of data memory (*4 bytes)", type=int, default=1024)
	args = parser.parse_args()
	
	dmSize = args.datamemory
	
	n = args.executionunits
	if n < 2:
		n = 2
	print("Generating: pipelined " + str(n) + "-way-superscalar processor...")
	generate_Processor(n,dmSize)
	

def generate_Processor(eu, dm):
	generate_Forwarding_Unit(eu)
	generate_Data_Memory(eu)
	generate_Instruction_Memory(eu) # Done by assembler
	generate_Fetch_Unit(eu)
	generate_Regfile(eu)
	generate_Hazard_Unit(eu)
	generate_mips_pipelined(eu, dm)
	generate_mips_pipelined_tb(eu)
	
# -------------------------------------------------------------
# -------------- Start Hazard Unit ----------------------------
# -------------------------------------------------------------

# generates the hazard unit file for n execution units
def generate_Hazard_Unit(n) :     
	global ports_haz
	output = """library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Unit is
    """
	
	ports_haz = """port (
"""
	# Add InstrF ports
	for i in range(1,n+1):
		ports_haz += """		InstrF{i}    : in std_logic_vector(31 downto 0);
""".format(i=i)
	
	# Add in ports
	for i in range(1,n+1):
		ports_haz += """        RsE{i}       : in std_logic_vector(4 downto 0);
        RtE{i}       : in std_logic_vector(4 downto 0);
        RsD{i}       : in std_logic_vector(4 downto 0);
        RtD{i}       : in std_logic_vector(4 downto 0);
		RegWriteE{i} : in std_logic;
        MemtoRegE{i} : in std_logic;
		MemtoRegM{i} : in std_logic;
		MemWriteM{i} : in std_logic;
		ALUOutM{i}   : in std_logic_vector(31 downto 0);
		WriteRegE{i} : in std_logic_vector(4 downto 0);
        WriteRegM{i} : in std_logic_vector(4 downto 0);
		BranchD{i}   : in std_logic;
""".format(i=i)

	ports_haz += """		StallF     : out std_logic;
"""
	# Add out ports
	for i in range(1,n+1):
		ports_haz += """        StallD{i}    : out std_logic;
        StallE{i}    : out std_logic;
        StallM{i}    : out std_logic;
        StallW{i}    : out std_logic;
        FlushE{i}    : out std_logic;
        FlushM{i}    : out std_logic;
""".format(i=i)
		if i > 1:
			ports_haz += """        FlushW{i}    : out std_logic;
		Stall{i}_out : out std_logic""".format(i=i)
			if i < n:
				ports_haz += """;
"""
	
	ports_haz += """
    );"""
	
	output += ports_haz
	
	output += """
end;

architecture behavior of Hazard_Unit is

	component mux2 is
		generic(w: integer := 8);
		port(
			d0: in std_logic_vector(w-1 downto 0);
			d1: in std_logic_vector(w-1 downto 0);
			s: in std_logic;
			y: out std_logic_vector(w-1 downto 0)
		);
	end component;

    signal lwstall, branchstall,"""
	for i in range(1,n+1):
		output += """sameAddressStall{i}, """.format(i=i)
	
	output += """readWriteStall : std_logic;
	signal Stall2"""
	# add stall signals
	for i in range(3, n+1):
		output += """, Stall{i}""".format(i=i)
	
	output += """ : std_logic;
	signal controlF1"""
	
	# add control signals for decoding
	for i in range(2, n+1):
		output += """, controlF{i}""".format(i=i)
	
	output += """ : std_logic_vector(1 downto 0);
	signal WriteRegF1"""
	
	for i in range(2, n+1):
		output += """, WriteRegF{i}""".format(i=i)
	
	for i in range(1,n+1):
		output += """, RsF{i}, RtF{i}""".format(i=i)
		
	output += """ : std_logic_vector(4 downto 0); 
begin
	
"""

	# Add branchstall
	output += """	--Branchstall (Stalling Decode phase when a branch instruction uses source registers that are written by instructions in Execute or Memory phase)
	process ("""
	
	for i in range(1,n+1):
		output += "RsD{i}, RtD{i}, WriteRegM{i}, BranchD{i}, RegWriteE{i}, WriteRegE{i}, MemtoRegM{i}".format(i=i)
		if i < n:
			output += ", "
	
	
	output += """) begin
		if  """
		
	for eu in range(1,n+1):
		for i in range(1, n+1):
			output += """( (BranchD{eu} = '1' AND RegWriteE{i} = '1' AND (WriteRegE{i} = RsD{eu} OR WriteRegE{i} = RtD{eu}) ) OR ( BranchD{eu} = '1' AND MemtoRegM{i} = '1' AND (WriteRegM{i} = RsD{eu} OR WriteRegM{i} = RtD{eu}) ) )""".format(eu=eu,i=i)
			flag = eu < n or i < n
			if eu < n or i < n:
				output += """ OR
			"""
	
	output += """	then
			branchstall <= '1';
		else
			branchstall <= '0';
		end if;
		
	end process;

"""
	
	# Add lwstall
	output += """	--lwstall (Stalling Decode Phase when an instruction uses registers that are written by a lw instruction currently in Execution phase)
  	process ("""
	for i in range(1,n+1):
		output += """RsD{i}, RtE{i}, RtD{i}, MemToRegE{i}""".format(i=i)
		if i < n:
			output += ", "
		
	output += """) begin
		if """
		
	for eu in range(1,n+1):
		for i in range(1,n+1):
			output += """(((RsD{eu} = RtE{i}) or (RtD{eu} = RtE{i})) and (RtE{i} /= "00000") and (MemToRegE{i} = '1'))""".format(eu=eu,i=i)
			if eu < n or i < n:
				output += """ OR
		   """
		   
	output += """ then
			lwstall <= '1';
		else 
			lwstall <= '0';
		end if;
	end process;
	
"""
	
	
	# Add sameAddressStall
	for eu in range(1,n):
		output += """	--same address stall (Execute EU{i} first, then the other EUs when storing and loading to/from the same address in Memory Phase)
	process (""".format(i=eu)
		for i in range(eu,n+1):
			output += "MemToRegM{i}, MemWriteM{i}, ALUOutM{i}".format(i=i)
			if i < n:
				output += ", "
			
		output += """) begin
		if """
		for i in range(eu+1,n+1):
			output += "( ( (MemToRegM{eu} = '1' and MemWriteM{i} = '1') or (MemToRegM{i} = '1' and MemWriteM{eu} = '1') ) and (ALUOutM{eu} = ALUOutM{i}) )".format(i=i,eu=eu)
			if i < n:
				output += """ OR 
		   """
			
			
		output += """ then
			sameAddressStall{eu} <= '1';
		else
			sameAddressStall{eu} <= '0';
		end if;
	end process;
	
""".format(eu=eu)
	
	
	# Add sameRegisterStall
	
	# Decoding instrF
	for i in range(1,n+1):
		output += """	process (InstrF{i}) begin
        case InstrF{i}(31 downto 26) is
            when "000000" => controlF{i} <= "11"; -- rtype
            when "100011" => controlF{i} <= "10"; -- lw
            when "101011" => controlF{i} <= "00"; -- sw
            when "000100" => controlF{i} <= "00"; -- beq
            when "001000" => controlF{i} <= "10"; -- addi
			when "001110" => controlF{i} <= "10"; -- xori
			when "001111" => controlF{i} <= "10"; -- lui
            when "000010" => controlF{i} <= "00"; -- j
            when others   => controlF{i} <= "--"; -- illegal
        end case;
    end process;
	
""".format(i=i)
	
	# mux to choose writeReg
	for i in range(1,n+1):
		output += """	-- mux to choose writeRegF{i}
	muxWriteRegF{i} : mux2 generic map(w => 5) port map(d0 => InstrF{i}(20 downto 16), d1 => InstrF{i}(15 downto 11), s => controlF{i}(0), y => WriteRegF{i});

""".format(i=i)

	# RsF and RtF
	for i in range(1,n+1):
		output += """	RsF{i} <= InstrF{i}(25 downto 21);
	RtF{i} <= InstrF{i}(20 downto 16);
""".format(i=i)

	
	output += """
"""

	# Add eu stall
	for eu in range(2,n+1):
		output += """	process(InstrF1"""
		for i in range(1,eu+1):
			output += """, InstrF{i}""".format(i=i)
			
		for i in range(1,eu+1):
			output += """, WriteRegF{i}""".format(i=i)
		
		output += """) begin
		if (InstrF{i}(31 downto 26) = "000100") or (InstrF{i}(31 downto 26) = "000010") """.format(i=i-1)
		
		for i in range(1, eu):
			output += """
			or ( ( controlF{i}(1) = '1' ) and (WriteRegF{i} /= "00000") and ( ( RsF{j} = WriteRegF{i}) or ( RtF{j} = WriteRegF{i}) ) )
			or ( ( controlF{j}(1) = '1' ) and (WriteRegF{j} /= "00000") and ( ( RsF{i} = WriteRegF{j}) or ( RtF{i} = WriteRegF{j}) ) )""". format(i=i,j=eu);
		
		output += """  then
			Stall{i} <= '1';
		else
			Stall{i} <= '0';
		end if;
	end process;

""".format(i=eu)
	
	# Stall and Flush outputs
	allSameAddressStalls = ""
	for i in range(1,n):
			allSameAddressStalls += "sameAddressStall{i}".format(i=i)
			if i < n-1:
				allSameAddressStalls += " OR "
	
	output += """	StallF  <= lwstall OR branchstall OR """
	output += allSameAddressStalls
	output +=""";

"""
	

	# Outputs for EU1
	output += """	StallD1 <= lwstall OR branchstall OR sameAddressStall1;
	StallE1 <= sameAddressStall1;
	StallM1 <= '0';
	StallW1 <= '0';
    FlushE1 <= lwstall OR branchstall;
	FlushM1 <= sameAddressStall1;
	
"""
	# Outputs for all other EUs
	
	for eu in range(2,n+1):
		prevSameAddressStalls = "" # All sameAddressStalls from 1 to eu-1
		fromSameAddressStalls = "" # All sameAddressStalls from eu to n-1
		for i in range(1,eu):
			prevSameAddressStalls += "sameAddressStall{i}".format(i=i)
			
			if i < eu-1:
				prevSameAddressStalls += " OR "
		
		
		for i in range(eu,n):
			fromSameAddressStalls += "sameAddressStall{i}".format(i=i)
			
			if i < n-1:
				fromSameAddressStalls += " OR "
		
		if eu >= n:
			fromSameAddressStalls = "'0'"
	
		output += ("""	StallD{eu} <= lwstall OR branchstall OR """ + allSameAddressStalls + """;
	StallE{eu} <= """ + allSameAddressStalls + """;
	StallM{eu} <= """ + prevSameAddressStalls + """;
	StallW{eu} <= '0';
    FlushE{eu} <= lwstall OR branchstall;
	FlushM{eu} <= """ + fromSameAddressStalls + """;
	FlushW{eu} <= """ + prevSameAddressStalls + """;
""").format(eu=eu)


	x = """	
    StallD1 <= lwstall OR branchstall OR sameAddressStall1 OR sameAddressStall2; --all
	StallE1 <= sameAddressStall1 OR sameAddressStall2; --all
	StallM1 <= '0';
	StallW1 <= '0';
    FlushE1 <= lwstall OR branchstall;
	FlushM1 <= sameAddressStall1; -- all
	
    StallD2 <= lwstall OR branchstall OR sameAddressStall1 OR sameAddressStall2; -- all
	StallE2 <= sameAddressStall1 OR sameAddressStall2; -- all
	StallM2 <= sameAddressStall1; -- all previous
	StallW2 <= '0';
    FlushE2 <= lwstall OR branchstall;
	FlushM2 <= sameAddressStall2; -- from this to end (execute this unit and flush when a stall in a higher eu happens)
	FlushW2 <= sameAddressStall1; -- all previous
	
	StallD3 <= lwstall OR branchstall OR sameAddressStall1 OR sameAddressStall2; -- all
	StallE3 <= sameAddressStall1 OR sameAddressStall2; -- all
	StallM3 <= sameAddressStall1 OR sameAddressStall2; -- all previous
	StallW3 <= '0';
    FlushE3 <= lwstall OR branchstall;
	FlushM3 <= '0';   -- from this to end (not for last eu)
	FlushW3 <= sameAddressStall1 OR sameAddressStall2; -- all previous  """

	
	# Stall execution unit output
	for eu in range(2,n+1):
		output += """	Stall{i}_out <= """.format(i=eu)
		for i in range(2,eu+1):
			output += "Stall{i}".format(i=i)
			if i < eu:
				output += " OR "
		output += """;
"""
	
	# end file
	output += "end;"
	
	with open('Hazard_Unit.vhdl', 'w') as file:
		file.write(output)
		

# -------------------------------------------------------------
# ------------------- End Hazard Unit -------------------------
# -------------------------------------------------------------


# -------------------------------------------------------------
# --------------- Start Fetch Unit ----------------------------
# -------------------------------------------------------------

# generates the fetch unit file for n execution units
def generate_Fetch_Unit(n) :     
	global ports_fetch
	output = """library ieee;
use ieee.std_logic_1164.all;

entity Fetch_Unit is
""" 
	# Add in and out ports
	ports_fetch = """    port (
		clk          : in std_logic;
		reset        : in std_logic;
		StallF       : in std_logic;
"""
	
	for i in range(2, n+1):
		ports_fetch += """		Stall{i}       : in std_logic;
""".format(i=i)
	
	for i in range(1, n+1):
		ports_fetch += """		JumpD{i}       : in std_logic;
		PCsrcD{i}      : in std_logic;
		PC{i}          : in std_logic_vector(31 downto 0);
""".format(i=i)
	ports_fetch += """		PC_out       : out std_logic_vector(31 downto 0);
"""
	for i in range(1, n+1):
		ports_fetch += "		PCplus{index}_out  : out std_logic_vector(31 downto 0)".format(index = i*4)
		if i < n:
			ports_fetch += """;
"""
	
	ports_fetch += """
    );"""
	
	output += ports_fetch
	
	# Add components
	output += """
end;

architecture behavior of Fetch_Unit is

	component syncresff is
    port (
        clk    : in std_logic;
        reset  : in std_logic;
        StallF : in std_logic;
        d      : in std_logic_vector(31 downto 0);
        q      : buffer std_logic_vector(31 downto 0)
    );
	end component;
	
	component adder is
    port (
        a : in std_logic_vector(31 downto 0);
        b : in std_logic_vector(31 downto 0);
        y : out std_logic_vector(31 downto 0)
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
	
	signal not_StallF"""
	
	# Add signals
	for i in range(1, n+1):
		output += ", PCcontrol{i}".format(i=i)
	
	output += """ : std_logic;
	"""
	
	output += "signal PCnext, PC" 
	for i in range(2,n+1):
		output += ", PCnext{i}".format(i=i)
	for i in range(2,n+1):
		output += ", PCjump{i}".format(i=i)
	for i in range(1,n+1):
		output += ", PCplus{i}".format(i=i*4)
	output += " : std_logic_vector(31 downto 0);"
	# Add program counter
	output += """

begin
	-- Program counter
	not_StallF <= not StallF;
	programCounter : syncresff port map(clk => clk, reset => reset, StallF => not_StallF, d => PCnext, q => PC);
	
	"""
	
	# Add PC adders
	for i in range(1,n+1):
		output += """-- adder +{i}
	adder{i} : adder port map(a => PC, b => x"{x}", y => PCplus{i});
	
	""".format(i=i*4,x=dez_to_hex(i*4,8))
	
	# Add PC muxes to choose between different PCplusX addresses
	output += """pcplusmux{i} : mux2 generic map(w => 32) port map(d0 => PCplus{index}, d1 => PCplus{index1}, s => Stall{i}, y => PCnext{i});
	""".format(i=n, index=n*4, index1=(n-1)*4)
	
	for i in range(n-1, 1, -1):
		output += """pcplusmux{i} : mux2 generic map(w => 32) port map(d0 => PCnext{i1}, d1 => PCplus{index1}, s => Stall{i}, y => PCnext{i});
	""".format(i=i, i1 = i+1, index1=(i-1)*4)
	
	# Add PC muxes to choose between different jump/branch addresses
	output += """pc{i}mux : mux2 generic map(w => 32) port map(d0 => PCnext2, d1 => PC{i}, s => PCcontrol{i}, y => PCjump{i});
	""".format(i=n)
	
	for i in range(n-1, 1, -1):
		output += """pc{i}mux : mux2 generic map(w => 32) port map(d0 => PCjump{i1}, d1 => PC{i}, s => PCcontrol{i}, y => PCjump{i});
	""".format(i=i,i1=i+1)
	
	output += """pc1mux : mux2 generic map(w => 32) port map(d0 => PCjump2, d1 => PC1, s => PCcontrol1, y => PCnext);
	"""
	
	# Add control signals for jump/branch muxes
	output += """
	-- Control signals to choose between PCplus and branch/jump addresses from the execution units
	"""
	for i in range(1,n+1):
		output += """PCcontrol{i} <= JumpD{i} or PCsrcD{i};
	""".format(i=i)
	
	# Add PC outputs
	output += """
	-- PC output
	PC_out <= PC;
	"""
	for i in range(1,n+1):
		output += """PCplus{i}_out <= PCplus{i};
	""".format(i=i*4)
	
	# end file
	output += "end;"
	
	with open('Fetch_Unit.vhdl', 'w') as file:
		file.write(output)
		
	print("Generated: Fetch_Unit.vhdl for " + str(n) + " execution units.")

# -------------------------------------------------------------
# -------------------- End Fetch Unit -------------------------
# -------------------------------------------------------------


# -------------------------------------------------------------
# -------------- Start Forwarding Unit ------------------------
# -------------------------------------------------------------

# generates the forwarding unit file for n execution units
def generate_Forwarding_Unit(n) :      
	global ports_fwd
	# file header
	
	output = """library ieee;
use ieee.std_logic_1164.all;

entity Forwarding_Unit is
"""

	ports_fwd = """    port (
		clk         : in std_logic;
"""

	# in ports
	for i in range(1, n+1):
		ports_fwd += """		RD1D{index}       : in std_logic_vector(31 downto 0);
		RD2D{index}       : in std_logic_vector(31 downto 0);
		RD1E{index}       : in std_logic_vector(31 downto 0);
		RD2E{index}       : in std_logic_vector(31 downto 0);
        RsE{index}        : in std_logic_vector(4 downto 0);
        RtE{index}        : in std_logic_vector(4 downto 0);
        RsD{index}        : in std_logic_vector(4 downto 0);
        RtD{index}        : in std_logic_vector(4 downto 0);
		RegWriteE{index}  : in std_logic;
        RegWriteM{index}  : in std_logic;
        RegWriteW{index}  : in std_logic;
		WriteRegE{index}  : in std_logic_vector(4 downto 0);
        WriteRegM{index}  : in std_logic_vector(4 downto 0);
        WriteRegW{index}  : in std_logic_vector(4 downto 0);
        ALUOutM{index}    : in std_logic_vector(31 downto 0);
        ResultW{index}    : in std_logic_vector(31 downto 0);
""".format(index=i)

	# out ports
	for i in range(1, n+1):
		ports_fwd += """		EqualAD{index}    : out std_logic_vector(31 downto 0);
		EqualBD{index}    : out std_logic_vector(31 downto 0);
        SrcAE{index}      : out std_logic_vector(31 downto 0);
        WriteDataE{index} : out std_logic_vector(31 downto 0)""".format(index=i)
		if i < n:
			ports_fwd += """;
"""
			
	ports_fwd += """    );
"""
	output += ports_fwd
	output += """end;

architecture behavior of Forwarding_Unit is

begin
	
"""
	
	# Forwarding D
	for eu in range(1, n+1):
		# comment and process header start
		output += """	--Forwarding D{index}
	process (clk, RsD{index}, RtD{index}, """.format(index=eu)
	
		# add regwrite and writereg from each execution unit to process header
		for i in range(1, n+1):
			output += """WriteRegM{index}, RegWriteM{index}, """.format(index=i)
		output += """RD1D{index}, RD2D{index}) begin
		""".format(index=eu)
		
		# Add if statements for EqualAD and EqualBD
		signals = ["EqualAD", "EqualBD"]
		regs = ["RsD", "RtD"]
		for s in range (0, 2):
			# add if statements
			for euA in range(1, n+1):
				output += ("""if ( (""" + regs[s] + """{ieu} /= "00000") AND (""" + regs[s] + """{ieu} = WriteRegM{ieuA}) AND (RegWriteM{ieuA} = '1') ) then
			""" + signals[s] + """{ieu} <= ALUOutM{ieuA};
		els""").format(ieu = eu, ieuA = euA)
			
			# close if statement
			output += """e
			""" + signals[s] + """{i} <= RD{s}D{i};
		end if;
			
	""".format(i = eu, s = s+1)
			if s < 1:
				output += """	"""
	
		output += """end process;

"""
	
	# Forwarding E
	for eu in range(1, n+1):
		# comment and process header start
		output += """	--Forwarding E{index}
	process (clk, RsE{index}, RtE{index}""".format(index=eu)
		
		# add RegWriteM, RegWriteW, WriteRegM and WriteRegW from all execution units to process header
		for i in range(1, n+1):
			output += """, RegWriteM{i}, RegWriteW{i}, WriteRegM{i}, WriteRegW{i}""".format(i = i)
			
		output += """) begin
        """
		
		# add if statements for SrcAE and WriteDataE
		outSignals = ["SrcAE","WriteDataE"]
		regs = ["RsE", "RtE"]
		inSignals = ["ALUOutM","ResultW"]
		controlSignals = ["M","W"]
		for outS in range(0, 2): # loop: 0 for SrcAE, 1 for WriteDataE
			for inS in range(0, 2): # loop: 0 to forward from memory stage, 1 to forward from writeback stage
				for euA in range(1, n+1): # loop: generate if statements for all execution units
					output += ("""if ((""" + regs[outS] + """{eu} /= "00000") and (""" + regs[outS] + """{eu} = WriteReg""" +controlSignals [inS] + """{euA}) and (RegWrite""" +controlSignals [inS] + """{euA} = '1')) then
            """ + outSignals[outS] + """{eu} <= """ + inSignals[inS] + """{euA};
		els""").format(eu = eu, euA = euA)
			
			# close if statement
			output += """e """ + outSignals[outS] + """{eu} <= RD{s}E{eu};
        end if;
		
	""".format(eu = eu, s = outS+1)
			if outS < 1 :
				output += """	"""
		# end process
		output += """end process;
	
"""
	
	# end file
	output += """end;"""

	with open('Forwarding_Unit.vhdl', 'w') as file:
		file.write(output)
		
	print("Generated: Forwarding_Unit.vhdl for " + str(n) + " execution units.")
		
# -------------------------------------------------------------
# -------------- End Forwarding Unit --------------------------
# -------------------------------------------------------------


# -------------------------------------------------------------
# --------------- Start Regfile -------------------------------
# -------------------------------------------------------------

# generates the regfile file for n execution units
def generate_Regfile(n) :     
	global ports_reg
	output = """library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
""" 
	# Add in and out ports
	ports_reg = """  port (
    clk: in std_logic;
"""
	
	for i in range(1, n+1):
		ports_reg += """    we{i}: in std_logic;
""".format(i=i*3)
	
	for i in range(1, (n*3)+1):
		ports_reg += """    a{i}: in std_logic_vector(4 downto 0);
""".format(i=i)

	for i in range(1, n+1):
		ports_reg += """    wd{i}: in std_logic_vector(31 downto 0);
""".format(i=i*3)

	for i in range(1, (n*2)+1):
		ports_reg += """    rd{i}: buffer std_logic_vector(31 downto 0)""".format(i = i)
		if i < (n*2):
			ports_reg += """;
"""
	
	ports_reg += """
  );"""
	
	output += ports_reg
	
	output += """
end;

architecture behavior of regfile is
  type ramtype is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal mem: ramtype;
begin
  process(clk) begin
    if rising_edge(clk) then
"""

	for i in range(1,n+1):
		output += """      if we{i3} = '1' then mem(to_integer(unsigned(a{i3}))) <= wd{i3};
	  end if;
""".format(i3=i*3)

	output += """    end if;
  end process;

"""
	rd = 1
	for i in range(1,(n*3)+1):
		if i % 3 > 0:
			output += """  rd{rd} <= x"00000000" when to_integer(unsigned(a{i})) = 0 else mem(to_integer(unsigned(a{i})));
""".format(i=i,rd=rd)
			rd += 1
		else:
			output += """
"""
	output += """  
end;"""
	
	with open('regfile.vhdl', 'w') as file:
		file.write(output)
		
	print("Generated: regfile.vhdl for " + str(n) + " execution units.")

# -------------------------------------------------------------
# -------------------- End Regfile ----------------------------
# -------------------------------------------------------------



# -------------------------------------------------------------
# -------------- Start Data Memory ----------------------------
# -------------------------------------------------------------

def generate_Data_Memory(n):
	global ports_dm
	# entity header
	output = """library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
  generic (size : Integer := 63);
  """
	ports_dm = """port (
	clk : in std_logic;
	"""
	# add in ports for each execution unit
	for eu in range(1,n+1):
		ports_dm += """addr{i}: in std_logic_vector(31 downto 0);
    """.format(i = eu)
		ports_dm += """data_in{i}: in std_logic_vector(31 downto 0);
	""".format(i = eu)
		ports_dm += """memwrite{i} : in std_logic;
	""".format(i = eu)
		
	# add out ports for each execution unit
	for eu in range(1,n+1):
		ports_dm += """data_out{i}: out std_logic_vector(31 downto 0)""".format(i = eu)
		if eu < n:
			ports_dm += """;
	"""
	
	ports_dm += """
  );
"""
	output += ports_dm
	
	output += """end;

architecture behavior of data_memory is
  type ramtype is array (size downto 0) of std_logic_vector(31 downto 0);
  signal mem: ramtype;
begin
	
"""
	# add writing process
	output += """	process(clk"""
	for eu in range(1,n+1):
		output += ",addr{i}".format(i = eu)
	
	output += """) begin
      if rising_edge(clk) then
"""
	for eu in range(1,n+1):
		output += """       if memwrite{i} = '1' then
			mem(to_integer(unsigned(addr{i}(31 downto 2)))) <= data_in{i};
        end if;
""".format(i = eu)
	
	output += """      end if;
    end process;

"""

	# add reading process
	output += """	process(clk"""
	for eu in range(1,n+1):
		output += ",addr{i}".format(i = eu)
	output += """) begin
"""
	for eu in range(1,n+1):
		output += """	  if to_integer(unsigned(addr{i}(31 downto 2))) < size then
	  data_out{i} <= mem(to_integer(unsigned(addr{i}(31 downto 2))));
	  else
	    data_out{i} <= x"00000000";
	  end if;
""".format(i = eu)
	
	  
	# end file
	output += """  end process;
end;"""
	
	with open('data_memory.vhdl', 'w') as file:
		file.write(output)
		
	print("Generated: data_memory.vhdl for " + str(n) + " execution units.")

# -------------------------------------------------------------
# -------------- End Data Memory ------------------------------
# -------------------------------------------------------------


# -------------------------------------------------------------
# -------------- Start Instruction Memory ---------------------
# -------------------------------------------------------------

def generate_Instruction_Memory(n):
	global ports_im
	# entity header
	output = """	library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
"""
	ports_im = """	port (
"""
	# add in ports for each execution unit
	for eu in range(1,n+1):
		ports_im += """		pc{i}: in std_logic_vector(31 downto 0);
""".format(i = eu)
		
	# add out ports for each execution unit
	for eu in range(1,n+1):
		ports_im += """		instr{i}: out std_logic_vector(31 downto 0)""".format(i = eu)
		if eu < n:
			ports_im += """;
"""
	
	ports_im += """
  );
"""
	output += ports_im
	
	output += """end;

architecture behavior of instr_mem is
	type ramtype is array (255 downto 0) of std_logic_vector(31 downto 0);
	signal mem: ramtype;
begin

-- Paste generated code here:



"""

	# add reading process
	output += """	process(pc1"""
	for eu in range(2,n+1):
		output += ",pc{i}".format(i = eu)
	
	output += """) begin
"""
	
	for eu in range(1,n+1):
		output += """		instr{i} <= mem(to_integer(unsigned(pc{i}(31 downto 2))));
""".format(i = eu)
	
	output += """	end process;
end;"""

	# Generating instruction emmory is done by assembler
	# with open('instr_mem.vhdl', 'w') as file:
	# 	file.write(output)
		
	print("Generated: instr_mem.vhdl for " + str(n) + " execution units.")

# -------------------------------------------------------------
# -------------- End Instruction Memory -----------------------
# -------------------------------------------------------------





# -------------------------------------------------------------
# -------------- Start MIPS Pipelined -------------------------
# -------------------------------------------------------------

# generates the mips_pipelined file for n execution units
def generate_mips_pipelined(n,dm) :
	global ports_dm, ports_fetch, ports_fwd, ports_haz, ports_im, ports_reg
	# Add input and output ports
	output = """library ieee;
use ieee.std_logic_1164.all;

entity mips_pipelined is
    port (
        clk   : in std_logic;
        reset : in std_logic;"""
	for i in range(1, n+1):
		output += """
        instrD{i}_out : out std_logic_vector(31 downto 0)""".format(i=i)
		if i < n:
			output += ";"
	
	# Add all components
	
	output += """
    );
end;

architecture structure of mips_pipelined is

	component data_memory is
	  generic (size : Integer := 63);
	  """
	
	output += ports_dm
	
	output += """	end component;
	
	component instr_mem is
"""
	output += ports_im
	
	output += """	end component;
	
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
"""

	output += ports_reg
	
	output += """	end component;
	
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
		StallW        : in std_logic;
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
"""

	output += ports_fwd
	
	output += """	end component;
	
	component Fetch_Unit is
"""
	
	output += ports_fetch
	
	output += """	end component;
	
	component Hazard_Unit is
"""

	output += ports_haz
	
	output += """	end component;
	
"""

	# Add all 1 bit signals for each execution unit
	output += """	signal StallF""" 
	
	for i in range(2,n+1):
		output += ",Stall{i}".format(i=i)
	
	output += """, not_clk : std_logic;
"""	

	output += """	signal """
	for eu in range(1,n+1):
		output += "ClearD{i}_in".format(i=eu)
		if eu < n:
			output += ", "	
	output += """: std_logic;
"""
	
	signals1 = ["StallD","JumpD","BranchD","PcSrcD","ClearD","StallE","RegWriteE","MemToRegE","FlushE","StallM","RegWriteM","MemToRegM","MemWriteM","FlushM","StallW","RegWriteW","FlushW"]
	for i in range(len(signals1)):
		output += """	signal """
		for eu in range(1,n+1):
			output += signals1[i] + str(eu)
			if eu < n:
				output += ", "	
		output += """: std_logic;
"""

	# signals with 5 bits
	signals5 = ["RsD","RtD","RsE","RtE","WriteRegE","WriteRegM","WriteRegW"]
	for i in range(len(signals5)):
		output += """	signal """
		for eu in range(1,n+1):
			output += signals5[i] + str(eu)
			if eu < n:
				output += ", "	
		output += """: std_logic_vector(4 downto 0);
"""
	

	# signals with 32 bits
	
	output += """	signal """
	for i in range(2,n+1):
		output += "instr" + str(i)
		if i < n:
			output += ", "
	output += """: std_logic_vector(31 downto 0);
"""
	
	output += """	signal PC, """
	for i in range(1,n+1):
		output += "PCplus" + str(i*4)
		if i < n:
			output += ", "
	output += """: std_logic_vector(31 downto 0);
"""


	signals32 = ["instrF","InstrD","EqualAD","EqualBD","RD1D","RD2D","PCnextD","RD1E","RD2E","SrcAE","WriteDataE","ALUOutM","WriteDataM","ReadDataM","ResultW"]
	for i in range(len(signals32)):
		output += """	signal """
		for eu in range(1,n+1):
			output += signals32[i] + str(eu)
			if eu < n:
				output += ", "	
		output += """: std_logic_vector(31 downto 0);
"""
	
	
	
	# Adds component ports
	output += """begin
    
	not_clk <= not clk;
"""
	# Registerfile
	output += """	registerfile : regfile port map(clk => not_clk,
"""
	for i in range(1,n+1):
		output += """									we{i3} => RegWriteW{i},
""".format(i=i,i3=i*3)
	
	for i in range(1,(3*n)+1,3):
		j = (i-1)//3 + 1
		output += """									a{i} => InstrD{j}(25 downto 21),
									a{i1} => InstrD{j}(20 downto 16),
									a{i2} => WriteRegW{j},
""".format(i=i,i1=i+1,i2=i+2,j=j)

	for i in range(1, n+1):
		output += """									wd{i3} => ResultW{i},
""".format(i=i,i3=i*3)


	for i in range(1, n+1):
		j = 2*i - 1
		output += """									rd{j} => RD1D{i},
									rd{j1} => RD2D{i}""".format(j=j,j1=j+1,i=i)
		if i < n:
			output += """,
"""
	
	
	# Fetch Unit
	output += """ );
									
	fetch : Fetch_Unit port map(clk => clk,
								reset => reset,
								StallF => StallF,
"""
	
	for i in range(2, n+1):
		output += """								Stall{i} => Stall{i},
""".format(i=i)
	
	for i in range(1, n+1):
		output += """								JumpD{i} => JumpD{i},
								PCsrcD{i} => PCsrcD{i},
								PC{i} => PCnextD{i},
""".format(i=i)
	output += """								PC_out => PC,
"""
	for i in range(1, n+1):
		output += "								PCplus{index}_out => PCplus{index}".format(index = i*4)
		if i < n:
			output += """,
"""
	
	
	# Forwarding Unit
	output += """);
								
    forwarding : Forwarding_Unit port map(  clk => clk,
"""

	# in ports
	for i in range(1, n+1):
		output += """											RD1D{i} => RD1D{i},
											RD2D{i} => RD2D{i},
											RD1E{i} => RD1E{i},
											RD2E{i} => RD2E{i},
											RsE{i} => RsE{i},
											RtE{i} => RtE{i},
											RsD{i} => RsD{i},
											RtD{i} => RtD{i},
											RegWriteE{i} => RegWriteE{i},
											RegWriteM{i} => RegWriteM{i},
											RegWriteW{i} => RegWriteW{i},
											WriteRegE{i} => WriteRegE{i},
											WriteRegM{i} => WriteRegM{i},
											WriteRegW{i} => WriteRegW{i},
											ALUOutM{i} => ALUOutM{i},
											ResultW{i} => ResultW{i},
""".format(i=i)

	# out ports
	for i in range(1, n+1):
		output += """											EqualAD{i} => EqualAD{i},
											EqualBD{i} => EqualBD{i},
											SrcAE{i} => SrcAE{i},
											WriteDataE{i} => WriteDataE{i}""".format(i=i)
		if i < n:
			output += """,
"""
	
	# Hazard Unit 
	output += """ );
										
	hazardUnit : Hazard_Unit port map(
"""
	
	output += """  InstrF1 => InstrF1,
"""
	
	# Add InstrF ports
	for i in range(2,n+1):
		output += """										InstrF{i} => Instr{i},
""".format(i=i)
	
	# Add in ports
	for i in range(1,n+1):
		output += """										RsE{i} => RsE{i},
										RtE{i} => RtE{i},
										RsD{i} => RsD{i},
										RtD{i} => RtD{i},
										RegWriteE{i} => RegWriteE{i},
										MemtoRegE{i} => MemtoRegE{i},
										MemtoRegM{i} => MemtoRegM{i},
										MemWriteM{i} => MemWriteM{i},
										ALUOutM{i} => ALUOutM{i},
										WriteRegE{i} => WriteRegE{i},
										WriteRegM{i} => WriteRegM{i},
										BranchD{i} => BranchD{i},
""".format(i=i)

	output += """										StallF => StallF,
"""
	# Add out ports
	for i in range(1,n+1):
		output += """										StallD{i} => StallD{i},
										StallE{i} => StallE{i},
										StallM{i} => StallM{i},
										StallW{i} => StallW{i},
										FlushE{i} => FlushE{i},
										FlushM{i} => FlushM{i},
""".format(i=i)
		if i > 1:
			output += """										FlushW{i} => FlushW{i},
										Stall{i}_out => Stall{i}""".format(i=i)
			if i < n:
				output += """,
"""
	
	# Data Memory
	output += """ );
										
	data_mem : data_memory generic map(size => """+str(dm)+""")
							  port map( clk => clk,
"""
	# add in ports for each execution unit
	for eu in range(1,n+1):
		output += """										addr{i} => ALUOutM{i},
""".format(i = eu)
		output += """										data_in{i} => WriteDataM{i},
""".format(i = eu)
		output += """										memwrite{i} => MemWriteM{i},
""".format(i = eu)
		
	# add out ports for each execution unit
	for eu in range(1,n+1):
		output += """										data_out{i} => ReadDataM{i}""".format(i = eu)
		if eu < n:
			output += """,
"""
	
	
	# Instruction Memory
	output += """ );
	
	instruction_mem : instr_mem port map( pc1 => PC,
"""
	for i in range(2,n+1):
		output += """										pc{i} => PCplus{i4},
""".format(i=i,i4=(i-1)*4)
	
	output += """										instr1 => InstrF1,
"""
	
	for i in range(2,n+1):
		output += """										instr{i} => Instr{i}""".format(i=i)
		if i < n:
			output += """,
"""
	
	
	output += """);
	
"""
	
	# Execution Units
	
	for eu in range(1,n+1):
		output += """	execution_unit{i} : execution_unit port map(  clk => clk,
												instrF => instrF{i},
												PCplusF => PCplus{i4},
												ClearD2 => ClearD{i}_in,
												StallD => StallD{i},
												EqualAD => EqualAD{i},
												EqualBD => EqualBD{i},
												RD1D => RD1D{i},
												RD2D => RD2D{i},
												StallE => StallE{i},
												FlushE => FlushE{i},
												SrcAE => SrcAE{i},
												WriteDataE => WriteDataE{i},
												StallM => StallM{i},
												FlushM => FlushM{i},
												ReadDataM => ReadDataM{i},
												StallW => StallW{i},
												FlushW => FlushW{i},
												BranchD_out => BranchD{i},
												JumpD_out => JumpD{i},
												ClearD_out => ClearD{i},
												PCsrcD_out => PCsrcD{i},
												PCnextbrD => PCnextD{i},
												RsD_out => RsD{i},
												RtD_out => RtD{i},
												RegWriteE_out => RegWriteE{i},
												MemtoRegE_out => MemtoRegE{i},
												RD1E => RD1E{i},
												RD2E => RD2E{i},
												RsE => RsE{i},
												RtE_out => RtE{i},
												WriteRegE_out => WriteRegE{i},
												RegWriteM_out => RegWriteM{i},
												MemToRegM_out => MemToRegM{i},
												MemWriteM => MemWriteM{i},
												ALUOutM_out => ALUOutM{i},
												WriteDataM => WriteDataM{i},
												WriteRegM_out => WriteRegM{i},
												RegWriteW => RegWriteW{i},
												ResultW => ResultW{i},
												WriteRegW => WriteRegW{i},
												InstrD_out => InstrD{i});
												
""".format(i=eu,i4=eu*4)
	
	
	# Stall Muxes
	for eu in range(2, n+1):
		output += """	stallMux{i} : mux2 generic map(w => 32)
					port    map(d0 => Instr{i},
								d1 => x"00000000",
								s => Stall{i},
								y => InstrF{i});

""".format(i=eu)
	
	
	# ClearD for clearing all decode phases when a branch or jump is executed (branch misprediction)
	for eu in range(1,n+1):
		output += """	ClearD{eu}_in <= """.format(eu=eu)
		for i in range(1,n+1):
			if i != eu:
				output += """ClearD{i}""".format(i=i)
				if i < n and not (i == n-1 and i == eu-1):
					output += " OR "
		output += """;
"""
	
	# Outputs for testbench
	output += """
	-- output InstrD for testbench
"""
	for i in range(1,n+1):
		output += """	instrD{i}_out <= InstrD{i};
""".format(i=i)
	
	
	output += """	FlushW1 <= '0';
"""
	
	# end file
	output += """	
end;"""
	
	with open('mips_pipelined.vhdl', 'w') as file:
		file.write(output)
		

# -------------------------------------------------------------
# ------------------- End MIPS Pipelined ----------------------
# -------------------------------------------------------------





# -------------------------------------------------------------
# -------------- Start MIPS Pipelined Testbench ---------------
# -------------------------------------------------------------

# generates the mips_pipelined_tb file for n execution units
def generate_mips_pipelined_tb(eu):
	output = """library ieee;
use ieee.std_logic_1164.all;

entity mips_pipelined_tb is
end;

architecture structure of mips_pipelined_tb is

  component mips_pipelined is
    port (
        clk   : in std_logic;
        reset : in std_logic;"""
	for i in range(1, eu+1):
		output += """
        instrD{i}_out : out std_logic_vector(31 downto 0)""".format(i=i)
		if i < eu:
			output += ";"
	
	output += """
    );
end component;

	signal clk, reset : std_logic;
	signal instrD1"""
	
	for i in range(2,eu+1):
		output += ", instrD{i}".format(i=i)
	
	output += """ : std_logic_vector(31 downto 0);
	signal count : integer;

begin
	mips : mips_pipelined port map(clk => clk, reset => reset, instrD1_out => instrD1"""
	for i in range(2,eu+1):
		output += ", instrD{i}_out => instrD{i}".format(i=i)
	
	output += """);

	process begin
	
		count <= 0;
		-- reset
		clk   <= '0';
		reset <= '1';
		wait for 10 ns;
		clk   <= '0';
		reset <= '0';
		wait for 10 ns;

		-- do cylces until end instruction
		while (instrD1 /= x"FFFFFFFF" """

	for i in range(2,eu+1):
		output += """AND instrD{i} /= x"FFFFFFFF" """.format(i=i)
	
	output += """) loop
			clk <= '1';
			wait for 10 ns;
			clk <= '0';
			wait for 10 ns;
			count <= count + 1;
		end loop;
	
		-- last 4 cycles of last instruction
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
		wait for 10 ns;
		
		assert false report "Cycles used for completion: " & integer'image(count);

		wait;
	end process;

end;
"""
	
	with open('mips_pipelined_tb.vhdl', 'w') as file:
		file.write(output)
	
# -------------------------------------------------------------
# ------------------- End MIPS Pipelined Testbench ------------
# -------------------------------------------------------------

# d: number to convert
# n: number of digits of result
def dez_to_hex(d, n):
	chars = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
	output = ""
	for i in range(n-1, 0, -1):
		div = 16**i
		dDiv = d // div
		dNext = d % div
		if dDiv > 0:
			output += chars[dDiv]
		else:
			output += "0"
	
	output += chars[dNext]
	return output
		
if __name__ == "__main__":
    main()