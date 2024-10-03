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

entity toplevel is
	generic (
		ro_length:	positive := 13;
		ro_count:	positive := 16
	);
	port (
		clock:	in	std_logic;	-- global clock input, 50 MHz clock
		reset:	in	std_logic	-- global asynchronous reset, button
	);
end entity toplevel;

architecture top of toplevel is
	-- TODO: any signal declarations you may need
begin

	-- TODO: make instance of ro_puf
	puf: ro_puf
		generic map (
			ro_lenght => ro_length,
			ro_count => ro_count
		)
		port map (
			-- add port information
			-- should use some signals internal to this architecture
			-- should use the `reset' input from toplevel
		);

	-- TODO: control unit
	-- use control unit entity from blackboard, make entity here
	-- uses the `clock' input and the `reset' input from toplevel

	-- TODO: BRAM
	-- create a BRAM using the IP Catalog, instance it here
	-- make sure you enable the In-System Memory Viewer!-- Quartus Prime VHDL Template

end architecture top;
