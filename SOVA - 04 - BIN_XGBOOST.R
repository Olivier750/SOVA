#install.packages("questionr")
#install.packages("forcats")
#install.packages("caret")
#install.packages("doSNOW")
#install.packages("e1071")
## CHARGEMENT DES LIBRAIRIES     #############################################################################
library(caret) # for dummyVars
#library(RCurl) # download https data
#library(Metrics) # calculate errors
library(xgboost) # model
library(doSNOW)
library(parallel)
library(e1071)
#library(forcats)
#library(questionr)
#library(RSQLite)
#library(sqldf)
#library(tidyr)

#Parallelisation des traitements
cluster <- makeCluster(detectCores() - 1) # On laisse un coeur ? l'OS


## CHARGEMENT DES DONNEES        #############################################################################
TAB_bis  <- read.csv(file = "C:/SOVA/Datasources/TAB_bis.csv", header = TRUE, sep = ";")
TAB_ECH  <- read.csv(file = "C:/SOVA/Datasources/TAB_ECH.csv", header = TRUE, sep = ";")
TAB_TEST <- read.csv(file = "C:/SOVA/Datasources/TAB_TEST.csv", header = TRUE, sep = ";")

#suppression des ages negatifs
TAB_bis$AGE_bis <- as.character(TAB_bis$AGE_bis)
TAB_ECH$AGE_bis <- as.character(TAB_ECH$AGE_bis)
TAB_TEST$AGE_bis <- as.character(TAB_TEST$AGE_bis)

TAB_bis$AGE_bis[TAB_bis$AGE_bis == "(-20,0]"] <- NA
TAB_ECH$AGE_bis[TAB_ECH$AGE_bis == "(-20,0]"] <- NA
TAB_TEST$AGE_bis[TAB_TEST$AGE_bis == "(-20,0]"] <- NA

#suppression des vitesses negatives
TAB_bis$VITESSE_bis <- as.character(TAB_bis$VITESSE_bis)
TAB_ECH$VITESSE_bis <- as.character(TAB_ECH$VITESSE_bis)
TAB_TEST$VITESSE_bis <- as.character(TAB_TEST$VITESSE_bis)

TAB_bis$VITESSE_bis[TAB_bis$VITESSE_bis == "(-10,0]"] <- NA
TAB_ECH$VITESSE_bis[TAB_ECH$VITESSE_bis == "(-10,0]"] <- NA
TAB_TEST$VITESSE_bis[TAB_TEST$VITESSE_bis == "(-10,0]"] <- NA

#suppression des na
TAB_bis <- TAB_bis[complete.cases(TAB_bis), ]
TAB_ECH <- TAB_bis[complete.cases(TAB_ECH), ]
TAB_TEST <- TAB_bis[complete.cases(TAB_TEST), ]

#refactorisation des ages et vitesses
TAB_bis$AGE_bis <- as.factor(TAB_bis$AGE_bis)
TAB_ECH$AGE_bis <- as.factor(TAB_ECH$AGE_bis)
TAB_TEST$AGE_bis <- as.factor(TAB_TEST$AGE_bis)

TAB_bis$VITESSE_bis <- as.factor(TAB_bis$VITESSE_bis)
TAB_ECH$VITESSE_bis <- as.factor(TAB_ECH$VITESSE_bis)
TAB_TEST$VITESSE_bis <- as.factor(TAB_TEST$VITESSE_bis)

## TRANSFORMATIONS DES DONNEES   #############################################################################

# Filtrage des donnees, on ne prends que les variables qui nous interesse
TAB_bis  <- TAB_bis [,c("Class_Binaire","Profil","EMPLACEMENT","AGE_bis","VITESSE_bis","TYPE_RAYON_COURBE","TRAIN","UIC")]
TAB_ECH  <- TAB_ECH [,c("Class_Binaire","Profil","EMPLACEMENT","AGE_bis","VITESSE_bis","TYPE_RAYON_COURBE","TRAIN","UIC")]
TAB_TEST <- TAB_TEST[,c("Class_Binaire","Profil","EMPLACEMENT","AGE_bis","VITESSE_bis","TYPE_RAYON_COURBE","TRAIN","UIC")]

