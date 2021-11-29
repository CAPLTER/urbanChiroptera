# README -----------------------------------------------------------------------

# Example workflow to evaluate the applicability of the activity package to
# assessing bat activity.


# libraries --------------------------------------------------------------------

library(activity)
library(readr)
library(tsibble)


# workflow ---------------------------------------------------------------------

# read data from file, ensure UTC-7
PAHE <- read_csv("~/Desktop/PAHE_subset.csv",
  locale = locale(tz = "America/Phoenix"))

PAHE

# collapse around a window
pahe <- as_tsibble(x = PAHE,
  key = NULL,
  index = "call_timestamp",
  regular = FALSE) %>%
fill_gaps(.full = TRUE) %>%
mutate(diff = difference(call_timestamp)) %>%
filter(diff > 15 | is.na(diff))

write.table(pahe, file = '~/Desktop/PAHE_independent.csv', sep=",")



# calculate and extract time in radians
paheRad <- gettime(pahe$call_timestamp, "%Y-%m-%d %H:%M:%S", "radian")

# calcuate activity, here default params and without CIs
mod2 <- fitact(paheRad)

# plot activity
plot(mod2)
