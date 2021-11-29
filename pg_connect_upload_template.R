source('pg_connect_upload_template.R')

# host: login to postgres database on localhost ---------------------------
pg_local <- dbConnect(dbDriver("PostgreSQL"),
                     user="jdwyer4",
                     dbname="jdwyer4",
                     host="localhost",
                     password=.rs.askForPassword("Enter password:"))

pg <- pg_local

# libraries ---------------------------------------------------------------

library(tidyverse)
library(RPostgreSQL)

# set wd to localrepos "Output Files" folder ------------------------------
setwd()

# enter filename for output files -----------------------------------------

sonobat_upload(sonobatFile = "5-10_S4Fall_Output.csv")

