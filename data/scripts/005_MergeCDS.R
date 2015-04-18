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

#####MERGE IN CDS FILE
spread <- melt(spread)
spread <- mutate(spread, year = as.integer(substr(variable, 2,5)))
spread <- group_by(spread, iso2c, year) %>%
  summarise(spreadCDS = mean(value, na.rm=TRUE))

spread1 <- filter(spread, !is.na(spreadCDS))
spread1 <- data.table(spread1)

data <- left_join(`04_merge_ratings`, spread1, by = c("iso2c", "year")) %>% arrange(agency, iso2c, year)
data$country <- as.character(data$country)

#Output merged file
setwd(loc_data_output)
write.csv(data, file="05_merge_cds.csv", row.names=FALSE)
