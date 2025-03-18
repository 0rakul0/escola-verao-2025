#fonte: https://portal.inmet.gov.br/dadoshistoricos

rm(list=ls())

main_dir = dirname(rstudioapi::getSourceEditorContext()$path)

library(tidyverse)

# BASE INMET
setwd(main_dir)
setwd("INMET/BR")
setwd("2022")
dir()
arq = dir()
inmet_2022 = NULL
for(f in arq){
  inmet = read.delim(
    file = f,
    skip = 9,
    sep = ";",
    dec = ",",
    header = F)
  colnames(inmet)[1] = "DATA"
  colnames(inmet)[3] = "PREC_TOTAL"
  colnames(inmet)[8] = "TEMP_AR"
  colnames(inmet)[16] = "UMIDADE_AR"
  inmet = inmet |> 
    select(DATA,
           PREC_TOTAL,
           TEMP_AR,
           UMIDADE_AR)
  inmet$DATA = as.Date(inmet$DATA)
  inmet = inmet |> 
    group_by(DATA) |> summarise(
      PREC_DIA = sum(PREC_TOTAL,na.rm = T),
      TEMP_MEDIA = mean(TEMP_AR,na.rm = T),
      UMIDADE_MEDIA = mean(UMIDADE_AR,na.rm = T),
      ESTACAO = strsplit(f,split = "_")[[1]][4]
    )
  inmet_2022 = 
    inmet_2022 |> rbind(inmet) 
}


setwd(main_dir)
setwd("INMET/BR")
setwd("2023")
arq = dir()
inmet_2023 = NULL
for(f in arq){
  inmet = read.delim(
    file = f,
    skip = 9,
    sep = ";",
    dec = ",",
    header = F)
  colnames(inmet)[1] = "DATA"
  colnames(inmet)[3] = "PREC_TOTAL"
  colnames(inmet)[8] = "TEMP_AR"
  colnames(inmet)[16] = "UMIDADE_AR"
  inmet = inmet |> select(
    DATA,
    PREC_TOTAL,
    TEMP_AR,
    UMIDADE_AR)
  inmet$DATA = as.Date(inmet$DATA)
  inmet = inmet |> 
    group_by(DATA) |> summarise(
      PREC_DIA = sum(PREC_TOTAL,na.rm = T),
      TEMP_MEDIA = mean(TEMP_AR,na.rm = T),
      UMIDADE_MEDIA = mean(UMIDADE_AR,na.rm = T),
      ESTACAO = strsplit(f,split = "_")[[1]][4])
  inmet_2023 = inmet_2023 |> rbind(inmet) 
}

setwd(main_dir)
setwd("INMET/BR")
setwd("2024")
arq = dir()
inmet_2024 = NULL
for(f in arq){
  inmet = read.delim(
    file = f,
    skip = 9,
    sep = ";",
    dec = ",",
    header = F)
  colnames(inmet)[1] = "DATA"
  colnames(inmet)[3] = "PREC_TOTAL"
  colnames(inmet)[8] = "TEMP_AR"
  colnames(inmet)[16] = "UMIDADE_AR"
  inmet = inmet |> select(DATA,PREC_TOTAL,TEMP_AR,UMIDADE_AR)
  inmet$DATA = as.Date(inmet$DATA)
  inmet = inmet |> 
    group_by(DATA) |> summarise(
      PREC_DIA = sum(PREC_TOTAL,na.rm = T),
      TEMP_MEDIA = mean(TEMP_AR,na.rm = T),
      UMIDADE_MEDIA = mean(UMIDADE_AR,na.rm = T),
      ESTACAO = strsplit(f,split = "_")[[1]][4])
  inmet_2024 = inmet_2024 |> rbind(inmet) 
}

setwd(main_dir)
setwd("INMET")
catalogo = read_csv2("CatalogoEstaçõesAutomáticas.csv")
estacao_UF_municipio = 
  catalogo |> 
  select(CD_ESTACAO,SG_ESTADO,DC_NOME) |> 
  rename(ESTACAO = CD_ESTACAO)

inmet_2022 = inmet_2022 |> 
  left_join(
    estacao_UF_municipio,
    by = "ESTACAO")
inmet_2023 = inmet_2023 |> 
  left_join(
    estacao_UF_municipio,
    by = "ESTACAO")
inmet_2024 = inmet_2024 |> 
  left_join(
    estacao_UF_municipio,
    by = "ESTACAO")

base_inmet = rbind(
  inmet_2022,
  inmet_2023,
  inmet_2024)

setwd(main_dir)
setwd("INMET")
dir()
saveRDS(base_inmet,file = "base_inmet.RDS")
glimpse(base_inmet)
which(is.na(base_inmet$SG_ESTADO))
base_inmet[84851,]
