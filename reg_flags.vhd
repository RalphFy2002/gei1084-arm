
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity reg_flags is
    Port (
        clock         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        -- Entrees des flags de l'ALU
        ALUFlags    : in  STD_LOGIC_VECTOR(3 downto 0);  -- [N, Z, C, V]
        -- Signaux de controle
        FlagW       : in  STD_LOGIC_VECTOR(1 downto 0);  -- Contrôle d'ecriture
        CondEx      : in  STD_LOGIC;                      -- Signal d'execution conditionnelle
        -- Sorties des flags stockes
        Flags_out       : out STD_LOGIC_VECTOR(3 downto 0)   -- [N, Z, C, V]
    );
end reg_flags;

architecture Behavioral of reg_flags is
    -- Registres de flags
    signal Flags_NZ : STD_LOGIC_VECTOR(1 downto 0);  -- Negative(1), Zero(0)
    signal Flags_CV : STD_LOGIC_VECTOR(1 downto 0);  -- Carry(1), oVerflow(0)
    
    -- Signal d'activation d'écriture pour chaque registre
    signal FlagWrite : STD_LOGIC_VECTOR(1 downto 0);

begin
    -- Logique de contrôle d'écriture : FlagWrite = FlagW AND CondEx
    FlagWrite(1) <= FlagW(1) and CondEx;  -- Pour registre NZ
    FlagWrite(0) <= FlagW(0) and CondEx;  -- Pour registre CV
    
    -- Process pour les registres
    process(clock, reset)
    begin
        if reset = '1' then
            Flags_NZ <= (others => '0');
            Flags_CV <= (others => '0');
        elsif rising_edge(clock) then
            -- Registre 1 : bits 1:0 (Zero et Negative)
            if FlagWrite(1) = '1' then
                Flags_NZ <= ALUFlags(1 downto 0);
            end if;
            
            -- Registre 2 : bits 3:2 (oVerflow et Carry)
            if FlagWrite(0) = '1' then
                Flags_CV <= ALUFlags(3 downto 2);
            end if;
        end if;
    end process;
    
    -- Sortie des flags : reconstruction du vecteur complet
    Flags_out <= Flags_CV & Flags_NZ;  -- [C, V, N, Z]

end Behavioral;