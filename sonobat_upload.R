
# README ------------------------------------------------------------------

#' @title sonobat_upload 
#'
#' @description sonobat_upload uploads a processed sonobat file to the
#'   urban_chiroptera database.
#'   
#' @details The surveyor/technician who processed the data (i.e., associated bat
#'   calls with a bat taxon) must exist in the urban_chiroptera database. Though
#'   not passed to the function, a connection to the urban_chiroptera database
#'   identified as 'pg' must exist in the R environment.
#'
#' @param sonobatFile The quoted path + name of a sonobat file to process.
#' @param surveyorSurname (optional) The quoted sur name of the technician who
#'   identified bat calls in sonobat. Note that this is not necessarily the same
#'   person uploading the data. The default is "dwyer", and this paramter should
#'   be passed only if someone other than J. Dwyer has processed the data. Note
#'   that the technician must exist in the urban_chiroptera database.
#' @param siteName (optional) The quoted study site name (e.g., "1_01"). If not
#'   passed, the site name is derived from the sonobat file name (if formatted
#'   properly)
#'
#' @import tidyverse
#' @import RPostgreSQL
#'
#' @return data uploaded to urban_chiroptera database with success flag, or no
#'   action with a message if there was an error during processing
#'
#' @examples
#' \dontrun{
#'
#' sonobat_upload("~/Dropbox/development/urbanChiroptera/1-01_S1Winter_Output.csv")
#' sonobat_upload("~/Dropbox/development/urbanChiroptera/1-02_S1Winter_Output.csv")
#' sonobat_upload("~/Dropbox/development/urbanChiroptera/1-03_S1Winter_Output.csv")
#' sonobat_upload("~/Dropbox/development/urbanChiroptera/1-03_S1Winter_Output.csv", surveyorSurname = "earl")
#'
#' }
#'
#' @export


# sonobat_upload ----------------------------------------------------------

