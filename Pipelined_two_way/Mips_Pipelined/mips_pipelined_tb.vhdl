library ieee;
use ieee.std_logic_1164.all;

entity mips_pipelined_tb is
end;

architecture structure of mips_pipelined_tb is

    component mips_pipelined is
        port (
            clk   : in std_logic;
            reset : in std_logic
        );
    end component;

  signal clk, reset : std_logic;

begin
    mips : mips_pipelined port map(clk => clk, reset => reset);

    process begin
        -- reset
        clk   <= '0';
        reset <= '1';
        wait for 10 ns;
        clk   <= '0';
        reset <= '0';
        wait for 10 ns;

        -- do cycles
        for i in 1 to 26 loop
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
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

        wait;
    end process;

end;


