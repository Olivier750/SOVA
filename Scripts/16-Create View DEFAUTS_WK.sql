CREATE VIEW DEFAUTS_WK AS
	SELECT
		ID_DEFAUT, 
		ANNEE_POSE,
		AGE,
		ANNEE_DECOUVERTE,
		PROFIL_RAIL,
		VITESSE,
		TYPE_GROUPE_UIC,
		TYPE_RAYON_COURBE,
		EMPLACEMENT,
		TYPE_CLASSEMENT
FROM
	DEFAUTS 
WHERE
	TYPE_CLASSEMENT IN ('X2','NR','X1','E','O')