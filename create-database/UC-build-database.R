
# README ------------------------------------------------------------------

# R code and SQL to create a relational database to house data from acoustic bat
# monitoring.


# libraries ---------------------------------------------------------------

library(tidyverse)
library(RPostgreSQL)


# database connection -----------------------------------------------------

source('pg_local.R')
pg <- pg_local


# schema ------------------------------------------------------------------

dbExecute(pg,'CREATE SCHEMA urban_chiroptera;')


# sites -------------------------------------------------------------------

dbExecute(pg,'
CREATE TABLE urban_chiroptera.sites
(
  id SERIAL PRIMARY KEY,
  site_id TEXT UNIQUE NOT NULL,
  cap_site TEXT,
  strata INTEGER,
  city TEXT,
  latitude NUMERIC,
  longitude NUMERIC,
  urban_value NUMERIC
)
WITH (
  OIDS=FALSE
);
')

# insert testing data
# dbExecute(pg,"
# INSERT INTO urban_chiroptera.sites (site_id) VALUES ('test site');
# INSERT INTO urban_chiroptera.sites (site_id) VALUES ('w15');          
# ")


# taxa --------------------------------------------------------------------

dbExecute(pg,'
CREATE TABLE urban_chiroptera.taxa
(
  id SERIAL PRIMARY KEY,
  species_code TEXT UNIQUE NOT NULL,
  name_scientific TEXT UNIQUE,
  name_common TEXT UNIQUE,
  call_frequency INTEGER,
  urban_category TEXT
)
WITH (
  OIDS=FALSE
);
')

taxa <- read_csv('create-database/SpeciesCodes.csv')

if (dbExistsTable(pg, c('urban_chiroptera', 'taxa_temp')))
  dbRemoveTable(pg, c('urban_chiroptera', 'taxa_temp'))
dbWriteTable(pg,
             c('urban_chiroptera', 'taxa_temp'),
             value = taxa,
             row.names = F
)

dbExecute(pg, "
INSERT INTO urban_chiroptera.taxa
(
  species_code,
  name_scientific,
  name_common,
  call_frequency,
  urban_category
)
(
SELECT
  species_code,
  name_scientific,
  name_common,
  call_frequency,
  urban_category
FROM
urban_chiroptera.taxa_temp
);"
)
  
# clean up taxa_temp
if (dbExistsTable(pg, c('urban_chiroptera', 'taxa_temp')))
  dbRemoveTable(pg, c('urban_chiroptera', 'taxa_temp')
  )


# surveyors ---------------------------------------------------------------

dbExecute(pg,'
CREATE TABLE urban_chiroptera.surveyors
(
  id SERIAL PRIMARY KEY,
  sur_name TEXT,
  given_name TEXT
)
WITH (
  OIDS=FALSE
);
')


dbExecute(pg,"
INSERT INTO urban_chiroptera.surveyors
(
  sur_name,
  given_name
) VALUES
(
  'Dwyer',
  'Jessie'
);")

 
# surveys -----------------------------------------------------------------

if (dbExistsTable(pg, c('urban_chiroptera', 'surveys')))
  dbRemoveTable(pg, c('urban_chiroptera', 'surveys')
  )

dbExecute(pg,'
CREATE TABLE urban_chiroptera.surveys
(
  id SERIAL PRIMARY KEY,
  sonobat_filename TEXT,
  sound_filename TEXT,
  surveyor INTEGER,
  site_id INTEGER,
  high_freq_bat BOOLEAN,
  low_freq_bat BOOLEAN,
  call_quality INTEGER,
  call_timestamp TIMESTAMP WITH TIME ZONE,
  monitoring_night DATE,
  num_pulses_autoid INTEGER,
  num_pulses_detected INTEGER,
  pulse_freq_mean NUMERIC,
  pulse_freq_stdev NUMERIC,
  pulse_dur_mean NUMERIC,
  pulse_dur_stdev NUMERIC,
  calls_sec FLOAT, --support Infinity
  mean_hi_freq NUMERIC,
  mean_low_freq NUMERIC,
  mean_up_slope NUMERIC,
  mean_low_slope NUMERIC,
  mean_total_slope NUMERIC,
  mean_prec_intvl NUMERIC,
  file_length NUMERIC,
  version NUMERIC,
  autoid_quality NUMERIC,
  max_pulses INTEGER,
  FOREIGN KEY (surveyor) REFERENCES urban_chiroptera.surveyors (id),
  FOREIGN KEY (site_id) REFERENCES urban_chiroptera.sites (id),
  UNIQUE(sound_filename, surveyor)
)
WITH (
  OIDS=FALSE
);
')

dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.high_freq_bat IS 'sonobat output: HiF: high frequency bat';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.low_freq_bat IS 'sonobat output: LoF: low frequency bat';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.call_quality IS 'sonobat output: Call Quality: quality of call (0=poor, 1=good, 2=voucher call/best quality';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.manual_id IS 'sonobat output: Species Manual ID: manual species ID';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.auto_id IS 'sonobat output: SppAccp: automatic species ID';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.num_pulses_autoid IS 'sonobat output: #Maj: number of call pulses auto identified as species';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.num_pulses_detected IS 'sonobat output: #Accp: number of call pulses detected';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.pulse_freq_mean IS 'sonobat output: Fc mean: mean call pulse frequency (kHz)';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.pulse_freq_stdev IS 'sonobat output: Fc StdDev: standard dev call frequency	(kHz)';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.pulse_dur_mean IS 'sonobat output: Dur mean: mean call pulse duration (ms)';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.pulse_dur_stdev IS 'sonobat output: Dur StdDev: standard dev call pulse duration (ms)';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.calls_sec IS 'sonobat output: calls/sec: number of call pulses per second';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.mean_hi_freq IS 'sonobat output: mean HiFreq: mean call pulse highest frequency (kHz)';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.mean_low_freq IS 'sonobat output: mean LoFreq: call pulse lowest frequency (kHz)';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.mean_up_slope IS 'sonobat output: mean UpprSlp: mean call pulse upper slope';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.mean_low_slope IS 'sonobat output: mean LwrSlp: mean call pulse lower slope';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.mean_total_slope IS 'sonobat output: mean TotalSlp: mean call pulse total slope';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.mean_prec_intvl IS 'sonobat output: mean PrecedingIntvl: METADATA REQUIRED';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.file_length IS 'sonobat output: FileLength(sec): file length';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.version IS 'sonobat output: Version: METADATA REQUIRED';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.autoid_quality IS 'sonobat output: AccpQuality: quality metric for auto identification';")
dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.surveys.max_pulses IS 'sonobat output: Max#CallsConsidered: max number of call pulses considered';")


# bat_observations --------------------------------------------------------

if (dbExistsTable(pg, c('urban_chiroptera', 'bat_observations')))
  dbRemoveTable(pg, c('urban_chiroptera', 'bat_observations')
  )

dbExecute(pg,'
CREATE TABLE urban_chiroptera.bat_observations
(
  id SERIAL PRIMARY KEY,
  survey_id INTEGER NOT NULL,
  sonobat_id_type INTEGER NOT NULL,
  taxa_id INTEGER NOT NULL,
  FOREIGN KEY (survey_id) REFERENCES urban_chiroptera.surveys (id),
  FOREIGN KEY (sonobat_id_type) REFERENCES urban_chiroptera.sonobat_id_types (id),
  FOREIGN KEY (taxa_id) REFERENCES urban_chiroptera.taxa (id),
  UNIQUE(survey_id, sonobat_id_type)
)
WITH (
  OIDS=FALSE
);
')


# sonobat_id_types --------------------------------------------------------

dbExecute(pg,'
CREATE TABLE urban_chiroptera.sonobat_id_types
(
  id SERIAL PRIMARY KEY,
  sonobat_field_name TEXT UNIQUE NOT NULL,
  observation_type_description TEXT
)
WITH (
  OIDS=FALSE
);
')

dbExecute(pg,"COMMENT ON COLUMN urban_chiroptera.sonobat_id_types.sonobat_field_name IS 'field name from sonobat output';")

dbExecute(pg,"
INSERT INTO urban_chiroptera.sonobat_id_types(
  sonobat_field_name,
  observation_type_description
) VALUES 
('Species Manual ID', 'manual species ID'),
('SppAccp', 'automatic species ID'),
('~Spp', 'most likely species'),
('1st', '1st choice species'),
('2nd', '2nd choice species'),
('3rd', '3rd choice species'),                
('4th', '4th choice species')
;")