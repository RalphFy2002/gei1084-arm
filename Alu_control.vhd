library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Alu_control is
    generic (N : integer := 32);
    port (
        A, B        : in  STD_LOGIC_VECTOR(N-1 downto 0);
        ALUControl  : in  STD_LOGIC_VECTOR(3 downto 0);
        Result      : out STD_LOGIC_VECTOR(N-1 downto 0);
        Neg, Z, C, V: out STD_LOGIC
    );
end Alu_control;

architecture Behavioral of Alu_control is

    signal B0              : STD_LOGIC_VECTOR(N-1 downto 0);
    signal S_Result_Internal : STD_LOGIC_VECTOR(N-1 downto 0); 
    signal Sum_Result_Ext  : STD_LOGIC_VECTOR(N downto 0);
    signal Sum_Result_N    : STD_LOGIC_VECTOR(N-1 downto 0);
    
    signal C_in            : STD_LOGIC;
    signal B_Sel           : STD_LOGIC;
    signal Op_Mux_Sel      : STD_LOGIC_VECTOR(1 downto 0);
    
    -- *** CORRECTION 1 : Déclaration de la constante pour la comparaison ***
    constant ZERO_VECTOR : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0'); 

begin

    -- Extraction des signaux de contrôle
    C_in          <= ALUControl(0);
    B_Sel         <= ALUControl(0);
    Op_Mux_Sel    <= ALUControl(2 downto 1);

    -- 1. MUX B / NOT B
    B0 <= B when B_Sel = '0' else not B;

    -- 2. Opération arithmétique
    process(A, B0, C_in)
    begin
        Sum_Result_Ext <= std_logic_vector(
                             unsigned('0' & A) + 
                             unsigned('0' & B0) + 
                             (TO_UNSIGNED(0, N) & C_in)
                          );
    end process;

    Sum_Result_N <= Sum_Result_Ext(N-1 downto 0);

    -- 3. MUX 4:1 final
    with Op_Mux_Sel select
        S_Result_Internal <= Sum_Result_N when "00",
                             Sum_Result_N when "01",
                             (A and B)    when "10",
                             (A or B)     when others;

    -- Connexion de la sortie finale
    Result <= S_Result_Internal;

    -- 4. Calcul des drapeaux (flags)
    
    -- *** CORRECTION 2 : Utilisation d'une affectation concurrente et de la constante ***
    -- Flag Zero (Z)
    Z <= '1' when S_Result_Internal = ZERO_VECTOR else '0';

    -- Flag Négatif (N)
    Neg <= S_Result_Internal(N-1); 

    -- Flag Carry (C) : Valide uniquement pour Arithmétique
    C <= Sum_Result_Ext(N) when Op_Mux_Sel(1) = '0' else '0';

    -- Flag Overflow (V) : Valide uniquement pour Arithmétique
    V <= (Sum_Result_Ext(N-1) XOR Sum_Result_Ext(N)) when Op_Mux_Sel(1) = '0' else '0';
    
end Behavioral;