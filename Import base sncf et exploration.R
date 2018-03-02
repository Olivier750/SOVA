###################################################################################
#####################           IMPORT DES DONNEES           ######################
###################################################################################


#Chargement de la librairie RSQLite, qui permet d'utiliser la base de données SQLite
library("RSQLite")

#Chargement dans la variable sqldrv du driver SQLite
sqldrv <- dbDriver("SQLite")

#Création de la connection à la base de données sncd.db
#activation des extensions de SQLite
con <- dbConnect(sqldrv, dbname = "D:\\sncf.db", loadable.extensions = TRUE)
con

# Import de la base #
base_sncf<-dbGetQuery(con,'select * from "DEFAUT_SNCF"')


###################################################################################
#####################           ETUDE DES INDICATEURS           ###################
###################################################################################

# Au global #
#############

names(base_sncf)
# [1] "Region"                         "CodeLigne"                      "CodeVoie"                      
# [4] "Vitesse"                        "GRUIC"                          "Pkdebutnum_Retrait"            
# [7] "Pkfinnum_Retrait"               "Longueurduretrait(enm)"         "Libelledefaut"                 
# [10] "Datededecouvertedudefautretire" "Mois_defaut"                    "Annee_defaut"                  
# [13] "ProfilderailARMEN"              "Anneepose"                      "Age_rail"    
str(base_sncf)
library(prettyR);describe(base_sncf)
summary(base_sncf)


# LA DUREE DE VIE A EXPLIQUER : Age du tronçon lors du defaut #
###############################################################

# Effectifs :
table(base_sncf$Age_rail,deparse.level=2,useNA="always")
# Histo des Effectifs :
hist(base_sncf$Age_rail, nclass=30, col = "grey", border = "white",
     main = paste("Répartition selon l'âge des", nrow(base_sncf), "tronçons de rail lors du défaut"),
     xlab = "âge[années]", ylab = "Effectifs", 
     ylim = c(0, 800),
     xlim = c(0,110),
     labels = TRUE)
# Histo des Fréquences relatives et densité de proba :
hist(base_sncf$Age_rail, nclass=30, col = "grey", border = "white",
     main = paste("Répartition selon l'âge des", nrow(base_sncf), "tronçons de rail lors du défaut") ,
     xlab = "âges[années]", ylab = "Densité",
     ylim = c(0,0.05),
     xlim = c(0,100),
     proba = TRUE)
lines(density(base_sncf$Age_rail, na.rm = TRUE), lwd = 2, col = "orange" )

# On etudie la variable sENSUREE : delai jusqu'au defaut,
install.packages("survival")
library(survival)
# Attention, ici on n'a que des défauts :
base_sncf$defaut <- 1

# Fonction de survie : Graphe de la courbe de maintien sans defaut 
# mark.time=TRUE permet de faire apparaitre les donnees censurees (ici on n'en a pas encore)
plot(survfit(Surv(base_sncf$Age_rail,base_sncf$defaut)~1),mark.time=TRUE,main="Courbe de maintien sans defaut")


# LES VARIABLES EXPLICATIVES QUANTITATIVES #
###########################################

# La vitesse :
##############

summary(base_sncf$Vitesse)
# Histo des Effectifs :
hist(base_sncf$Vitesse, nclass=30, col = "grey", border = "white",
     main = paste("Répartition selon la vitesse maximale autorisée"),
     xlab = "vitesse[km/h]", ylab = "Effectifs", 
     ylim = c(0, 1000),
     xlim = c(30,200),
     labels = TRUE)
# Histo des Fréquences relatives et densité de proba :
hist(base_sncf$Vitesse, nclass=30, col = "grey", border = "white",
     main = paste("Répartition selon la vitesse maximale autorisée") ,
     xlab = "vitesse[km/h]", ylab = "Densité",
     ylim = c(0,0.05),
     xlim = c(30,200),
     proba = TRUE)
lines(density(base_sncf$Vitesse, na.rm = TRUE), lwd = 2, col = "orange" )

