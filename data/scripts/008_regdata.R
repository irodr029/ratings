#####Regression Data
#This script creates data for regging

#Packages for data cleaning
library('WDI')
library('reshape2')
library('dplyr')
library('lubridate')
library('data.table')
library('zoo')
library('ggplot2')
library('stargazer')

#Define input and output locations
loc_data_input <- "~/Desktop/Ratings/data/input"
loc_data_output <- "~/Desktop/Ratings/data/output"

#Read in all the input data files in working directory as data frames----
setwd(loc_data_output)
data <- read.csv('07_final.csv', sep = ',', stringsAsFactors=FALSE)

setwd(loc_data_input)
rating_indicator <- read.csv('ratings_indicator.csv', sep = ',', stringsAsFactors=FALSE)

data <- left_join(data, rating_indicator, by = c('agency', 'ratings'))

#If NA use 2nd data sources
reg_data <- tbl_df(data) %>% transmute(
  agency = agency, 
  country  = country, 
  iso2c = iso2c, 
  year = year,
  rating = ratings_indicator, 
  CDS = lag_cds, 
  GNI_cap = lag_GNIpercap,
  GDP_grw = ma_GDPgrowth,
  inf = ifelse(is.na(ma_inflation_cpi), ma_inflation_def, ma_inflation_cpi),
  ext_bal = ifelse(is.na(lag_currentaccount), lag_current_account_WEO, lag_currentaccount),
  fsc_bal = ifelse(is.na(ma_budget), ma_fiscal_balance_WEO, ma_budget),
  ext_dbt = ifelse(is.na(external_debt), ext_debt_2/lag_export, external_debt), 
  def = dflt, 
  dev = dvlp_wb
) %>%
  filter(complete.cases(.))

#Create average data
dat <- select(reg_data, agency, country, iso2c, year, rating)
dat <- dcast(dat, iso2c + country + year ~ agency)
colnames(dat)[4] <- 'Moodys'
colnames(dat)[5] <- 'SP'
dat <- mutate(dat, Difference = Moodys - SP, 
              Average = (Moodys + SP)/2)
dat <- melt(dat, id=c("iso2c","country", "year"))
colnames(dat)[4] <- 'agency'
colnames(dat)[5] <- 'rating'

dat1 <- reg_data %>%
  filter(agency == "S&P") %>%
  select(-agency, -rating)

dat2 <- left_join(dat, dat1, by=c('iso2c', 'country', 'year'))

#Output final reg data
setwd(loc_data_output)
write.csv(dat2, file="08_regdata.csv", row.names=FALSE)