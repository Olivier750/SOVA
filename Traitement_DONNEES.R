
# Lecture de la Table table TAB
#TAB <- readRDS(file = "TAB.rds")

#essayons de coiser la base des données 2010

DONNEE_2010<-read.csv2(file.choose(), header=TRUE, sep=";") # mettre le chemin du fichier donnee_2010.csv
TAB_ter<-sqldf("select distinct *
FROM TAB as t0 left join DONNEE_2010 as t1 on
               t0.ID_DEFAUT=t1.ID_DEFAUT
               ")
rownames(TAB_ter)<-NULL

id<-unique(c(which(TAB_ter$AGE<0),which(is.na(TAB_ter$ANNEE_POSE))))
TAB_ter$ANNEE_POSE[id]<-TAB_ter$ANRAIL[id]
TAB_ter$AGE<-TAB_ter$ANNEE_DECOUVERTE-TAB_ter$ANNEE_POSE
TAB$AGE_bis<-cut(TAB$AGE,breaks = c(-20,0,10,20,30,40,50,60,70,80,90,200))

TAB1<-TAB_ter[,names(TAB)]
TAB1<-unique(TAB1)

#Essayons d'ajouter l'information de la circulation TGV, Transilien ou autre et rectifier l'information de rayon de courbe

DONNEE_CIRCULATION<-read.csv2(file.choose(), header=TRUE, sep=";") # Lira le fichier DONNEE_CIRCULATION.csv


## Merger les deux tableaux
TAB_ter<- merge(TAB1,DONNEE_CIRCULATION, by=1)
rownames(TAB_ter)<-NULL


## La colonne Aj_TypRayon contient plus d'info que la colonne TYPE_RAYON_COURBE ==< on en complétera
TAB_ter$COURBE<-TAB_ter$TYPE_RAYON_COURBE
id<-which(is.na(TAB_ter$RAYON_COURBE))
TAB_ter$COURBE<-as.character(TAB_ter$COURBE)
TAB_ter$COURBE[id]<-TAB_ter[id,"Aj_TypRayon"]
TAB_ter$COURBE<-factor(TAB_ter$COURBE)


TAB2<-TAB_ter[,c(names(TAB),"COURBE","TRAIN")]
TAB2<-unique(TAB2)
TAB2$COURBE[which(TAB2$COURBE=="600m < R <= 1200m" |TAB2$COURBE=="R<= 600m")]<-"COURBE"
TAB2$COURBE[which(TAB2$COURBE=="Alignement"|TAB2$COURBE=="R > 1200m" |TAB2$COURBE=="Tracé inconnu")]<-"ALIGNEMENT"
TAB2$COURBE[which(is.na(TAB2$COURBE))]<-"ALIGNEMENT"
TAB2$TYPE_RAYON_COURBE<-TAB2$COURBE
TAB2<-unique(TAB2)

# Travailler la variable du groupe UIC

TAB2[which(TAB2$GROUPE_UIC=="2" |TAB2$GROUPE_UIC=="3" |TAB2$GROUPE_UIC=="4"),"UIC"]<-"G2_4"
TAB2[which(TAB2$GROUPE_UIC==5 |TAB2$GROUPE_UIC==6),"UIC"]<-"G5_6"
TAB2[which(TAB2$GROUPE_UIC=="7SV" |TAB2$GROUPE_UIC=="7AV"| TAB2$GROUPE_UIC=="9AV" |
             TAB2$GROUPE_UIC=="8AV" |TAB2$GROUPE_UIC=="9SV"| TAB2$GROUPE_UIC=="8SV" ),"UIC"]<-"G7_9"



### Convertir ttes les variables catégoriel en factor
TAB2$TYPE_CLASSEMENT=factor(TAB2$TYPE_CLASSEMENT)
TAB2$TYPE_RAYON_COURBE=factor(TAB2$TYPE_RAYON_COURBE)
TAB2$UIC=factor(TAB2$UIC)
TAB2$Profil=factor(TAB2$Profil)
TAB2$TRAIN=factor(TAB2$TRAIN)

# GARDER Uniquement les variables qui nous intérèssents

TAB_bis<-TAB2[,c(1:4,6,7,10,11,13,14,15,16,17,19,20)]

## graph for categorial variables

par(mfrow=c(2,2))
barplot(table(TAB_bis$Profil),col="lightblue",main="PROFIL")
barplot(table(TAB_bis$UIC),col="lightblue",main="UIC")
barplot(table(TAB_bis$TYPE_RAYON_COURBE),col="lightblue",main="COURBE")
#barplot(table(TAB_bis$TYPE_CLASSEMENT),col="lightblue",main="Type Defaut")
barplot(table(TAB_bis$TRAIN),col="lightblue",main="Type Defaut")
## graph for continus variables
par(mfrow=c(1,2))
boxplot(TAB_bis$AGE~TAB_bis$TYPE_CLASSEMENT, main=" AGE",ylab="Age del'installation",xlab="Type de Défaut",col="orange")
boxplot(TAB_bis$VITESSE~TAB_bis$TYPE_CLASSEMENT, main=" Vitess",ylab="Vitesse des Trains",xlab="Type de Défaut",col="orange")


### netoyage des données et retrait des valeurs manquantes et abérantes

## supprimons les age négatives et les NA
TAB_bis<-TAB_bis[-which(is.na(TAB_bis$AGE)),]
TAB_bis<-TAB_bis[-which(TAB_bis$AGE<0),]
TAB_bis<-TAB_bis[-which(TAB_bis$AGE>150),]

par(mfrow=c(1,1))
boxplot(TAB_bis$AGE~TAB_bis$TRAIN, main=" AGE",ylab="Age del'installation",xlab="Type de Défaut",col="orange")

#ajouter la variable des O/1
TAB_bis$Class_Binaire<-0
TAB_bis$Class_Binaire[which(TAB_bis$TYPE_CLASSEMENT=="S"|
     TAB_bis$TYPE_CLASSEMENT=="X1"|TAB_bis$TYPE_CLASSEMENT=="X2")]<-1


## diviser l'�chantillon TEST et l'apprentissage
set.seed(1444)

sample_taille = 0.60 * nrow( TAB_bis)
IND<-sample(seq_len( nrow ( TAB_bis) ), size = sample_taille)

TAB_ECH<-TAB_bis[IND,]
TAB_TEST<-TAB_bis[-IND,]


## Déclarer le tabeleau d'étude

M<-TAB_bis[,c(7,5,6,9,13,14,15)]
#Graphe des corrélations par pairs 
pairs(M, col = M$TYPE_CLASSEMENT)

## ~~ Y
barplot(table(TAB_bis$TYPE_CLASSEMENT),col="lightblue",main="Type Defaut")
MAT<-matrix(table(TAB_bis$TYPE_CLASSEMENT),nrow = 1,ncol=6)
rownames(MAT)="Freq"
colnames(MAT)=c("E","NR","O","S","X1","X2")

write.csv2(TAB_bis, "E:/Others/Formation Data Science/Projet/Datasources/TAB_bis.csv",row.names = FALSE)
write.csv2(TAB_ECH, "E:/Others/Formation Data Science/Projet/Datasources/TAB_ECH.csv",row.names = FALSE)
write.csv2(TAB_TEST, "E:/Others/Formation Data Science/Projet/Datasources/TAB_TEST.csv",row.names = FALSE)


  