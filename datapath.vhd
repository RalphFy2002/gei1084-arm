library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity datapath is
    generic (
        N : integer := 4;   -- Nombre de bits pour adresse registre
        M : integer := 32   -- Largeur des donnees
    );
    port (
        -- Horloge
        CLK : in STD_LOGIC;
        
        -- Signaux de controle du main_decoder
        Op : in STD_LOGIC_VECTOR(1 downto 0);
        Funct5 : in STD_LOGIC;
        Funct0 : in STD_LOGIC;
 
        -- Signaux de controle du ALU_decoder
        ALUOp : in STD_LOGIC;
        Funct4_1 : in STD_LOGIC_VECTOR(3 downto 0);
        
        -- Entree PCPlus8 (R15)
        R15 : in STD_LOGIC_VECTOR(M-1 downto 0);
        
        -- Flags en sortie
        Neg : out STD_LOGIC;
        Z : out STD_LOGIC;
        C : out STD_LOGIC;
        V : out STD_LOGIC;
        
        -- Sortie du multiplexeur final
        Result : out STD_LOGIC_VECTOR(M-1 downto 0);
        Result_alu : out STD_LOGIC_VECTOR(M-1 downto 0);
        Result_data : out STD_LOGIC_VECTOR(M-1 downto 0)
    );
end datapath;
 
