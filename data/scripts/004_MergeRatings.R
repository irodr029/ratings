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

#####MERGE IN RATINGS FILE

#Create a table to merge in the ratings
data1 <- tbl_df(`03_merge_default`)
data2 <- data1

data1$agency <- "S&P"
data2$agency <- "Moody's"

data1 <- rbind(data1,data2)

ratings <- ratings %>%
  select(iso2c = Ctry, date = Date, agency = Agency, 
         rating = Curr.Rtg, rating_prior = Last.Rtg)

ratings$date <- as.Date(ratings$date, "%m/%d/%Y")
ratings$year <- year(ratings$date)
ratings <- data.frame(arrange(ratings, agency, iso2c, year),stringsAsFactors=FALSE)
ratings <- group_by(ratings, agency, iso2c, year)
ratings <- ratings[-grep("[*]", ratings$rating),]

ratings_agg1 <- aggregate(I(ratings$rating),
                          by=list(ratings$agency, ratings$iso2c,ratings$year),tail,n=1)
ratings_agg1 <- select(ratings_agg1, agency = Group.1, iso2c = Group.2, year = Group.3, rating = x)

ratings_agg2 <- aggregate(I(ratings$rating_prior),
                          by=list(ratings$agency, ratings$iso2c,ratings$year),tail,n=1)
ratings_agg2 <- select(ratings_agg2, agency = Group.1, iso2c = Group.2, year = Group.3, rating_prior = x)

ratings_agg <- left_join(ratings_agg1, ratings_agg2, by = c("iso2c", "year", "agency"))

ratings_agg$ratings <- as.character(ratings_agg$rating)
ratings_agg$ratings_prior <- as.character(ratings_agg$rating_prior)

ratings_agg <- select(ratings_agg, -rating, -rating_prior)
ratings_agg <- arrange(ratings_agg, iso2c, agency, year)

data2 <- data.table(data1)
data3 <- data.table(ratings_agg)

setkey(data2, iso2c, agency, year)
setkey(data3, iso2c, agency, year)

data4 <- data3[data2, roll=Inf]

#Output merged file
setwd(loc_data_output)
write.csv(data4, file="04_merge_ratings.csv", row.names=FALSE)
