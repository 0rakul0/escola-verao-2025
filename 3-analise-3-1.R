rm(list=ls())
main_dir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(main_dir)

codigo = "41"
sigla = "PR"

library(tidyverse)
library(dplyr)

setwd("DENGUE")
dir()
dengue_BR_2022 = readRDS("dengue_BR_2022.RDS")
dengue_BR_2023 = readRDS("dengue_BR_2023.RDS")
dengue_BR_2024 = readRDS("dengue_BR_2024.RDS")
dengue_BR = rbind(
  dengue_BR_2022,
  dengue_BR_2023,
  dengue_BR_2024)

glimpse(dengue_BR)
base_3 = 
  dengue_BR |> filter(
    SG_UF_NOT==codigo) |> 
  mutate(
    SEM = epiweek(DT_NOTIFIC),
    ANO = ifelse(
      SEM == 1 & month(DT_NOTIFIC) == 12,
      year(DT_NOTIFIC) + 1,
      ifelse(
        SEM == 52 & month(DT_NOTIFIC) == 1,
        year(DT_NOTIFIC) - 1,
        year(DT_NOTIFIC))
    ) 
  ) |> ungroup() 

glimpse(base_3)

base_3 = base_3 |> 
  group_by(SEM,ANO) |> 
  mutate(num_casos = sum(casos))

glimpse(base_3)

base_3 = base_3 |> 
  select(c(SEM,ANO,num_casos)) |> 
  unique()

glimpse(base_3)

base_3 = base_3 |> 
  arrange(SEM) |> 
  arrange(ANO) |>
  cbind(ind = 1:nrow(base_3))

plot(base_3$num_casos)
base_3

setwd(main_dir) 
setwd("INMET")
dir()
base_inmet = readRDS("base_inmet.RDS")
colnames(base_inmet)



base_inmet_sem = base_inmet |> 
  filter(SG_ESTADO==sigla) |> 
  mutate(
    SEM = epiweek(DATA),
    ANO = ifelse(
      SEM == 1 & month(DATA) == 12,
      year(DATA) + 1,
      ifelse(
        SEM == 52 & month(DATA) == 1,
        year(DATA) - 1,
        year(DATA))
    )
  ) |> ungroup()

glimpse(base_inmet_sem)

base_inmet_sem = base_inmet_sem |> 
  group_by(SEM,ANO) |> 
  summarise(
    TEMP_MEDIA = mean(TEMP_MEDIA,na.rm = T),
    UMIDADE_MEDIA = mean(UMIDADE_MEDIA,na.rm = T),
    PREC_SUM = sum(PREC_DIA,na.rm = T)
  ) |> ungroup()

glimpse(base_inmet_sem)
base_inmet_sem = 
  base_inmet_sem |> 
  arrange(SEM) |> 
  arrange(ANO)

glimpse(base_inmet_sem)
tail(base_inmet_sem)
base_3 = base_3 |> 
  left_join(base_inmet_sem)

plot(base_3$num_casos)

setwd(main_dir)
dir()
saveRDS(base_3,paste0("base_3_",sigla,".RDS"))
