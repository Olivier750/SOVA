PROJET SOVA

Structure du projet
- Dossier Database
     Contient la base de données SQLite avec l'extension Spatialite
- Dossier Scripts
     Contient les scripts SQL
- Dossier Datasources
     Contient les sources de données du projet
     - basegeometrie.rds : coordonnées GPS des lignes
     - DEF_PN_BIS.csv : données de défaut repérées sur les lignes
- Dossier Logiciels
     Contient les Dlls permettant de manipuler les objets spatiaux



-----------------------------------------------------------------------------
Installation Spatialite

-Téléchargement de la version 32b de SQL Lite
     https://www.sqlite.org/2018/sqlite-dll-win32-x86-3220000.zip

-Téléchargement de la version 32b de Spatialite
     http://www.gaia-gis.it/gaia-sins/windows-bin-x86/mod_spatialite-4.3.0a-win-x86.7z

-Mettre les fichiers telecharges et dezippe dans le répertoire "logiciels"

-Ajouter ce repertoire au path windows '%PATH%'
	Dans Rechercher, lancez une recherche et sélectionnez : Système (Panneau de configuration)
	Cliquez sur le lien Paramètres système avancés.
	Cliquez sur Variables d'environnement. 
		Dans la section Variables système, recherchez la variable d'environnement PATH et sélectionnez-la. 
		Cliquez sur Modifier. Si la variable d'environnement PATH n'existe pas, cliquez sur Nouvelle.
	Dans la fenêtre Modifier la variable système (ou Nouvelle variable système), indiquez la valeur de la variable d'environnement PATH. 
		Cliquez sur OK. 
		Fermez toutes les fenêtres restantes en cliquant sur OK.

-Demarrer RStudio en maintenant la touche CTRL enfoncée pour choisir la version 32b
-----------------------------------------------------------------------------

Compréhension et nettoyage des données

Ligne_num
   - Numéro de la ligne
   
NOMVOIE
   - Nom de la voie
   
ID_DEFAUT
   - Numéro unique du défaut
   
PK_DEFAUT
   - Point kilométrique du défaut
      - suppression de toutes les lignes > 118+0000, on ne s'interesse qu'a l'ile de france (nouvelle base avec bon perimetre)
   
PROFIL_RAIL
   - Profil des rails
      - regroupe en 5 catégories : Autre, 46-E2, 50-E6, 55-E1, 60-E1

ANNEE_POSE
   - Année de pose du rail
      - on garde pour l'instant les lignes ou l'année de pose est NR (133 cas) et on verra en fonction des methodes stat
      - on supprime l'année de pose renseignée inferieure à 1900

VITESSE
	- création d'une variable en 5 tranches pour l'instant (0-50, 50-100, 100-160, 160-200, >200) 

GROUPE_UIC
   - Fréquence de passage des trains
   - Exclusion des 13 lignes GROUPE_UIC = ( '.',  'U50' et 'V5')
   - Regroupement (1-4 forte densité, 5-6 densité moyenne, 7-9 faible densité)

RAYON_COURBE
	- courbe si >0 et <= 1200
	- droit si r>1200 ou 0 ou NR

ID_TYPE_CLASSEMENT (variable a expliquer)
   - Exclusion des modalités autre que :
        - E : N'évolue pas en fissuration, défauts de surface du rail ou d’usure ondulatoire (déforme le rail => gène et abîme le train) 
        - NR : Provoque des fissurations mais le rail peut rester en voie, avec ou sans surveillance, Gravité 1
        - O : Provoque des fissurations mais le rail peut rester en voie, avec ou sans surveillance, Gravité 2
        - X1 : Provoque des fissurations et demande des mesures de sécurité, Risque de rupture faible
        - X2 : Provoque des fissurations et demande des mesures de sécurité, Risque de rupture important
        - S : Provoque des fissurations et demande des mesures de sécurité, Risque de rupture imminent
   PS : proposition de modéle : On regroupe E NR O en 0 et X1 X2 et S en 1 pour une premeire analyse
   
ID_TYPE_EMPLACEMENT
   - Emplacement du rail
   - Remplacement de la modalité NR par ciel ouvert

ID_TYPE_DEFAUT
   - 4 codes (1270,2270,2271,2272) corespondent a des fissurations (1/4 de la base). On exclut la corrosion.
   - Donner une definition des 4 type de defaut dans le filtre de la base

Annee_Decouverte
   - Année de découverte du défaut
      - Exclusion de l'année de pose < 1900
      - Année de pose non renseignée, 113 lignes. ==> on supprime les lignes

PKM (nouvelle colonne)
   - Transformation du champs PK_Defaut en une valeur numérique en mètre

Age du rail (nouvelle colonne)
   - différence entre année de pose et année de découverte
   - Forçage des années de pose à 1980 pour les 6 cas où l'âge est négatif, puis re-calcul de l'âge.

Tranche d'âge- AGE : 10 tranches (les deciles)


Doublons :
   - on les garde car plusieurs defaut sur meme pk

