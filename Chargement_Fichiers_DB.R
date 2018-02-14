library("RSQLite")

sqldrv <- dbDriver("SQLite")

con <- dbConnect(sqldrv, dbname = "D:\\sncf.db", loadable.extensions = TRUE)


dbWriteTable(con, name="MON_TEST", value="D:\\test.csv", row.names=TRUE, append=TRUE)
dbGetQuery( con,'delete from   "MON_TEST"' )
p1 = dbGetQuery( con,'select * from "MON_TEST"' )

file_list <- list.files()
temp = list.files(pattern="*.csv")

a <- length(temp)
for (i in 1:a)
{
  dbWriteTable(con, name="MON_TEST", value=temp[[i]], row.names=FALSE, append=TRUE)
  
}


