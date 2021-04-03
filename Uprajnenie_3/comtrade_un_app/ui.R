library('shiny')
library('RCurl')

URL <- 'https://raw.githubusercontent.com/Spbrly/R/main/Uprajnenie_3/data/un_comtrade_2.csv'

df <- read.csv(URL)

# Торговые потоки, переменная для фильтра фрейма
trade.flow <- as.character(unique(df$Trade.Flow))
names(trade.flow) <- trade.flow
trade.flow <- as.list(trade.flow)

shinyUI(
  pageWithSidebar(
    headerPanel("Коробчатые диаграммы разброса суммарной стоимости поставок по фактору\n «вхождение страны-поставщика в объединение»"),
    sidebarPanel(
      # Выбор кода продукции
      selectInput('sp.to.plot',
                  'Товар: ',
                  list('Мясо крупного рогатого скота; свежее или охлажденное' = '201',
                       'Мясо крупного рогатого скота; замороженное' = '202',
                       'Свинина; свежая, охлажденная или замороженная' = '203',
                       'Мясо овец или коз; свежее, охлажденное или замороженное' = '204',
                       'Мясо; лошадей, ослов, мулов или лошаков, свежее, охлажденное или замороженное' = '205'),
                  selected = '201'),
      # Выбор торгового потока
      selectInput('trade.to.plot',
                  'Торговый поток:',
                  trade.flow),
      # Период, по годам
      sliderInput('year.range', 'Года:',
                  min = 2010, max = 2020, value = c(2010, 2020),
                  width = '100%', sep = '')
    ),
    mainPanel(
      plotOutput('sp.ggplot')
    )
  )
)
