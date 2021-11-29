
# README ------------------------------------------------------------------

# base script to harvest data from the urban_chiroptera database.

# libraries ---------------------------------------------------------------

library(tidyverse)
library(RPostgreSQL)
library(tsibble)
library(dplyr)
library(tidyr)


# database connection -----------------------------------------------------

source('pg_connect_template.R')
pg <- pg_local

currentData <- dbGetQuery(pg, "
SELECT
  surveys.sonobat_filename,
  surveys.sound_filename,
  sites.site_id,
  surveyors.sur_name,
  surveys.high_freq_bat,
  surveys.low_freq_bat,
  surveys.call_quality,
  surveys.call_timestamp,
  surveys.monitoring_night,
  surveys.num_pulses_autoid,
  surveys.num_pulses_detected,
  surveys.most_likely_spp,
  surveys.pulse_freq_mean,
  surveys.pulse_freq_stdev,
  surveys.pulse_dur_mean,
  surveys.pulse_dur_stdev,
  surveys.calls_sec,
  surveys.mean_hi_freq,
  surveys.mean_low_freq,
  surveys.mean_up_slope,
  surveys.mean_low_slope,
  surveys.mean_total_slope,
  surveys.mean_prec_intvl,
  surveys.file_length,
  surveys.version,
  surveys.autoid_quality,
  surveys.max_pulses,
  taxa.species_code,
  SIT.observation_type_description
FROM urban_chiroptera.surveys
RIGHT JOIN urban_chiroptera.bat_observations BO ON (surveys.id = BO.survey_id)
JOIN urban_chiroptera.taxa ON (BO.taxa_id = taxa.id)
JOIN urban_chiroptera.sites ON (sites.id = surveys.site_id)
JOIN urban_chiroptera.surveyors ON (surveyors.id = surveys.surveyor_id)
JOIN urban_chiroptera.sonobat_id_types SIT ON (SIT.id = BO.sonobat_id_type)
WHERE
    BO.sonobat_id_type = 1;
")

currentData %>%
  spread(key = observation_type_description, value = species_code) %>% View()
str(currentData)
print(currentData)
write.csv(mutate(currentData, time=format(call_timestamp, "%Y-%m-%d %H:%M:%S")), file="currentData.csv", row.names=FALSE)

#subsets--------------------------------------------------------------------------------------------------------------------

#subset of voucher files of one species
PAHE_subset <- currentData %>%
  filter(species_code == 'PAHE') %>%
  select(site_id, monitoring_night, call_timestamp, species_code)
print(PAHE_subset)

#subset of voucher files at one site
site_subset <- currentData %>%
  filter(call_quality == 2, site_id == '1_01') %>%
  select(site_id, monitoring_night, species_code, call_quality)
print(site_subset)

#subset of voucher files during one occassion
night_subset <- currentData %>%
  filter(call_quality == 2, monitoring_night == '2019-01-14') %>%
  select(site_id, monitoring_night, species_code, call_quality)
print(night_subset)

#subset of voucher files of one species one site
PAHE_subset <- currentData %>%
  filter(species_code == 'PAHE', site_id == '5_10') %>%
  select(site_id, monitoring_night, call_timestamp, species_code)
print(PAHE_subset)
#class(NYSP_subset)
write.csv(PAHE_subset, file = '~/Desktop/PAHE_subset_50.csv')
#write.csv(mutate(NYSP_subset, time=format(call_timestamp, "%Y-%m-%d %H:%M:%S")), file="NYSP.csv", row.names=FALSE)

# read data from file, ensure UTC-7
Data <- read_csv("~/Desktop/currentData.csv",
                 locale = locale(tz = "America/Phoenix"))

# filter by time
Data <- as_tsibble(x = Data,
                  key = NULL,
                  index = "call_timestamp",
                  regular = FALSE) %>%
  fill_gaps(.full = TRUE) %>%
  mutate(diff = difference(call_timestamp)) %>%
  filter(diff > 15 | is.na(diff))


data_subset <- currentData %>%
  mutate(diff = difference(call_timestamp)) %>%
  filter(diff > 15 | is.na(diff))
  select(site_id, monitoring_night, species_code, call_timestamp)
print(data_subset)

data_subset %>%
  spread(key = observation_type_description, value = species_code) %>% View()
str(data_subset)
write.csv('~/Desktop/data_subset.csv')

#subset of voucher files of one species, filter by time 
PAHE_subset <- currentData %>%
  filter(species_code == 'PAHE') %>%
  select(site_id, monitoring_night, call_timestamp, species_code, season)
print(PAHE_subset)
class(PAHE_subset)
write.csv(PAHE_subset, file = '~/Desktop/PAHE_subset.csv')
write.csv(mutate(PAHE_subset, time=format(call_timestamp, "%Y-%m-%d %H:%M:%S")), file="test.csv", row.names=FALSE)

pahe <- read_csv("~/Desktop/pahe_subset.csv",
                 locale = locale(tz = "America/Phoenix"))
pahe

PAHE <- as_tsibble(x = pahe,
                   time = "call_timestamp",
                   key = NULL,
                   index = time,
                   regular = TRUE) %>%
  fill_gaps(.full = TRUE) %>%
  mutate(diff = difference(call_timestamp)) %>%
  filter(diff > 15 | is.na(diff))

str(pahe)
duplicates(pahe)


# desired output ----------------------------------------------------------------------

library(tidyverse)
library(lubridate)

left_join(
  tibble(
    dateBlock = seq(ymd('2019-08-05'),ymd('2019-08-09'), by = '1 days')
  ),
  currentData %>% 
    filter(
      monitoring_night >= '2019-08-05' & monitoring_night <= '2019-08-09',
      site_id == '2_01'
    ) %>% 
    group_by(
      site_id,
      monitoring_night,
      species_code
    ) %>% 
    summarise(count = n()) %>% 
    filter(species_code == "TABR"),
  by = c("dateBlock" = "monitoring_night")
) %>% 
  spread(key = dateBlock, value = count)

