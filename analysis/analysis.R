#####Regression Data
#This script creates data for regging

#Packages for regression analysis and data manipulation
library('WDI')
library('reshape2')
library('dplyr')
library('lubridate')
library('data.table')
library('zoo')
library('car')
library('ggplot2')
library('GGally')
library('stargazer')
library('Hmisc')
library('stats')

#Define input and output locations
loc_data_output <- "~/Desktop/Ratings/data/output"
loc_results_output <- "~/Desktop/Ratings/analysis/output"

#Read in regression file in working directory as data frame----
setwd(loc_data_output)
data <- read.csv('08_regdata.csv', sep = ',', stringsAsFactors=FALSE)
data <- data[complete.cases(data),]

##################################################################################

#Regression Analysis
setwd(loc_results_output)

###########################
##These results are only for the latest year (2012)
rep_data <- filter(data, year == 2012)

###Results - Replicate CP table using 2012
rep_results <- group_by(rep_data, agency, year) %>%
  do(model = lm(rating ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def, data = .))

stargazer(rep_results[[3]], title = 'Replication of CP (1996) - 2012 data', type = "text", column.labels=c("Avg","Diff", "Moody's", "S&P"), report = "vct*", out = "repl_2012.txt")

###Results - Crossectional Regressions by Agency only CDS using 2012
rep_results_uniCDS <- group_by(rep_data, agency, year) %>%
  do(model = lm(rating ~  log(CDS), data = .))

stargazer(rep_results_uniCDS[[3]], title = 'Univariate Regression for 2012 - Ratings on CDS spread', type = "text", column.labels=c("Avg","Diff", "Moody's", "S&P"), report = "vct*", out = "repl_uniCDS.txt")

###Results - Replicate CP table using 2012 adding CDS
rep_results_multCDS <- group_by(rep_data, agency, year) %>%
  do(model = lm(rating ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def + log(CDS), data = .))

stargazer(rep_results_multCDS[[3]], title = 'Multivariate Regression including CDS spread - 2012 data', type = "text", column.labels=c("Avg","Diff", "Moody's", "S&P"), report = "vct*", out = "repl_multCDS.txt")

###########################
##These results are for all of the years (average ratings only)

##These results are only for the latest year (2012)
reg_data <- filter(data, agency == "Average")

###Results - Replicate CP table using average ratings across time
reg_results <- group_by(reg_data, agency, year) %>%
  do(model = lm(rating ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def, data = .))

stargazer(reg_results[[3]], title = 'Replication of CP (1996) Across Time - Average Rating', type = "text", column.labels=c("2007","2008", "2009", "2010", "2011", "2012"), report = "vct*", out = "reg_avg.txt")

###Results - Univariate regression (CDS) using average ratings across time
reg_results_uniCDS <- group_by(reg_data, agency, year) %>%
  do(model = lm(rating ~ log(CDS), data = .))

stargazer(reg_results_uniCDS[[3]], title = 'Univariate Regressions Across Time - Average Rating on CDS spread', type = "text", column.labels=c("2007","2008", "2009", "2010", "2011", "2012"), report = "vct*", out = "reg_uniCDS.txt")

###Results - Replicate CP table using average ratings across time
reg_results_multCDS <- group_by(reg_data, agency, year) %>%
  do(model = lm(rating ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def + log(CDS), data = .))

stargazer(reg_results_multCDS[[3]], title = 'Multivariate Regressions Across Time Including CDS spread - Average Rating ', type = "text", column.labels=c("2007","2008", "2009", "2010", "2011", "2012"), report = "vct*", out = "reg_multCDS.txt")

###########################
#CDS spread on Macro Variables
cds_macro <- group_by(reg_data, agency, year) %>%
  do(model = lm(log(CDS) ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def, data = .))

stargazer(cds_macro[[3]], title = 'Multivariate Regressions Across Time (CDS on Macro variables) - Average Rating ', type = "text", column.labels=c("2007","2008", "2009", "2010", "2011", "2012"), report = "vct*", out = "cds_macro.txt")

###########################
#Check for multicollinearity using VIF (only checking for average rating across time)

#VIF for CP replication over time using average ratings
reg_results_vif <- group_by(reg_data, agency, year) %>%
  do(vif = vif(lm(rating ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def, data = .)))

