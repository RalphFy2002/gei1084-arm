library ieee;
use IEEE.STD_LOGIC_1164.all;

entity main_decoder is
    port(
    Op : in  STD_LOGIC_VECTOR(1 downto 0);
    Funct5 : in STD_LOGIC;
    Funct0 : in STD_LOGIC; 
    AluOp  : out std_logic;
    RegW : out std_logic;
    MemW : out std_logic;
    MemtoReg : out std_logic;
    ALUSrc : out std_logic;
    ImmSrc : out std_logic_vector(1 downto 0);
    RegSrc : out std_logic_vector(1 downto 0)
    );
end main_decoder;

architecture behavioral of main_decoder is
    begin
    process(Op, Funct5, Funct0)
    begin
        case Op is
            
            -- Op = "00" : Instructions de Data Processing
            -- Funct0 indique si on utilise un registre (0) ou un immediat (1)
            when "00" =>
                MemW <= '0';           
                RegW <= '1';
                AluOp <= '1';         
                
                if Funct5 = '0' then
                    -- Operande 2 est un REGISTRE 
                    MemtoReg <= '0';   
                    ALUSrc   <= '0';   
                    ImmSrc   <= "00";  
                    RegSrc   <= "00";
                else
                    -- Operande 2 est un IMMEDIAT 
                    MemtoReg <= '0';   
                    ALUSrc   <= '1';   
                    ImmSrc   <= "00";  
                    RegSrc   <= "00";
                end if;
            
            -- Op = "01" : Instructions memoire (Load/Store)
            -- Funct0 indique STR (0) ou LDR (1)
            when "01" =>
                ALUSrc <= '1';         -- Toujours immediat (offset d'adresse)
                ImmSrc <= "01";        -- Format immediat 12 bits
                AluOp <= '0';
                
                if Funct0 = '0' then
                    -- Instruction STR (Store Register)
                    MemtoReg <= '0';   -- Don't care (pas de write-back)
                    MemW     <= '1';   -- Ecriture en memoire
                    RegW     <= '0';   -- Pas d'ecriture registre
                    RegSrc   <= "10";  -- RegSrc pour adressage memoire
                else
                    -- Instruction LDR (Load Register)
                    MemtoReg <= '1';   -- Donnees viennent de la memoire
                    MemW     <= '0';   -- Pas d'ecriture memoire (lecture)
                    RegW     <= '1';   -- Ecriture dans registre destination
                    RegSrc   <= "00";  -- RegSrc[0]=0, RegSrc[1]=don't care
                end if;
            
            -- Op = "10" : Instructions de branchement (Branch)
            when "10" =>
                MemtoReg <= '0';
                MemW     <= '0';
                ALUSrc   <= '1';
                ImmSrc   <= "10";     
                RegW     <= '0';
                RegSrc   <= "01";      
            
            -- Op = "11" : Non utilise
            when others =>
                MemtoReg <= '0';
                MemW     <= '0';
                ALUSrc   <= '0';
                ImmSrc   <= "00";
                RegW     <= '0';
                RegSrc   <= "00";

        end case;
    end process;

    end behavioral;