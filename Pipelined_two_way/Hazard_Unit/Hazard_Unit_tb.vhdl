library ieee;
use ieee.std_logic_1164.all;

entity Hazard_Unit_tb is
end Hazard_Unit_tb;

architecture test of Hazard_Unit_tb is

    component Hazard_Unit is
		port (
			RsE       : in std_logic_vector(4 downto 0);
			RtE       : in std_logic_vector(4 downto 0);
			RsD       : in std_logic_vector(4 downto 0);
			RtD       : in std_logic_vector(4 downto 0);
			RegWriteE : in std_logic;
			RegWriteM : in std_logic;
			RegWriteW : in std_logic;
			MemtoRegE : in std_logic;
			MemtoRegM : in std_logic;
			WriteRegE : in std_logic_vector(4 downto 0);
			WriteRegM : in std_logic_vector(4 downto 0);
			WriteRegW : in std_logic_vector(4 downto 0);
			BranchD   : in std_logic;
			ForwardAE : out std_logic_vector(1 downto 0);
			ForwardBE : out std_logic_vector(1 downto 0);
			ForwardAD : out std_logic;
			ForwardBD : out std_logic;
			StallF    : out std_logic;
			StallD    : out std_logic;
			FlushE    : out std_logic
		);
	end component;

    signal RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD, ForwardAD, ForwardBD, StallF, StallD, FlushE   : std_logic;
    signal RsE, RtE, RsD, RtD, WriteRegE, WriteRegM, WriteRegW  : std_logic_vector(4 downto 0);
	signal ForwardAE, ForwardBE 								: std_logic_vector(1 downto 0);

begin

    HU : Hazard_Unit port map(
		RsE => RsE,
		RtE => RtE,
		RsD => RsD,
		RtD => RtD,
		RegWriteE => RegWriteE,
		RegWriteM => RegWriteM,
		RegWriteW => RegWriteW,
		MemtoRegE => MemtoRegE,
		MemtoRegM => MemtoRegM,
		WriteRegE => WriteRegE,
		WriteRegM => WriteRegM,
		WriteRegW => WriteRegW,
		BranchD => BranchD,
		ForwardAE => ForwardAE,
		ForwardBE => ForwardBE,
		ForwardAD => ForwardAD,
		ForwardBD => ForwardBD,
		StallF => StallF,
		StallD => StallD,
		FlushE => FlushE
	);

    process begin
        -- init
        RsE <= "00000";
		RtE <= "00000";
		RsD <= "00000";
		RtD <= "00000";
		RegWriteE <= '0';
		RegWriteM <= '0';
		RegWriteW <= '0';
		MemtoRegE <= '0';
		MemtoRegM <= '0';
		WriteRegE <= "00000";
		WriteRegM <= "00000";
		WriteRegW <= "00000";
		BranchD <= '0';
        wait for 10 ns;
		
		
		--Forwarding D
		
		--ForwardAD = 1
		RsD <= "00010";
		WriteRegM <= "00010";
		RegWriteM <= '1';
		--ForwardBD = 0
		RtD <= "00011";
		--branchstall = 1
		BranchD <= '1';
		RegWriteE <= '1';
		WriteRegE <= "00011";
		wait for 1 ns;
		assert ForwardAD = '1' report "ForwardAD is not 1";
		assert ForwardBD = '0' report "ForwardBD is not 0";
		assert StallD = '1' AND StallF = '1' AND FlushE = '1' report "Branchstall is not 1";
		wait for 10 ns;
		
		--ForwardAD = 0
		RsD <= "00011";
		WriteRegM <= "00010";
		RegWriteM <= '1';
		--ForwardBD = 1
		RtD <= "00010";
		--branchstall = 1
		BranchD <= '1';
		RegWriteE <= '0';
		MemtoRegM <= '1';
		wait for 1 ns;
		assert ForwardAD = '0' report "ForwardAD is not 0";
		assert ForwardBD = '1' report "ForwardBD is not 1";
		assert StallD = '1' AND StallF = '1' AND FlushE = '1' report "Branchstall is not 1";
		wait for 10 ns;
		
		--branchstall = 0
		BranchD <= '0';
		RegWriteE <= '0';
		MemtoRegM <= '0';
		wait for 1 ns;
		assert StallD = '0' AND StallF = '0' AND FlushE = '0' report "Branchstall is not 0";
		wait for 10 ns;

		
		--Forwarding E
		
		--ForwardAE = 10
		RsE <= "00100";
		WriteRegM <= "00100";
		RegWriteM <= '1';
		--ForwardBE = 10
		RtE <= "00100";
		wait for 1 ns;
		assert ForwardAE = "10" report "ForwardAE is not 10";
		assert ForwardBE = "10" report "ForwardBE is not 10";
		wait for 10 ns;
		
		--ForwardAE = 01
		RegWriteM <= '0';
		WriteRegW <= "00100";
		RegWriteW <= '1';
		--ForwardBE = 01
		wait for 1 ns;
		assert ForwardAE = "01" report "ForwardAE is not 01";
		assert ForwardBE = "01" report "ForwardBE is not 01";
		wait for 10 ns;
		
		--ForwardAE = 00
		RegWriteM <= '0';
		RegWriteW <= '0';
		--ForwardBE = 00
		wait for 1 ns;
		assert ForwardAE = "00" report "ForwardAE is not 00";
		assert ForwardBE = "00" report "ForwardBE is not 00";
		wait for 10 ns;
		
		--Stalling
		
		--lwstall = 1
		--((RsD = RtE) or (RtD = RtE)) and (MemToRegE = '1')
		RsD <= "01001";
		RtE <= "01001";
		MemtoRegE <= '1';
		wait for 1 ns;
		assert StallD = '1' AND StallF = '1' AND FlushE = '1' report "lwstall is not 1";
		wait for 10 ns;
		
		--lwstall = 1
		--((RsD = RtE) or (RtD = RtE)) and (MemToRegE = '1')
		RsD <= "00000";
		RtD <= "01001";
		RtE <= "01001";
		MemtoRegE <= '1';
		wait for 1 ns;
		assert StallD = '1' AND StallF = '1' AND FlushE = '1' report "lwstall is not 1";
		wait for 10 ns;
		
		--lwstall = 0
		RsD <= "00000";
		RtD <= "01000";
		RtE <= "01001";
		wait for 1 ns;
		assert StallD = '0' AND StallF = '0' AND FlushE = '0' report "lwstall is not 0";
		wait for 10 ns;
		

        wait;
    end process;
end;