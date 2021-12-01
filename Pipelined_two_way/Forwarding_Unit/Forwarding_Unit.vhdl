library ieee;
use ieee.std_logic_1164.all;

entity Forwarding_Unit is
    port (
		clk         : in std_logic;
	
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
end;

architecture behavior of Forwarding_Unit is

begin
	
	
	--Forwarding D1    missing branchstall!!!
	process (clk, RsD1, RtD1, WriteRegM1, RegWriteM1, WriteRegM2, RegWriteM2, RD1D1, RD2D1)begin
		if ( (RsD1 /= "00000") AND (RsD1 = WriteRegM2) AND (RegWriteM2 = '1') ) then
			EqualAD1 <= ALUOutM2;
		elsif ( (RsD1 /= "00000") AND (RsD1 = WriteRegM1) AND (RegWriteM1 = '1') ) then
			EqualAD1 <= ALUOutM1;
		else
			EqualAD1 <= RD1D1;
		end if;
		
		if ( (RtD1 /= "00000") AND (RtD1 = WriteRegM2) AND (RegWriteM2 = '1') ) then
			EqualBD1 <= ALUOutM2;
		elsif ( (RtD1 /= "00000") AND (RtD1 = WriteRegM1) AND (RegWriteM1 = '1') ) then
			EqualBD1 <= ALUOutM1;
		else
			EqualBD1 <= RD2D1;
		end if;
		
	end process;
	
	--Forwarding D2    missing branchstall!!!
	process (clk, RsD2, RtD2, WriteRegM1, RegWriteM1, WriteRegM2, RegWriteM2, RD1D1, RD2D1)begin
		if ( (RsD2 /= "00000") AND (RsD2 = WriteRegM2) AND (RegWriteM2 = '1') ) then
			EqualAD2 <= ALUOutM2;
		elsif ( (RsD2 /= "00000") AND (RsD2 = WriteRegM1) AND (RegWriteM1 = '1') ) then
			EqualAD2 <= ALUOutM1;
		else
			EqualAD2 <= RD1D2;
		end if;
		
		if ( (RtD2 /= "00000") AND (RtD2 = WriteRegM2) AND (RegWriteM2 = '1') ) then
			EqualBD2 <= ALUOutM2;
		elsif ( (RtD2 /= "00000") AND (RtD2 = WriteRegM1) AND (RegWriteM1 = '1') ) then
			EqualBD2 <= ALUOutM1;
		else
			EqualBD2 <= RD2D2;
		end if;
		
	end process;

    --Forwarding E1
    process (clk, RsE1, RtE1, RegWriteM1, RegWriteW1, WriteRegM1, WriteRegW1, RegWriteM2, RegWriteW2, WriteRegM2, WriteRegW2) begin
        if ((RsE1 /= "00000") and (RsE1 = WriteRegM2) and (RegWriteM2 = '1')) then
            SrcAE1 <= ALUOutM2;
		elsif ((RsE1 /= "00000") and (RsE1 = WriteRegM1) and (RegWriteM1 = '1')) then
            SrcAE1 <= ALUOutM1;
        elsif ((RsE1 /= "00000") and (RsE1 = WriteRegW2) and (RegWriteW2 = '1')) then
            SrcAE1 <= ResultW2;
		elsif ((RsE1 /= "00000") and (RsE1 = WriteRegW1) and (RegWriteW1 = '1')) then
            SrcAE1 <= ResultW1;
        else SrcAE1 <= RD1E1;
        end if;
		
		if ((RtE1 /= "00000") and (RtE1 = WriteRegM2) and (RegWriteM2 = '1')) then
            WriteDataE1 <= ALUOutM2;
		elsif ((RtE1 /= "00000") and (RtE1 = WriteRegM1) and (RegWriteM1 = '1')) then
            WriteDataE1 <= ALUOutM1;
        elsif ((RtE1 /= "00000") and (RtE1 = WriteRegW2) and (RegWriteW2 = '1')) then
            WriteDataE1 <= ResultW2;
		elsif ((RtE1 /= "00000") and (RtE1 = WriteRegW1) and (RegWriteW1 = '1')) then
            WriteDataE1 <= ResultW1;
        else WriteDataE1 <= RD2E1;
        end if;
    end process;
	
	--Forwarding E2
    process (clk, RsE2, RtE2, RegWriteM1, RegWriteW1, WriteRegM1, WriteRegW1, RegWriteM2, RegWriteW2, WriteRegM2, WriteRegW2) begin
        if ((RsE2 /= "00000") and (RsE2 = WriteRegM2) and (RegWriteM2 = '1')) then
            SrcAE2 <= ALUOutM2;
		elsif ((RsE2 /= "00000") and (RsE2 = WriteRegM1) and (RegWriteM1 = '1')) then
            SrcAE2 <= ALUOutM1;
        elsif ((RsE2 /= "00000") and (RsE2 = WriteRegW2) and (RegWriteW2 = '1')) then
            SrcAE2 <= ResultW2;
		elsif ((RsE2 /= "00000") and (RsE2 = WriteRegW1) and (RegWriteW1 = '1')) then
            SrcAE2 <= ResultW1;
        else SrcAE2 <= RD1E2;
        end if;
		
		if ((RtE2 /= "00000") and (RtE2 = WriteRegM2) and (RegWriteM2 = '1')) then
            WriteDataE2 <= ALUOutM2;
		elsif ((RtE2 /= "00000") and (RtE2 = WriteRegM1) and (RegWriteM1 = '1')) then
            WriteDataE2 <= ALUOutM1;
        elsif ((RtE2 /= "00000") and (RtE2 = WriteRegW2) and (RegWriteW2 = '1')) then
            WriteDataE2 <= ResultW2;
		elsif ((RtE2 /= "00000") and (RtE2 = WriteRegW1) and (RegWriteW1 = '1')) then
            WriteDataE2 <= ResultW1;
        else WriteDataE2 <= RD2E2;
        end if;
    end process;

end;