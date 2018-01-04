
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
library work;
use work.init.all;

entity mac is
	generic ( bit_width : integer := 16 ;
				num_mult : integer := 4 ); 
	
	port( i_clk: in std_logic;
		i_a: in parallel_array(num_mult-1 downto 0);
		i_b: in parallel_array(num_mult-1 downto 0);
		i_rstn : in std_logic;
		o_sout : out signed(2*bit_width-1 downto 0)
	);
end mac;

architecture main of mac is

--output from multiplier
signal product: parallel_array_product_signed(num_mult-1 downto 0);

signal product_in: parallel_array_product_signed(num_mult-1 downto 0);

signal sout : signed(2*bit_width-1 downto 0);


component adder_tree 
	generic ( num_mult : integer := num_mult );
	port( i_clk: in std_logic;
		i_input: in parallel_array_product_signed(num_mult-1 downto 0);
		i_rstn : in std_logic;
		o_sout: out signed(2*bit_width-1 downto 0)
	);
end component;
	
begin

	--multiply, registered output
--	process(i_clk) begin
--		if rising_edge(i_clk) then
--			if i_rstn = '0' then
--				product <= (others=>(others => '0'));
--			else
--				for i in 0 to num_mult-1 loop
--					product(i) <= i_a(i) * i_b(i);
--				end loop;		
--			end if;
--		end if;
--	end process;
	
	process(i_a, i_b) begin
		for i in 0 to num_mult-1 loop
			product(i) <= signed(i_a(i)) * signed(i_b(i));
		end loop;		
	end process;
	
	add_tree:  adder_tree generic map(num_mult => num_mult) 
	port map( 	i_clk,
				product_in,
				i_rstn,
				sout
	);
	
	process begin
		wait until rising_edge(i_clk);
		
		if i_rstn = '0' then 
			product_in <= (others=>(others => '0'));
			o_sout <= (others => '0');
		else
			product_in <= product;
			o_sout <= sout; 
		end if;
	end process;
		
		
end architecture;