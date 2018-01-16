wosr
================

> R clients to the Web of Science and Incites APIs

[![Project Status: WIP â€“ Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Linux Build Status](https://travis-ci.org/vt-arc/wosr.svg?branch=master)](https://travis-ci.org/vt-arc/wosr) [![CRAN version](http://www.r-pkg.org/badges/version/wosr)](https://cran.r-project.org/package=wosr)

Installation
------------

You can get the development version from GitHub:

``` r
if (!require(devtools)) install.packages("devtools")

devtools::install_github("vt-arc/wosr")
```

### Web of Science

``` r
library(wosr)

# Save your WoS API username and password in environment vars
Sys.setenv(WOS_USERNAME = "your_username", WOS_PASSWORD = "your_password")

# Get session ID
sid <- auth()
```

``` r
# Query WoS to see how many results there are for a particular query
query <- 'TS = ("animal welfare") AND PY = (2002-2003)'
query_wos(query, sid = sid)
#> Matching records: 548
```

``` r
# Download data (this may take some time)
pull_wos(query, sid = sid)
#> List of 8
#>  $ publication   :'data.frame':  548 obs. of  8 variables:
#>   ..$ ut       : chr [1:548] "WOS:000173956100001" ...
#>   ..$ title    : chr [1:548] "FMD and animal welfare" ...
#>   ..$ journal  : chr [1:548] "Veterinary Record" ...
#>   ..$ date     : Date[1:548], format: "2002-01-26" ...
#>   ..$ doc_type : chr [1:548] "Editorial Material" ...
#>   ..$ doi      : chr [1:548] NA ...
#>   ..$ tot_cites: num [1:548] 0 0 ...
#>   ..$ abstract : chr [1:548] NA ...
#>  $ author        :'data.frame':  1438 obs. of  7 variables:
#>   ..$ ut          : chr [1:1438] "WOS:000176714800003" ...
#>   ..$ author_no   : num [1:1438] 1 1 ...
#>   ..$ display_name: chr [1:1438] "Nolen, RS" ...
#>   ..$ first_name  : chr [1:1438] "RS" ...
#>   ..$ last_name   : chr [1:1438] "Nolen" ...
#>   ..$ email       : chr [1:1438] NA ...
#>   ..$ daisng_id   : num [1:1438] 27466471 ...
#>  $ address       :'data.frame':  838 obs. of  7 variables:
#>   ..$ ut      : chr [1:838] "WOS:000182036200014" ...
#>   ..$ addr_no : num [1:838] 1 1 ...
#>   ..$ org_pref: chr [1:838] "University of Prince Edward Island" ...
#>   ..$ org     : chr [1:838] "Univ Prince Edward Isl" ...
#>   ..$ city    : chr [1:838] "Charlottetown" ...
#>   ..$ state   : chr [1:838] "PE" ...
#>   ..$ country : chr [1:838] "Canada" ...
#>  $ author_address:'data.frame':  18 obs. of  3 variables:
#>   ..$ ut       : chr [1:18] "WOS:000208276800197" ...
#>   ..$ author_no: num [1:18] 1 2 ...
#>   ..$ addr_no  : num [1:18] 1 1 ...
#>  $ jsc           :'data.frame':  900 obs. of  2 variables:
#>   ..$ ut : chr [1:900] "WOS:000173956100001" ...
#>   ..$ jsc: chr [1:900] "Veterinary Sciences" ...
#>  $ keyword       :'data.frame':  2096 obs. of  2 variables:
#>   ..$ ut     : chr [1:2096] "WOS:000177154900014" ...
#>   ..$ keyword: chr [1:2096] "animality" ...
#>  $ keywords_plus :'data.frame':  2020 obs. of  2 variables:
#>   ..$ ut           : chr [1:2020] "WOS:000180265600060" ...
#>   ..$ keywords_plus: chr [1:2020] "housing conditions" ...
#>  $ grant         :'data.frame':  1 obs. of  3 variables:
#>   ..$ ut          : chr "WOS:000208574800048"
#>   ..$ grant_agency: chr "Selcuk University Research Foundation"
#>   ..$ grant_id    : chr "2000/062"
```

### InCites

``` r
# Save your InCites developer key in an environment variable
Sys.setenv(INCITES_KEY = "your_key")
```

``` r
# Vector of UTs (publication identifiers) to get InCites data for
uts <- c("000272272000015", "000272366800025", "000272877700013")

# Download InCites data for those UTs
pull_incites(uts)
#> NULL
```

### Web of Science and Incites

``` r
# Download WoS data
wos <- pull_wos('TS = ("dog welfare")', sid = sid)

# Download InCites data
pull_incites(wos$publication$ut)
#> NULL
```

Learning more
-------------

-   To learn more, head over to `wosr`'s [webpage](https://vt-arc.github.io/wosr/index.html).
