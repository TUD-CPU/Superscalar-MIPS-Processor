library ieee;
use ieee.std_logic_1164.all;

entity Fetch_Unit is
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
	
	signal PCcontrol1, PCcontrol2, not_StallF : std_logic;
	signal PCplus, PCjump2, PCnext, PC, PCplus4, PCplus8 : std_logic_vector(31 downto 0);

begin
	-- Program counter
	not_StallF <= not StallF;
	programCounter : syncresff port map(clk => clk, reset => reset, StallF => not_StallF, d => PCnext, q => PC);
	
	-- adder +4
	adder4 : adder port map(a => PC, b => x"00000004", y => PCplus4);
	
	-- adder +8
	adder8 : adder port map(a => PC, b => x"00000008", y => PCplus8);
	
	-- mux2 choose between PCplus4 and PCplus8
	pcplusmux : mux2 generic map(w => 32) port map(d0 => PCplus8, d1 => PCplus4, s => Stall2, y => PCplus);
	
	-- mux2 choose between PCplus and branch/jump address from execution unit 2
	pc2mux : mux2 generic map(w => 32) port map(d0 => PCplus, d1 => PC2, s => PCcontrol2, y => PCjump2);
	
	-- mux2 choose between PCjump2 and branch/jump address from execution unit 1
	pc1mux : mux2 generic map(w => 32) port map(d0 => PCjump2, d1 => PC1, s => PCcontrol1, y => PCnext);
	
	-- Control signals to choose between PCplus and branch/jump addresses from the execution units
	PCcontrol1 <= JumpD1 or PCsrcD1;
	PCcontrol2 <= JumpD2 or PCsrcD2;
	
	-- PC output
	PC_out <= PC;
	PCplus4_out <= PCplus4;
	PCplus8_out <= PCplus8;
end;