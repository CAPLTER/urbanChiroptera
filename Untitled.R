# Capture History Attempt #

currentData %>%
  spread(key = observation_type_description, value = species_code) %>% View()
str(currentData)

#subset of voucher files
data_subset <- currentData %>%
  filter(call_quality == 2) %>%
  select(site_id, monitoring_night, species_code, call_quality)
print(data_subset)

make.capthist(data_subset, traps, fmt = c("trapID", "XY"), noccasion = NULL, covnames = NULL, 
              bysession = TRUE, sortrows = TRUE, cutval = NULL, tol = 0.01, 
              snapXY = FALSE, noncapt = "NONE", signalcovariates)

# create some dummy dates from tomorrow to 20 days from today
x = c(Sys.Date()+1:20)
# extract the year and change to numeric
as.numeric(format(x, "%Y"))
# you can also extract the month and day with
as.numeric(format(x, "%m"))
as.numeric(format(x, "%d"))

# create dummy capture data; id is animal and date is the date it was captured or recaptured
df=data.frame(id=floor(runif(100,1,50)),date=runif(100,0,5000)+as.Date("1980-01-01"))
#create some dummy date intervals that are approximately every 6 months
intervals=as.Date("1979-01-01")+seq(180,15*365,182.5)

# cut the dates into intervals
occasions=cut(df$date,intervals)
