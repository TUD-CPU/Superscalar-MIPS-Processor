library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Unit is
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
        StallM1    : out std_logic;
        StallW1    : out std_logic;
        FlushE1    : out std_logic;
        FlushM1    : out std_logic;
        StallD2    : out std_logic;
        StallE2    : out std_logic;
        StallM2    : out std_logic;
        StallW2    : out std_logic;
        FlushE2    : out std_logic;
        FlushM2    : out std_logic;
        FlushW2    : out std_logic;
		Stall2     : out std_logic
    );
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

    signal lwstall, branchstall, sameAddressStall, readWriteStall : std_logic;
	signal controlF1, controlF2 : std_logic_vector(1 downto 0);
	signal WriteRegF1, WriteRegF2 : std_logic_vector(4 downto 0);
	
	signal RsF1, RtF1, RsF2, RtF2 : std_logic_vector(4 downto 0); 
begin
	
	--Branchstall 1 + 2 (Stalling Decode phase when a branch instruction uses source registers that are written by instructions in Execute or Memory phase)
	process (RsD1, RtD1, WriteRegM1, BranchD1, RegWriteE1, WriteRegE1, MemtoRegM1, RsD2, RtD2, WriteRegM2, BranchD2, RegWriteE2, WriteRegE2, MemtoRegM2) begin
		if ( (BranchD1 = '1' AND RegWriteE1 = '1' AND (WriteRegE1 = RsD1 OR WriteRegE1 = RtD1) ) OR ( BranchD1 = '1' AND MemtoRegM1 = '1' AND (WriteRegM1 = RsD1 OR WriteRegM1 = RtD1) ) ) OR
		   ( (BranchD1 = '1' AND RegWriteE2 = '1' AND (WriteRegE2 = RsD1 OR WriteRegE2 = RtD1) ) OR ( BranchD1 = '1' AND MemtoRegM2 = '1' AND (WriteRegM2 = RsD1 OR WriteRegM2 = RtD1) ) ) OR
		   ( (BranchD2 = '1' AND RegWriteE1 = '1' AND (WriteRegE1 = RsD2 OR WriteRegE1 = RtD2) ) OR ( BranchD2 = '1' AND MemtoRegM1 = '1' AND (WriteRegM1 = RsD2 OR WriteRegM1 = RtD2) ) ) OR
		   ( (BranchD2 = '1' AND RegWriteE2 = '1' AND (WriteRegE2 = RsD2 OR WriteRegE2 = RtD2) ) OR ( BranchD2 = '1' AND MemtoRegM2 = '1' AND (WriteRegM2 = RsD2 OR WriteRegM2 = RtD2) ) ) then
			branchstall <= '1';
		else
			branchstall <= '0';
		end if;
		
	end process;


	--lwstall (Stalling Decode Phase when an instruction uses registers that are written by a lw instruction currently in Execution phase)
  	process (RsD1, RtE1, RtD1, MemToRegE1, RsD2, RtE2, RtD2, MemToRegE2) begin
		if (((RsD1 = RtE1) or (RtD1 = RtE1)) and (MemToRegE1 = '1')) OR
		   (((RsD1 = RtE2) or (RtD1 = RtE2)) and (MemToRegE2 = '1')) OR
		   (((RsD2 = RtE1) or (RtD2 = RtE1)) and (MemToRegE1 = '1')) OR
		   (((RsD2 = RtE2) or (RtD2 = RtE2)) and (MemToRegE2 = '1')) then
			lwstall <= '1';
		else 
			lwstall <= '0';
		end if;
		-- lwstall <= (((RsD = RtE) or (RtD = RtE)) and (MemToRegE = '1'));
	end process;
	
	--same address stall (Execute EU1 then EU2 when storing and loading to/from the same address in Memory Phase)
	process (MemToRegM1, MemWriteM2, MemToRegM2, MemWriteM1, ALUOutM1, ALUOutM2) begin
		if ( (MemToRegM1 = '1' and MemWriteM2 = '1') or (MemToRegM2 = '1' and MemWriteM1 = '1') ) and (ALUOutM1 = ALUOutM2) then
			sameAddressStall <= '1';
		else
			sameAddressStall <= '0';
		end if;
	end process;
	
	--read/write from/to the same register simultaneously
	--nr1: detect hazard in execution stage
	-- process (RegWriteE1, RsE1, RtE1, WriteRegE1, RegWriteE2, RsE2, RtE2, WriteRegE2) begin
		-- if ( ( ( RegWriteE1 = '1' ) and (WriteRegE1 /= "00000") and ( ( RsE2 = WriteRegE1) or ( RtE2 = WriteRegE1) ) ) or
			 -- ( ( RegWriteE2 = '1' ) and (WriteRegE2 /= "00000") and( ( RsE1 = WriteRegE2) or ( RtE1 = WriteRegE2) ) ) ) then
			-- readWriteStall <= '1';
		-- else
			-- readWriteStall <= '0';
		-- end if;
	-- end process;
	
	--if branch or jump in execution unit 1 -> stall execution unit 2 (may be replaced by branch prediction)
	-- process(InstrF1) begin
		-- if InstrF1(31 downto 26) = "000100" or InstrF1(31 downto 26) = "000010" then
			-- Stall2 <= '1';
		-- else
			-- Stall2 <= '0';
		-- end if;
	-- end process;
	
	
	--nr2: detect hazard in fetch stage -> could be faster than nr1
	
	-- decode instructions in fetch stage (only use regwrite (index 1) and regdst (index 0))
	process (InstrF1) begin
        case InstrF1(31 downto 26) is
            when "000000" => controlF1 <= "11"; -- rtype
            when "100011" => controlF1 <= "10"; -- lw
            when "101011" => controlF1 <= "00"; -- sw
            when "000100" => controlF1 <= "00"; -- beq
            when "001000" => controlF1 <= "10"; -- addi
            when "000010" => controlF1 <= "00"; -- j
            when others   => controlF1 <= "--"; -- illegal
        end case;
    end process;
	
	process (InstrF2) begin
        case InstrF2(31 downto 26) is
            when "000000" => controlF2 <= "11"; -- rtype
            when "100011" => controlF2 <= "10"; -- lw
            when "101011" => controlF2 <= "00"; -- sw
            when "000100" => controlF2 <= "00"; -- beq
            when "001000" => controlF2 <= "10"; -- addi
            when "000010" => controlF2 <= "00"; -- j
            when others   => controlF2 <= "--"; -- illegal
        end case;
    end process;
	
	
	-- mux to choose writeRegF1
	muxWriteRegF1 : mux2 generic map(w => 5) port map(d0 => InstrF1(20 downto 16), d1 => InstrF1(15 downto 11), s => controlF1(0), y => WriteRegF1);
	
	-- mux to choose writeRegF2
	muxWriteRegF2 : mux2 generic map(w => 5) port map(d0 => InstrF2(20 downto 16), d1 => InstrF2(15 downto 11), s => controlF2(0), y => WriteRegF2);
	
	RsF1 <= InstrF1(25 downto 21);
	RtF1 <= InstrF1(20 downto 16);
	RsF2 <= InstrF2(25 downto 21);
	RtF2 <= InstrF2(20 downto 16);
	
	-- if branch or jump in execution unit 1 -> stall execution unit 2 (may be replaced by branch prediction)
	-- read/write from/to the same register simultaneously -> stall execution unit 2
	-- process(InstrF1, InstrF2) begin
		-- if (InstrF1(31 downto 26) = "000100") or (InstrF1(31 downto 26) = "000010") 
			-- or ( ( controlF1(1) = '1' ) and (WriteRegF1 /= "00000") and ( ( InstrF2(25 downto 21) = WriteRegF1) or ( InstrF2(20 downto 16) = WriteRegF1) ) )
			-- or ( ( controlF2(1) = '1' ) and (WriteRegF2 /= "00000") and ( ( InstrF1(25 downto 21) = WriteRegF2) or ( InstrF1(20 downto 16) = WriteRegF2) ) )  then
			-- Stall2 <= '1';
		-- else
			-- Stall2 <= '0';
		-- end if;
	-- end process;
	
	process(InstrF1, InstrF2, WriteRegF1, WriteRegF2) begin
		if (InstrF1(31 downto 26) = "000100") or (InstrF1(31 downto 26) = "000010") 
			or ( ( controlF1(1) = '1' ) and (WriteRegF1 /= "00000") and ( ( RsF2 = WriteRegF1) or ( RtF2 = WriteRegF1) ) )
			or ( ( controlF2(1) = '1' ) and (WriteRegF2 /= "00000") and ( ( RsF1 = WriteRegF2) or ( RtF1 = WriteRegF2) ) )  then
			Stall2 <= '1';
		else
			Stall2 <= '0';
		end if;
	end process;
	
	
	--tests
	-- readWriteStall <= '0';
	-- sameAddressStall <= '0';
	-- Stall2 <= '0';
	
	
    -- StallF  <= lwstall OR branchstall OR sameAddressStall OR readWriteStall;
    -- StallD1 <= lwstall OR branchstall OR sameAddressStall OR readWriteStall;
	-- StallE1 <= sameAddressStall;
	-- StallM1 <= '0';
	-- StallW1 <= '0';
    -- FlushE1 <= lwstall OR branchstall OR readWriteStall;
	-- FlushM1 <= sameAddressStall;
	
    -- StallD2 <= lwstall OR branchstall OR sameAddressStall OR readWriteStall;
	-- StallE2 <= sameAddressStall OR readWriteStall;
	-- StallM2 <= sameAddressStall OR readWriteStall;
	-- StallW2 <= readWriteStall; -- Pruefe forwarding von resultw2 nach execution stage 1 und 2
    -- FlushE2 <= lwstall OR branchstall;
	-- FlushM2 <= readWriteStall;
	-- FlushW2 <= sameAddressStall;
	
	StallF  <= lwstall OR branchstall OR sameAddressStall;
    StallD1 <= lwstall OR branchstall OR sameAddressStall;
	StallE1 <= sameAddressStall;
	StallM1 <= '0';
	StallW1 <= '0';
    FlushE1 <= lwstall OR branchstall;
	FlushM1 <= sameAddressStall;
	
    StallD2 <= lwstall OR branchstall OR sameAddressStall;
	StallE2 <= sameAddressStall;
	StallM2 <= sameAddressStall;
	StallW2 <= '0'; -- Pruefe forwarding von resultw2 nach execution stage 1 und 2
    FlushE2 <= lwstall OR branchstall;
	FlushM2 <= '0';
	FlushW2 <= sameAddressStall;
	
	
end;