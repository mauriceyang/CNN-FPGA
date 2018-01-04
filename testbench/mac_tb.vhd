
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

library work;
use work.init.all;

entity mac_tb is
end mac_tb;

architecture main of mac_tb is


	constant period : time := 10 ns;
	
	constant a_val : std_logic_vector(bit_width-1 downto 0) := "00000001";
	constant b_val : std_logic_vector(bit_width-1 downto 0) := "00000010";
	
	constant num_mult : integer := 8;
	
	signal a : parallel_array(num_mult-1 downto 0);
	signal b : parallel_array(num_mult-1 downto 0);
		
	signal clk : std_logic;
	signal rst : std_logic;
	signal result :signed(2*bit_width-1 downto 0);
	
	component mac
		generic (bit_width : integer := bit_width; 
					num_mult : integer := num_mult ); 		
		port( i_clk: in std_logic;
			i_a: in parallel_array(num_mult-1 downto 0);
			i_b: in parallel_array(num_mult-1 downto 0);
			i_rstn : in std_logic;
			o_sout : out signed(2*bit_width-1 downto 0)
		);
	end component;
	
begin
  
	mult : mac generic map(bit_width => bit_width, num_mult => num_mult) port map( 
		clk,
		a, 
		b,
		rst,
		result
	);

	process begin
		clk <= '0';
		wait for period;
		loop
		  clk <= not clk;
		  wait for 0.5 * period;
		end loop;
	end process;
	
	process begin
			
		rst <= '0';
		--Test1
		wait for period;
		rst <= '1';
		a <= (others => (a_val));
		b <= (others => (b_val));

		--Test2
		wait for period;
		a <= (others => ("00000010"));
		b <= (others => (b_val));
		
		wait for 10*period;
		assert false report "" severity FAILURE;
	end process;
	
end architecture;

