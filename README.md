wosr
================

> R clients to the Web of Science and Incites APIs

[![Linux Build Status](https://travis-ci.org/vt-arc/wosr.svg?branch=master)](https://travis-ci.org/vt-arc/wosr) [![CRAN version](http://www.r-pkg.org/badges/version/wosr)](https://cran.r-project.org/package=wosr)

Installation
------------

You can get the development version from GitHub:

``` r
if (!require(devtools)) install.packages("devtools")

devtools::install_github("vt-arc/wosr")
```

Web of Science
--------------

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
#> List of 9
#>  $ publication   :'data.frame':  548 obs. of  7 variables:
#>   ..$ ut       : chr [1:548] "WOS:000173956100001" ...
#>   ..$ title    : chr [1:548] "FMD and animal welfare" ...
#>   ..$ journal  : chr [1:548] "Veterinary Record" ...
#>   ..$ date     : Date[1:548], format: "2002-01-26" ...
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
#>  $ doc_type      :'data.frame':  642 obs. of  2 variables:
#>   ..$ ut      : chr [1:642] "WOS:000173956100001" ...
#>   ..$ doc_type: chr [1:642] "Editorial Material" ...
```

InCites
-------

``` r
# Save your InCites developer key in an environment variable
Sys.setenv(INCITES_KEY = "your_key")
```

``` r
# Vector of UTs (publication identifiers) to get InCites data for
uts <- c("000272272000015", "000272366800025", "000272877700013")

# Download InCites data for those UTs
head(pull_incites(uts))
#>                      ut article_type tot_cites journal_expected_citations
#> 1.1 WOS:000272272000015           AA         2                        8.5
#> 1.2 WOS:000272366800025           AA         4                        4.1
#> 1.3 WOS:000272877700013           AA         1                        3.2
#>     journal_act_exp_citations impact_factor avg_expected_rate percentile
#> 1.1                      0.24          1.28                19         77
#> 1.2                      0.97          0.80                19         62
#> 1.3                      0.31          0.47                19         87
#>      nci esi_most_cited_article hot_paper is_international_collab
#> 1.1 0.11                  FALSE     FALSE                   FALSE
#> 1.2 0.21                  FALSE     FALSE                   FALSE
#> 1.3 0.05                  FALSE     FALSE                   FALSE
#>     is_institution_collab is_industry_collab oa_flag
#> 1.1                 FALSE              FALSE   FALSE
#> 1.2                 FALSE              FALSE   FALSE
#> 1.3                 FALSE              FALSE   FALSE
```

Web of Science and InCites
--------------------------

``` r
# Download WoS data
wos <- pull_wos('TS = ("dog welfare")', sid = sid)

# Download InCites data
head(pull_incites(wos$publication$ut))
#>                      ut article_type tot_cites journal_expected_citations
#> 1.1 WOS:000173967900005           AA         0                          5
#> 1.2 WOS:000247216100018           AA        19                         16
#> 1.3 WOS:000249481000004           AA        20                         18
#> 1.4 WOS:000255700900005           AA        28                         22
#> 1.5 WOS:000258136200005           AA        10                         12
#> 1.6 WOS:000261541300005           AA        22                         19
#>     journal_act_exp_citations impact_factor avg_expected_rate percentile
#> 1.1                      0.00          -1.0                14        100
#> 1.2                      1.15           1.5                13         18
#> 1.3                      1.09           1.8                15         17
#> 1.4                      1.29           2.0                10          9
#> 1.5                      0.86           1.5                12         35
#> 1.6                      1.14           1.8                14         14
#>      nci esi_most_cited_article hot_paper is_international_collab
#> 1.1 0.00                  FALSE     FALSE                   FALSE
#> 1.2 1.48                  FALSE     FALSE                   FALSE
#> 1.3 1.36                  FALSE     FALSE                    TRUE
#> 1.4 2.71                  FALSE     FALSE                   FALSE
#> 1.5 0.85                  FALSE     FALSE                    TRUE
#> 1.6 1.60                  FALSE     FALSE                   FALSE
#>     is_institution_collab is_industry_collab oa_flag
#> 1.1                 FALSE              FALSE   FALSE
#> 1.2                 FALSE              FALSE   FALSE
#> 1.3                  TRUE              FALSE   FALSE
#> 1.4                 FALSE              FALSE   FALSE
#> 1.5                  TRUE              FALSE   FALSE
#> 1.6                 FALSE              FALSE   FALSE
```

Learning more
-------------

-   To learn more, head over to `wosr`'s [webpage](https://vt-arc.github.io/wosr/index.html).
