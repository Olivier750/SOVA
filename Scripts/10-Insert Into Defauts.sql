INSERT INTO DEFAUTS (ID_DEFAUT,LIGNE,VOIE,LIGNE_VOIE,METRE,ANNEE_POSE,PROFIL_RAIL,VITESSE,GROUPE_UIC,TYPE_GROUPE_UIC,RAYON_COURBE,TYPE_RAYON_COURBE,TYPE_CLASSEMENT,EMPLACEMENT,TYPE_DEFAUT,ANNEE_DECOUVERTE,AGE) 

SELECT
	MIN(ID_DEFAUT)	AS ID_DEFAUT, 
	Ligne_Num	AS LIGNE, 
	Nomvoie	AS VOIE,
	Ligne_num ||'-'||Nomvoie AS LIGNE_VOIE,
	substr(pk_defaut,1,instr(pk_defaut,'+')-1)*1000 + substr(pk_defaut,instr(pk_defaut,'+')+1) AS METRE,
	ANNEE_POSE AS ANNEE_POSE,
	PROFIL_RAIL AS PROFIL_RAIL,
	VITESSE AS VITESSE,
	GROUPE_UIC AS GROUPE_UIC,
	case
		when groupe_uic between 2 and 4 then 'G2_4' 
		when groupe_uic between 5 and 6 then 'G5_6' 
		when groupe_uic between 7 and 9 then 'G7_9' 
		when groupe_uic like '9%' then 'G7_9' 
		else 'AUTRES'
		end AS TYPE_GROUPE_UIC,
	
	RAYON_COURBE AS RAYON_COURBE,
	case
		when 0 < RAYON_COURBE AND RAYON_COURBE < 1200 THEN 'COURBE'
		else	'ALIGNEMENT'
		END AS TYPE_RAYON_COURBE,
	ID_TYPE_CLASSEMENT AS TYPE_CLASSEMENT,
	ID_TYPE_EMPLACEMENT AS EMPLACEMENT,
	ID_TYPE_DEFAUT AS TYPE_DEFAUT,
	ANNEE_DECOUVERTE AS ANNEE_DECOUVERTE,
	ANNEE_DECOUVERTE - ANNEE_POSE AS AGE
	
FROM
	DEF_PN_BIS
GROUP BY
	MIN(ID_DEFAUT), 
	Ligne_Num, 
	Nomvoie,
	Ligne_num ||'-'||Nomvoie,
	substr(pk_defaut,1,instr(pk_defaut,'+')-1)*1000 + substr(pk_defaut,instr(pk_defaut,'+')+1),
	ANNEE_POSE,
	PROFIL_RAIL,
	VITESSE,
	GROUPE_UIC,
	case
		when groupe_uic between 2 and 4 then 'G2_4' 
		when groupe_uic between 5 and 6 then 'G5_6' 
		when groupe_uic between 7 and 9 then 'G7_9' 
		when groupe_uic like '9%' then 'G7_9' 
		else 'AUTRES'
		end,
	
	RAYON_COURBE,
	case
		when 0 < RAYON_COURBE AND RAYON_COURBE < 1200 THEN 'COURBE'
		else	'ALIGNEMENT'
		END,
	ID_TYPE_CLASSEMENT,
	ID_TYPE_EMPLACEMENT,
	ID_TYPE_DEFAUT,
	ANNEE_DECOUVERTE,
	ANNEE_DECOUVERTE - ANNEE_POSE