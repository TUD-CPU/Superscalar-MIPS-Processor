-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity hazard_unit is
  port(
	clk: in std_logic;
	reset: in std_logic;
    instr1: in std_logic_vector(31 downto 0);
    instr2: in std_logic_vector(31 downto 0);
    aluout1: in std_logic_vector(31 downto 0);
    aluout2: in std_logic_vector(31 downto 0);
	jump1: in std_logic;
	pcsrc1: in std_logic;
	jump2: in std_logic;
	pcsrc2: in std_logic;
    writereg1: in std_logic_vector(4 downto 0);
    writereg2: in std_logic_vector(4 downto 0);
	regwrite1: in std_logic;
	regwrite2: in std_logic;
	pc1: in std_logic_vector(31 downto 0);
	pc2: in std_logic_vector(31 downto 0);
	stall2: out std_logic;
    pc: buffer std_logic_vector(31 downto 0);
    pcplus4_out: out std_logic_vector(31 downto 0);
    pcplus8_out: out std_logic_vector(31 downto 0)
  );
end;

architecture structure of hazard_unit is

  component adder
    port(
      a: in std_logic_vector(31 downto 0);
      b: in std_logic_vector(31 downto 0);
      y: out std_logic_vector(31 downto 0)
    );
  end component;

  component mux2
    generic(w: integer := 8);
    port(
      d0: in std_logic_vector(w-1 downto 0);
      d1: in std_logic_vector(w-1 downto 0);
      s: in std_logic;
      y: out std_logic_vector(w-1 downto 0)
    );
  end component;
  
  component syncresff is
	  generic (w: integer := 32);
	  port(
		clk: in std_logic;
		reset: in std_logic;
		d: in std_logic_vector(w-1 downto 0);
		q: buffer std_logic_vector(w-1 downto 0)
	  );
  end component;

  
  signal PCplus4, PCplus8: std_logic_vector(31 downto 0);
  signal PCnext, PCplus, PCjump2: std_logic_vector(31 downto 0);
  signal PCcontrol1, PCcontrol2: std_logic;
  signal stall: std_logic;
begin
  -- program counter
  program_counter: syncresff generic map(32)
                             port map(clk => clk, 
							          reset => reset,
									  d => PCnext,
									  q => pc);
									  
  -- add 4 to pc
  adder4: adder port map(a => pc,
                         b => x"00000004",
						 y => pcplus4);
						 
  -- add 8 to pc
  adder8: adder port map(a => pc,
                         b => x"00000008",
						 y => pcplus8);
						 
  -- mux to choose between pcplus8 and pcplus4
  pcplusMux: mux2 generic map(32)
                  port map(d0 => pcplus8,
				           d1 => pcplus4,
						   s  => stall,
						   y  => PCplus);
						   
  -- mux to choose between pcplus and branch/jump address from execution unit 2
  pcjump2Mux: mux2 generic map(32)
                  port map(d0 => PCplus,
				           d1 => pc2,
						   s  => PCcontrol2,
						   y  => PCjump2);
						   
  -- mux to choose between pcplus and branch/jump address from execution unit 1
  pcjump1Mux: mux2 generic map(32)
                  port map(d0 => PCjump2,
				           d1 => pc1,
						   s  => PCcontrol1,
						   y  => PCnext);
						   
  -- use branch/jump address from execution unit 1?
  PCcontrol1 <= jump1 or pcsrc1;
  
  -- use branch/jump address from execution unit 2?
  PCcontrol2 <= jump2 or pcsrc2;

  -- hazard solving
  
  process (instr1, instr2, writereg1, writereg2, regwrite1, regwrite2, aluout1, aluout2) begin
    ---- stalling execution unit 2 if one of these hazard occurs
	-- stall <= '0';
	---- sw and lw to the same address
	if ( ( ( (instr1(31 downto 26) = "100011") and (instr2(31 downto 26) = "101011") ) or 
	     ( (instr1(31 downto 26) = "101011") and (instr2(31 downto 26) = "100011") ) ) and aluout1 = aluout2 ) then
	  stall <= '1';
	
	---- jump or branch in first execution unit
	elsif ( instr1(31 downto 26) = "000100" ) or ( instr1(31 downto 26) = "000010" ) then
	  stall <= '1';
	
	---- write and read the same register
	
	elsif ( ( ( regwrite1 = '1' ) and ( ( instr2(25 downto 21) = writereg1) or ( instr2(20 downto 16) = writereg1) ) ) or
		      ( ( regwrite2 = '1' ) and ( ( instr1(25 downto 21) = writereg2) or ( instr1(20 downto 16) = writereg2) ) ) ) then
	  stall <= '1';
	
	---- else no stall
	else
	  stall <= '0';
	end if;
	
  end process;

  -- stall output
  stall2 <= stall;
  
  pcplus4_out <= PCplus4;
  pcplus8_out <= PCplus8;

end;