#transformation en level
levels(TAB_bis$Profil)            <- seq(1,length(levels(TAB_bis$Profil)),length.out = length(levels(TAB_bis$Profil)))
levels(TAB_bis$EMPLACEMENT)       <- seq(1,length(levels(TAB_bis$EMPLACEMENT)),length.out = length(levels(TAB_bis$EMPLACEMENT)))
levels(TAB_bis$AGE_bis)           <- seq(1,length(levels(TAB_bis$AGE_bis)),length.out = length(levels(TAB_bis$AGE_bis)))
levels(TAB_bis$VITESSE_bis)       <- seq(1,length(levels(TAB_bis$VITESSE_bis)),length.out = length(levels(TAB_bis$VITESSE_bis)))
levels(TAB_bis$TYPE_RAYON_COURBE) <- seq(1,length(levels(TAB_bis$TYPE_RAYON_COURBE)),length.out = length(levels(TAB_bis$TYPE_RAYON_COURBE)))
levels(TAB_bis$TRAIN)             <- seq(1,length(levels(TAB_bis$TRAIN)),length.out = length(levels(TAB_bis$TRAIN)))
levels(TAB_bis$UIC)               <- seq(1,length(levels(TAB_bis$UIC)),length.out = length(levels(TAB_bis$UIC)))
#Possibilit? d'utiliser questionr::irec(TAB_bis, Profil)

levels(TAB_ECH$Profil)            <- seq(1,length(levels(TAB_ECH$Profil)),length.out = length(levels(TAB_ECH$Profil)))
levels(TAB_ECH$EMPLACEMENT)       <- seq(1,length(levels(TAB_ECH$EMPLACEMENT)),length.out = length(levels(TAB_ECH$EMPLACEMENT)))
levels(TAB_ECH$AGE_bis)           <- seq(1,length(levels(TAB_ECH$AGE_bis)),length.out = length(levels(TAB_ECH$AGE_bis)))
levels(TAB_ECH$VITESSE_bis)       <- seq(1,length(levels(TAB_ECH$VITESSE_bis)),length.out = length(levels(TAB_ECH$VITESSE_bis)))
levels(TAB_ECH$TYPE_RAYON_COURBE) <- seq(1,length(levels(TAB_ECH$TYPE_RAYON_COURBE)),length.out = length(levels(TAB_ECH$TYPE_RAYON_COURBE)))
levels(TAB_ECH$TRAIN)             <- seq(1,length(levels(TAB_ECH$TRAIN)),length.out = length(levels(TAB_ECH$TRAIN)))
levels(TAB_ECH$UIC)               <- seq(1,length(levels(TAB_ECH$UIC)),length.out = length(levels(TAB_ECH$UIC)))

levels(TAB_TEST$Profil)            <- seq(1,length(levels(TAB_TEST$Profil)),length.out = length(levels(TAB_TEST$Profil)))
levels(TAB_TEST$EMPLACEMENT)       <- seq(1,length(levels(TAB_TEST$EMPLACEMENT)),length.out = length(levels(TAB_TEST$EMPLACEMENT)))
levels(TAB_TEST$AGE_bis)           <- seq(1,length(levels(TAB_TEST$AGE_bis)),length.out = length(levels(TAB_TEST$AGE_bis)))
levels(TAB_TEST$VITESSE_bis)       <- seq(1,length(levels(TAB_TEST$VITESSE_bis)),length.out = length(levels(TAB_TEST$VITESSE_bis)))
levels(TAB_TEST$TYPE_RAYON_COURBE) <- seq(1,length(levels(TAB_TEST$TYPE_RAYON_COURBE)),length.out = length(levels(TAB_TEST$TYPE_RAYON_COURBE)))
levels(TAB_TEST$TRAIN)             <- seq(1,length(levels(TAB_TEST$TRAIN)),length.out = length(levels(TAB_TEST$TRAIN)))
levels(TAB_TEST$UIC)               <- seq(1,length(levels(TAB_TEST$UIC)),length.out = length(levels(TAB_TEST$UIC)))

