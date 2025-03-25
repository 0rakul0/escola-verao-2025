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
dir()

base_2 = readRDS("base_1.RDS")
glimpse(base_2)
prop = base_2$prop_esperada[1]
N = sum(base_2$Populacao)
Lim_S_prop = 
  prop + 
  qnorm(p = 0.95)*sqrt(prop*(1-prop)/N)

base_2 = base_2 |> mutate(
  surto = ifelse(
    casos_mes > Lim_S_prop*Populacao,1,0)
)
glimpse(base_2)

base_2 = base_2 |> 
  select(-c(
    casos_mes,
    Populacao,
    Despesa,
    prop_esperada,
    casos_esperados,
    dif_casos
    ))

glimpse(base_2)

setwd(main_dir)
saveRDS(base_2,file = "base_2.RDS")