architecture Structural of datapath is
    
    -- Declaration des composants
    component registre
       generic(
            N : integer := 4;
            M : integer := 32
        );
        port(
            clk : in std_logic;
            a1, a2 : in std_logic_vector(N-1 downto 0);
            a3 : in std_logic_vector(N-1 downto 0);
            wd3 : in std_logic_vector(M-1 downto 0);
            RegWrite : in STD_LOGIC;
            R15 : in std_logic_vector(M-1 downto 0);
            rd1 : out std_logic_vector(M-1 downto 0); 
            rd2 : out std_logic_vector(M-1 downto 0)
        );
    end component;
    
    component ext
        port(
            Instr : in std_logic_vector(23 downto 0);
            ImmSrc : in std_logic_vector(1 downto 0);
            ExtImm : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component ALU
        generic (N : integer := 32);
        port (
            A, B : in STD_LOGIC_VECTOR(N-1 downto 0);
            mux2to1_32b : in STD_LOGIC;
            mux4to1_32b : in STD_LOGIC_VECTOR(1 downto 0);
            sum_32b : in STD_LOGIC;
            Result : out STD_LOGIC_VECTOR(N-1 downto 0);
            Neg, Z, C, V : out STD_LOGIC
        );
    end component;
    
    component memoire
        generic(N : integer := 32);
        port(
            CLK : in std_logic;
            MemWrite : in std_logic;
            A : in std_logic_vector(N-1 downto 0);
            WD : in std_logic_vector(N-1 downto 0);
            RD : out std_logic_vector(N-1 downto 0)
        );
    end component;
 
    component main_decoder
        port(
            Op : in STD_LOGIC_VECTOR(1 downto 0);
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
    end component;
 
    component ALU_decoder
        port(
            ALUOp : in STD_LOGIC;
            Funct4_1 : in STD_LOGIC_VECTOR(3 downto 0);
            Funct0 : in STD_LOGIC;
            ALUControl : out STD_LOGIC_VECTOR(1 downto 0);
            FlagW : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    component reg_flags
     port(
            clock         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            ALUFlags    : in  STD_LOGIC_VECTOR(3 downto 0);  
            FlagW       : in  STD_LOGIC_VECTOR(1 downto 0);  
            CondEx      : in  STD_LOGIC;                      
            Flags_out       : out STD_LOGIC_VECTOR(3 downto 0)   
         );
    end component;
 
    component ConditionCheck
    Port (
        Flags_in       : in  STD_LOGIC_VECTOR(3 downto 0);  
        Cond        : in  STD_LOGIC_VECTOR(3 downto 0);
        CondEx      : out STD_LOGIC
         );
    end component;
 
component mem_instruct
    port(
        PC: in std_logic_vector(31 downto 0);      
        instr: out std_logic_vector(31 downto 0)   
    );
end component;
    
component Adder is -- adder
 port(
    a, b: in STD_LOGIC_VECTOR(31 downto 0);
    y: out STD_LOGIC_VECTOR(31 downto 0)
    );
end component;  

COMPONENT PC_Register is
    port(
        clk : in std_logic;
        reset : in std_logic;
        PC_prime: in std_logic_vector(31 downto 0);
        PC: out std_logic_vector(31 downto 0)
    );
end COMPONENT;
    
    -- Signaux internes
    signal a1, a2 : STD_LOGIC_VECTOR(N-1 downto 0);
    signal rd1, rd2 : STD_LOGIC_VECTOR(M-1 downto 0);
    signal ExtImm : STD_LOGIC_VECTOR(M-1 downto 0);
    signal SrcB : STD_LOGIC_VECTOR(M-1 downto 0);
    signal ALUResult : STD_LOGIC_VECTOR(M-1 downto 0);
    signal RD : STD_LOGIC_VECTOR(M-1 downto 0);
    signal Result_internal : STD_LOGIC_VECTOR(M-1 downto 0);
 

    -- Signaux de controle generes par les decodeurs
    signal RegSrc : STD_LOGIC_VECTOR(1 downto 0);
    signal RegWrite : STD_LOGIC;
    signal ImmSrc : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUSrc : STD_LOGIC;
    signal MemWrite : STD_LOGIC;
    signal MemtoReg : STD_LOGIC;
    signal ALUControl : STD_LOGIC_VECTOR(1 downto 0);
    signal FlagW : STD_LOGIC_VECTOR(1 downto 0);
    signal mux2to1 : STD_LOGIC;
    signal sum : STD_LOGIC;
    signal mux4to1 : STD_LOGIC_VECTOR(1 downto 0);
    
    -- Signaux condcheck et reg_flags 
    signal clock: STD_LOGIC := '0';
    signal reset: STD_LOGIC := '0';
    signal ALUFlags: STD_LOGIC_VECTOR(3 downto 0);
    signal FlagW0: STD_LOGIC_VECTOR(1 downto 0);
    signal CondEx: STD_LOGIC;
    signal Flags_out: STD_LOGIC_VECTOR(3 downto 0);
    
    signal Flags_in : STD_LOGIC_VECTOR(3 downto 0);
    signal Cond        : STD_LOGIC_VECTOR(3 downto 0);

    
    signal CLK1: std_logic := '0';
    signal MemWr: std_logic;
    signal A0: std_logic_vector(N-1 downto 0);
    signal WData: std_logic_vector(N-1 downto 0);
    signal RData:  std_logic_vector(N-1 downto 0);
    
    signal PC : std_logic_vector(31 downto 0);
    SIGNAL PC_PRIME:std_logic_vector(31 DOWNTO 0);
    signal PCPlus4 : std_logic_vector(31 downto 0);
    signal PCPlus8 : std_logic_vector(31 downto 0);
    signal y : std_logic_vector(31 downto 0);
    signal Instr: std_logic_vector(31 downto 0);
begin
 
    -- Instanciation du main_decoder
    main_dec : main_decoder
        port map(
            Op => Op,
            Funct5 => Funct5,
            Funct0 => Funct0,
            --AluOp => AluOp,
            RegW => RegWrite,
            MemW => MemWrite,
            MemtoReg => MemtoReg,
            ALUSrc => ALUSrc,
            ImmSrc => ImmSrc,
            RegSrc => RegSrc
        );
 
    -- Instanciation du ALU_decoder
    alu_dec : ALU_decoder
        port map(
            ALUOp => ALUOp,
            Funct4_1 => Funct4_1,
            Funct0 => Funct0,
            ALUControl => ALUControl,
            FlagW => FlagW
        );
 
    -- Mapping des signaux ALU
    -- Conversion de ALUControl vers les signaux de l'ALU
    mux4to1 <= ALUControl;
    mux2to1 <= '0';  
    sum <= '0';      
    
    -- Multiplexeur pour a1 (selection de l'adresse du registre source 1)
    -- RegSrc(0) selectionne entre Instr(19:16) et Instr(3:0)
    a1 <= "1111" when RegSrc(0) = '1' else Instr(19 downto 16);
    
    -- Multiplexeur pour a2 (selection de l'adresse du registre source 2)
    -- RegSrc(1) selectionne entre Instr(3:0) et Instr(15:12)
    a2 <= Instr(15 downto 12) when RegSrc(1) = '1' else Instr(3 downto 0);
    
    -- Instanciation du fichier de registres
    reg_file : registre
        generic map(
            N => N,
            M => M
        )
        port map(
            clk => CLK,
            a1 => a1,
            a2 => a2,
            a3 => Instr(15 downto 12),
            wd3 => Result_internal,
            RegWrite => RegWrite,
            R15 => PCPlus8,
            rd1 => rd1,
            rd2 => rd2
        );
    
    -- Instanciation de l'extension d'immediat
    extend : ext
        port map(
            Instr => Instr(23 downto 0),
            ImmSrc => ImmSrc,
            ExtImm => ExtImm
        );
    
    -- Multiplexeur ALUSrc (selection entre registre et immediat)
    SrcB <= ExtImm when ALUSrc = '1' else rd2;
    
    -- Instanciation de l'ALU
    alu_unit : ALU
        generic map(N => M)
        port map(
            A => rd1,
            B => SrcB,
            mux2to1_32b => mux2to1,
            sum_32b => sum,
            mux4to1_32b => mux4to1,
            Result => ALUResult,
            Neg => Neg,
            Z => Z,
            C => C,
            V => V
        );
    
    -- Instanciation du registre des flags
    registerflags : reg_flags
    port map (
        clock => clock,
        reset => reset,
        ALUFlags => ALUFlags,
        FlagW => FlagW0,
        CondEx => CondEx,
        Flags_out => Flags_out
    );
    
    -- Instanciation du registre de Conditional check
      Cond_check : ConditionCheck
        port map(
        Flags_in => Flags_in,
        Cond => Cond,
        CondEx => CondEx
      );
      
    -- Instanciation du registre de la nemoire d'instruction
      memory_instruction : mem_instruct
        port map(
        PC => PC,
        instr => instr
      );
      
      
      
      PC_PLus4 : Adder
      port map (
      a => PC,
      b => x"00000004",
      y => PCPlus4
      );
      
      PC_PLus8 : Adder
      port map (
      a => PCPlus4,
      b => x"00000004",
      y => PCPlus8
      );
      
      PC_PLUS : PC_Register
         port map(
        clk => CLK,
        reset => reset,
        PC_prime => PC_PRIME,
        PC => PC
    );
    -- Instanciation de la memoire de donnees
    data_mem : memoire
        generic map(N => M)
        port map(
            CLK => CLK,
            MemWrite => MemWrite,
            A => ALUResult,
            WD => rd2,
            RD => RD
        );
    
    -- Multiplexeur MemtoReg (selection entre ALU et memoire)
    Result_internal <= RD when MemtoReg = '1' else ALUResult;
    
    -- Sortie finale
    Result <= Result_internal;
    result_alu <=ALUResult;
    result_data <= rd2;
    
end Structural;
