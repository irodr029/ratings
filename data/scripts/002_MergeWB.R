#####Merge data
#This script merges together the files from
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

#Read in all the data files in working directory as data frames----
setwd(loc_data_input)

files <- dir(loc_data_input)
for (file in files){
  perpos <- which(strsplit(file, "")[[1]]==".")
  assign(
    gsub(" ","",substr(file, 1, perpos-1)), 
    read.csv(paste(file,sep=""), stringsAsFactors=FALSE))
}

#####MERGE WDI FILES & EXTERNAL DEBT
#This section merges the files from the World Bank
#WDI files - downloaded using script
#External Debt - partly manually uploaded

#Two data frames don't have iso2c codes, so merging them with code vector
code_country <- select(as.data.frame(WDI_data$country), iso3c, iso2c)

defaulthistory <- inner_join(defaulthistory, code_country, by = c("iso3c"))
externaldebt <- inner_join(externaldebt, code_country, by = c("iso3c"))

#Clean up external debt
externaldebt <- externaldebt %>%
  melt(value.name = "ext_debt") %>%
  mutate(year = as.integer(substr(variable, 2, 5))) %>%
  select(iso2c, year, ext_debt)

externaldebt$iso2c <- as.character(externaldebt$iso2c)
externaldebt <- aggregate(externaldebt, by=list(externaldebt$year, externaldebt$iso2c), 
                          FUN=mean, na.rm=TRUE)
externaldebt <- select(externaldebt, year = Group.1, iso2c = Group.2, ext_debt)

#Cleanup everything else
budget <- select(budget, -country)
current_account <- select(current_account, -country)
development <- select(development, -country)
export <- select(export, -country)
GDPgrowth <- select(GDPgrowth, -country)
GDPpercap <- select(GDPpercap, -country)
GNIpercap <- select(GNIpercap, -country)
inflation_cpi<- select(inflation_cpi, -country)
inflation_def <- select(inflation_def, -country)
currency_debt <- select(currency_debt, -country)

#Merge data
data <- inner_join(GDPpercap, GDPgrowth, by = c("iso2c","year"))
data <- inner_join(data, inflation_cpi, by = c("iso2c","year"))
data <- inner_join(data, inflation_def, by = c("iso2c","year"))
data <- inner_join(data, development, by = c("iso2c","year"))
data <- inner_join(data, GNIpercap, by = c("iso2c","year"))
data <- inner_join(data, export, by = c("iso2c","year"))
data <- inner_join(data, current_account, by = c("iso2c","year"))
data <- inner_join(data, budget, by = c("iso2c","year"))
data <- left_join(data, externaldebt, by = c("iso2c","year"))
data <- left_join(data, currency_debt, by = c("iso2c","year"))

#Merge country info
country <- select(as.data.frame(WDI_data$country), iso2c, country)
data <- left_join(data, country, by = c("iso2c"))

#Output World Bank data
setwd(loc_data_output)
write.csv(data, file="01_WB.csv", row.names=FALSE)
