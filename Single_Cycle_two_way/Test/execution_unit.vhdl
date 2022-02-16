-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity execution_unit is
  port(
	pcadd: in std_logic_vector(31 downto 0);
	instr: in std_logic_vector(31 downto 0);
	srcA: in std_logic_vector(31 downto 0);
	writedata: in std_logic_vector(31 downto 0);
    readdata: in std_logic_vector(31 downto 0);
	stall: in std_logic;
    regwrite: out std_logic;
	jump_out: out std_logic;
	memwrite_out: out std_logic;
    pcsrc_out: out std_logic;
	writereg: out std_logic_vector(4 downto 0);
	writedata_out: out std_logic_vector(31 downto 0);
    aluout: buffer std_logic_vector(31 downto 0);
	result: out std_logic_vector(31 downto 0);
	pcnextbr: out std_logic_vector(31 downto 0)
  );
end;

architecture structure of execution_unit is
  component alu
      port (
		a          : in std_logic_vector(31 downto 0);
		b          : in std_logic_vector(31 downto 0);
		shamt      : in std_logic_vector(4 downto 0);
		alucontrol : in std_logic_vector(3 downto 0);
		result     : buffer std_logic_vector(31 downto 0);
		zero       : out std_logic
	  );
    end component;
  
  component controller is
	port(
	  op: in std_logic_vector(5 downto 0);
	  funct: in std_logic_vector(5 downto 0);
	  zero: in std_logic;
	  memtoreg: out std_logic;
	  memwrite: out std_logic;
	  pcsrc: out std_logic;
	  alusrc: out std_logic_vector(1 downto 0);
	  regdst: out std_logic;
	  regwrite: out std_logic;
	  jump: out std_logic;
	  alucontrol: out std_logic_vector(3 downto 0)
	);
  end component;

  component adder
    port(
      a: in std_logic_vector(31 downto 0);
      b: in std_logic_vector(31 downto 0);
      y: out std_logic_vector(31 downto 0)
    );
  end component;

  component sl2
    port(
      a: in std_logic_vector(31 downto 0);
      y: out std_logic_vector(31 downto 0)
    );
  end component;

  component signext
    port(
      a: in std_logic_vector(15 downto 0);
      aext: out std_logic_vector(31 downto 0)
    );
  end component;
  
  component sl16 is
    port (
        a    : in std_logic_vector(15 downto 0);
        y    : out std_logic_vector(31 downto 0)
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
  
  component mux4
    generic(w: integer := 8);
    port(
      d0: in std_logic_vector(w-1 downto 0);
      d1: in std_logic_vector(w-1 downto 0);
      d2: in std_logic_vector(w-1 downto 0);
      d3: in std_logic_vector(w-1 downto 0);
      s: in std_logic_vector(1 downto 0);
      y: out std_logic_vector(w-1 downto 0)
    );
  end component;

signal signimm, signimmsh, zeroex, pcjump, pcbranch: std_logic_vector(31 downto 0);
signal srcb: std_logic_vector(31 downto 0);
signal zero, memtoreg, regdst: std_logic;
signal alusrc : std_logic_vector(1 downto 0);
signal alucontrol : std_logic_vector(3 downto 0);
signal shamt : std_logic_vector(4 downto 0);
signal not_stall, memwrite, pcsrc, jump: std_logic;

begin
  -- next pc logic
  pcjump <= pcadd(31 downto 28) & instr(25 downto 0) & "00";
  
  -- shift amount for shift instructions
  shamt <= instr(10 downto 6);
  
  -- shift left2
  immsh: sl2 port map(signimm, signimmsh);
  
  -- adder to add immediate to pc+4 as an option for branch
  pcaddBranch: adder port map(pcadd, signimmsh, pcbranch);
  
  -- mux to chose between branch or jump address
  pcbrmux: mux2 generic map(32) port map(pcbranch, pcjump, jump, pcnextbr);
  
  -- mux for deciding into which register (out of the two specified in the instruction) to write
  wrmux: mux2 generic map(5) port map(instr(20 downto 16),
									  instr(15 downto 11), regdst, writereg);

  -- chose to store value from alu or memory to register
  resmux: mux2 generic map(32) port map(aluout, readdata, memtoreg, result);
  
  -- sign extender
  se: signext port map(instr(15 downto 0), signimm);
  
  -- shift left 16 for lui
  shiftLeft16 : sl16 port map(instr(15 downto 0), zeroex);
  
  -- chose rd2 or sign extended value (add immediate to a register or add two values in registers)
  srcbmux: mux4 generic map(32) port map(writedata, signimm, zeroex, x"00000000", alusrc, srcb);
  
  -- alu
  mainalu: alu port map(srca, srcb, shamt, alucontrol, aluout, zero);
  
  -- controller
  control: controller port map(op => instr(31 downto 26), funct => instr(5 downto 0), zero => zero, memtoreg => memtoreg,
                               memwrite => memwrite, pcsrc => pcsrc, alusrc => alusrc, regdst => regdst, regwrite => regwrite,
							   jump => jump, alucontrol => alucontrol);
  
  
  writedata_out <= writedata;
  
  -- if stall is 1 then memwrite, regwrite, pcsrc and jump are set to 0
  -- this stops any changes to the processor
  not_stall <= not stall;
  
  memwrite_out  <= memwrite and not_stall;
  pcsrc_out     <= pcsrc and not_stall;
  jump_out      <= jump and not_stall;
  
  -- regwrite is handled in mips.vhdl
  
end;
