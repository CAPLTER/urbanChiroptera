# host: login to postgres database on localhost ---------------------------
pg_local <- dbConnect(dbDriver("PostgreSQL"),
                     user="jdwyer4",
                     dbname="jdwyer4",
                     host="localhost",
                     password=.rs.askForPassword("Enter password:"))

# libraries ---------------------------------------------------------------

library(tidyverse)
library(RPostgreSQL)

# set wd to localrepos "Output Files" folder ------------------------------
setwd()

# enter filename for output files -----------------------------------------

sonobat_upload(sonobatFile = "5-09_S3Summer_Output.csv")

# Winter Output Files Uploaded #
# #

# Spring Output Files Uploaded #
# 1-03 #