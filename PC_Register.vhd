library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity PC_Register is
    port(
        clk : in std_logic;
        reset : in std_logic;
        PC_prime: in std_logic_vector(31 downto 0);
        PC: out std_logic_vector(31 downto 0)
    );
end PC_Register;

architecture behavioral of PC_Register is
    signal PC1 : std_logic_vector(31 downto 0);
begin
    -- Processus d'Ecriture synchrone sur le port 3
    process(clk, reset) begin
    if reset = '1' then
        PC1 <= X"00000000";
        elsif rising_edge(clk) then
                PC1 <= PC_PRIME;
        end if;
    end process;
    
    PC <= PC1;
    
end behavioral;