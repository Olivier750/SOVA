
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


## Déclarer le tabeleau d'étude

M<-TAB_bis[,c(7,5,6,9,13,14,15)]
#Graphe des corrélations par pairs 
pairs(M, col = M$TYPE_CLASSEMENT)

## ~~ Y
barplot(table(TAB_bis$TYPE_CLASSEMENT),col="lightblue",main="Type Defaut")
MAT<-matrix(table(TAB_bis$TYPE_CLASSEMENT),nrow = 1,ncol=6)
rownames(MAT)="Freq"
colnames(MAT)=c("E","NR","O","S","X1","X2")

###----------Modélisation---------------------------------------------------

## utiliser c

install.packages("FactoMineR")
library(FactoMineR)
install.packages("factoextra")
library(factoextra)

MFA<-MFA(M, 
    group = c(1, 1, 1, 1,1, 1,1), 
    type = c("n", "n", "s", "s", "n", "n","n"),
    name.group = names(M),
    num.group.sup = c(1, 7),
    graph = TRUE)
fviz_mfa_ind(MFA, 
             habillage = "TYPE_CLASSEMENT", # color by groups 
             palette = c("#00AFBB", "#E7B800", "#FC4E07", "magenta","blue","black"),
             addEllipses = TRUE, ellipse.type = "confidence", 
             repel = TRUE 
) 
# Contribution � la premi�re dimension
fviz_contrib (res.mfa, "group", axes = 1)
# Contribution � la deuxi�me dimension
fviz_contrib (res.mfa, "group", axes = 2)
# install library
install.packages("neuralnet ")

# load library
library(neuralnet)

samplesize = 0.80 * nrow(TAB_bis)
index = sample(seq_len( nrow (TAB_bis) ), size = samplesize)


# creating training and test set
trainNN = TAB_bis[index , ]
testNN = TAB_bis[-index , ]



trainNN = maxmindf[index , ]
testNN = maxmindf[-index , ]
MOD<-data.frame(model.matrix(  ~ AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE+TYPE_CLASSEMENT +TRAIN, trainNN))
#MOD_TEST<-data.frame(model.matrix(  ~ AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE+TRAIN, testNN))
MOD_TEST<-data.frame(model.matrix(  ~ TYPE_CLASSEMENT+AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE+TRAIN, testNN))

# sclaed les data

maxs <- apply(MOD, 2, max) 
mins <- apply(MOD, 2, min)
trainNN_S <- as.data.frame(scale(MOD, center = mins, scale = maxs - mins))
testNN_S <- scale(MOD_TEST)

NN = neuralnet(TYPE_CLASSEMENTNR+ TYPE_CLASSEMENTO+TYPE_CLASSEMENTS+TYPE_CLASSEMENTX1+TYPE_CLASSEMENTX2 ~ AGE +VITESSE+ UICG5_6+ UICG7_9 +Profil50.E6 +Profil55.E1 +Profil60.E1 +ProfilAutre+ TYPE_RAYON_COURBECOURBE +TRAINTGV + TRAINTRANSILIEN  ,
                data.frame(trainNN_S[,-1]), hidden = 3  , err.fct = "sse", act.fct = "logistic", 
               threshold = 0.1, linear.output=FALSE, lifesign = "full",stepmax=1e6)
nn.results <- compute(NN, MOD_TEST[-c(1:6)])

# plot neural network
plot(NN)
results <- data.frame(cbind(testNN_S$TYPE_CLASSEMENTNR,testNN_S$TYPE_CLASSEMENTO,testNN_S$TYPE_CLASSEMENTS,
                            testNN_S$TYPE_CLASSEMENTX1,testNN_S$TYPE_CLASSEMENTX2), prediction = nn.results$net.result)

