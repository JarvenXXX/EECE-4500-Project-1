library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity toplevel is
	generic (
		ro_length:	positive := 13;
		ro_count:	positive := 16
	);
	port (
		clock:	in	std_logic;	-- global clock input, 50 MHz clock
		reset:	in	std_logic;	-- global asynchronous reset, button
		done :  out std_logic := '0'
	);
end entity toplevel;

architecture top of toplevel is

	Component ram is
		Port
		(
			address		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
		);

	end Component;

	Component control_unit is
		generic (
			challenge_bits:		positive := 4;
			clock_frequency:	positive := 200;	-- in MHz
			delay_us:			positive := 10		-- in microseconds
			);
		port (
			clock:	in	std_logic;
			reset:	in	std_logic;
			enable:	in	std_logic;
		
			counter_enable:	out	std_logic;
			counter_reset:	out	std_logic;
			challenge:		out	std_logic_vector(2*challenge_bits - 1 downto 0);
			store_response:	out	std_logic;
			done:	out	std_logic
		);
	end Component;

	Component ro_puf is 
		Generic(ro_length : positive := 13;
			     ro_count  : positive := 16);
		Port(reset : in std_logic;
			  enable: in std_logic;
	        challenge : in std_logic_vector(2*positive(ceil(log2(real(ro_count / 2)))) - 1 downto 0);
		     response : out std_logic);
	End Component;
	
	signal controller_counterenable : std_logic;
	constant challenge_bits: positive := 2 * positive(ceil(log2(real(ro_count / 2))));
   signal controller_challenge : std_logic_vector(challenge_bits - 1 downto 0);
	
	signal store    : std_logic_vector(0 downto 0);
	signal storeen  : std_logic;
	-- TODO: any signal declarations you may need
begin

	-- TODO: make instance of ro_puf
	puf: ro_puf
		generic map (
			ro_length => ro_length,
			ro_count => ro_count
		)
		port map (
			reset => reset,
			enable => controller_counterenable,
			challenge => controller_challenge,
			response => store(0)
		);

	CTRL: control_unit
		generic map(
			challenge_bits => challenge_bits/2,
			clock_frequency => 50
		)
		port map(
			clock => clock,
			reset => reset,
			enable => '1',
			counter_enable => controller_counterenable,
			challenge => controller_challenge,
			store_response => storeen,
			done => done
		);

	SPR: ram
		port map(
			clock => clock,
			address => controller_challenge,
			data => store,
			wren => storeen
		);

end architecture top;
