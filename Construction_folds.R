

## création des folds 10 folds où dedans y a une meme répartition de modalité O, X1 et X2

FOLDS_func<-function(X,a){
#X<-BASE_Multi_train
rownames(X)<-NULL

X_O<-X[which(X$TYPE_CLASSEMENT=="O"),]
X_1<-X[which(X$TYPE_CLASSEMENT=="X1"),]
X_2<-X[which(X$TYPE_CLASSEMENT=="X2"),]
rownames(X_O)<-NULL
rownames(X_1)<-NULL
rownames(X_2)<-NULL

CROSS<-function(X){
set.seed(a)
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
#rownames(X_fin)<-NULL
return(X_fin)
}