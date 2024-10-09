Library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

Entity ro_puf is 
	Generic(ro_length : positive := 13;
			  ro_count  : positive := 16);
	Port(reset : in std_logic;
		  enable: in std_logic;
	     challenge : in std_logic_vector(2*positive(ceil(log2(real(ro_count / 2)))) - 1 downto 0);
		  response : out std_logic);
End ro_puf;

Architecture comparison of ro_puf is 
   constant challenge_bits: positive := 2 * positive(ceil(log2(real(ro_count / 2))));
	type natarray is array (0 to ro_count-1) of natural;
	signal counts : natarray;
	
	signal group_a_select_v: std_logic_vector(challenge_bits/2 - 1 downto 0);
	signal group_b_select_v: std_logic_vector(challenge_bits/2 - 1 downto 0);

	signal group_a_select: natural range 0 to 2**(challenge_bits / 2) - 1;
	signal group_b_select: natural range 0 to 2**(challenge_bits / 2) - 1;

	signal osc_out: std_logic_vector(ro_count - 1 downto 0);
	
	Component ring_oscillator is 
		Generic (osc_len : positive := 13);
		Port (en  : in std_logic;
				osc : out std_logic);
	end component;
	
	Function is_power_two (n :	in	positive) return boolean is
		variable t1: std_logic_vector(31 downto 0);
		variable t2: std_logic_vector(31 downto 0);
		variable t3: std_logic_vector(31 downto 0);
	Begin
		t1 := std_logic_vector(to_unsigned(n, 32));
		t2 := std_logic_vector(to_unsigned(n - 1, 32));
		t3 := t1 and t2;
		return to_integer(unsigned(t3)) = 0;
	End function;
	
Begin
	assert is_power_two(ro_count) report "Error: The number of oscillators must be a power of 2!" severity failure;

	group_a_select_v <= challenge(challenge_bits/2 - 1 downto 0);
	group_a_select <= to_integer(unsigned(group_a_select_v));

	group_b_select_v <= challenge(challenge_bits - 1 downto challenge_bits/2);
	group_b_select <= to_integer(unsigned(group_b_select_v));
	
	-- TODO: generate group a
	group_a: for i in 0 to ro_count / 2 - 1 generate
		OSCA : ring_oscillator generic map (osc_len => ro_length)
									  port map (en => enable,
													osc => osc_out(i));
	end generate group_a;

	-- TODO: generate group_b
	group_b: for i in ro_count / 2 to ro_count - 1 generate
		OSCB : ring_oscillator generic map (osc_len => ro_length)
										  port map (en => enable,
														osc => osc_out(i));
	end generate group_b;
	
	counters: for i in 0 to ro_count - 1 generate
		CTR: process(reset, osc_out(i)) is
		begin
			if reset = '0' then
				counts(i) <= 0;
			elsif rising_edge(osc_out(i)) then
				if enable = '1' then
					counts(i) <= counts(i) + 1;
				end if;
			end if;
		end process ctr;
	end generate counters;
	
	response <= '1' when counts(group_a_select) < counts(group_b_select + ro_count/2)) else
					'0';
	
End comparison;
