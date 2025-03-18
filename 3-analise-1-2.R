
rm(list=ls())

main_dir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(main_dir)
dir()

base = readRDS("base_2.RDS")
glimpse(base)

#Correlacao entre variaveis
cor(base |> select(-c(MES,ANO,ID_MUNICIP,UF,EST_PROXIMA)))
#Nao considerar
#Despesa
#Populacao

max(abs(cor(base |> select(-c(
  MES,ANO,ID_MUNICIP,UF,EST_PROXIMA,surto))) - 
    diag(1,9)
))

#padronizar as variaveis continuas
glimpse(base)
base$Area = scale(base$Area)[,1]
base$DensidadeDemo = scale(base$DensidadeDemo)[,1]
base$IDHM = scale(base$IDHM)[,1]
base$Receita = scale(base$Receita)[,1]
base$PIB = scale(base$PIB)[,1]
base$TEMP_MEDIA_MES = scale(base$TEMP_MEDIA_MES)[,1]
base$UMIDADE_MEDIA_MES = scale(base$UMIDADE_MEDIA_MES)[,1]
base$PREC_MES = scale(base$PREC_MES)[,1]

base$surto

base_ind = base |> select(
  Area,
  DensidadeDemo,
  IDHM,
  Receita,
  PIB)
glimpse(base_ind)

base_inmet = base |> select(
  TEMP_MEDIA_MES,
  UMIDADE_MEDIA_MES,
  PREC_MES            
)
glimpse(base_inmet)


library(randomForest)
set.seed(123456789)
RF_ind <- randomForest(
  x = base_ind, 
  y = base$Y,
  ntree=50)
importancia = RF_ind$importance
sort(importancia[,1],
     decreasing = TRUE)

RF_inmet <- randomForest(
  x = base_inmet, 
  y = base$Y,
  ntree=50)
importancia = RF_inmet$importance
sort(importancia[,1],
     decreasing = TRUE)


library(xgboost)
set.seed(123456789)
X = base_ind
M_X = model.matrix(~. ,data = X)[,-1]
XGB_ind <- xgboost(
  data = M_X,
  label = base$surto,
  objective = "binary:logistic",
  nrounds = 50)
importancia = xgb.importance(
  model = XGB_ind)
importancia

X = base_inmet
M_X = model.matrix(~. ,data = X)[,-1]
XGB_inmet <- xgboost(
  data = M_X,
  label = base$surto,
  objective = "binary:logistic",
  nrounds = 50)
importancia = xgb.importance(
  model = XGB_inmet)
importancia

library(rpart)
library("rpart.plot")

tree <- rpart(
  Y ~ .,
  data = data.frame(
    Receita = base_ind$Receita,
    Y = as.factor(base$surto)),
  ) 
rpart.plot(
  tree,type=5,cex=1)


tree <- rpart(
  Y ~ .,
  data = data.frame(
    TEMP = base_inmet$TEMP_MEDIA_MES,
    Y = as.factor(base$surto)))
rpart.plot(
  tree,type=5,cex=1)
