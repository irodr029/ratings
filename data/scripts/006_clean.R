#####Clean data
#This script cleans up the final merged
#data file

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

dat <- arrange(`05_merge_cds`, agency, country, desc(year))

#####Argentina had no GNI, using the UN database
iso2c <- 'AR'
year <- c(2006, 2007, 2008, 2009, 2010, 2011, 2012)
GNIpercap <- c(5579, 6632, 8287, 10101, 9282, 11227, 13453)
argGNI <- cbind.data.frame(iso2c, year, GNIpercap)
dat <- merge(dat, argGNI, by=c('year', 'iso2c'), all = TRUE)
dat <- mutate(dat, GNIpercap = ifelse(iso2c == "AR", GNIpercap.y, GNIpercap.x))
dat <- select(dat, -GNIpercap.x, -GNIpercap.y)

####Convert these to numeric for next step
dat$current_account_WEO <- as.numeric(dat$current_account_WEO)
dat$fiscal_balance_WEO <- as.numeric(dat$fiscal_balance_WEO)

####Outputs data file before lagging and averaging. This will be the data for SAS.
setwd(loc_data_output)
write.csv(dat, file="05_clean.csv", row.names=FALSE)


####Create lag of all necessary variables
dat <- dat %>% 
  group_by(agency, iso2c) %>%
  arrange(agency, year) %>%
  mutate(
  lag_GNIpercap = lag(GNIpercap,1),
  lag_export = lag(export,1),
  lag_currentaccount = lag(currentaccount,1),
  lag_ext_debt = lag(ext_debt,1),
  lag_currency_debt = lag(currency_debt,1),
  lag_current_account_WEO = lag(current_account_WEO,1)
  )

dat <- dat %>% 
  group_by(agency, iso2c) %>%
  arrange(agency, year) %>%
  mutate(
    ma_GDPgrowth = lag(rollapply(GDPgrowth, 4, mean, align = "right", fill = NA, na.rm=TRUE),1), 
    ma_fiscal_balance_WEO = lag(rollapply(fiscal_balance_WEO, 3, mean, align = "right", fill = NA, na.rm=TRUE),1),
    ma_budget = lag(rollapply(budget, 3, mean, align = "right", fill = NA, na.rm=TRUE),1),
    ma_inflation_cpi = lag(rollapply(inflation_cpi, 3, mean, align = "right", fill = NA, na.rm=TRUE),1),
    ma_inflation_def = lag(rollapply(inflation_def, 3, mean, align = "right", fill = NA, na.rm=TRUE),1),
    lag_cds = lag(rollapply(spreadCDS, 3, mean, align = "right", fill = NA, na.rm=TRUE),1)
  )
####Only countries and years available from cds file
dat <- filter(dat, !is.na(spreadCDS))

####Create development indicator (using port_develop) and external debt
dat <- dat %>%
  mutate(development_indicator_port = ifelse(development < 3.6 | is.na(development),0,1),
         external_debt = lag_ext_debt/lag_export * 100)

####Create development indicator using WB guidlines
dat <- merge(dat,dev_min, by = 'year')
dat <- mutate(dat, development_indicator_wb = ifelse(dev_min < GNIpercap,1,0))

#Output merged file
setwd(loc_data_output)
write.csv(dat, file="06_cleanLags.csv", row.names=FALSE)

