#################### Neural Network with caret 


#---------------------------------------------------------------------------------------------------
# Clean and prepare data for neural network #
#---------------------------------------------------------------------------------------------------

source("E:/Others/Formation Data Science/Projet/Nouveau dossier/Cross_valisation.R")
library(caret)
library(doParallel)
## Les 2 bases de données à utiliser :
## BASE_Bin_train et BASE_Bin_test

str(BASE_Bin_train)
str(BASE_Bin_test)


# choisir les covariables 
#"Profil","VITESSE","TYPE_CLASSEMENT","AGE",
#"TYPE_RAYON_COURBE", "TRAIN", "UIC","ANNEE_POSE"
Data_TRAIN_Bin<-BASE_Bin_train[,c(5,6,7,18,10,15,16,17)]
Data_TRAIN_Bin$Class_Binaire[which(Data_TRAIN_Bin$Class_Binaire==1)]<-"X1"
Data_TRAIN_Bin$Class_Binaire[which(Data_TRAIN_Bin$Class_Binaire==0)]<-"X0"

# on scale les données

maxs <- apply(Data_TRAIN_Bin[,c(1,3,5)], 2, max) 
mins <- apply(Data_TRAIN_Bin[,c(1,3,5)], 2, min)
Data_TRAIN_Bin <- cbind(Data_TRAIN_Bin[,c(2,4,6:8)],as.data.frame(scale(Data_TRAIN_Bin[,c(1,3,5)], center = mins, scale = maxs - mins)))
rownames(Data_TRAIN_Bin)<-NULL
Data_TRAIN_Bin$Class_Binaire=as.factor(Data_TRAIN_Bin$Class_Binaire)


# Grille des paramètres
NN.Grid <- expand.grid(.size=c(15,20,30), .decay=c(0.1,0.2,0.5))

# comme on va faire un 10-fold repetée 2 fois 
## on choisi les seeds pour les itérations 

set.seed(1444)
seeds <- vector(mode = "list", length = 21)
for(i in 1:20) seeds[[i]] <- sample(1000,9)
seeds[[21]] <- 1 # Pour le dernier model

## Remplir les paramètres de la traincontrol


Controle<-trainControl(method = "repeatedcv", 
                       number = 10, # the number of folds
                       repeats = 2,
                       classProbs = TRUE, summaryFunction = twoClassSummary,
                       seeds = seeds)#,index = IDX)


cl = makeCluster(3)
registerDoParallel(cl)

#Neural Model
MOD_NN_Bin<- train(Class_Binaire ~ .,
               data=Data_TRAIN_Bin,
               method='nnet',
               maxit = 1000,
               linout = FALSE,
               trControl = Controle,
               tuneGrid = NN.Grid,
               metric = "Accuracy",
               allowParallel = TRUE)

stopCluster(cl)
remove(cl)
registerDoSEQ()

MOD_NN_Bin
plot(MOD_NN_Bin, metric = "ROC")

## testter le model 

## scaler les data

Data_TEST_Bin<-BASE_Bin_test[,c(5,6,7,18,10,15,16,17)]
Data_TEST_Bin$Class_Binaire[which(Data_TEST_Bin$Class_Binaire==1)]<-"X1"
Data_TEST_Bin$Class_Binaire[which(Data_TEST_Bin$Class_Binaire==0)]<-"X0"
Data_TEST_Bin$Class_Binaire<-as.factor(Data_TEST_Bin$Class_Binaire)
# on scale les données
maxs <- apply(Data_TEST_Bin[,c(1,3,5)], 2, max) 
mins <- apply(Data_TEST_Bin[,c(1,3,5)], 2, min)
Data_TEST_Bin <- cbind(Data_TEST_Bin[,c(2,4,6:8)],as.data.frame(scale(Data_TEST_Bin[,c(1,3,5)], center = mins, scale = maxs - mins)))
rownames(Data_TEST_Bin)<-NULL


NN_Predictions_Bin <-predict(MOD_NN_Bin, Data_TEST_Bin ,type = "prob")

## faisons varier le seuil k et regardons le taux d'erreur
P<-seq(0,1,0.05)
ERREUR_Bin <-c()
for (i in 1:length(P)){
  Confusion<-(NN_Predictions_Bin >P[i])+0
  X<-apply(Confusion,1,which.is.max)
  X[which(X==1)]<-"X0"
  X[which(X==2)]<-"X1"
  X<-as.factor(as.matrix(as.factor(X)))
  
  MAT<-confusionMatrix(X, Data_TEST_Bin$Class_Binaire)$table
  ERR<-(MAT[1,2]+MAT[2,1])/nrow(Data_TEST_Bin)
  ERREUR_Bin=c(ERREUR_Bin,ERR)
}
plot(P,ERREUR_Bin,type='p')
cbind(P,ERREUR_Bin)

## Faison la 