original_values <- max.col(MOD_TEST2[, 2:6])
pr.nn_2 <- max.col(results[,6:10])
mean(pr.nn_2 == original_values)

 
## Travailler sur uniquement 3 cluster à éliminer E, NE et S
TAB_ter<-TAB_bis[-which(TAB_bis$TYPE_CLASSEMENT=="S"|TAB_bis$TYPE_CLASSEMENT=="NR"|TAB_bis$TYPE_CLASSEMENT=="E" ),]
TAB_ter$Profil=factor(TAB_ter$Profil)
TAB_ter$UIC=factor(TAB_ter$UIC)
TAB_ter$TYPE_RAYON_COURBE=factor(TAB_ter$TYPE_RAYON_COURBE)
TAB_ter$TYPE_CLASSEMENT=factor(TAB_ter$TYPE_CLASSEMENT)
TAB_ter$TRAIN=factor(TAB_ter$TRAIN)


## générer un inde aléatoir pour la séparation des echantillons 
samplesize = 0.80 * nrow(TAB_ter)
index = sample(seq_len(nrow (TAB_ter)), size = samplesize)

#Add a "fake" class to allow for all factors
levels(TAB_ter$Profil) <- c(levels(TAB_ter$Profil),"fake")
levels(TAB_ter$UIC) <- c(levels(TAB_ter$UIC),"fake")
levels(TAB_ter$TRAIN) <- c(levels(TAB_ter$TRAIN),"fake")
levels(TAB_ter$TYPE_RAYON_COURBE) <- c(levels(TAB_ter$TYPE_RAYON_COURBE),"fake")

#Relevel to make the fake class the factor
TAB_ter$Profil <- relevel(TAB_ter$Profil,ref = "fake")
TAB_ter$UIC <- relevel(TAB_ter$UIC,ref = "fake")
TAB_ter$TRAIN <- relevel(TAB_ter$TRAIN,ref = "fake")
TAB_ter$TYPE_RAYON_COURBE <- relevel(TAB_ter$TYPE_RAYON_COURBE,ref = "fake")

# creating training and test set
trainNN = TAB_ter[index , ]
testNN = TAB_ter[-index , ]



MOD2<-data.frame(model.matrix( ~-1+TYPE_CLASSEMENT + AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE + TRAIN,data= trainNN))
MOD_TEST2<-data.frame(model.matrix( ~-1+TYPE_CLASSEMENT + AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE + TRAIN,data= testNN))



# sclaed les data

maxs <- apply(MOD2, 2, max) 
mins <- apply(MOD2, 2, min)
trainNN_S <- as.data.frame(scale(MOD2, center = mins, scale = maxs - mins))
testNN_S <- as.data.frame(scale(MOD_TEST2, center = mins, scale = maxs - mins))

NN2 = neuralnet( TYPE_CLASSEMENTO+TYPE_CLASSEMENTX1+TYPE_CLASSEMENTX2 ~ AGE +VITESSE+ UICG2_4 +UICG5_6+ UICG7_9 
               +Profil46.E2  +Profil50.E6 +Profil55.E1 +Profil60.E1 +ProfilAutre+ TYPE_RAYON_COURBEALIGNEMENT+ TYPE_RAYON_COURBECOURBE
              +TRAINAutre +TRAINTGV + TRAINTRANSILIEN  ,
              MOD2, hidden = 3  , err.fct = "sse", act.fct = "logistic", 
               threshold = 0.1, linear.output=FALSE, lifesign = "full",stepmax=1e6)

nn.results <- compute(NN2, MOD_TEST2[-c(1:3)])
#nn.results$net.result*(max(data$medv)-min(data$medv))+min(data$medv)
# plot neural network
plot(NN)
results <- data.frame(cbind(MOD_TEST2$TYPE_CLASSEMENTO,MOD_TEST2$TYPE_CLASSEMENTX1,
                            MOD_TEST2$TYPE_CLASSEMENTX2), prediction = nn.results$net.result)

original_values <- max.col(MOD_TEST2[,1:3])
pr.nn_2 <- max.col(results[,4:6])
mean(pr.nn_2 == original_values)

