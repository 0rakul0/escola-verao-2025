#fonte: https://www.ibge.gov.br/cidades-e-estados/rj.html

rm(list=ls())

main_dir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(main_dir)
dir()

library(tidyverse)

substituicao = function(x){
  padrao = c("&aacute;","&eacute;","&iacute;","&oacute;","&uacute;",
             "&Aacute;","&Eacute;","&Iacute;","&Oacute;","&Uacute;",
             "&ccedil;","&atilde;",
             "&Ccedil;","&Atilde;",
             "&acirc;","&ecirc;","&ocirc;",
             "&Acirc;","&Ecirc;","&Ocirc;")
  substi = c("a","e","i","o","u",
             "A","E","I","O","U",
             "c","a","C","A",
             "a","e","o",
             "A","E","O")
  n = length(padrao)
  for(i in 1:n){
    x = str_replace_all(x,
                        pattern = padrao[i],
                        replacement = substi[i]
    )
  }
  return(x)
}

setwd("IBGE/Indicadores")
dir()
arq = dir()
indicadores_mun_BR = NULL
for(f in arq){
  indicadores_mun = read_delim(
    file=f,delim = ",",skip = 1)
  Mindicadores_mun = as.matrix(indicadores_mun)
  Mindicadores_mun = apply(
    Mindicadores_mun, 
    MARGIN = 2,
    FUN =  "substituicao")
  indicadores_mun = as.tibble(Mindicadores_mun)
  indicadores_mun = indicadores_mun[,c(1,2,5,6,7,9,11,12,13)]
  colnames(indicadores_mun) = 
    c("NOME_MUNICIP",
      "ID_MUNICIP",
      "Area",
      "Populacao",
      "DensidadeDemo",
      "IDHM",
      "Receita",
      "Despesa",
      "PIB")
  indicadores_mun$Area = as.numeric(indicadores_mun$Area)
  indicadores_mun$Populacao = as.numeric(indicadores_mun$Populacao)
  indicadores_mun$DensidadeDemo = as.numeric(indicadores_mun$DensidadeDemo)
  indicadores_mun$IDHM = as.numeric(indicadores_mun$IDHM)
  indicadores_mun$Receita = as.numeric(indicadores_mun$Receita)
  indicadores_mun$Despesa = as.numeric(indicadores_mun$Despesa)
  indicadores_mun$PIB = as.numeric(indicadores_mun$PIB)
  
  SG_UF_NOT = str_sub(f,1,2)
  UF = str_sub(f,4,5)
  indicadores_mun = 
    indicadores_mun |> cbind(SG_UF_NOT,UF)
  indicadores_mun_BR = 
    indicadores_mun_BR |> rbind(indicadores_mun)
}

indicadores_mun_BR = as_tibble(indicadores_mun_BR)
setwd(main_dir)
setwd("IBGE")
saveRDS(indicadores_mun_BR,file = "indicadores_mun_BR.RDS")

