-- Single port RAM with single read/write address 
library ieee;
use ieee.std_logic_1164.all;

entity single_port_ram is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);

	port 
	(
		clk		: in std_logic;
		addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '0';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end entity;

architecture rtl of single_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t;

	-- Register to hold the address 
	signal addr_reg : natural range 0 to 2**ADDR_WIDTH-1;

begin

	process(clk)
	begin
	if(rising_edge(clk)) then
		if(we = '1') then
			ram(addr) <= data;
		end if;

		-- Register the address for reading
		addr_reg <= addr;
	end if;
	end process;

	q <= ram(addr_reg);

end rtl;

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
		done :  out std_logic
	);
end entity toplevel;

architecture top of toplevel is

	Component single_port_ram is

		generic 
		(
			DATA_WIDTH : natural := 8;
			ADDR_WIDTH : natural := 6
		);

		port 
		(
			clk		: in std_logic;
			addr	: in natural range 0 to 2**ADDR_WIDTH - 1;
			data	: in std_logic;
			we		: in std_logic := '0';
			q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
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
	
	signal store    : std_logic;
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
			response => store
		);

	CTRL: control_unit
		generic map(
			challenge_bits => challenge_bits/2
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

	RAM: single_port_ram
		generic map(
			DATA_WIDTH => 1,
			ADDR_WIDTH => challenge_bits
		)
		port map(
			clk => clock,
			addr => to_integer(unsigned(controller_challenge)),
			data => store,
			we => storeen
		);

end architecture top;
