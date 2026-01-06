library ieee;
use IEEE.STD_LOGIC_1164.all;

entity ALU_decoder is
    port(
        ALUOp : in STD_LOGIC;
        Funct4_1 : in STD_LOGIC_VECTOR(3 downto 0);
        Funct0 : in STD_LOGIC;
        ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
        FlagW : out STD_LOGIC_VECTOR(1 downto 0)
    );
end ALU_decoder;

architecture Behavioral of ALU_decoder is
begin
    
 process(ALUOp, Funct4_1, Funct0)
    begin
        
        if ALUOp = '0' then
            -- Type: Not DP (Data Processing)
            ALUControl <= "00";  
            FlagW      <= "00";  
            
        else  -- ALUOp = '1'
            -- Type: DP (Data Processing)
            -- Decode l'operation selon Funct4_1 et Funct0
            case Funct4_1 is
                
                -- ADD : Addition
                when "0100" =>
                    ALUControl <= "00";  -- ADD
                    if Funct0 = '0' then
                        FlagW <= "00";   
                    else  -- Funct0 = '1'
                        FlagW <= "11";  
                    end if;
                                    
                -- SUB : Soustraction
                when "0010" =>
                    ALUControl <= "01";  -- SUB
                    if Funct0 = '0' then
                        FlagW <= "00";   
                    else  -- Funct0 = '1'
                        FlagW <= "11";   
                    end if;
                
                -- AND : ET logique
                when "0000" =>
                    ALUControl <= "10";  -- AND
                    if Funct0 = '0' then
                        FlagW <= "00";   
                    else  -- Funct0 = '1'
                        FlagW <= "10";   
                    end if;
                
                -- ORR : OU logique
                when "1100" =>
                    ALUControl <= "11";  -- ORR
                    if Funct0 = '0' then
                        FlagW <= "00";   
                    else  -- Funct0 = '1'
                        FlagW <= "10";   
                    end if;
                
                -- Operation non reconnue (defaut securitaire)
                when others =>
                    ALUControl <= "00";  
                    FlagW      <= "00";  
                    
            end case;
            
        end if;
        
    end process;
    
end Behavioral;