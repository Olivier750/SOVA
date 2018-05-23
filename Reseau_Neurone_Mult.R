###----------ModÃ©lisation---------------------------------------------------


#install.packages("FactoMineR")
#install.packages("groupdata2")
#install.packages("factoextra")
#library(groupdata2)
#library(dplyr) # %>%
#library(knitr) # kable
#library(FactoMineR)
#library(factoextra)
library(neuralnet)
source("Cross_valisation.R")
######----------------- Récap------------------

# X_fin est notre base de données test finale
# Comme on est sur la modelisation de reseau de neuronne, on selectionne que quelques variables
BASE_Multi_train<-read.table("E:/Others/Formation Data Science/Projet/Datasources/BASE_Multi_train.csv",sep=";",header=TRUE)

Data_TRAIN<-FOLDS_func(BASE_Multi_train[,c("Profil","VITESSE","TYPE_CLASSEMENT","AGE",
                                           "TYPE_RAYON_COURBE", "TRAIN", "UIC","ANNEE_POSE")])
# Ajouter une modalité fake


#Add a "fake" class to allow for all factors
levels(Data_TRAIN$Profil) <- c(levels(Data_TRAIN$Profil),"fake")
levels(Data_TRAIN$UIC) <- c(levels(Data_TRAIN$UIC),"fake")
levels(Data_TRAIN$TRAIN) <- c(levels(Data_TRAIN$TRAIN),"fake")
levels(Data_TRAIN$TYPE_RAYON_COURBE) <- c(levels(Data_TRAIN$TYPE_RAYON_COURBE),"fake")

#Relevel to make the fake class the factor
Data_TRAIN$Profil <- relevel(Data_TRAIN$Profil,ref = "fake")
Data_TRAIN$UIC <- relevel(Data_TRAIN$UIC,ref = "fake")
Data_TRAIN$TRAIN <- relevel(Data_TRAIN$TRAIN,ref = "fake")
Data_TRAIN$TYPE_RAYON_COURBE <- relevel(Data_TRAIN$TYPE_RAYON_COURBE,ref = "fake")

# conversion les variables catégorielle en variable num
Data_TRAIN<-data.frame(model.matrix( ~-1+TYPE_CLASSEMENT + AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE + TRAIN+fold,data= Data_TRAIN))

# on scale les données

# sclaed les data

maxs <- apply(Data_TRAIN, 2, max) 
mins <- apply(Data_TRAIN, 2, min)
Data_TRAIN <- as.data.frame(scale(Data_TRAIN, center = mins, scale = maxs - mins))
rownames(Data_TRAIN)<-NULL

## créer l'indice pour paramètrer le nombre de couches dans neuralnet 
Erreur=c(rep(0,3))
for (j in c(10,c(5,2),c(3))){
# créer la fonction de la cross validation
performances <- c()

# Création de la boucles sur les 10 folders
for (i in 1:10){
  
  # Train qui contient 9 blocs
  training_set <- Data_TRAIN[Data_TRAIN$fold != i,]
  # test qui contient 1 bloc
  testing_set <-  Data_TRAIN[Data_TRAIN$fold == i,]
  
  ##  model
  
  model<- neuralnet(TYPE_CLASSEMENTO+TYPE_CLASSEMENTX1+TYPE_CLASSEMENTX2 ~ AGE +VITESSE+ UICForte.Densite +UICMoyenne.Densite+ UICFaible.Densite 
                    +Profil46.E2  +Profil50.E6 +Profil55.E1 +Profil60.E1 +ProfilAutre+ TYPE_RAYON_COURBEALIGNEMENT+ TYPE_RAYON_COURBECOURBE
                    +TRAINAutre +TRAINTGV + TRAINTRANSILIEN  ,   training_set, hidden =c(10,10)  , err.fct = "ce", act.fct = "logistic", 
                    threshold = 0.1, linear.output=FALSE, lifesign = "full",stepmax=1e6)
    ## Test model  : essayer avec keras
  ## ce comme erreur de la dernière couche  
  
    # Predict 
    predicted <- compute(model, testing_set[,-c(1:3,19)])
    Pred<-data.frame(predicted$net.result)
    colnames(Pred)<-c("Pred_O","Pred_X1","Pred_X2") 
  ## changer les proba en indicateurs
  
  ## la matrice de confusion
  test<-cbind(Pred,testing_set[,c(1:3)])
 test$max<-apply(test[,1:3],1,max)
 test$Pred_O=(test$Pred_O==test$max)*1
 test$Pred_X1=(test$Pred_X1==test$max)*1
 test$Pred_X2=(test$Pred_X2==test$max)*1

  # K<-xtabs(~test$Pred_O+test$TYPE_CLASSEMENTO)
 #xtabs(~test$Pred_X1+test$TYPE_CLASSEMENTX1)
 #xtabs(~test$Pred_X2+test$TYPE_CLASSEMENTX2)
K<- table(c(test$Pred_O,test$Pred_X1,test$TYPE_CLASSEMENTX1),c(test$TYPE_CLASSEMENTO,test$TYPE_CLASSEMENTX1,test$TYPE_CLASSEMENTX2))
  # calcule de l'erreur
  ERREUR_MOD<-(K[1,2]+K[2,1])/(K[1,2]+K[2,1]+K[1,1]+K[2,2])
  # Ajouter à la liste ->> à la fin on obtient 10 : on les moyenne
  performances[i] <- ERREUR_MOD
}

# 
Erreur[j]<-c('ERREUR' = mean(performances))

}
