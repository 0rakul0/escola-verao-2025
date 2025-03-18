rm(list=ls())
main_dir = dirname(rstudioapi::getSourceEditorContext()$path)

library(tidyverse)
library(geosphere)

setwd(main_dir)
setwd("IBGE")
dir()
lat_lon_mun = read_csv("munic_lat_lon.csv")
indicadores_mun_BR = readRDS("indicadores_mun_BR.RDS")

setwd(main_dir)
setwd("INMET")
dir()
estacoes = read_csv2("CatalogoEstaçõesAutomáticas.csv")

#vamos criar na planilha indicadores_mun_BR uma nova coluna:
# EST_PROXIMA = estacao mais proxima
EST_PROXIMA = NULL
for(mun in 1:nrow(indicadores_mun_BR)){
  #mun = 1
  cod = indicadores_mun_BR$ID_MUNICIP[mun]
  linha_mun = lat_lon_mun |> 
    filter(GEOCODIGO_MUNICIPIO==cod)
  if(nrow(linha_mun)!=0){
    lat1 = linha_mun$LATITUDE
    lon1 = linha_mun$LONGITUDE
    
    d = NULL
    for(j in 1:nrow(estacoes)){
      lat2 = estacoes$VL_LATITUDE[j] 
      lon2 = estacoes$VL_LONGITUDE[j] 
      d[j] = geosphere::distHaversine(
        cbind(lon1,lat1),cbind(lon2,lat2))
    }
    
    l = which.min(d)
    EST_PROXIMA[mun] = estacoes$CD_ESTACAO[l]  
  } else {
    EST_PROXIMA[mun] = NA
  }
  
}
indicadores_mun_BR_com_EM = 
  cbind(indicadores_mun_BR,EST_PROXIMA)
indicadores_mun_BR_com_EM = as_tibble(indicadores_mun_BR_com_EM)
 
#A chave que junta a base de indicadores 
# com a base do INMET eh EST_PROXIMA

# precisamos ajustar a chave que junta as
# bases de indicadores com dengue
# a coluna ID_MUNICIP das duas bases
# estao em formatos distintos
# para a base dengue temos 6 digitos
# e para a base inidcadores 7 digitos
# acredito que o ultimo digito 
# 

indicadores_mun_BR_com_EM = 
  indicadores_mun_BR_com_EM |> 
  rename("ID_MUNICIP7"="ID_MUNICIP")

indicadores_mun_BR_com_EM = indicadores_mun_BR_com_EM |> 
  mutate(
    ID_MUNICIP = str_sub(
      ID_MUNICIP7,
      start = 1,
      end = 6))
colnames(indicadores_mun_BR_com_EM)

setwd(main_dir)
setwd("IBGE")
dir()
saveRDS(
  indicadores_mun_BR_com_EM,
  "indicadores_mun_BR_com_EM.RDS")

