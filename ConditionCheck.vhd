library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.NUMERIC_STD_UNSIGNED.all;


entity ConditionCheck is
    Port (
        -- Entree des flags stockes
        Flags_in       : in  STD_LOGIC_VECTOR(3 downto 0);  -- [N, Z, C, V]
        -- Code de condition (bits 31:28 de l'instruction)
        Cond        : in  STD_LOGIC_VECTOR(3 downto 0);
        -- Sortie : signal d'execution conditionnelle
        CondEx      : out STD_LOGIC
    );
end ConditionCheck;

architecture Behavioral of ConditionCheck is
    -- Flags individuels
    signal N_flag : STD_LOGIC;  -- Negative
    signal Z_flag : STD_LOGIC;  -- Zero
    signal C_flag : STD_LOGIC;  -- Carry
    signal V_flag : STD_LOGIC;  -- oVerflow

begin
    -- Decomposition des flags
    N_flag <= Flags_in(1);  -- Negative
    Z_flag <= Flags_in(0);  -- Zero
    C_flag <= Flags_in(3);  -- Carry
    V_flag <= Flags_in(2);  -- oVerflow
    
    -- Logique de verification des conditions
    -- Basee sur l'architecture ARM avec les codes de condition
    process(Cond, N_flag, Z_flag, C_flag, V_flag)
    begin
        case Cond is
            when "0000" =>  -- EQ (Equal): Z=1
                CondEx <= Z_flag;
                
            when "0001" =>  -- NE (Not Equal): Z=0
                CondEx <= not Z_flag;
                
            when "0010" =>  -- CS/HS (Carry Set/Higher or Same): C=1
                CondEx <= C_flag;
                
            when "0011" =>  -- CC/LO (Carry Clear/Lower): C=0
                CondEx <= not C_flag;
                
            when "0100" =>  -- MI (Minus/Negative): N=1
                CondEx <= N_flag;
                
            when "0101" =>  -- PL (Plus/Positive): N=0
                CondEx <= not N_flag;
                
            when "0110" =>  -- VS (Overflow Set): V=1
                CondEx <= V_flag;
                
            when "0111" =>  -- VC (Overflow Clear): V=0
                CondEx <= not V_flag;
                
            when "1000" =>  -- HI (Higher): C=1 AND Z=0
                CondEx <= C_flag and (not Z_flag);
                
            when "1001" =>  -- LS (Lower or Same): C=0 OR Z=1
                CondEx <= (not C_flag) or Z_flag;
                
            when "1010" =>  -- GE (Greater or Equal): N=V
                CondEx <= not (N_flag xor V_flag);
                
            when "1011" =>  -- LT (Less Than): N xor V
                CondEx <= N_flag xor V_flag;
                
            when "1100" =>  -- GT (Greater Than): Z=0 AND N=V
                CondEx <= (not Z_flag) and (not (N_flag xor V_flag));
                
            when "1101" =>  -- LE (Less or Equal): Z=1 OR N xor V
                CondEx <= Z_flag or (N_flag xor V_flag);
                
            when "1110" =>  -- AL (Always): toujours vrai
                CondEx <= '1';
                
            when others =>  -- Cas non defini (incluant "1111")
                CondEx <= '0';
        end case;
    end process;

end Behavioral;