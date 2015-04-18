#####Merge WEO data
#This script merges in the  WEO file from
#the input folder

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
setwd(loc_data_input)

files <- dir(loc_data_input)
for (file in files){
  perpos <- which(strsplit(file, "")[[1]]==".")
  assign(
    gsub(" ","",substr(file, 1, perpos-1)), 
    read.csv(paste(file,sep=""), stringsAsFactors=FALSE))
}

#Read in all the output data files in working directory as data frames----
setwd(loc_data_output)

files <- dir(loc_data_output)
for (file in files){
  perpos <- which(strsplit(file, "")[[1]]==".")
  assign(
    gsub(" ","",substr(file, 1, perpos-1)), 
    read.csv(paste(file,sep=""), stringsAsFactors=FALSE))
}

#Rename file
weo <- WEOOct2014all

#data frame doesn't have iso2c codes, so merging them with code vector
code_country <- select(as.data.frame(WDI_data$country), iso3c, iso2c)
weo <- rename(weo, iso3c = ISO)
weo <- inner_join(weo, code_country, by = c("iso3c"))

#Choosing the variables I'm interested in from file
#BCA_NGDPD - Current Account (%GDP)
#GGXCNL_NGDP - Fiscal Balance (%GDP)
weo <- weo %>%
  filter(grepl('BCA_NGDPD|GGXCNL_NGDP', WEO.Subject.Code)) %>%
  mutate(value.name = ifelse(WEO.Subject.Code == 'BCA_NGDPD','current_account_WEO', 'fiscal_balance_WEO'))

#Change from wide format to long
weo <- weo %>%
  select(iso2c, value.name, starts_with('X')) %>%
  melt(id.vars = c("iso2c", "value.name")) %>%
  mutate(year = as.integer(substr(variable, 2, 5))) %>%
  arrange(iso2c, value.name, year) %>%
  select(-variable)

#Change from long format back to wide
weo <- dcast(weo, iso2c + year ~ value.name)

#Select only years that interest us. Note that some years include estimates.
weo <- filter(weo, year <= 2014 & year >= 1990)

#Merge with prior file
data <- left_join(`01_WB`, weo, by = c("iso2c","year"))

#Output merged file
setwd(loc_data_output)
write.csv(data, file="02.1_merge_weo.csv", row.names=FALSE)