#Factorisation de Class_Binaire
TAB_bis$Class_Binaire  <- as.factor(TAB_bis$Class_Binaire)
TAB_ECH$Class_Binaire  <- as.factor(TAB_ECH$Class_Binaire)
TAB_TEST$Class_Binaire <- as.factor(TAB_TEST$Class_Binaire)



## PARAMETRE XGBOOST             #############################################################################
#-01- On commence avec les parametres par defaut
registerDoSNOW(cluster)

BIN_XGBOOST_01 <- train(Class_Binaire~., 
                        data = TAB_ECH,
                        method = "xgbTree"
                        )

BIN_XGBOOST_01$method
BIN_XGBOOST_01$modelType
BIN_XGBOOST_01$bestTune
BIN_XGBOOST_01$call

PRED_BIN_XGBOOST_01 <- predict(BIN_XGBOOST_01, TAB_TEST)
Resultat.XG01 <- confusionMatrix(PRED_BIN_XGBOOST_01, TAB_TEST$Class_Binaire)
print(paste0("Resultat XG01 : ", Resultat.XG01$overall[1]*100))



#-02- Parametres par defaut avec Cross Validation (avec repetition)
train.control.02 <- trainControl(method = "repeatedcv",
                                 number = 10,
                                 repeats = 5)

BIN_XGBOOST_02 <- train(Class_Binaire~., 
                        data = TAB_ECH,
                        method = "xgbTree",
                        trControl = train.control.02)

BIN_XGBOOST_02$method
BIN_XGBOOST_02$modelType
BIN_XGBOOST_02$bestTune
BIN_XGBOOST_02$call

PRED_BIN_XGBOOST_02 <- predict(BIN_XGBOOST_02, TAB_TEST)
Resultat.XG02 <- confusionMatrix(PRED_BIN_XGBOOST_02, TAB_TEST$Class_Binaire)
print(paste0("Resultat XG02 : ", Resultat.XG02$overall[1]*100))


#-03- Parametres par defaut avec Cross Validation (sans repetition)
train.control.03 <- trainControl(method = "cv",
                                 number = 10)

BIN_XGBOOST_03 <- train(Class_Binaire~., 
                        data = TAB_ECH,
                        method = "xgbTree",
                        trControl = train.control.03)

BIN_XGBOOST_03$method
BIN_XGBOOST_03$modelType
BIN_XGBOOST_03$bestTune
BIN_XGBOOST_03$call

PRED_BIN_XGBOOST_03 <- predict(BIN_XGBOOST_03, TAB_TEST)
Resultat.XG03 <- confusionMatrix(PRED_BIN_XGBOOST_03, TAB_TEST$Class_Binaire)
print(paste0("Resultat XG03 : ", Resultat.XG03$overall[1]*100))

BIN_XGBOOST_01$bestTune
BIN_XGBOOST_02$bestTune
BIN_XGBOOST_03$bestTune


#-04- Parametres repris des 3 premieres essais
train.control.04 <- trainControl(method = "repeatedcv",
                                 number = 10,
                                 repeats = 5)

tune.grid.04 <- expand.grid(eta = c(0.2, 0.3, 0.4, 0.5),
                            nrounds = c(140, 150, 160),
                            max_depth = 2:5,
                            min_child_weight = 1,
                            colsample_bytree = c(0.5, 0.6, 0.7, 0.8, 0.9),
                            gamma = 0,
                            subsample = c(0.5, 0.75, 1))

BIN_XGBOOST_04 <- train(Class_Binaire~., 
                        data = TAB_ECH,
                        method = "xgbTree",
                        tuneGrid = tune.grid.04,
                        trControl = train.control.04)

BIN_XGBOOST_04$method
BIN_XGBOOST_04$modelType
BIN_XGBOOST_04$bestTune
BIN_XGBOOST_04$call

