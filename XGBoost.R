#---------------------------------------------------
#                               XGBOOST
#"""""""""""""""""""""""""""""""""""""""""""

install.packages("xgboost")
library(xgboost)


# Full data set
X<- as.matrix(AMIRA[,-19])
data_label <- X$TYPE_CLASSEMENTO
data_matrix <- xgb.DMatrix(data = as.matrix(X), label = data_label)
# split train data and make xgb.DMatrix
train_data   <- data_variables[train_index,]
train_label  <- data_label[train_index]
train_matrix <- xgb.DMatrix(data = train_data, label = train_label)
# split test data and make xgb.DMatrix
test_data  <- data_variables[-train_index,]
test_label <- data_label[-train_index]
test_matrix <- xgb.DMatrix(data = test_data, label = test_label)


MOD_GBOOST<-xgboost(data = X, 
        label = c("TYPE_CLASSEMENTO","TYPE_CLASSEMENTX1","TYPE_CLASSEMENTX2"), 
        eta = 0.1,
        max_depth = 15, 
        nround=25, 
        subsample = 0.5,
        colsample_bytree = 0.5,
        seed = 1444,
        eval_metric = "merror",
        objective = "multi:softprob",
        num_class = 12,
        nthread = 3
)