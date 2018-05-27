UPDATE lignes_tmp
SET LIGNE2 = substr(LIGNE,1,instr(LIGNE,'-')-1) ,
    LIGNE_VOIE = substr(LIGNE,1,instr(LIGNE,'-')-1) ||'-'|| NOM_VOIE