results_bis<-results
results_bis$prediction.1[which(results_bis$prediction.1>=0.5)]<-1
results_bis$prediction.1[which(results_bis$prediction.1<0.5)]<-0
results_bis$prediction.2[which(results_bis$prediction.2>=0.5)]<-1
results_bis$prediction.2[which(results_bis$prediction.2<0.5)]<-0
results_bis$prediction.3[which(results_bis$prediction.3>=0.5)]<-1
results_bis$prediction.3[which(results_bis$prediction.3<0.5)]<-0

## essayer un autre modele
NN3<-neuralnet( TYPE_CLASSEMENTO+TYPE_CLASSEMENTX1+TYPE_CLASSEMENTX2 ~ AGE +VITESSE+ UICG2_4 +UICG5_6+ UICG7_9 
                +Profil46.E2  +Profil50.E6 +Profil55.E1 +Profil60.E1 +ProfilAutre+ TYPE_RAYON_COURBEALIGNEMENT+ TYPE_RAYON_COURBECOURBE
                +TRAINAutre +TRAINTGV + TRAINTRANSILIEN  ,
                MOD2, hidden = c(3,2)  , err.fct = "sse", act.fct = "logistic", 
                threshold = 0.1, linear.output=FALSE, lifesign = "full",stepmax=1e6)
nn.results3 <- compute(NN3, MOD_TEST2[-c(1:3)])
#nn.results$net.result*(max(data$medv)-min(data$medv))+min(data$medv)
# plot neural network
plot(NN3)
results3 <- data.frame(cbind(MOD_TEST2$TYPE_CLASSEMENTO,MOD_TEST2$TYPE_CLASSEMENTX1,
                            MOD_TEST2$TYPE_CLASSEMENTX2), prediction = nn.results3$net.result)

original_values <- max.col(MOD_TEST2[,1:3])
pr.nn_3 <- max.col(results3[,4:6])
mean(pr.nn_3== original_values)


## un autre modele
NN4<-neuralnet( TYPE_CLASSEMENTO+TYPE_CLASSEMENTX1+TYPE_CLASSEMENTX2 ~ AGE +VITESSE+ UICG2_4 +UICG5_6+ UICG7_9 
                +Profil46.E2  +Profil50.E6 +Profil55.E1 +Profil60.E1 +ProfilAutre+ TYPE_RAYON_COURBEALIGNEMENT+ TYPE_RAYON_COURBECOURBE
                +TRAINAutre +TRAINTGV + TRAINTRANSILIEN  ,
                MOD2, hidden = 10  , err.fct = "sse", act.fct = "logistic", 
                threshold = 0.1, linear.output=FALSE, lifesign = "full",stepmax=1e6)
nn.results4 <- compute(NN4, MOD_TEST2[-c(1:3)])
# plot neural network
plot(NN4)
results4 <- data.frame(cbind(MOD_TEST2$TYPE_CLASSEMENTO,MOD_TEST2$TYPE_CLASSEMENTX1,
                             MOD_TEST2$TYPE_CLASSEMENTX2), prediction = nn.results4$net.result)

original_values <- max.col(MOD_TEST2[,1:3])
pr.nn_4 <- max.col(results4[,4:6])
mean(pr.nn_4== original_values)


results_bis<-results4
results_bis$prediction.1[which(results_bis$prediction.1>=0.5)]<-1
results_bis$prediction.1[which(results_bis$prediction.1<0.5)]<-0
results_bis$prediction.2[which(results_bis$prediction.2>=0.5)]<-1
results_bis$prediction.2[which(results_bis$prediction.2<0.5)]<-0
results_bis$prediction.3[which(results_bis$prediction.3>=0.5)]<-1
results_bis$prediction.3[which(results_bis$prediction.3<0.5)]<-0
#write.csv2(results, "E:/results.csv",row.names = FALSE)

## la matrice de confusion
PREDICTION<-c(results_bis$X1,results_bis$X2,results_bis$X3)
REEL<-c(results_bis$prediction.1,results_bis$prediction.2,results_bis$prediction.3)

K<-xtabs(~PREDICTION+ REEL)

ERREUR_MOD<-(K[1,2]+K[2,1])/(K[1,2]+K[2,1]+K[1,1]+K[2,2])


## esayer le meme modèle mais en données scale

