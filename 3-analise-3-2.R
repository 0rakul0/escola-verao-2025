rm(list=ls())
main_dir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(main_dir)

library(tidyverse)
library(dplyr)
library(TSLSTMplus)

set.seed(123456789)

sigla = "PR"
unidades = 500 #seq(100,200,20)
valores_k = c(104,112,120,128) #ultimo instante do treino
valores_h = c(4,8,12)

base = readRDS(
  file = 
    paste0("base_3_",sigla,".RDS"))
    

glimpse(base)
base = base |> ungroup()
glimpse(base)

base$TEMP_MEDIA = scale(base$TEMP_MEDIA)[,1]
base$UMIDADE_MEDIA = scale(base$UMIDADE_MEDIA)[,1]
base$PREC_SUM = scale(base$PREC_SUM)[,1]

glimpse(base)

plot(base$num_casos)

base0 = base

#for(k in valores_k){

k = 116
plot(base0$num_casos)
abline(v=k)
#  for(h in valores_h){

h = 4
  
    # MIN_MAE = Inf
    # MAX_R2 = -Inf
    # lagx_otimo = NULL
    # lagy_otimo = NULL
    # lag_otimo = NULL
    # 
    # for(lag_x in 2:8){
    #   
    #   for(lag_y in 2:8){
    #     
    #     for(lag in 1:4){
    #       
    #       k1 = k - 52
    #       maxlag = max(lag_x,lag_y,h)
    #       base1 = base0[1:(k1+maxlag),]
    #       
    #       X = base1 |> select(
    #         TEMP_MEDIA,
    #         UMIDADE_MEDIA,
    #         PREC_SUM)
    #       nomes_coluna = colnames(X)  
    #       N = nrow(X)
    #       m = ncol(X)
    #       
    #       for(l in 1:lag_x){
    #         linhas_vazias = matrix(
    #           NA,
    #           nrow=l,
    #           ncol=m,
    #           dimnames = list(NULL,nomes_coluna))
    #         X_lag = rbind(linhas_vazias,
    #                       X[1:(N-l),])
    #         colnames(X_lag) = paste0(
    #           nomes_coluna,"_",l,"_SEM_ANTES")
    #         base1 = cbind(base1,X_lag)
    #       }
    #       
    #       Y = base1$num_casos
    #       nomes_coluna = colnames(Y)  
    #       N = length(Y)
    #       
    #       for(l in 2:lag_y){
    #         linhas_vazias = rep(NA,l)
    #         Y_lag = c(linhas_vazias,Y[1:(N-l)])
    #         base_y = data.frame(Y_lag)
    #         colnames(base_y) = paste0("num_casos_",l,"_SEM_ANTES")
    #         base1 = cbind(base1,base_y)
    #       }
    #       
    #       glimpse(base1)
    #       base1 = na.omit(base1)
    #       base1 = as_tibble(base1)
    #       
    #       N = nrow(base1)
    #       
    #       
    #       Y = base1$num_casos
    #       X = base1 |> select(-c(
    #         SEM,ANO,ind,num_casos))
    #       
    #       k_ = k1-maxlag
    #       
    #       #modelo para data presente k
    #       lstm <- ts.lstm(
    #         ts = Y[1:k_],
    #         xreg = X[1:k_,],
    #         tsLag = lag,
    #         xregLag = lag,
    #         LSTMUnits = unidades, 
    #         ScaleInput = 'scale',
    #         ScaleOutput = 'scale')
    #       
    #       #previsao no teste para h dias
    #       pred = predict(
    #         lstm,
    #         horizon = h,
    #         xreg = X,
    #         ts = Y[1:k_],
    #         xreg.new = X[(k_+1):(k_+h),])
    #       
    #       pred = ifelse(pred<0,0,pred)
    #       
    #       #medidas de qualidade do ajuste
    #       (MAE = mean(abs(Y[(k_+1):(k_+h)] - pred)))
    #       (R2 = 1 - (sum((Y[(k_+1):(k_+h)] - pred)^2))/
    #           (sum((Y[(k_+1):(k_+h)] - mean(Y[1:k_]))^2))
    #       )
    #       
    #       if(R2 > MAX_R2){
    #         MIN_MAE = MAE
    #         MAX_R2 = R2
    #         lagx_otimo = lag_x
    #         lagy_otimo = lag_y
    #         lag_otimo = lag
    #       }
    #     }
    #   }
    # }
    # 
    
    # lag_x = lagx_otimo
    # lag_y = lagy_otimo
    # lag = lag_otimo

    lag_x = 2
    lag_y = 2
    
    base = base0
    
    X = base |> select(TEMP_MEDIA,
                       UMIDADE_MEDIA,
                       PREC_SUM)
    nomes_coluna = colnames(X)  
    N = nrow(X)
    m = ncol(X)
    
    for(l in 1:lag_x){
      linhas_vazias = matrix(
        NA,
        nrow=l,
        ncol=m,
        dimnames = list(NULL,nomes_coluna))
      X_lag = rbind(linhas_vazias,
                    X[1:(N-l),])
      colnames(X_lag) = paste0(
        nomes_coluna,"_",l,"_SEM_ANTES")
      base = cbind(base,X_lag)
    }
    
    glimpse(base)
    
    Y = base$num_casos
    nomes_coluna = colnames(Y)  
    N = length(Y)
    
    for(l in 1:lag_y){
      linhas_vazias = rep(NA,l)
      Y_lag = c(linhas_vazias,Y[1:(N-l)])
      base_y = data.frame(Y_lag)
      colnames(base_y) = paste0("num_casos_",l,"_SEM_ANTES")
      base = cbind(base,base_y)
    }
    
    glimpse(base)
    head(base)
    base = na.omit(base)
    base = as_tibble(base)
    
    N = nrow(base)

    maxlag = max(lag_x,lag_y)
    k_ = k-maxlag
    
    Y = base$num_casos
    X = base |> select(-c(
      SEM,ANO,ind,num_casos))
    
    #modelo para data presente k
    lstm <- ts.lstm(
      ts = Y[1:k_],
      xreg = X[1:k_,],
      tsLag = 1,
      xregLag = 1,
      LSTMUnits = unidades, 
      ScaleInput = 'scale',
      ScaleOutput = 'scale')
    
    #previsao no teste para h dias
    pred = predict(
      lstm,
      horizon=h,
      xreg = X,
      ts = Y[1:k_],
      xreg.new = 
        X[(k_+1):(k_+h),])
    
    #medidas de qualidade do ajuste
    (MAE = mean(abs(Y[(k_+1):(k_+h)] - pred)))
    (R2 = 1 - (sum((Y[(k_+1):(k_+h)] - pred)^2))/
        (sum((Y[(k_+1):(k_+h)] - mean(Y[1:k_]))^2))
    )
    
    # #Grafico
    # dir()
    # png(file=paste0("plot_",sigla,"_k_",k,"_prev_",h,"_SEM.png"),
    #     width=1600, height=800)
    
    plot(x = 1:N,
         y = Y[1:N],
         type = "b",
         axes=F,
         xlab = "Semanas Epidemiológicas",
         ylab = "",
         cex.main=2,
         cex.lab=1.5,
         main = paste0("Previsão para ",sigla),
    )
    title(
      ylab = "Nº de casos",
      line = 2,cex.lab=1.5) 
    
    box()
    axis(1,
         at = base$ind,
         labels = base$SEM,cex.axis=2)
    axis(3,
         at = c(26,26+52,26+104),
         labels = c("2022","2023","2024"),
         line = -3,lty = 0,cex.axis=2)
    axis(2,
         at = c(0,max(base$num_casos)%/%2,max(base$num_casos)))
    
    
    abline(v=1,lty=2,col="gray")
    abline(v=53,lty=2,col="gray")
    abline(v=105,lty=2,col="gray")
    abline(v=156,lty=2,col="gray")
    abline(v=k_)
    
    #points(x=((k+1):(k+h)),y=pred,col="blue",type = "l",lwd=2)
    points(x=((k):(k+h)),y=c(Y[k],pred),col="blue",type = "b",lwd=2)
    
    text = paste0(
      "horizonte=",h,
      "   lag_x = ",lag_x,
      "   lag_y = ",lag_y,
      "   lag = ",1,
      "   units = ",unidades,
      "   MAE=",round(MAE,2),
      "   R2=",round(R2,2))
    
    mtext(text, side=3, 
          line=0, cex.lab=1,las=1, col="blue")
    
#     dev.off()
# 
#   }
# }
