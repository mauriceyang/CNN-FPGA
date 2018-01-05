library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package init is
	--kernel dimensions
	constant kernel_width : integer := 5;
	constant kernel_height : integer  := 5;
	constant kernel_size : integer := kernel_height*kernel_width;
	
	constant input_width : integer := 6;
	constant input_height : integer := 6;
	
	constant num_kernel : integer := 2;
	
	
	constant bit_width : integer := 8; 
	constant num_mult : integer := 3; 
	
	type parallel_array is array(natural range <>) of std_logic_vector(bit_width-1 downto 0);
	type parallel_array_signed is array(natural range <>) of signed(bit_width-1 downto 0);
	type parallel_array_product_signed is array(natural range <>) of signed(2*bit_width-1 downto 0);
	type serial_array is array(natural range <>) of std_logic;
	type integer_array is array(natural range <>) of integer;
	type natural_array is array(natural range <>) of natural;
	
	type parallel_matrix is array(natural range <>, natural range <>) of std_logic_vector(bit_width-1 downto 0);
	type integer_matrix is array(natural range <>, natural range <>) of integer;
	
	
	--stores bits from t_he 5x5 kernel
	type kernel_array25 is array (24 downto 0) of std_logic_vector(bit_width-1 downto 0);
	
	--input _window to t_he convolutional layer - 5x5
	type conv_input_window is array (24 downto 0) of std_logic_vector(bit_width-1 downto 0);
	
	
	
	--CNN layers
	
	constant N_conv_stages : natural := 2;
	constant N_fc_stages : natural := 2;
	constant N_stages : natural := N_conv_stages + N_fc_stages;
	
	constant inputfm_W_params :  natural_array(0 to N_stages-1) := (28,12,800,500);
	constant inputfm_H_params :  natural_array(0 to N_stages-1) := (28,12,1,1);
	constant inputfm_N_params :  natural_array(0 to N_stages-1) := (1,20,1,1);
	
	constant outputfm_W_params :  natural_array(0 to N_stages-1) := (24,8,500,10);
	constant outputfm_H_params :  natural_array(0 to N_stages-1) := (24,8,1,1);
	constant outputfm_M_params :  natural_array(0 to N_stages-1) := (20,50,1,1);
	
	
	constant N_keep_params : natural_array(0 to N_stages-1) := (6,3,3,3);
	constant kernel_size_params : natural_array(0 to N_stages-1) := (5,5,5,5);
	constant N_masks_params : natural_array(0 to N_stages-1) := (8,8,8,8);
	constant N_SPE_params : natural_array(0 to N_stages-1) := (5,5,5,5);
	
	
			
end package init;