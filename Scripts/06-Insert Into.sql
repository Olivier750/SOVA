INSERT INTO lignes (LIGNE_VOIE, LIGNE, VOIE, COORDONNEES, RANG)
	SELECT DISTINCT
		LIGNE_VOIE AS LIGNE_VOIE,
		ligne2 AS LIGNE,
		nom_voie AS VOIE,
		group_concat(''||Longitude||' '||Latitude||'') as COORDONNEES
		,RANG
	FROM
		lignes_tmp
	GROUP BY
		LIGNE_VOIE
		,RANG
	ORDER BY
		LIGNE_VOIE,PK ASC;