#queremos responder a pergunta:
#considerando que a quantidade de casos de dengue no ano em 
#um municipio seja funcao das condicoes meteorologia das 
#semanas anteriores e tambem dos indicadores sociais
#será que conseguimos entender quais desses fatores
#sao mais relevantes para explicar o numero de casos?

#base trabalhada: 
#unidades amostrais = mes e municipios brasileiros
#covariavais:
# - ano (A)
# - mes (M)
# - indicadores do municipio
# - quantidade de chuva no mes M-1
# - temperatura media no mes M-1
# 
#variavel alvo:
# - numero de casos de dengue no mes M


rm(list=ls())
main_dir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(main_dir)

library(tidyverse)
library(dplyr)

setwd("DENGUE")
dir()
dengue_BR_2022 = readRDS("dengue_BR_2022.RDS")
dengue_BR_2023 = readRDS("dengue_BR_2023.RDS")
dengue_BR_2024 = readRDS("dengue_BR_2024.RDS")

base_1 = 
  dengue_BR_2022 |> 
  rbind(dengue_BR_2023)|> 
  rbind(dengue_BR_2024)|>
  mutate(
    ANO = year(DT_NOTIFIC),
    MES = month(DT_NOTIFIC)) |> 
  group_by(MES,ANO,ID_MUNICIP) |> 
  summarise(casos_mes = sum(casos))
glimpse(base_1)


setwd(main_dir) 
setwd("IBGE")
dir()
indicadores_mun_BR_com_EM = 
  readRDS("indicadores_mun_BR_com_EM.RDS")
dim(indicadores_mun_BR_com_EM)
colnames(indicadores_mun_BR_com_EM)

base_1 = base_1 |> left_join(
  indicadores_mun_BR_com_EM,
  by = "ID_MUNICIP")
glimpse(base_1)

setwd(main_dir) 
setwd("INMET")
dir()
base_inmet = readRDS("base_inmet.RDS")
colnames(base_inmet)

base_inmet_mes = base_inmet |> 
  mutate(
    ANO = year(DATA),
    MES = month(DATA)) |> 
  group_by(MES,ANO,ESTACAO) |> 
  summarise(
    TEMP_MEDIA_MES = mean(TEMP_MEDIA,na.rm = T),
    UMIDADE_MEDIA_MES = mean(UMIDADE_MEDIA,na.rm = T),
    PREC_MES = sum(PREC_DIA,na.rm = T)
    ) |> ungroup()

glimpse(base_inmet_mes)

#definir chave para juntar
#MES_ANO_ESTACAO
base_inmet_mes = 
  base_inmet_mes |> mutate(
  CHAVE = 
    paste0(ESTACAO,"_",
           ifelse(MES!=12,
                  paste0(MES+1,"_",ANO),
                  paste0("1","_",ANO+1)
                  )
          )
  ) |> select(-c(MES,ANO,ESTACAO)) 
glimpse(base_inmet_mes)

base_1 = base_1 |> 
  mutate(CHAVE = 
           paste0(
             EST_PROXIMA,
             "_",
             MES,
             "_",
             ANO))

base_1 = base_1 |> left_join(
  base_inmet_mes,
  by = "CHAVE")

base_1 = base_1 |> select(-c(CHAVE,
                             NOME_MUNICIP,
                             ID_MUNICIP7,
                             SG_UF_NOT))

glimpse(base_1)
base_1$MES = as.factor(base_1$MES)
base_1$ANO = as.factor(base_1$ANO)
base_1$UF = as.factor(base_1$UF)
glimpse(base_1)
dim(base_1)


library(naniar)

dim(base_1)
gg_miss_var(base_1)
summary(n_miss_row(base_1))
max = max(n_miss_row(base_1))
linhas = which(n_miss_row(base_1) == max)
base_1 = base_1[-linhas,]


gg_miss_var(base_1)
summary(n_miss_row(base_1))
linhas = which(n_miss_row(base_1) != 0)
length(linhas)
dim(base_1)
length(linhas)/nrow(base_1)
base_1 = base_1[-linhas,]

gg_miss_var(base_1)
summary(n_miss_row(base_1))

dim(base_1)

glimpse(base_1)

table(base_1$MES)
table(base_1$ANO)
table(base_1$UF)

hist(base_1$casos_mes)
summary(base_1$casos_mes)
which.max(base_1$casos_mes)
base_1[28795,]

base_1 = 
  base_1 |> 
  group_by(MES,ANO) |> 
  mutate(
    prop_esperada = 
      sum(casos_mes)/sum(Populacao)
) |> ungroup()
 

base_1 = 
  base_1 |>
  mutate(
    casos_esperados = 
      prop_esperada*Populacao,
    Y = casos_mes - casos_esperados
    )
glimpse(base_1)

hist(base_1$Y)
summary(base_1$Y)
boxplot(base_1$Y)
sort(base_1$Y,decreasing = T)[1:20]
linhas = which(base_1$Y > 25000)
base_1 = base_1[-linhas,]

sort(base_1$Y)[1:20]
linhas = which(base_1$Y < - 18000)
base_1 = base_1[-linhas,]

hist(base_1$Y)
summary(base_1$Y)
boxplot(base_1$Y)


hist(base_1$Y - min(base_1$Y))
summary(base_1$Y- min(base_1$Y))
boxplot(base_1$Y)


setwd(main_dir)
dir()
saveRDS(base_1,file = "base_1.RDS")
