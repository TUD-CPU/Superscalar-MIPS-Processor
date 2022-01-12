-- Some portions of this code are based on code from the book "Digital Design and Computer Architecture" by Harris and Harris.
-- For educational purposes in TU Dortmund only.

library ieee;
use ieee.std_logic_1164.all;

entity mips is
  port(
    clk: in std_logic;
	reset: in std_logic;
	instr1_out: out std_logic_vector(31 downto 0);
	instr2_out: out std_logic_vector(31 downto 0)
  );
end;

architecture structure of mips is
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
  
  component hazard_unit is
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
  end component;

  component execution_unit is
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
  end component;
  
  component instr_mem is
  port (
	pc1: in std_logic_vector(31 downto 0);
	pc2: in std_logic_vector(31 downto 0);
	instr1: out std_logic_vector(31 downto 0);
	instr2: out std_logic_vector(31 downto 0)
  );
  end component;
  
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

  signal instr1, instr2, pcnextbr1, pcnextbr2, pc, pcplus4, pcplus8: std_logic_vector(31 downto 0);
  signal result1, result2, aluout1, aluout2, rd1, rd2, rd3, rd4: std_logic_vector(31 downto 0);
  signal readdata1, readdata2, writedata1, writedata2: std_logic_vector(31 downto 0);
  
  signal writereg1, writereg2: std_logic_vector(4 downto 0);
  
  signal jump1, pcsrc1, jump2, pcsrc2, stall, not_stall: std_logic;
  signal regwrite1, regwrite2, regwrite2_reg, memwrite1, memwrite2: std_logic;
  
  
begin

  haz_unit: hazard_unit port map(clk         => clk,
								 reset       => reset,
								 instr1      => instr1,
								 instr2      => instr2,
								 aluout1     => aluout1,
								 aluout2     => aluout2,
								 jump1       => jump1,
								 pcsrc1      => pcsrc1,
								 jump2       => jump2,
								 pcsrc2      => pcsrc2,
								 writereg1   => writereg1,
								 writereg2   => writereg2,
								 regwrite1   => regwrite1,
								 regwrite2   => regwrite2,
								 pc1         => pcnextbr1,
								 pc2         => pcnextbr2,
								 stall2      => stall,
								 pc          => pc,
								 pcplus4_out => pcplus4,
								 pcplus8_out => pcplus8);

  register_file: regfile port map(clk => clk,
								  we3 => regwrite1,
								  we6 => regwrite2_reg,
								  a1  => instr1(25 downto 21),
								  a2  => instr1(20 downto 16),
								  a3  => writereg1,
								  a4  => instr2(25 downto 21),
								  a5  => instr2(20 downto 16),
								  a6  => writereg2,
								  wd3 => result1,
								  wd6 => result2,
								  rd1 => rd1,
								  rd2 => rd2,
								  rd3 => rd3,
								  rd4 => rd4);
	

  execution_unit1: execution_unit port map(pcadd => pcplus4,
										   instr => instr1,
										   srcA => rd1,
										   writedata => rd2,
										   readdata => readdata1,
										   stall => '0',
										   regwrite => regwrite1,
										   jump_out => jump1,
										   memwrite_out => memwrite1,
										   pcsrc_out => pcsrc1,
										   writereg => writereg1,
										   writedata_out => writedata1,
										   aluout => aluout1,
										   result => result1,
										   pcnextbr => pcnextbr1);
										  
										  
  execution_unit2: execution_unit port map(pcadd => pcplus8,
										   instr => instr2,
										   srcA => rd3,
										   writedata => rd4,
										   readdata => readdata2,
										   stall => stall,
										   regwrite => regwrite2,
										   jump_out => jump2,
										   memwrite_out => memwrite2,
										   pcsrc_out => pcsrc2,
										   writereg => writereg2,
										   writedata_out => writedata2,
										   aluout => aluout2,
										   result => result2,
										   pcnextbr => pcnextbr2);
  
  instruction_memory: instr_mem port map(pc1    => pc,
										 pc2    => pcplus4,
										 instr1 => instr1,
										 instr2 => instr2);
  
  data_mem: data_memory generic map(size => 1024)
					    port map(clk       => clk,
								 addr1     => aluout1,
								 addr2     => aluout2,
								 data_in1  => writedata1,
								 data_in2  => writedata2,
								 memwrite1 => memwrite1,
								 memwrite2 => memwrite2,
								 data_out1 => readdata1,
								 data_out2 => readdata2);
								 

  instr1_out <= instr1; 
  instr2_out <= instr2; 
  
  
  not_stall <= not stall;
  
  regwrite2_reg  <= regwrite2 and not_stall;
  
end;
