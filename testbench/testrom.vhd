-- SHA256 Hashing Module - ROM with test data
-- Kristian Klomsten Skordal <kristian.skordal@wafflemail.net>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testrom is
	port(
		clk : in std_logic;
		
		word_address : in std_logic_vector(5 downto 0);
		word_output : out std_logic_vector(31 downto 0)
	);
end entity testrom;

architecture behaviour of testrom is
	type testdata2_array is array(0 to 31) of std_logic_vector(31 downto 0);
	constant testdata2 : testdata2_array := (
		x"61626364", x"62636465", x"63646566", x"64656667", x"65666768", x"66676869", x"6768696a", x"68696a6b",
		x"696a6b6c", x"6a6b6c6d", x"6b6c6d6e", x"6c6d6e6f", x"6d6e6f70", x"6e6f7071", x"80000000", x"00000000",
		x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",  
		x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"00000000", x"000001c0");
begin

	readproc: process(clk)
	begin
		if falling_edge(clk) then -- FIXME
			if word_address(5 downto 4) = b"00" then -- Test set 1, "abc"
				if word_address = b"000000" then
					word_output <= x"61626380"; -- "abc" and a 1 bit at the end
				elsif word_address = b"001111" then
					word_output <= x"00000018"; -- message length is 24 bits
				else
					word_output <= (others => '0');
				end if;
			else -- Test set 2, "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
				if word_address(5) = '1' then
					word_output <= testdata2(16 + to_integer(unsigned(word_address(3 downto 0))));
				else
					word_output <= testdata2(to_integer(unsigned(word_address(3 downto 0))));
				end if;
			end if;
		end if;
	end process readproc;

end architecture behaviour;
