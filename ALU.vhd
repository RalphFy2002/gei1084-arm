library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    generic (N : integer := 32);
    port (
        A, B : in STD_LOGIC_VECTOR(N-1 downto 0);
        mux2to1_32b : in STD_LOGIC;
        mux4to1_32b : in STD_LOGIC_VECTOR(1 downto 0);
        sum_32b : in STD_LOGIC;
        Result : out STD_LOGIC_VECTOR(N-1 downto 0);
        Neg, Z, C, V: out STD_LOGIC -- Negative, Zero, Carry, OverFlow
    );
end ALU;

architecture Structural of ALU_FLAGS32B is
    signal mux2to1  : STD_LOGIC_VECTOR(N-1 downto 0);
    signal sum      : STD_LOGIC_VECTOR(N-1 downto 0);
    signal et       : STD_LOGIC_VECTOR(N-1 downto 0);
    signal ou       : STD_LOGIC_VECTOR(N-1 downto 0);
    signal notB     : STD_LOGIC_VECTOR(N-1 downto 0);
    signal Cout_Flag : STD_LOGIC; -- carryout
    signal compute_flag  : STD_LOGIC_VECTOR(N-1 downto 0); -- Signal du calcul interne des flags
    
    -- Signaux pour le calcul des flags selon le schema
    signal not_ALU0, not_ALU1 : STD_LOGIC;
begin
    -- Calcul de NOT(B)
    notB <= not B;
    
    -- Mux B / NOT(B)
    mux2to1_inst : entity work.mux2to1_32b
        generic map(N => N)
        port map (
            d0 => B,
            d1 => notB,
            s  => mux2to1_32b,
            y  => mux2to1
        ); 
        
    -- Additionneur / Soustracteur
    sum_inst : entity work.sum_32b
        generic map(N => N)
        port map (
            a     => A,
            b     => mux2to1,
            c_in  => sum_32b,
            somme => sum,
            Cout  => Cout_Flag,
            V     => open  -- Non utilise, calcule selon le schema
        );
             
    -- Logiques
    et <= A and B;
    ou <= A or B;
    
    -- Selection finale avec mux4to1
    mux4to1_inst : entity work.mux4to1_32b
        generic map(N => N)
        port map (
            D0 => sum, -- 00
            D1 => sum, -- 01
            D2 => et,  -- 10
            D3 => ou,  -- 11   
            sel => mux4to1_32b,
            y0  => compute_flag 
        );
        
    -- Connexion du resultat interne a la sortie
    Result <= compute_flag;
    
    -- Calcul des flags selon le schema
    
    -- Signaux intermediaires
    not_ALU0 <= not mux4to1_32b(0);
    not_ALU1 <= not mux4to1_32b(1);
    
    -- Flag Negative : bit de signe (MSB du resultat)
    Neg <= compute_flag(N-1);
    
    -- Flag Carry : (NOT ALU(1)) AND Cout
    -- Carry valide seulement pour operations arithmetiques (ALU(1)=0, soit sel="00" ou "01")
    C <= not_ALU1 and Cout_Flag;
    
    -- Flag Overflow : (NOT ALU(0) XOR A(31) XOR B(31)) AND (A(31) XOR Sum(31)) AND (NOT ALU(1))
    -- Selon le schema : detecte overflow pour addition/soustraction uniquement
    V <= (not_ALU0 xor A(N-1) xor B(N-1)) and (A(N-1) xor sum(N-1)) and not_ALU1;
    
    -- Processus pour le flag Zero 
    process(compute_flag)
    begin
        if compute_flag = (N-1 downto 0 => '0') then
            Z <= '1';
        else 
            Z <= '0';
        end if;
    end process;
        
end Structural;