#################### Neural Network with caret 


#---------------------------------------------------------------------------------------------------
# Clean and prepare data for neural network #
#---------------------------------------------------------------------------------------------------

source("E:/Others/Formation Data Science/Projet/Nouveau dossier/Cross_valisation.R")
library(caret)
library(doParallel)
## Les 2 bases de données à utiliser :
## BASE_Multi_train et BASE_Multi_test

str(BASE_Multi_train)
str(BASE_Multi_test)


# choisir les covariables 
#"Profil","VITESSE","TYPE_CLASSEMENT","AGE",
#"TYPE_RAYON_COURBE", "TRAIN", "UIC","ANNEE_POSE"
Data_TRAIN<-BASE_Multi_train[,c(6,7,8,10,15,16,17,5)]


# on scale les données

maxs <- apply(Data_TRAIN[,c(2,4,8)], 2, max) 
mins <- apply(Data_TRAIN[,c(2,4,8)], 2, min)
Data_TRAIN <- cbind(Data_TRAIN[,c(1,3,5:7)],as.data.frame(scale(Data_TRAIN[,c(2,4,8)], center = mins, scale = maxs - mins)))
rownames(Data_TRAIN)<-NULL

## appler la fonction FOLDS_func Pour la cross-validation
Data_TRAIN1<-FOLDS_func(Data_TRAIN,1444)
Data_TRAIN2<-FOLDS_func(Data_TRAIN,12)

# Grille des paramètres
NN.Grid <- expand.grid(.size=c(15,20,30), .decay=c(0.1,0.2,0.5))

# comme on va faire un 10-fold repetée 2 fois 
## on choisi les seeds pour les itérations 

set.seed(1444)
seeds <- vector(mode = "list", length = 21)
for(i in 1:20) seeds[[i]] <- sample(1000,9)
seeds[[21]] <- 1 # Pour le dernier model
 
## Remplir les paramètres de la traincontrol

# Commençons par l'indice des observations à prendre
IDX<-vector(mode = "list", length = 20)  
for(i in 1:10) IDX[[i]] <-as.integer(rownames(Data_TRAIN1[which(Data_TRAIN1[,"fold"]==i),]))
for(i in 1:10) IDX[[10+i]] <-as.integer(rownames(Data_TRAIN2[which(Data_TRAIN2[,"fold"]==i),]))

Controle<-trainControl(method = "repeatedcv", 
                       number = 10, # the number of folds
                       repeats = 2,
                       classProbs = TRUE, summaryFunction = multiClassSummary,
                       seeds = seeds)#,index = IDX)


cl = makeCluster(3)
registerDoParallel(cl)

#Neural Model
MOD_NN<- train(TYPE_CLASSEMENT ~ .,
                  data=Data_TRAIN,
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

MOD_NN
plot(MOD_NN, metric = "Accuracy")

## testter le model 

## scaler les data

Data_TEST<-BASE_Multi_test[,c(6,7,8,10,15,16,17,5)]
# on scale les données

maxs <- apply(Data_TEST[,c(2,4,8)], 2, max) 
mins <- apply(Data_TEST[,c(2,4,8)], 2, min)
Data_TEST <- cbind(Data_TEST[,c(1,3,5:7)],as.data.frame(scale(Data_TEST[,c(2,4,8)], center = mins, scale = maxs - mins)))
rownames(Data_TEST)<-NULL


NN_Predictions <-predict(MOD_NN, Data_TEST,type = "prob")

## faisons varier le seuil k et regardons le taux d'erreur
P<-seq(0,1,0.05)
ERREUR<-c()
for (i in 1:length(P)){
Confusion<-(NN_Predictions>P[i])+0
X<-apply(Confusion,1,which.is.max)
X[which(X==1)]<-"O"
X[which(X==2)]<-"X1"
X[which(X==3)]<-"X2"
X<-as.factor(as.matrix(as.factor(X)))

MAT<-confusionMatrix(X, Data_TEST$TYPE_CLASSEMENT)$table
ERR<-(MAT[1,2]+MAT[1,3]+MAT[2,1]+MAT[2,3]+MAT[3,1]+MAT[3,2])/nrow(Data_TEST)
ERREUR=c(ERREUR,ERR)
}
plot(P,ERREUR,type='p')
cbind(P,ERREUR)

## Faison la 