PRED_BIN_XGBOOST_04 <- predict(BIN_XGBOOST_04, TAB_TEST)
Resultat.XG04 <- confusionMatrix(PRED_BIN_XGBOOST_04, TAB_TEST$Class_Binaire)
print(paste0("Resultat XG04 : ", Resultat.XG04$overall[1]*100))


train.control.05 <- trainControl(method = "repeatedcv",
                                 number = 20,
                                 repeats = 5)

tune.grid.05 <- expand.grid(eta = c(0.2, 0.3, 0.4, 0.5),
                            nrounds = c(140, 150, 160),
                            max_depth = 2:5,
                            min_child_weight = 1,
                            colsample_bytree = c(0.5, 0.6, 0.7, 0.8, 0.9),
                            gamma = 0,
                            subsample = c(0.5, 0.75, 1))

BIN_XGBOOST_05 <- train(Class_Binaire~., 
                        data = TAB_ECH,
                        method = "xgbTree",
                        tuneGrid = tune.grid.05,
                        trControl = train.control.05)


BIN_XGBOOST_05$method
BIN_XGBOOST_05$modelType
BIN_XGBOOST_05$bestTune
BIN_XGBOOST_05$call

PRED_BIN_XGBOOST_05 <- predict(BIN_XGBOOST_05, TAB_TEST)
Resultat.XG05 <- confusionMatrix(PRED_BIN_XGBOOST_05, TAB_TEST$Class_Binaire)
print(paste0("Resultat XG05 : ", Resultat.XG05$overall[1]*100))


#Avec les parametres optimises
tune.grid.06 <- expand.grid(eta = 0.4,
                            nrounds = 150,
                            max_depth = 5,
                            min_child_weight = 1,
                            colsample_bytree = 0.8,
                            gamma = 0,
                            subsample = 0.5)

train.control.06 <- trainControl(method = "repeatedcv",
                                 number = 50,
                                 repeats = 10)

BIN_XGBOOST_06 <- train(Class_Binaire~., 
                        data = TAB_ECH,
                        method = "xgbTree",
                        tuneGrid = tune.grid.06,
                        trControl = train.control.06)


BIN_XGBOOST_06$method
BIN_XGBOOST_06$modelType
BIN_XGBOOST_06$bestTune
BIN_XGBOOST_06$call

PRED_BIN_XGBOOST_06 <- predict(BIN_XGBOOST_06, TAB_TEST)
Resultat.XG06 <- confusionMatrix(PRED_BIN_XGBOOST_06, TAB_TEST$Class_Binaire)
print(paste0("Resultat XG06 : ", Resultat.XG06$overall[1]*100))
































stopCluster(cluster)

#questionr::iorder(TAB_bis)
#reg <- glm(Class_Binaire ~ ., data = TAB_ECH, family = binomial(logit))
#summary(reg)

#drop1(reg, test = "Chisq")
#reg2 <- step(reg)

#=================================================================
# Impute Missing Ages
#=================================================================

# First, transform all feature to dummy variables.
#dummy.vars <- dummyVars(~ ., data = TAB_bis[, -1])
#train.dummy <- predict(dummy.vars, TAB_bis[, -1])
#View(train.dummy)

# Now, impute!
#pre.process <- preProcess(train.dummy, method = "bagImpute")
#imputed.data <- predict(pre.process, train.dummy)
#View(imputed.data)

#TAB_bis$Profil <- imputed.data[, 6]
#View(train)
#imputed.data[, 6]


## TRANSFORMATIONS DES DONNEES   #############################################################################
# binarize all factors
#dmy <- dummyVars(" ~ .", data = TAB_bis)
#TAB_bis <- data.frame(predict(dmy, newdata = TAB_bis))

# what we're trying to predict adults that make more than 50k
#Y <- c('Class_Binaire')
# list of features
#predictors <- names(TAB_bis)[!names(TAB_bis) %in% Y]

# take first 10% of the data only!
#trainPortion <- floor(nrow(TAB_bis)*0.1)

#trainSet <- TAB_bis[ 1:floor(trainPortion/2),]
#testSet <- TAB_bis[(floor(trainPortion/2)+1):trainPortion,]