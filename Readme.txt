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