# Etude de la correlation entre la vitesse et l'age du tronçon au moment du defaut :
plot(jitter(base_sncf$Age_rail),jitter(base_sncf$Vitesse))
# Y=aged es rail suit une loi normale : on utilise donc le test de Pearson :
cor.test(base_sncf$Age_rail,base_sncf$Vitesse)
# cor=-0.1408199, p<5% => la correlation est significativement differente de 0
# cor<0 donc Plus la vitesse max autorisée est grande, plus l'age des rail au moment du defaut est petit

# Test d'association entre la survie et la vitesse max autorisée :
# On utilise le modéle de Cox :
coxph(Surv(Age_rail,defaut)~Vitesse,data=base_sncf)
# p<5% => association significative entre la survie et la vitesse
# coef=0.004250 > 0 => la rechute sera plus tardive pour les rail à plus faible vitesse


# LES VARIABLES EXPLICATIVES QUANTITATIVES A mETTRE EN FACTEUR CAR NON QUANTITE #
#################################################################################

# CodeLigne : 
#############

# Effectifs
sort(table(base_sncf$CodeLigne, deparse.level=2, useNA="always"), decreasing = TRUE) 
# 25 modalites
# Représentation graphique :
barplot(table(base_sncf$CodeLigne), 
        horiz = TRUE,las=1, 
        col = "purple", 
        border = "white",
        cex.names = 0.5,
        main ="Effectif par CodeLigne",
        xlab = "Effectifs")

# Boîtes à moustaches côte à côte, pour mieux comparer les dispersions d'age du rail pour chaque code voie 
boxplot(base_sncf$Age_rail ~ base_sncf$CodeLigne,
        col = "purple", border = "black",
        main = "Age du rail au moment du defaut en fonction du code ligne",
        ylab = "âges[années]"
)

# On changer la modalite de reference, pour cela on met dans un indicateur local le facteur de la var :
CodeLigne <- factor(base_sncf$CodeLigne)
CodeLigne <- relevel(CodeLigne, ref="272000")

# correlation entre Y-quanti Age_rail et Xi-quali CodeVoie : Analyse de la variance
modele <- lm(base_sncf$Age_rail~CodeLigne)
summary(modele)
# On obtient le nb d'années en plus ou en moins selon tel codeligne en fonction de celui de reference : 272000
# pas evident a lire donc  on regarde l'effet global du code voie sur le modele :
drop1(modele,.~.,test="F")
# p<5% : il y a une difference moyenne de l'age du rail selon le code ligne

# Test d'association entre la survie et le code ligne :
# On utilise le modéle de Cox : il transforme la quali en plusieurs binaires 
mod<-coxph(Surv(Age_rail,defaut)~CodeLigne,data=base_sncf)
exp(coef(mod))
# p<5% => association significative entre la survie et le CodeLigne
# Comme on travaille avec plusieurs binaires, on ne peut pas interpreter le coef
# On travaille sur le exp(coef)=1 => 1-exp(coef) = 0% de moins de risque de rechute selon le codeligne


# Mois_defaut : 
###############

# Effectifs
sort(table(base_sncf$Mois_defaut, deparse.level=2, useNA="always"), decreasing = TRUE) 
# 12 modalites
# Représentation graphique :
barplot(table(base_sncf$Mois_defaut), 
        horiz = TRUE,las=1, 
        col = "purple", 
        border = "white",
        cex.names = 0.5,
        main ="Effectif par Mois_defaut",
        xlab = "Effectifs")

# Boîtes à moustaches côte à côte, pour mieux comparer les dispersions d'age du rail pour chaque code voie 
boxplot(base_sncf$Age_rail ~ base_sncf$Mois_defaut,
        col = "purple", border = "black",
        main = "Age du rail au moment du defaut en fonction du Mois_defaut",
        ylab = "âges[années]"
)

# On changer la modalite de reference, pour cela on met dans un indicateur local le facteur de la var :
Mois_defaut <- factor(base_sncf$Mois_defaut)
Mois_defaut <- relevel(Mois_defaut, ref="6")

