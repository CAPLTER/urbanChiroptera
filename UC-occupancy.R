
# README ------------------------------------------------------------------

# The values in the matrix include 0, 1, and NA. 0 and 1 correspond to absence,
# presence. NA corresponds to cases where there was not a monitoring night
# during a season for a site. A good example of this is site 1_04 during the
# winter (week 6); there were only two monitoring nights at that site for that
# season: Feb 12 (occasion 2) and 13 (occasion 3) - PAHE was not identified on
# either of those nights so the value is zero for both occasion 2 and 3, but
# monitoring nights corresponding to occasions 1, 4, and 5 did not occur so
# values corresponding to those columns are NA.

# regarding NAs per above:
# I talked with Jesse and we came to the conclusion that the 'NA' should only be
# used if the monitor was not at the site recording or had been malfunctioning
# in some way. So, if the monitor was on and working, then there was a survey
# even if no bats were detected. To the best of my knowledge, the monitors at
# these sites were on, with enough battery, and fully functioning. We had very
# few detections at site 1-04 every season, so it makes sense that there is very
# very low bat activity at that site in the winter. Therefore, the occasions
# with no recordings should also be a '0' for no bat detections.


# libraries ---------------------------------------------------------------

library(tidyverse)


# connections -------------------------------------------------------------

# connect to the database


# query data --------------------------------------------------------------

dbGetQuery(pg,'
SELECT
  sites.site_id,
  sampling_dates.week,
  sampling_dates.season,
  sampling_dates.occasion,
  sampling_dates.monitoring_night,
  taxa.species_code,
  observations.count
FROM urban_chiroptera.sampling_dates
LEFT JOIN (
  SELECT DISTINCT
  surveys.site_id,
  surveys.monitoring_night
  FROM urban_chiroptera.surveys 
  WHERE surveys.monitoring_night IS NOT NULL
) AS surveydata ON (surveydata.monitoring_night = sampling_dates.monitoring_night)
JOIN urban_chiroptera.sites ON (sites.id = surveydata.site_id)
CROSS JOIN urban_chiroptera.taxa
LEFT JOIN (
  SELECT
    sites.site_id,
    surveys.monitoring_night,
    taxa.species_code,
    count(*)
  FROM urban_chiroptera.surveys
  LEFT JOIN urban_chiroptera.bat_observations BO ON (surveys.id = BO.survey_id)
  JOIN urban_chiroptera.sites ON (sites.id = surveys.site_id)
  JOIN urban_chiroptera.taxa ON (taxa.id = BO.taxa_id)
  WHERE
    BO.sonobat_id_type = 1
  GROUP BY 
    sites.site_id,
    surveys.monitoring_night,
    taxa.species_code
) AS observations ON (
  observations.site_id = sites.site_id AND
  observations.monitoring_night = sampling_dates.monitoring_night AND
  observations.species_code = taxa.species_code
);') -> occupancy

occupancy %>% 
  mutate(
    count = case_when(
      is.na(count) ~ 0,
      !is.na(count) ~ 1,
      TRUE ~ NA_real_
    )
  ) %>% 
  pivot_wider(id_cols = -c(monitoring_night), names_from = occasion, values_from = count) %>% 
  # convert NAs to 0 see note in README
  mutate_at(vars(contains("occasion")), .funs = function(x) { x = case_when(is.na(x) ~ 0, TRUE ~ x) }) %>%
  arrange(species_code, season, site_id) %>%
  write_csv('~/Desktop/occupancy.csv')
