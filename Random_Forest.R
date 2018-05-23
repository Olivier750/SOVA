#-----------------------------------------------------------------------------------
#                               Random Forest
#----------------------------------------------------------------------------------

#install.packages("caret")
#library(caret)

install.packages("randomForest")
library(randomForest)


## les data a utiliser sont TAB_ECH1 et TAB_TEST

# Declarons les nouvelles variables 
TAB_ECH1<-TAB_ECH[-(which(TAB_ECH$TYPE_CLASSEMENT=="E"|TAB_ECH$TYPE_CLASSEMENT=="S"|TAB_ECH$TYPE_CLASSEMENT=="NR")),c(5,6,7,9,13,14,15)]
TAB_TEST1<-TAB_TEST[-(which(TAB_TEST$TYPE_CLASSEMENT=="E"|TAB_TEST$TYPE_CLASSEMENT=="S"|TAB_TEST$TYPE_CLASSEMENT=="NR")),c(5,6,7,9,13,14,15)]
TAB_ECH1$TYPE_CLASSEMENT=factor(TAB_ECH1$TYPE_CLASSEMENT)
TAB_TEST1$TYPE_CLASSEMENT=factor(TAB_TEST1$TYPE_CLASSEMENT)
rownames(TAB_ECH1)<-NULL
rownames(TAB_TEST1)<-NULL
# sclaed les data

maxs <- apply(TAB_ECH1[,c(2,4)], 2, max) 
mins <- apply(TAB_ECH1[,c(2,4)], 2, min)
trainNN_RF <- cbind(as.data.frame(scale(TAB_ECH1[,c(2,4)], center = mins, scale = maxs - mins)),TAB_ECH1[,c(1,3,5:7)])
maxs <- apply(TAB_TEST1[,c(2,4)], 2, max) 
mins <- apply(TAB_TEST1[,c(2,4)], 2, min)
testNN_RF <- cbind(as.data.frame(scale(TAB_TEST1[,c(2,4)], center = mins, scale = maxs - mins)),TAB_TEST1[,c(1,3,5:7)])


## avant d'appliquer la cross validation , testons le modèle et essayons de regler
# les paramètres

model_RF <-randomForest(TYPE_CLASSEMENT ~ ., data = trainNN_RF,ntree = 5000, mtry = 3, na.action = na.roughfix)
plot(model_RF$err.rate[, 1], type = "l", xlab = "nombre d'arbres", ylab = "erreur OOB")

model_RF2 <-randomForest(TYPE_CLASSEMENT ~ ., data = trainNN_RF,ntree = 2000, mtry = 6, na.action = na.omit)

## Cross validation

set.seed(1444) # For reproducibility
TRAIN <- data.frame(fold(trainNN_RF, k = 10,method = 'n_fill'), cat_col=trainNN_RF$TYPE_CLASSEMENT)
# Order by .folds
TRAIN <-TRAIN[order(TRAIN$.folds),]
TRAIN <-TRAIN[,-9]

crossvalidate_RF <- function(data){
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
    
    model <-randomForest(TYPE_CLASSEMENT ~ ., data = data,ntree = 2000, mtry = 6, na.action = na.omit)   #na.action = na.roughfix
     ## Test model
    PRED<-cbind(data.frame(predict(model_RF2,newdata=testing_set)),testing_set$TYPE_CLASSEMENT)
    colnames(PRED)<-c("PRED","REEL")
    
    # Matrice de confusion
    K<-xtabs(~a$REEL+a$PRED)
    ERREUR_MOD<-(K[1,2]+K[1,2]+K[2,1]+K[2,3]+K[3,1]+K[3,2])/nrow(testing_set)
    performances[fold] <- ERREUR_MOD}
  
  # Return the mean of the recorded RMSEs
  return(c('ERREUR' = mean(performances)))
  
}

MOD_RF1<-crossvalidate_RF(TRAIN)

### à refaire la cross validation

#ERREUR
#xtabs(~a$REEL+a$PRED)
#(357+24+766+80+ 24+90 )/nrow(testNN_RF)
