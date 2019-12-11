### Basic Queries ###

# connect to the table
batsurveys = dbGetQuery(pg, "select * from urban_chiroptera.surveys") # using 'pg' instead of 'con'
summary(batsurveys)
str(batsurveys)

# get part of the table
rm(batsurveys)
batsurveys = dbGetQuery(pg, "select call_quality, sonobat_filename from urban_chiroptera.surveys")
summary (batsurveys)

# connect to the table
batobs = dbGetQuery(pg, "select * from urban_chiroptera.bat_observations") 
summary(batobs)
str(batobs)

#get part of the table 
rm(batobs)
batobs = dbGetQuery(pg, "select taxa_id, created_at from urban_chiroptera.bat_observations")
summary (batobs)