sonobat_upload <- function(sonobatFile,
                           surveyorSurname = "dwyer",
                           siteName = NULL) {
  
  # check for required inputs -----------------------------------------------
  
  if (missing(sonobatFile)) { stop("provide a file to upload") }  
  
  
  # extract site name from sonobat file -------------------------------------
  
  if (is.null(siteName)) {
    
    siteName <- str_extract(basename(sonobatFile), "^\\d+-\\d+") %>% 
      str_replace("-", "_")
    
  }
  
  
  # read sonobat file -------------------------------------------------------
  
  surveyData <- read_csv(sonobatFile,
                         locale = locale(tz = "America/Phoenix")) %>%
    mutate(
      MonitoringNight = as.Date(MonitoringNight, format = "%m/%d/%y"),
      HiF = as.logical(HiF),
      LoF = as.logical(LoF),
      surveyor = surveyorSurname,
      sonobat_filename = basename(sonobatFile),
      site = siteName 
    )
  
  tryCatch({
    
    
    # survey data -------------------------------------------------------------
    
    dbGetQuery(pg, "BEGIN TRANSACTION")
    
    # # write new samples to surveys_temp
    if (dbExistsTable(pg, c('urban_chiroptera', 'surveys_temp')))
      dbRemoveTable(pg, c('urban_chiroptera', 'surveys_temp'))
    dbWriteTable(pg,
                 c('urban_chiroptera', 'surveys_temp'),
                 value = surveyData,
                 row.names = F
    )
    
    # insert from surveys_temp to surveys
    dbExecute(pg, '
    INSERT INTO urban_chiroptera.surveys
    (
      sonobat_filename,
      sound_filename,
      surveyor_id,
      site_id,
      high_freq_bat,
      low_freq_bat,
      call_quality,
      call_timestamp,
      monitoring_night,
      num_pulses_autoid,
      num_pulses_detected,
      most_likely_spp,
      pulse_freq_mean,
      pulse_freq_stdev,
      pulse_dur_mean,
      pulse_dur_stdev,
      calls_sec,
      mean_hi_freq,
      mean_low_freq,
      mean_up_slope,
      mean_low_slope,
      mean_total_slope,
      mean_prec_intvl,
      file_length,
      version,
      autoid_quality,
      max_pulses
    )
    (
    SELECT
      surveys_temp.sonobat_filename,
      surveys_temp."Filename",
      surveyors.id,
      sites.id,
      surveys_temp."HiF",
      surveys_temp."LoF",
      surveys_temp."Call Quality",
      surveys_temp."Timestamp",
      surveys_temp."MonitoringNight",
      surveys_temp."#Maj",
      surveys_temp."#Accp",
      surveys_temp."~Spp",
      surveys_temp."Fc mean",
      surveys_temp."Fc StdDev",
      surveys_temp."Dur mean",
      surveys_temp."Dur StdDev",
      surveys_temp."calls/sec",
      surveys_temp."mean HiFreq",
      surveys_temp."mean LoFreq",
      surveys_temp."mean UpprSlp",
      surveys_temp."mean LwrSlp",
      surveys_temp."mean TotalSlp",
      surveys_temp."mean PrecedingIntvl",
      surveys_temp."FileLength(sec)",
      surveys_temp."Version",
      surveys_temp."AccpQuality",
      surveys_temp."Max#CallsConsidered"
    FROM urban_chiroptera.surveys_temp 
    JOIN urban_chiroptera.surveyors ON (surveys_temp.surveyor ~~* surveyors.sur_name)
    JOIN urban_chiroptera.sites ON (surveys_temp.site = sites.site_id)
    );'
    )
    
    # remove surveys_temp
    if (dbExistsTable(pg, c('urban_chiroptera', 'surveys_temp')))
      dbRemoveTable(pg, c('urban_chiroptera', 'surveys_temp')
      )
    
    
    # observation data --------------------------------------------------------
    
    # extract and mutate observations from survey data
    observationData <- surveyData %>%
      select(Filename,
             `Species Manual ID`,
             SppAccp,
             `1st`,
             `2nd`,
             `3rd`,
             `4th`,
             surveyor) %>%
      gather(key = id_type, value = bat_taxon,-Filename,-surveyor) %>%
      filter(!is.na(bat_taxon)) %>%
      mutate(surveyor_id = as.integer(NA))
    
    # write observation data to observations_temp
    if (dbExistsTable(pg, c('urban_chiroptera', 'observations_temp')))
      dbRemoveTable(pg, c('urban_chiroptera', 'observations_temp'))
    dbWriteTable(
      pg,
      c('urban_chiroptera', 'observations_temp'),
      value = observationData,
      row.names = F
    )
    
    # add surveyor_id to observations_temp
    dbExecute(pg, '
    UPDATE urban_chiroptera.observations_temp
    SET surveyor_id = urban_chiroptera.surveyors.id
    FROM urban_chiroptera.surveyors
    WHERE surveyors.sur_name ~~* observations_temp.surveyor
    ;')
    
    # insert into bat_observations from observations_temp
    dbExecute(pg, '
    INSERT INTO urban_chiroptera.bat_observations
    (
      survey_id,
      sonobat_id_type,
      taxa_id
    )
    (
    SELECT
      surveys.id,
      sonobat_id_types.id,
      taxa.id
    FROM urban_chiroptera.observations_temp
    LEFT JOIN urban_chiroptera.surveys ON (surveys.sound_filename = observations_temp."Filename" AND surveys.surveyor_id = observations_temp.surveyor_id)
    LEFT JOIN urban_chiroptera.sonobat_id_types ON (sonobat_id_types.sonobat_field_name = observations_temp.id_type)
    LEFT JOIN urban_chiroptera.taxa ON (taxa.species_code ~~* observations_temp.bat_taxon)
    )
    ;')
    
    # remove observations_temp
    if (dbExistsTable(pg, c('urban_chiroptera', 'observations_temp')))
      dbRemoveTable(pg, c('urban_chiroptera', 'observations_temp'))
    
    # commit all database operations if there were not errors
    dbCommit(pg)
    
  }, warning = function(warn) {
    
    print(paste("WARNING: ", warn))
    
  }, error = function(err) {
    
    print(paste("ERROR: ", err))
    print("ROLLING BACK TRANSACTION")
    
    dbRollback(pg)
    
  }) # close try catch  
  
} # close sonobat_upload 
