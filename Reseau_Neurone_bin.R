#------------------------------------------------------------------------------------
#                         Reseau de neronne 0/1
#------------------------------------------------------------------------------------


BASE_Bin_train<-read.table("E:/Others/Formation Data Science/Projet/Datasources/BASE_Multi_train.csv",sep=";",header=TRUE)
              
Data_TRAIN_bin<-FOLDS_func(BASE_Bin_train[,c("Profil","VITESSE","Class_Binaire","AGE",
                                           "TYPE_RAYON_COURBE", "TRAIN", "UIC","ANNEE_POSE")])


#Add a "fake" class to allow for all factors
levels(Data_TRAIN_bin$Profil) <- c(levels(Data_TRAIN_bin$Profil),"fake")
levels(Data_TRAIN_bin$UIC) <- c(levels(Data_TRAIN_bin$UIC),"fake")
levels(Data_TRAIN_bin$TRAIN) <- c(levels(Data_TRAIN_bin$TRAIN),"fake")
levels(Data_TRAIN_bin$TYPE_RAYON_COURBE) <- c(levels(Data_TRAIN_bin$TYPE_RAYON_COURBE),"fake")

#Relevel to make the fake class the factor
Data_TRAIN_bin$Profil <- relevel(Data_TRAIN_bin$Profil,ref = "fake")
Data_TRAIN_bin$UIC <- relevel(Data_TRAIN_bin$UIC,ref = "fake")
Data_TRAIN_bin$TRAIN <- relevel(Data_TRAIN_bin$TRAIN,ref = "fake")
Data_TRAIN_bin$TYPE_RAYON_COURBE <- relevel(Data_TRAIN_bin$TYPE_RAYON_COURBE,ref = "fake")




# conversion les variables catégorielle en variable num
Data_TRAIN_bin<-data.frame(model.matrix( ~ -1+Class_Binaire +AGE + VITESSE + UIC + Profil + TYPE_RAYON_COURBE + TRAIN,data= Data_TRAIN_bin))[,-1]
rownames(Data_TRAIN_bin)<-NULL
colnames(Data_TRAIN_bin)[1]<-"Class_Binaire"

# sclaed les data

maxs <- apply(train_set, 2, max) 
mins <- apply(train_set, 2, min)
trainNN_S <- as.data.frame(scale(train_set, center = mins, scale = maxs - mins))
maxs <- apply(test_set, 2, max) 
mins <- apply(test_set, 2, min)
testNN_S <- as.data.frame(scale(test_set, center = mins, scale = maxs - mins))
#rownames(testNN_S)<-NULL

## Cross validation

set.seed(1444) # For reproducibility
TRAIN <- data.frame(fold(trainNN_S, k = 10,method = 'n_fill'))
# Order by .folds
TRAIN  <-TRAIN [order(TRAIN$.folds),]

# créer la fonction de la cross validation

crossvalidate_NN_bin <- function(data){
  # data is the training set with the ".folds" column
  # random is a logical; do we have random effects in the model?
  
  # Initialize empty list for recording performances
  performances <- c()
  
  # One iteration per fold
  for (fold in 1:10){
    
    # Create training set for this iteration
    # Subset all the datapoints where .folds does not match the current fold
    training_set <- data[data$.folds != fold,]
    
    # Create test set for this iteration
    # Subset all the datapoints where .folds matches the current fold
    testing_set <- data[data$.folds == fold,]
    
    ## Train model
    
    model <- neuralnet(Class_Binaire ~ AGE +VITESSE+ UICG2_4 +UICG5_6+ UICG7_9 
                       +Profil46.E2  +Profil50.E6 +Profil55.E1 +Profil60.E1 +ProfilAutre+ TYPE_RAYON_COURBEALIGNEMENT+ TYPE_RAYON_COURBECOURBE
                       +TRAINAutre +TRAINTGV + TRAINTRANSILIEN  ,  training_set, hidden =10  , err.fct = "sse", act.fct = "logistic", 
                       threshold = 0.1, linear.output=FALSE, lifesign = "full",stepmax=1e6)
   
    ## Test model
    
    # Predict the dependent variable in the testing_set with the trained model
    #predicted <- predict(model, testing_set, allow.new.levels=TRUE)
    nn.results <- compute(model, testing_set[2:16])
    results4 <- data.frame(Reel=cbind(testing_set$Class_Binaire), prediction = nn.results$net.result)
    
    results_bis<-results4
    results_bis$prediction[which(results_bis$prediction>=0.5)]<-1
    results_bis$prediction[which(results_bis$prediction<0.5)]<-0
   
    #write.csv2(results, "E:/results.csv",row.names = FALSE)
    
    ## la matrice de confusion
    
    K<-xtabs(~results_bis$Reel+results_bis$prediction)
    
    ERREUR_MOD<-(K[1,2]+K[2,1])/(K[1,2]+K[2,1]+K[1,1]+K[2,2])
    # Add the RMSE to the performance list
    performances[fold] <- ERREUR_MOD
  }
  
  # Return the mean of the recorded RMSEs
  return(c('ERREUR' = mean(performances)))
  
}
MOD_NEURALNET_bin<-crossvalidate_NN_bin(TRAIN)

