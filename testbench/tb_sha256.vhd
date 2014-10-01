-- SHA256 Hashing Module - Testbench
-- Kristian Klomsten Skordal <kristian.skordal@wafflemail.net>

library ieee;
use ieee.std_logic_1164.all;

entity tb_sha256 is
end entity tb_sha256;

architecture testbench of tb_sha256 is
	-- Input signals:
	signal reset : std_logic := '0';
	signal update : std_logic := '0';
	signal word_input : std_logic_vector(31 downto 0) := (others => '0');

	-- Output signals:
	signal ready : std_logic;
	signal word_address : std_logic_vector(3 downto 0);
	signal debug_port : std_logic_vector(31 downto 0);
	signal hash_output : std_logic_vector(255 downto 0);

	-- Clock signal:
	signal clk : std_logic;
	constant clk_period : time := 10 ns;

	-- Other signals:
	signal testdata_address : std_logic_vector(5 downto 0);
begin

	uut: entity work.sha256
		port map(
			clk => clk,
			reset => reset,
			ready => ready,
			update => update,
			word_address => word_address,
			word_input => word_input,
			hash_output => hash_output,
			debug_port => debug_port
		);

	testdata_address(3 downto 0) <= word_address;
	testdata: entity work.testrom
		port map(
			clk => clk,
			word_address => testdata_address,
			word_output => word_input
		);

	clock: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clock;
	
	stimulus: process
	begin
		testdata_address(5 downto 4) <= b"00";

		wait for clk_period * 2;

		-- Reset the module:
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		wait for clk_period;

		-- The module should now be ready for work:
		assert ready = '1' report "Module is not ready after reset!";	
		wait for clk_period;

		-- Start hashing the first test data:
		update <= '1';
		wait for clk_period;
		update <= '0';

		wait until ready = '1';
		assert hash_output = x"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
			report "Hash of 'abc' is not ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad!";
		wait for clk_period;

		-- Reset the module to prepare for the second set of test data:
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		wait for clk_period;
		
		-- Check again that the module is ready for work:
		assert ready = '1' report "Module is not ready after reset!";
		wait for clk_period;

		-- Run the first block:
		testdata_address(4) <= '1';
		update <= '1';
		wait for clk_period;
		update <= '0';

		wait until ready = '1';
		assert hash_output = x"85e655d6417a17953363376a624cde5c76e09589cac5f811cc4b32c1f20e533a"
			report "Hash from the first round of testdata 2 is not 85e655d6417a17953363376a624cde5c76e09589cac5f811cc4b32c1f20e533a!";
		wait for clk_period;

		-- Run the second block:
		testdata_address(5) <= '1';
		update <= '1';
		wait for clk_period;
		update <= '0';

		wait until ready = '1';
		assert hash_output = x"248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
			report "Hash from the second round of testdata 2 is not 248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1!";
		wait for clk_period;

		report "Victory 8D";

		wait;
	end process stimulus;

end architecture testbench;
