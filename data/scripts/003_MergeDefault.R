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

#####CLEAN DEFAULT HISTORY
#Default History data frame doesn't have iso2c code
code_country <- select(as.data.frame(WDI_data$country), iso3c, iso2c)

defaulthistory <- inner_join(defaulthistory, code_country, by = c("iso3c"))
defaulthistory <- select(defaulthistory, iso2c, year, default_date = date)
defaulthistory$default_date <- as.Date(defaulthistory$default_date, "%m/%d/%y")

#Output clean default history
setwd(loc_data_output)
write.csv(defaulthistory, file="02_default.csv", row.names=FALSE)

#Create column where we measure the 25th year after default
defaulthistory$prior25 <- defaulthistory$year + 25

#Find out the year in which 25 years have elapsed since the default
summary <- summarise(group_by(defaulthistory, iso2c), max_prior25 = max(prior25))

#Initialize matrix to create indicator variable
year <- seq(from = 1990, to = 2014, by = 1)
iso2c <- summary$iso2c
default_matrix <- merge(year, iso2c)
default_matrix <- select(default_matrix, year = x, iso2c = y)
default_matrix <- mutate(default_matrix, def_indicator = ifelse(default_matrix$year <= summary$max_prior25,1,0))

#Merge with WB
data <- left_join(`02`, default_matrix, by = c("iso2c","year"))
data$def_indicator[is.na(data$def_indicator)] <- 0

#Output merged file
setwd(loc_data_output)
write.csv(data, file="03_merge_default.csv", row.names=FALSE)
