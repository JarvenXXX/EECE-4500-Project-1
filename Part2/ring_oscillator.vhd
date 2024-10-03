Library ieee;
use ieee.std_logic_1164.all;

Entity ring_oscillator is 
	Generic (osc_len : positive := 13);
	Port (en  : in std_logic;
			osc : out std_logic);
end ring_oscillator;

Architecture oscillate of ring_oscillator is
	signal invers : std_logic_vector(osc_len - 1 downto 0) := (others => 'U');
	Component inverter is
		port(i : in std_logic;
			  o : out std_logic);
	end component inverter;
Begin

	assert (osc_len mod 2 /= 0) report "Error: There must be an odd number of inverters!" severity failure;

	invers(0) <= en nand invers(osc_len-1);
	
	INV: for i in 1 to osc_len-1 generate
		invers(i) <= not invers(i-1);
	end generate;
	
	osc <= invers(osc_len-1);
	
end oscillate;