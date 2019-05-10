urbanChiroptera
================

<!-- README.md is generated from README.Rmd. Please edit the latter. -->

#### overview

Code and documentation related to acoustic monitoring and analyses of
bats in the greater Phoenix metropolitan area.

#### database schema

![](create-database/urbanChiroptera%20-%20normalized.png)

#### uploading sonobat data

The `sonobat_upload` function is used to upload sonobat output to the
urban\_chiroptera database. The function takes three arguments: (1) the
path and name of the sonobat file to upload, (2) the sur name of the
investigator who processed the sonobat file (note that is not
necessarily the person uploading the data), and (3) the name of the
study site. The name of the investigator and the study site name are
optional parameters with J. Dwyer represented as the default
investigator processing the data, and the study site name extracted from
the sonobat file name.

Upload a sonobat file with default arguments: J. Dwyer as the
investigator who identified the bats, and extracting the site name from
the sonobat file
name.

``` r
sonobat_upload(sonobatFile = "~/Dropbox/development/urbanChiroptera/1-03_S1Winter_Output.csv")
```

Upload a sonobat file with the surveyor argument denoting that someone
other than J. Dwyer processed the data in the sonobat file. The site
name is extracted from the sonobat file
name.

``` r
sonobat_upload(sonobatFile = "~/Dropbox/development/urbanChiroptera/1-03_S1Winter_Output.csv",
               surveyorSurname = "lewis")
```

Upload a sonobat file with the surveyor argument denoting that someone
other than J. Dwyer processed the data in the sonobat file, and
explicitly identifying the study site
name.

``` r
sonobat_upload(sonobatFile = "~/Dropbox/development/urbanChiroptera/1-03_S1Winter_Output.csv",
               surveyorSurname = "lewis",
               siteName = "1_01")
```
