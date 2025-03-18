rm(list=ls())
main_dir = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(main_dir)
setwd("DENGUE")

#BASE DENGUE
#todos o brasil, sera agregado por semana epo
#anos 2022, 2023 e 2024

#install.packages("remotes")
#remotes::install_github("rfsaldanha/microdatasus")


# Carregar o pacote microdatasus
library(tidyverse)
library(microdatasus)

# Baixar os dados do Brasil 

#2022
ti = Sys.time()
dengue_BR_2022 <- fetch_datasus(year_start = 2022, 
                                year_end = 2022,
                                information_system = "SINAN-DENGUE",
                                timeout = 1000)
tf = Sys.time()
tf-ti #2.194594 mins
dengue_BR_2022 <- dengue_BR_2022 |> 
  group_by(DT_NOTIFIC,SG_UF_NOT,ID_MUNICIP) |> 
  summarise(casos = n()) 
saveRDS(dengue_BR_2022,file = "dengue_BR_2022.RDS")
rm(dengue_BR_2022)





#2023
ti = Sys.time()
dengue_BR_2023 <- fetch_datasus(year_start = 2023, 
                                year_end = 2023,
                                information_system = "SINAN-DENGUE")
tf = Sys.time()
tf-ti #Time difference of 56.70404 secs
dengue_BR_2023 <- dengue_BR_2023 |> 
  group_by(DT_NOTIFIC,SG_UF_NOT,ID_MUNICIP) |> 
  summarise(casos = n()) 
saveRDS(dengue_BR_2023,file = "dengue_BR_2023.RDS")
rm(dengue_BR_2023)



#2024
ti = Sys.time()
dengue_BR_2024 <- fetch_datasus(year_start = 2024, 
                                year_end = 2024,
                                information_system = "SINAN-DENGUE",
                                timeout = 1000)
tf = Sys.time()
tf-ti  #Time difference of 4.32186 mins

dengue_BR_2024 <- dengue_BR_2024 |> 
  group_by(DT_NOTIFIC,SG_UF_NOT,ID_MUNICIP) |> 
  summarise(casos = n()) 

saveRDS(dengue_BR_2024,
        file = "dengue_BR_2024.RDS")
rm(dengue_BR_2024)
