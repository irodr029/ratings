#####Finalize data
#This script cleans up the final cleaned data
#data file for checking

#Packages for data cleaning
library('WDI')
library('reshape2')
library('dplyr')
library('lubridate')
library('data.table')
library('zoo')
library('ggplot2')

#Define input and output locations
loc_data_input <- "~/Desktop/Ratings/data/input"
loc_data_output <- "~/Desktop/Ratings/data/output"

#Read in all the input data files in working directory as data frames----
setwd(loc_data_output)

data <- read.csv('06_cleanLags.csv', sep = ',', stringsAsFactors=FALSE)
ratings <- read.csv('ratings_corrected.csv', sep = ',', stringsAsFactors=FALSE)

data <- data %>%
  group_by(agency, iso2c, year) %>%
  select(agency, country, iso2c, year, ratings, ratings_prior, lag_cds, 
         lag_GNIpercap, ma_GDPgrowth, ma_inflation_cpi, ma_inflation_def, lag_currentaccount, lag_current_account_WEO, 
         ma_budget, ma_fiscal_balance_WEO, external_debt, ext_debt_2 = lag_currency_debt, lag_export, dflt = def_indicator, port = development, 
         dvlp_port = development_indicator_port, dvlp_wb = development_indicator_wb) %>%
  arrange(agency, iso2c, year)

data <- left_join(data, ratings, by = c('agency', 'iso2c', 'year', 'country'))
data <- mutate(data, ratings = ratings.y)

#Output merged file
setwd(loc_data_output)
write.csv(data, file="07_final.csv", row.names=FALSE)