# correlation entre Y-quanti Age_rail et Xi-quali CodeVoie : Analyse de la variance
modele <- lm(base_sncf$Age_rail~Mois_defaut)
summary(modele)
# On obtient le nb d'années en plus ou en moins selon tel codeligne en fonction de celui de reference : juin
# pas evident a lire donc  on regarde l'effet global du code voie sur le modele :
drop1(modele,.~.,test="F")
# p<5% : il y a une difference moyenne de l'age du rail selon le mois du defaut

# Test d'association entre la survie et le Mois_defaut :
# On utilise le modéle de Cox : il transforme la quali en plusieurs binaires 
mod<-coxph(Surv(Age_rail,defaut)~Mois_defaut,data=base_sncf)
mod
exp(coef(mod))
# p=50% => association non significative entre la survie et le Mois_defaut
# Comme on travaille avec plusieurs binaires, on ne peut pas interpreter le coef
# On travaille sur le exp(coef)~=1 => 1-exp(coef) = 0% de moins de risque de rechute selon le codeligne


# LES VARIABLES EXPLICATIVES QUALITATIVES #
###########################################

# CodeVoie :
###########

# Effectifs
sort(table(base_sncf$CodeVoie, deparse.level=2, useNA="always"), decreasing = TRUE) 
# 82 modalites
# Représentation graphique :
barplot(table(base_sncf$CodeVoie), 
        horiz = TRUE,las=1, 
        col = "purple", 
        border = "white",
        cex.names = 0.5,
        main ="Effectif par CodeVoie",
        xlab = "Effectifs")

# Boîtes à moustaches côte à côte, pour mieux comparer les dispersions d'age du rail pour chaque code voie 
boxplot(base_sncf$Age_rail ~ base_sncf$CodeVoie,
        col = "purple", border = "black",
        main = "Age du rail au moment du defaut en fonction du code voie",
        ylab = "âges[années]"
)

# On changer la modalite de reference, pour cela on met dans un indicateur local le facteur de la var :
CodeVoie <- factor(base_sncf$CodeVoie)
CodeVoie <- relevel(CodeVoie, ref="V1")

# correlation entre Y-quanti Age_rail et Xi-quali CodeVoie : Analyse de la variance
modele <- lm(base_sncf$Age_rail~CodeVoie)
summary(modele)
# On obtient le nb d'années en plus ou en moins selon tel codevoie en fonction de celui de reference
# pas evident a lire donc  on regarde l'effet global du code voie sur le modele :
drop1(modele,.~.,test="F")
# p<5% : il y a une difference moyenne de l'age du rail selon le code voie

# Test d'association entre la survie et le Mois_defaut :
# On utilise le modéle de Cox : il transforme la quali en plusieurs binaires 
mod<-coxph(Surv(Age_rail,defaut)~CodeVoie,data=base_sncf)
mod
exp(coef(mod))
# bcp de proba elevée sauf pour quelques voies => association non significative entre la survie et la plupart des CodeVoie
# Comme on travaille avec plusieurs binaires, on ne peut pas interpreter le coef
# On travaille sur le exp(coef) mais on a vu que ce n'etait pas significatif


# GRUIC :
#########

# Effectifs
sort(table(base_sncf$GRUIC, deparse.level=2, useNA="always"), decreasing = TRUE) 
# 10 modalites
# Représentation graphique :
barplot(table(base_sncf$GRUIC), 
        horiz = TRUE,las=1, 
        col = "purple", 
        border = "white",
        cex.names = 0.5,
        main ="Effectif par GRUIC",
        xlab = "Effectifs")

# Boîtes à moustaches côte à côte, pour mieux comparer les dispersions d'age du rail pour chaque GRUIC 
boxplot(base_sncf$Age_rail ~ base_sncf$GRUIC,
        col = "purple", border = "black",
        main = "Age du rail au moment du defaut en fonction du GRUIC",
        ylab = "âges[années]"
)

# On changer la modalite de reference, pour cela on met dans un indicateur local le facteur de la var :
GRUIC <- factor(base_sncf$GRUIC)
GRUIC <- relevel(GRUIC, ref="4")

