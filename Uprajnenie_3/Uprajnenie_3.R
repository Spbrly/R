# Библиотеки необходимые для выполнени задачи
library('shiny')               # создание интерактивных приложений
library('lattice')             # графики lattice
library('data.table')          # работаем с объектами "таблица данных"
library('ggplot2')             # графики ggplot2
library('dplyr')               # трансформации данных
library('lubridate')           # работа с датами, ceiling_date()
library('zoo')                 # работа с датами, as.yearmon()

# функция, реализующая API (источник: UN COMTRADE)
source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")

# Получаем данные с UN COMTRADE за период 2010-2020 года, по следующим кодам
code = c('0201', '0202', '0203', '0204', '0205')
df = data.frame()
for (i in code){
  print(i)
  for (j in 2010:2020){
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = 643,
                       ps = as.character(j), freq = "M",
                       cc = i, fmt = 'csv')
    df <- rbind(df, s1$data)
    print(j)
  }
}

data.dir <- './data'

# Создаем директорию для данных
if (!file.exists(data.dir)) {
  dir.create(data.dir)
}

# Загружаем полученные данные в файл, чтобы не выгружать их в дальнейшем заново
file.name <- paste('./data/un_comtrade.csv', sep = '')
write.csv(df, file.name, row.names = FALSE)

write(paste('Файл',
            paste('un_comtrade.csv', sep = ''),
            'загружен', Sys.time()), file = './data/download.log', append=TRUE)

# Загружаем данные из файла
df <- read.csv('./data/un_comtrade.csv', header = T, sep = ',')

# Оставляем  только те столбцы, которые понядобятся в дальше
df <- df[, c(2, 8, 10, 22, 32)]

df

# СНГ без Белоруссии и Казахстана
CIS <- c('Armenia', 'Kyrgyzstan', 'Azerbaijan', 'Rep. of Moldova', 'Tajikistan', 'Turkmenistan', 'Uzbekistan', 'Ukraine')
# Таможенный союз России, Белоруссии и Казахстана
customs_union <- c('Russian Federation', 'Belarus', 'Kazakhstan')

new.df <- data.frame(Year = numeric(), Trade.Flow = character(), Reporter = character(),
                        Trade.Value..US.. = numeric(), Group = character())
new.df <- rbind(new.df, cbind(df[df$Reporter %in% CIS, ], data.frame(Group = 'СНГ, без Казахстана и Белоруссии')))
new.df <- rbind(new.df, cbind(df[df$Reporter %in% customs_union, ], data.frame(Group = 'Таможенный союз Казахстан, Россия, Белорусь')))
new.df <- rbind(new.df, cbind(df[!(df$Reporter %in% CIS) & !(df$Reporter %in% customs_union), ],
                                                data.frame(Group = 'Остальные страны')))

new.df

file.name <- paste('./data/un_comtrade_2.csv', sep = '')
write.csv(new.df, file.name, row.names = FALSE)

new.df <- read.csv('./data/un_comtrade_2.csv', header = T, sep = ',')

# Код продукта
code <- as.character(unique(new.df$Commodity.Code))
names(code) <- code
code <- as.list(code)
code

# Торговые потоки
trade.flow <- as.character(unique(new.df$Trade.Flow))
names(trade.flow) <- trade.flow
trade.flow <- as.list(trade.flow)
trade.flow

DF <- new.df[new.df$Commodity.Code == code[2] & new.df$Trade.Flow == trade.flow[1], ]
DF

gp <- ggplot(data = DF, aes(x = Trade.Value..US.., y = Group, group = Group, color = Group))
gp <- gp + geom_boxplot() + coord_flip() + scale_color_manual(values = c('red', 'blue', 'green'),
                                                              name = 'Страны-поставщики')
gp <- gp + labs(title = 'Коробчатые диаграммы разброса суммарной стоимости поставок по фактору\n "вхождение страны-поставщика в объединение"',
                x = 'Сумма стоимости поставок', y = 'Страны')
gp

# Запуск приложения
runApp('./comtrade_un_app', launch.browser = TRUE,
       display.mode = 'showcase')
