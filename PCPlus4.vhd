library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity Adder is -- adder
 port(
    a, b: in STD_LOGIC_VECTOR(31 downto 0);
    y: out STD_LOGIC_VECTOR(31 downto 0)
    );
end Adder; 

architecture behavioral of Adder is

begin
 y <= a + b;

end behavioral;