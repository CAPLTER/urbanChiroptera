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

dbExecute(pg,'
CREATE TABLE urban_chiroptera.taxa
(
  id SERIAL PRIMARY KEY,
  species_code UNIQUE NOT NULL,
  name_scientific TEXT,
  name_common TEXT,
  call_frequency INTEGER,
  urban_category TEXT
)
WITH (
  OIDS=FALSE
);
')

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
  timestamp TIMESTAMP WITH TIME ZONE,
  monitoring_night DATE,
  manual_id INTEGER,
  auto_id INTEGER,
  num_pulses_autoid INTEGER,
  num_pulses_detected INTEGER,
  likely_spp INTEGER,
  spp_choice_1 INTEGER,
  spp_choice_2 INTEGER,
  spp_choice_3 INTEGER,
  spp_choice_4 INTEGER,
  pulse_freq_mean NUMERIC,
  pulse_freq_stdev NUMERIC,
  pulse_dur_mean NUMERIC,
  pulse_dur_stdev NUMERIC,
  calls_sec NUMERIC,
  mean_hi_freq NUMERIC,
  mean_low_freq NUMERIC,
  mean_up_slope NUMERIC,
  mean_low_slope NUMERIC,
  mean_total_slope NUMERIC,
  mean_prec_intvl NUMERIC,
  file_length NUMERIC,
  version NUMERIC,
  autoid_quality NUMERIC,
  max_pulses INTEGER
)
WITH (
  OIDS=FALSE
);
')