# correlation entre Y-quanti Age_rail et Xi-quali GRUIC : Analyse de la variance
modele <- lm(base_sncf$Age_rail~GRUIC)
summary(modele)
# On obtient le nb d'années en plus ou en moins selon tel GRUIC en fonction de celui de reference GRUIC=4
# pas evident a lire mais on voit que tout est >0 donc tous sont plus resistant que le GRUIC=4
# On regarde l'effet global du GRUIC sur le modele :
drop1(modele,.~.,test="F")
# p<5% : il y a une difference moyenne de l'age du rail selon le GRUIC

# Test d'association entre la survie et le GRUIC :
# On utilise le modéle de Cox : il transforme la quali en plusieurs binaires 
mod<-coxph(Surv(Age_rail,defaut)~GRUIC,data=base_sncf)
mod
exp(coef(mod))
# p<5% sauf pour GRUIC=4 leplus représenté => association significative entre la survie et tous les guic sauf le 4
# Comme on travaille avec plusieurs binaires, on ne peut pas interpreter le coef
# On travaille sur le exp(coef) 
# exple pour le guic3 : exp(coef)=0.66 => 1-0.66=34% de risque de rechute en moins avec le 3


# ProfilderailARMEN :
#####################

# Effectifs
sort(table(base_sncf$ProfilderailARMEN, deparse.level=2, useNA="always"), decreasing = TRUE) 
# 13 modalites
# Représentation graphique :
barplot(table(base_sncf$ProfilderailARMEN), 
        horiz = TRUE,las=1, 
        col = "purple", 
        border = "white",
        cex.names = 0.5,
        main ="Effectif par ProfilderailARMEN",
        xlab = "Effectifs")

# Boîtes à moustaches côte à côte, pour mieux comparer les dispersions d'age du rail pour chaque ProfilderailARMEN 
boxplot(base_sncf$Age_rail ~ base_sncf$ProfilderailARMEN,
        col = "purple", border = "black",
        main = "Age du rail au moment du defaut en fonction du ProfilderailARMEN",
        ylab = "âges[années]"
)

# On changer la modalite de reference, pour cela on met dans un indicateur local le facteur de la var :
ProfilderailARMEN <- factor(base_sncf$ProfilderailARMEN)
ProfilderailARMEN <- relevel(ProfilderailARMEN, ref="UIC60")

# correlation entre Y-quanti Age_rail et Xi-quali ProfilderailARMEN : Analyse de la variance
modele <- lm(base_sncf$Age_rail~ProfilderailARMEN)
summary(modele)
# On obtient le nb d'années en plus ou en moins selon tel codevoie en fonction de celui de reference UIC60
# pas evident a lire donc  on regarde l'effet global du code voie sur le modele :
drop1(modele,.~.,test="F")
# p<5% : il y a une difference moyenne de l'age du rail selon le ProfilderailARMEN

# Test d'association entre la survie et le GRUIC :
# On utilise le modéle de Cox : il transforme la quali en plusieurs binaires 
mod<-coxph(Surv(Age_rail,defaut)~ProfilderailARMEN,data=base_sncf)
mod
exp(coef(mod))
# p<5% sauf pour Nord45 leplus représenté => association significative entre la survie et tous les guic sauf le 4
# Comme on travaille avec plusieurs binaires, on ne peut pas interpreter le coef
# On travaille sur le exp(coef) 
# Ils sont tous proches de 0 donc 100% de risque de rechute en moins avec eux ???


###################################################################################
#####################    Modele de COX avec toutes les var      ###################
###################################################################################



mod<-coxph(Surv(Age_rail,defaut)~Vitesse+Mois_defaut +CodeLigne+CodeVoie+ProfilderailARMEN+GRUIC,data=base_sncf)
mod
exp(coef(mod))



# CREATION D'UN MODELE DE SURVIE AVEC LES VAR QUI L'INFLUENCENT #
#################################################################





# Pour le choix du vrai modele : 
# Faire un surveyselect sur l'age du tronçon pour ech constr test de 70-30
# faire une boucle qui crée autant d'associations possibles entre les variables retenues : 
# p associations => p modeles à créer sur l'ech constr avec calcul parallele
# Tester les p modéles sur l'ech test avec calcul parallele
# Choisir celui qui estime le mieux la survie 


# On peut aussi faire du bootstrap ? => Ca nous ferait encore une boucle en parallele




