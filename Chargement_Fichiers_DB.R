#Chargement de la librairie RSQLite, qui permet d'utiliser la base de données SQLite
library("RSQLite")

#Chargement dans la variable sqldrv du driver SQLite
sqldrv <- dbDriver("SQLite")

#Création de la connection à la base de données sncd.db
#activation des extensions de SQLite
con <- dbConnect(sqldrv, dbname = "D:\\sncf.db", loadable.extensions = TRUE)

#listing de tous les fichiers se trouvant dans le repertoire courant
file_list <- list.files()
#filtre sur les fichiers csv
temp = list.files(pattern="*.csv")

#on compte le nb de fichiers csv trouvé
a <- length(temp)

#boucle sur les fichiers csv
for (i in 1:a)
{
  #on insere le contenu des fichiers csv dans la table MON_TEST
  dbWriteTable(con, name="MON_TEST", value=temp[[i]], row.names=FALSE, append=TRUE)
  
}







dbWriteTable(con, name="MON_TEST", value="D:\\test.csv", row.names=TRUE, append=TRUE)
dbGetQuery( con,'delete from   "MON_TEST"' )
p1 = dbGetQuery( con,'select * from "MON_TEST"' )

