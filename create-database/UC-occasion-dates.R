
# README ------------------------------------------------------------------

# To construct an occupany table identifying the presence/absence of taxa at
# sites throughout the study, a table detailing the sampling nights across
# seasons is required. A season typically spans approximately eight weeks.
# Occasions are sampling efforts within a season, and typically all the dates of
# a day within a season. For example, occasion 2 in winter could be all of the
# Tuesdays in February and part of March.

# sampling_dates was added to the database after its initial construction hence
# the code in this file separate from UC-build-database.R.

# libraries ---------------------------------------------------------------

library(tidyverse)
library(DBI)


# connection --------------------------------------------------------------

# establish DB connection


# read data from files ----------------------------------------------------

sampling_dates <- bind_rows(
  read_csv('Season1_Winter2019_occasiondates.csv') %>% 
    rename(week = X1) %>% 
    mutate_at(vars(contains("occasion")), function(x) parse_date(x, format = "%m/%d/%y")) %>% 
    mutate(season = 'Season1_Winter2019'),
  read_csv('Season2_Spring2019_occasiondates.csv') %>% 
    rename(week = X1) %>% 
    mutate_at(vars(contains("occasion")), function(x) parse_date(x, format = "%m/%d/%y")) %>% 
    mutate(season = 'Season2_Spring2019'),
  read_csv('Season3_Summer2019_occasiondates.csv') %>% 
    rename(week = X1) %>% 
    mutate_at(vars(contains("occasion")), function(x) parse_date(x, format = "%m/%d/%y")) %>% 
    mutate(season = 'Season3_Summer2019'),
  read_csv('Season4_Fall2019_occasiondates.csv') %>% 
    rename(week = X1) %>% 
    mutate_at(vars(contains("occasion")), function(x) parse_date(x, format = "%m/%d/%y")) %>% 
    mutate(season = 'Season4_Fall2019')
) %>% 
  pivot_longer(cols = contains("occasion"), names_to = "occasion", values_to = "monitoring_night")


# write table to the database ---------------------------------------------

dbWriteTable(conn = pg,
             name = c('urban_chiroptera', 'sampling_dates'),
             value = sampling_dates,
             row.names = F)
