UPDATE DEFAUTS
SET
      longitude = (SELECT lignes_tmp.longitude 
                            FROM lignes_tmp
                            WHERE lignes_tmp.ligne_voie = DEFAUTS.ligne_voie AND lignes_tmp.pk = DEFAUTS.metre )
    , latitude = (SELECT lignes_tmp.latitude
                            FROM lignes_tmp
                            WHERE lignes_tmp.ligne_voie = DEFAUTS.ligne_voie AND lignes_tmp.pk = DEFAUTS.metre )
WHERE
    EXISTS (
        SELECT *
        FROM lignes_tmp
        WHERE lignes_tmp.ligne_voie = DEFAUTS.ligne_voie AND lignes_tmp.pk = DEFAUTS.metre
    );