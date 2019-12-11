# host: postgres database on localhost
pg_local <- dbConnect(dbDriver("PostgreSQL"),
                     user="jdwyer4",
                     dbname="jdwyer4",
                     host="localhost",
                     password=.rs.askForPassword("Enter password:"))
