library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity switch_to_led is

	port 
	(
		SW	   : in signed	(9 downto 0);
		LEDR  : out signed (9 downto 0)
	);

end entity;

architecture rtl of switch_to_led is
begin

	LEDR <= SW;

end rtl;
