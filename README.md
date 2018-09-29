wosr
================

> R clients to the Web of Science and Incites APIs

[![Linux Build Status](https://travis-ci.org/vt-arc/wosr.svg?branch=master)](https://travis-ci.org/vt-arc/wosr) [![CRAN version](http://www.r-pkg.org/badges/version/wosr)](https://cran.r-project.org/package=wosr)

Installation
------------

You can get the stable version from CRAN

``` r
install.packages("wosr")
```

Or the development version from GitHub

``` r
if (!"devtools" %in% rownames(installed.packages())) 
  install.packages("devtools")

devtools::install_github("vt-arc/wosr")
```

Web of Science
--------------

``` r
library(wosr)

# Save your WoS API username and password in environment variables
Sys.setenv(WOS_USERNAME = "your_username", WOS_PASSWORD = "your_password")

# Get session ID
sid <- auth()
```

``` r
# Query WoS to see how many results match your query
query <- 'TS = ("animal welfare") AND PY = (2002-2003)'
query_wos(query, sid = sid)
#> Matching records: 548
```

``` r
# Download data
pull_wos(query, sid = sid)
#> List of 9
#>  $ publication   :'data.frame':  548 obs. of  7 variables:
#>   ..$ ut       : chr [1:548] "WOS:000186387100005" ...
#>   ..$ title    : chr [1:548] "Farm animal welfare: The interaction of et"..
#>   ..$ journal  : chr [1:548] "Animal Welfare" ...
#>   ..$ date     : Date[1:548], format: "2003-11-01" ...
#>   ..$ doi      : chr [1:548] NA ...
#>   ..$ tot_cites: int [1:548] 37 15 ...
#>   ..$ abstract : chr [1:548] "Farm animal welfare has now been studied, "..
#>  $ author        :'data.frame':  1438 obs. of  7 variables:
#>   ..$ ut          : chr [1:1438] "WOS:000186387100005" ...
#>   ..$ author_no   : int [1:1438] 1 2 ...
#>   ..$ display_name: chr [1:1438] "Sandoe, P" ...
#>   ..$ first_name  : chr [1:1438] "P" ...
#>   ..$ last_name   : chr [1:1438] "Sandoe" ...
#>   ..$ email       : chr [1:1438] "pes@kvl.dk" ...
#>   ..$ daisng_id   : int [1:1438] 196427 3327343 ...
#>  $ address       :'data.frame':  838 obs. of  7 variables:
#>   ..$ ut      : chr [1:838] "WOS:000186387100005" ...
#>   ..$ addr_no : int [1:838] 1 2 ...
#>   ..$ org_pref: chr [1:838] "University of Copenhagen" ...
#>   ..$ org     : chr [1:838] "Royal Vet & Agr Univ" ...
#>   ..$ city    : chr [1:838] "Frederiksberg" ...
#>   ..$ state   : chr [1:838] NA ...
#>   ..$ country : chr [1:838] "Denmark" ...
#>  $ author_address:'data.frame':  18 obs. of  3 variables:
#>   ..$ ut       : chr [1:18] "WOS:000208276800197" ...
#>   ..$ author_no: int [1:18] 1 2 ...
#>   ..$ addr_no  : int [1:18] 1 1 ...
#>  $ jsc           :'data.frame':  901 obs. of  2 variables:
#>   ..$ ut : chr [1:901] "WOS:000186387100005" ...
#>   ..$ jsc: chr [1:901] "Veterinary Sciences" ...
#>  $ keyword       :'data.frame':  2096 obs. of  2 variables:
#>   ..$ ut     : chr [1:2096] "WOS:000186387100005" ...
#>   ..$ keyword: chr [1:2096] "animal welfare" ...
#>  $ keywords_plus :'data.frame':  2020 obs. of  2 variables:
#>   ..$ ut           : chr [1:2020] "WOS:000179260700001" ...
#>   ..$ keywords_plus: chr [1:2020] "system" ...
#>  $ grant         :'data.frame':  1 obs. of  3 variables:
#>   ..$ ut          : chr "WOS:000208574800048"
#>   ..$ grant_agency: chr "Selcuk University Research Foundation"
#>   ..$ grant_id    : chr "2000/062"
#>  $ doc_type      :'data.frame':  642 obs. of  2 variables:
#>   ..$ ut      : chr [1:642] "WOS:000186387100005" ...
#>   ..$ doc_type: chr [1:642] "Article" ...
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
pull_incites(uts)
#>                      ut article_type tot_cites journal_expected_citations
#> 1.1 WOS:000272877700013           AA         1                        3.4
#> 1.2 WOS:000272366800025           AA         4                        4.3
#> 1.3 WOS:000272272000015           AA         3                        8.9
#>     journal_act_exp_citations impact_factor avg_expected_rate percentile
#> 1.1                      0.30          0.49                20         87
#> 1.2                      0.94          0.85                20         63
#> 1.3                      0.34          1.90                20         69
#>      nci esi_most_cited_article hot_paper is_international_collab
#> 1.1 0.05                  FALSE     FALSE                   FALSE
#> 1.2 0.20                  FALSE     FALSE                   FALSE
#> 1.3 0.15                  FALSE     FALSE                   FALSE
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
#> 1.1 WOS:A1996VH04300002           AA        18                      30.07
#> 1.2 WOS:000435128900013            R         2                       1.50
#> 1.3 WOS:000432234000011           AA         0                       0.12
#> 1.4 WOS:000425564500005           AA         0                       0.12
#> 1.5 WOS:000425532500001            R         0                       0.67
#> 1.6 WOS:000422961700001           AA         0                       0.64
#>     journal_act_exp_citations impact_factor avg_expected_rate percentile
#> 1.1                       0.6           1.5             19.07       23.9
#> 1.2                       1.3           1.6              0.25        2.1
#> 1.3                       0.0           1.5              0.11      100.0
#> 1.4                       0.0           1.5              0.11      100.0
#> 1.5                       0.0           2.8              0.40      100.0
#> 1.6                       0.0           1.7              0.69      100.0
#>      nci esi_most_cited_article hot_paper is_international_collab
#> 1.1 0.94                  FALSE     FALSE                   FALSE
#> 1.2 8.07                  FALSE     FALSE                    TRUE
#> 1.3 0.00                  FALSE     FALSE                   FALSE
#> 1.4 0.00                  FALSE     FALSE                   FALSE
#> 1.5 0.00                  FALSE     FALSE                   FALSE
#> 1.6 0.00                  FALSE     FALSE                   FALSE
#>     is_institution_collab is_industry_collab oa_flag
#> 1.1                 FALSE              FALSE   FALSE
#> 1.2                  TRUE              FALSE   FALSE
#> 1.3                 FALSE              FALSE   FALSE
#> 1.4                 FALSE              FALSE   FALSE
#> 1.5                 FALSE              FALSE   FALSE
#> 1.6                 FALSE              FALSE    TRUE
```

Learning more
-------------

-   To learn more, head over to `wosr`'s [webpage](https://vt-arc.github.io/wosr/index.html).
