# Escola de Verão 2025

Este repositório contém os scripts desenvolvidos para o projeto da Escola de Verão 2025, que visa integrar bases de dados públicas relacionadas à saúde, demografia e clima, e aplicar técnicas de análise exploratória e **aprendizado de máquina (Machine Learning)** para investigar fatores que influenciam os casos de dengue no Brasil.

---

## 🎯 Motivação

O aumento dos casos de dengue é uma preocupação recorrente de saúde pública no Brasil. Dada a natureza complexa do problema, é fundamental explorar possíveis associações entre os casos notificados e fatores estruturais (como IDH, população, PIB) e ambientais (temperatura, precipitação etc.). A proposta é investigar, por meio de dados e técnicas estatísticas/computacionais, **quais fatores explicam ou ajudam a prever os surtos de dengue**.

---

## 🧠 Introdução ao Problema de Machine Learning

Conforme apresentado na introdução teórica deste projeto, um problema de Machine Learning (ML) consiste em:

> “Extrair informações e/ou encontrar padrões em uma base de dados a partir de análises estatísticas, formulações matemáticas e métodos computacionais.”  
> — *Jessica Kubrusly, UFF*

Neste projeto, os dados integrados fornecem uma excelente oportunidade para formular hipóteses, aplicar modelos supervisionados (como regressão e classificação com XGBoost) e até modelos de séries temporais (como LSTM), com o objetivo de responder a perguntas como:

- **Regressão:**  
  Quais variáveis explicam a quantidade de casos de dengue em um município durante um determinado mês?

- **Classificação:**  
  É possível prever se um município terá um número de casos acima de um limite esperado?

- **Previsão temporal:**  
  Podemos prever a quantidade de casos em uma semana com base em dados de semanas anteriores?

Esses problemas são tratados no decorrer dos scripts de análise, conforme descrito a seguir.

---
## Estrutura do Repositório

- **1-leitura-base-dengue.R**  
  Script responsável por acessar e baixar os dados de dengue para os anos de 2022, 2023 e 2024 utilizando o pacote `microdatasus`. Os dados são agrupados por data de notificação, UF e município, e salvos em arquivos RDS.

- **1-leitura-base-ibge.R**  
  Script que processa os indicadores municipais disponibilizados pelo IBGE. A partir dos arquivos CSV presentes na pasta `IBGE/Indicadores`, o script realiza a limpeza dos textos (substituindo entidades HTML por caracteres normais), seleciona variáveis de interesse (como nome do município, área, população, IDHM, receita, despesa e PIB) e converte as colunas para os tipos apropriados. O resultado é salvo em um arquivo RDS (`indicadores_mun_BR.RDS`).

- **1-leitura-base-inmet.R**  
  (Presumido) Script para a leitura e tratamento dos dados meteorológicos do INMET. Assim como os demais scripts de leitura, este deverá importar, limpar e salvar os dados relevantes para posterior análise.

- **2-juncao-bases.R**  
  Script que realiza a integração das bases de dados provenientes dos scripts de leitura (dengue, IBGE e INMET). A junção possibilita a análise conjunta dos indicadores epidemiológicos, demográficos e meteorológicos.

- **3-analise-*.R**  
  Conjunto de scripts (divididos em “3-analise-1-1.R”, “3-analise-1-2.R”, “3-analise-2-1.R”, “3-analise-2-2.R”, “3-analise-3-1.R” e “3-analise-3-2.R”) que realizam diferentes análises exploratórias e/ou modelagens sobre os dados integrados. Cada script pode abordar aspectos distintos, como análise temporal, espacial ou de correlações entre as variáveis.

- **Apresentacao-O que é um problema de Machine Learnig.pdf**  
  Apresentação que possivelmente discute os fundamentos e a aplicação de Machine Learning para a resolução do problema estudado.

- **Pasta DENGUE, IBGE e demais diretórios**  
  Contêm os arquivos brutos e intermediários (como os dados salvos em RDS) que são gerados e utilizados pelos scripts.

## Pré-requisitos

Antes de executar os scripts, certifique-se de ter:

- [R](https://www.r-project.org/) (recomenda-se a versão mais recente)
- [RStudio](https://www.rstudio.com/) (opcional, mas recomendado para facilitar o fluxo de trabalho)
- Os seguintes pacotes R instalados:
  - `tidyverse`  
    ```r
    install.packages("tidyverse")
    ```
  - `microdatasus`  
    ```r
    install.packages("remotes")  # se ainda não estiver instalado
    remotes::install_github("rfsaldanha/microdatasus")
    ```
  - Outros pacotes que possam ser necessários para análise (verifique os scripts para dependências adicionais)

## Como Utilizar

1. **Clonar o Repositório**  
   Clone este repositório para o seu ambiente local:
   ```bash
   git clone https://github.com/jessicakubrusly/escola-verao-2025.git
   ```

2. **Organização das Pastas**  
   Certifique-se de que as pastas **DENGUE**, **IBGE** (e seus subdiretórios, como `IBGE/Indicadores`) estejam organizadas conforme esperado. Esses diretórios contêm os arquivos brutos necessários para o processamento.

3. **Execução dos Scripts de Leitura**  
   - Abra cada um dos scripts de leitura (por exemplo, `1-leitura-base-dengue.R`, `1-leitura-base-ibge.R` e `1-leitura-base-inmet.R`) no RStudio.
   - Cada script define o diretório de trabalho com base na localização do próprio arquivo (usando `rstudioapi::getSourceEditorContext()$path`). Verifique se o RStudio está aberto e os arquivos estão no local correto.
   - Execute os scripts para baixar, processar e salvar os dados em arquivos RDS.

4. **Integração das Bases**  
   - Após gerar os arquivos RDS dos diferentes conjuntos de dados, execute o script `2-juncao-bases.R` para realizar a junção das bases.
   - O script deverá gerar uma base integrada para análise.

5. **Realização das Análises**  
   - Execute os scripts de análise (localizados na pasta “3-analise-…”) conforme a ordem desejada ou a sequência sugerida.
   - Estes scripts podem gerar gráficos, tabelas e outros resultados exploratórios. Analise os outputs e ajuste parâmetros, se necessário.

## Considerações Finais

Este repositório oferece uma abordagem prática para o estudo de um problema real de saúde pública, integrando dados de diversas fontes e aplicando ferramentas modernas de ciência de dados. É ideal para quem deseja aprender mais sobre análise de dados públicos, visualização, e técnicas de modelagem com R.

- **Performance:** Note que o download dos dados (especialmente no script de dengue) pode levar alguns minutos dependendo da conexão e do volume de dados. Os tempos de execução são informados nos scripts.
- **Dependências e Versões:** Caso haja problemas com pacotes ou versões, consulte a documentação dos pacotes utilizados ou entre em contato com o mantenedor do repositório.
- **Customização:** Sinta-se à vontade para adaptar os scripts às suas necessidades ou para realizar análises adicionais utilizando a base integrada gerada.
