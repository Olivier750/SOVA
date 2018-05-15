

## création des folds 10 folds où dedans y a une meme répartition de modalité O, X1 et X2

X<-BASE_Multi_train
rownames(X)<-NULL
X_O<-X[which(X$TYPE_CLASSEMENT=="O"),]
X_1<-X[which(X$TYPE_CLASSEMENT=="X1"),]
X_2<-X[which(X$TYPE_CLASSEMENT=="X2"),]
rownames(X_O)<-NULL
rownames(X_1)<-NULL
rownames(X_2)<-NULL

CROSS<-function(X){
set.seed(1444)
ID<-sample(1:nrow(X),nrow(X))
a<- seq(1,nrow(X),round((nrow(X)/10))+1)
X$fold<-10
for (i in 1:9){
  X$fold[ID[a[i]:(a[i+1]-1)]]<-i
}
return(X)
}
X_O<-CROSS(X_O)
X_1<-CROSS(X_1)
X_2<-CROSS(X_2)

X_fin<-rbind(X_O,X_1,X_2)
X_fin<-X_fin[order(X_fin$fold),]
rownames(X_fin)<-NULL


# créer la fonction de la cross validation


  performances <- c()
  
  # Création de la boucles sur les 10 folders
  for (i in 1:10){
    
    # Train qui contient 9 blocs
    training_set <- X_fin[X_fin$fold != i,]
   # test qui contient 1 bloc
    testing_set <-  X_fin[X_fin$fold == i,]
    
    ##  model
    
    model<- #### Votre modèle
    ## Test model
    
    # Predict 
    predicted <- predict(model, testing_set)
   
    ## changer les proba en indicateurs
    
    ## la matrice de confusion
    
    # K<-xtabs(....)
    
    # calcule de l'erreur
    ERREUR_MOD<-(K[1,2]+K[2,1])/(K[1,2]+K[2,1]+K[1,1]+K[2,2])
    # Ajouter à la liste ->> à la fin on obtient 10 : on les moyenne
    performances[i] <- ERREUR_MOD
  }
  
  # 
  c('ERREUR' = mean(performances))

