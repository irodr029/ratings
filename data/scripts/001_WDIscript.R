#####DOWNLOAD WDI INDICATORS
#This script downloads the raw data files for the variables
#from the World Bank and saves them as .csv

loc_data_input <- "~/Desktop/Ratings/data/input"
loc_data_ouput <- "~/Desktop/Ratings/data/output"

#Sets the working directory to save our input files
setwd(loc_data_input)

library('WDI') #load WDI function to download WB's World Development Indicators

#Sets the working directory to save our input files
setwd(loc_data_input)

#Per Capita Income ----
#Download the per Capita GDP
GDPpercap <- WDI(indicator = "NY.GDP.MKTP.CD", start=1990, end=2014)
names(GDPpercap)[3] <- "GDPpercap"
write.csv(GDPpercap, file="GDPpercap.csv", row.names=FALSE)

#Download the per Capita GNI
GNIpercap <- WDI(indicator = "NY.GNP.PCAP.CD", start=1990, end=2014)
names(GNIpercap)[3] <- "GNIpercap"
write.csv(GNIpercap, file="GNIpercap.csv", row.names=FALSE)

#GDP growth ----
#Download the annual percentage growth of GDP
GDPgrowth <- WDI(indicator = "NY.GDP.MKTP.KD.ZG", start=1990, end=2014)
names(GDPgrowth)[3] <- "GDPgrowth"
write.csv(GDPgrowth, file="GDPgrowth.csv", row.names=FALSE)

#Inflation ----
#Download the annual inflation - consumer prices
inflation_cpi <- WDI(indicator = "FP.CPI.TOTL.ZG", start=1990, end=2014)
names(inflation_cpi)[3] <- "inflation_cpi"
write.csv(inflation_cpi, file="inflation_cpi.csv", row.names=FALSE)

#Download the annual inflation - gdp deflator
inflation_def <- WDI(indicator = "NY.GDP.DEFL.KD.ZG", start=1990, end=2014)
names(inflation_def)[3] <- "inflation_def"
write.csv(inflation_def, file="inflation_def.csv", row.names=FALSE)

#Economic Development ----
#Download port infrastructure data
development <- WDI(indicator = "IQ.WEF.PORT.XQ", start=1990, end=2014)
names(development)[3] <- "development"
write.csv(development, file="development.csv", row.names=FALSE)

#External Balance ----
#Download current account surplus as a percentage of GDP
currentaccount <- WDI(indicator = "BN.CAB.XOKA.GD.ZS", start=1990, end=2014)
names(currentaccount)[3] <- "currentaccount"
write.csv(currentaccount, file="current_account.csv", row.names=FALSE)

#Fiscal Balance ----
#Download central government budget as a percentage of GDP
budget <- WDI(indicator = "GC.BAL.CASH.GD.ZS", start=1990, end=2014)
names(budget)[3] <- "budget"
write.csv(budget, file="budget.csv", row.names=FALSE)

#External debt = FCD(ED)/EXPORTS----
#Download exports of goods and services in current dollars
export <- WDI(indicator = "NE.EXP.GNFS.CD", start=1990, end=2014)
names(export)[3] <- "export"
write.csv(export, file="export.csv", row.names=FALSE)

#External Debt
currencydebt <- WDI(indicator = "DT.DOD.DECT.CD", start=1990, end=2014)
names(currencydebt)[3] <- "currency_debt"
write.csv(currencydebt, file="currency_debt.csv", row.names=FALSE)


