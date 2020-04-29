
# README ------------------------------------------------------------------

# base script to harvest data from the urban_chiroptera database.

# libraries ---------------------------------------------------------------

library(tidyverse)
library(RPostgreSQL)


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
JOIN urban_chiroptera.sonobat_id_types SIT ON (SIT.id = BO.sonobat_id_type)
JOIN urban_chiroptera.sites ON (sites.id = surveys.site_id)
JOIN urban_chiroptera.surveyors ON (surveyors.id = surveys.surveyor_id);
")

currentData %>%
  spread(key = observation_type_description, value = species_code) %>% View()
str(currentData)

#subset of voucher files
data_subset <- currentData %>%
  filter(call_quality == 2) %>%
  select(site_id, monitoring_night, species_code, call_quality)
print(data_subset)

#subset of voucher files of one species 
PAHE_subset <- currentData %>%
  filter(call_quality == 2, species_code == 'PAHE') %>%
  select(site_id, monitoring_night, species_code, call_quality)
print(PAHE_subset)
view(PAHE_subset)

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

