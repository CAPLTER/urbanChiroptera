source('pg_connect_template.R')
pg <- pg_local

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

sonobat_upload(sonobatFile = "2-02_S1Winter_Output.csv")