reg_results_vif <- as.data.frame(reg_results_vif[[3]])
names(reg_results_vif) <- c('2007', '2008', '2009', '2010', '2011', '2012')
stargazer(reg_results_multCDS_vif, type = 'text', summary = FALSE,
          title = 'VIF - CP replication using Avg. Rating (2007 - 2012)', out = 'vif_reg_results.txt')

#VIF for CDS on Macro Variables using average ratings
reg_results_multCDS_vif <- group_by(reg_data, agency, year) %>%
  do(vif = vif(lm(rating ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def + log(CDS), data = .)))

reg_results_multCDS_vif <- as.data.frame(reg_results_multCDS_vif[[3]])
names(reg_results_multCDS_vif) <- c('2007', '2008', '2009', '2010', '2011', '2012')
stargazer(reg_results_multCDS_vif, type = 'text', summary = FALSE,
          title = 'VIF - Multivariate w/ CDS spread using Avg. Rating (2007 - 2012)', out = 'vif_reg_results_multCDS.txt')


cds_macro_vif <- group_by(reg_data, agency, year) %>%
  do(vif = vif(lm(log(CDS) ~ log(GNI_cap) + GDP_grw + log(inf) + fsc_bal + ext_bal + ext_dbt + dev + def, data = .)))

cds_macro_vif <- as.data.frame(cds_macro_vif[[3]])
names(cds_macro_vif) <- c('2007', '2008', '2009', '2010', '2011', '2012')
stargazer(cds_macro_vif, type = 'text', summary = FALSE,
          title = 'VIF - CDS on Macro Variables using Avg. Rating (2007 - 2012)', out = 'vif_cs_macro.txt')

##########################
#Plotting Average ratings

data.plot <- tbl_df(reg_data)
data.plot$year <- as.factor(data.plot$year)
data.plot$def <- as.factor(data.plot$def)
data.plot$dev <- as.factor(data.plot$dev)
str(data.plot)
ggpairs(data.plot, columns = 5:14, colour = 'year', alpha = 0.20, lower = list(continuous = "smooth", combo = "facetdensity"))

##########################
#Correlations
correl_data <- group_by(reg_data, year) %>% select(-iso2c, -country, -agency, -year, -rating) %>%
  do(correl = cor(.))

#Need to manually update years (2007-2012)
stargazer(correl_data[[2]], type = 'text', title = "Correlation (2007-2012)",out = 'correl_year.txt')
stargazer(cor(select(reg_data, -iso2c, -country, -agency, -year, -rating)), type = 'text', title = "Correlation",out = 'correl.txt')



##Correlation Plot - Overall
abbreviateSTR <- function(value, prefix){  # format string more concisely
  lst = c()
  for (item in value) {
    if (is.nan(item) || is.na(item)) { # if item is NaN return empty string
      lst <- c(lst, '')
      next
    }
    item <- round(item, 2) # round to two digits
    if (item == 0) { # if rounding results in 0 clarify
      item = '<.01'
    }
    item <- as.character(item)
    item <- sub("(^[0])+", "", item)    # remove leading 0: 0.05 -> .05
    item <- sub("(^-[0])+", "-", item)  # remove leading -0: -0.05 -> -.05
    lst <- c(lst, paste(prefix, item, sep = ""))
  }
  return(lst)
}

d <- select(reg_data, -iso2c, -country, -agency, -year, -rating)

cormatrix = rcorr(as.matrix(d), type='pearson')
cordata = melt(cormatrix$r)
cordata$labelr = abbreviateSTR(melt(cormatrix$r)$value, 'r')
cordata$labelP = abbreviateSTR(melt(cormatrix$P)$value, 'P')
cordata$label = paste(cordata$labelr, "\n", 
                      cordata$labelP, sep = "")
cordata$strike = ""
cordata$strike[cormatrix$P > 0.05] = "X"

txtsize <- par('din')[2] / 2
ggplot(cordata, aes(x=Var1, y=Var2, fill=value)) + geom_tile() + 
  theme(axis.text.x = element_text(angle=90, hjust=TRUE)) +
  xlab("") + ylab("") + 
  geom_text(label=cordata$label, size=txtsize) + 
  geom_text(label=cordata$strike, size=txtsize * 4, color="red", alpha=0.4)
