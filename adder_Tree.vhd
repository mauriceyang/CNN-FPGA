



library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
library work;
use work.init.all;

entity adder_tree is
	generic ( num_mult : integer := 8 ); 
	port( i_clk: in std_logic;
		i_input: in parallel_array_product_signed(num_mult-1 downto 0);
		i_rstn : in std_logic;
		o_sout: out signed(2*bit_width-1 downto 0)
	);
end adder_tree;

architecture main of adder_tree is

	--adder tree
	constant adder_levels: integer := integer(ceil(log2(real(num_mult))));
	
	type add_tree_info_type is  
    record
        nsize : integer_array(adder_levels-1 downto 0);
        num_adders : integer_array(adder_levels-1 downto 0);
		index_start_a : integer_array(adder_levels-1 downto 0);
		index_end_a : integer_array(adder_levels-1 downto 0);
		index_start_b : integer_array(adder_levels-1 downto 0);
		index_end_b : integer_array(adder_levels-1 downto 0);
		index_start_sout : integer_array(adder_levels-1 downto 0);
		index_end_sout : integer_array(adder_levels-1 downto 0);
		index_remainder : integer_array(adder_levels-1 downto 0);
		num_remainder : integer;
		total_elements : integer;
    end record;
	
function construct_adder_tree(
	num_in: integer; adder_levels : integer) return add_tree_info_type is 
	
	variable tree_info : add_tree_info_type;
	variable num_add_curr_level : integer;
	variable nsize : integer_array(adder_levels-1 downto 0);
	variable curr : integer := 0;
	variable prev : integer := 0;
	variable num_remainder : integer := 0;
	variable total_elements : integer := 0;
begin
	
	tree_info.index_start_a(0) := 0;
	report "num_mult " & integer'image(num_mult);
	report "adder_levels " & integer'image(adder_levels);
	
	nsize(0) := num_in;
	for level in 0 to adder_levels-1 loop
	report "curr " & integer'image(curr);
	report "nsize(level) " & integer'image(nsize(level));
	
		num_add_curr_level := (nsize(level))/2;
		tree_info.num_adders(level) := num_add_curr_level;
		tree_info.index_end_a(level) := curr + num_add_curr_level-1;
		
		tree_info.index_start_b(level) := curr + num_add_curr_level;
		tree_info.index_end_b(level) := curr + 2*num_add_curr_level-1;
				
		--if there is a odd one out
		if level < adder_levels-1 then 
			if (nsize(level) mod 2) = 1 then 
				--update the current index
				curr := curr + (nsize(level));
				--update the size of the current level
				nsize(level+1) := nsize(level)/2 + 1;
				
				--update index of one left out
				tree_info.index_remainder(level) := curr - 1;
				num_remainder := num_remainder + 1;
			else
				curr := curr + nsize(level);
				nsize(level+1) := nsize(level)/2;	
			end if;
		else
			curr := curr + nsize(level);
		end if;
		
		
		if level < adder_levels-1 then
			tree_info.index_start_a(level+1) := curr;
		end if;
				
		tree_info.index_start_sout(level) := curr;
		tree_info.index_end_sout(level) := curr + num_add_curr_level-1;
		tree_info.nsize := nsize;
		
	end loop;
	
	for level in 0 to num_remainder-1 loop
		tree_info.index_remainder(level) := tree_info.index_start_a(level+1)-1;
		tree_info.index_remainder(level+1) := tree_info.index_start_a(level+1)+nsize(level+1)-1;
	end loop;
		
	for i in 0 to adder_levels-1 loop
		total_elements := total_elements + nsize(i);
	report "num_adders " & integer'image(tree_info.num_adders(i));
	report "index_start_a " & integer'image(tree_info.index_start_a(i));
	report "index_end_a " & integer'image(tree_info.index_end_a(i));
	report "index_start_b " & integer'image(tree_info.index_start_b(i));
	report "index_end_b " & integer'image(tree_info.index_end_b(i));
	report "index_start_sout " & integer'image(tree_info.index_start_sout(i));
	report "index_end_sout " & integer'image(tree_info.index_end_sout(i));
	report "index_remainder " & integer'image(tree_info.index_remainder(i));
	end loop;
	
	tree_info.total_elements := total_elements;
	tree_info.num_remainder := num_remainder;
		
	report "num_remainder " & integer'image(tree_info.num_remainder);
	report "total_elements " & integer'image(tree_info.total_elements);
	-- report "index_start_sout " & integer'image(tree_info.index_start_sout(1));
	return tree_info;
end construct_adder_tree;

constant adder_tree_info: add_tree_info_type := construct_adder_tree(num_mult, adder_levels);

--last index is output
signal temp_storage : parallel_array_product_signed(adder_tree_info.total_elements downto 0);
	



begin
	
	
	process(i_input, temp_storage) begin

				
		temp_storage(adder_tree_info.nsize(0)-1 downto 0) <= i_input(num_mult-1 downto 0);

		for level in 0 to adder_levels-1 loop
			for i in 0 to adder_tree_info.num_adders(level)-1 loop
				temp_storage(adder_tree_info.index_start_sout(level) + i) <= temp_storage(adder_tree_info.index_start_a(level) + i) + temp_storage(adder_tree_info.index_start_b(level) + i);
			end loop;
		end loop;
		
		
		for index in 0 to adder_tree_info.num_remainder-1 loop
			--remainder
			temp_storage(adder_tree_info.index_remainder(index+1)) <= temp_storage(adder_tree_info.index_remainder(index));
		end loop;	
				
	end process;
	
	o_sout <= temp_storage(adder_tree_info.total_elements);
end architecture;