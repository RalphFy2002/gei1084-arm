# Architecture d'un Processeur ARM (VHDL) 

Ce dépôt contient la conception et l'implémentation en VHDL des composants critiques d'un processeur ARM simplifié. [cite_start]Ce projet a été réalisé dans le cadre du cours **GEI1084 - Architecture des ordinateurs et calcul accéléré** à l'Université du Québec à Trois-Rivières (UQTR)[cite: 1, 7, 8].

## Présentation du Projet
[cite_start]L'objectif est de modéliser le fonctionnement interne d'un processeur, du décodage d'instructions à la gestion de la logique conditionnelle[cite: 13, 300].

### Fonctionnalités clés :
* [cite_start]**Décodage d'instructions :** Un décodeur principal identifie le type d'instruction : Traitement de données (`00`), Accès mémoire (`01`) ou Branchement (`10`)[cite: 23, 24, 25].
* [cite_start]**Unité Arithmétique et Logique (ALU) :** Support des opérations fondamentales telles que `ADD`, `SUB`, `AND`, et `ORR`[cite: 122, 123, 124, 125].
* [cite_start]**Logique Conditionnelle :** Gestion des drapeaux d'état (Flags NZCV) et exécution basée sur les codes de condition ARM (EQ, NE, CS, etc.)[cite: 305, 335, 337, 340].
* [cite_start]**Contrôle du Programme :** Gestion du Programme Counter (PC) avec incrémentation par pas de 4 pour la lecture séquentielle[cite: 371].

---

## Détails Techniques

### 1. Décodeur Principal & ALU
[cite_start]Le décodeur analyse les bits `Op[1:0]` et `Funct` pour générer les signaux de contrôle tels que `MemW`, `RegW`, et `ALUSrc`[cite: 21, 26]. 
* [cite_start]Pour les instructions mémoire (LDR/STR), l'ALU est forcée en mode addition pour le calcul d'adresse[cite: 119].
* [cite_start]Pour le traitement de données, le signal `ALUControl` définit l'opération logique ou arithmétique[cite: 121, 126].

### 2. Logique de Vérification (Condition Check)
[cite_start]Le système utilise les bits [31:28] de l'instruction pour déterminer l'état de `CondEx`[cite: 328, 330].
* [cite_start]Si `CondEx = 1`, l'écriture est effectuée, sinon elle est bloquée[cite: 331].
* [cite_start]Les flags sont mis à jour sélectivement : les quatre flags pour les opérations arithmétiques, et seulement `N` et `Z` pour les opérations logiques[cite: 131, 132].

---

## Structure du Code (Aperçu)

### Exemple : Logique des Registres de Flags
```vhdl
-- Extrait de l'implémentation des registres de flags [cite: 309-325]
process(clk, reset)
begin
    if reset = '1' then
        Flags_NZ <= (others => '0');
        Flags_CV <= (others => '0');
    elsif rising_edge(clk) then
        if FlagWrite(1) = '1' then
            Flags_NZ <= ALUFlags(1 downto 0); -- Zero et Negative
        end if;
        if FlagWrite(0) = '1' then
            Flags_CV <= ALUFlags(3 downto 2); -- Overflow et Carry
        end if;
    end if;
end process;
