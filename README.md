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
#>   ..$ daisng_id   : num [1:1438] 25184 ...
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
#>  $ jsc           :'data.frame':  901 obs. of  2 variables:
#>   ..$ ut : chr [1:901] "WOS:000173956100001" ...
#>   ..$ jsc: chr [1:901] "Veterinary Sciences" ...
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
pull_incites(uts)
#>                      ut article_type tot_cites journal_expected_citations
#> 1.1 WOS:000272877700013           AA         1                        3.3
#> 1.2 WOS:000272366800025           AA         4                        4.2
#> 1.3 WOS:000272272000015           AA         2                        8.8
#>     journal_act_exp_citations impact_factor avg_expected_rate percentile
#> 1.1                      0.30          0.47                20         87
#> 1.2                      0.95          0.80                20         62
#> 1.3                      0.23          1.28                20         77
#>      nci esi_most_cited_article hot_paper is_international_collab
#> 1.1 0.05                  FALSE     FALSE                   FALSE
#> 1.2 0.20                  FALSE     FALSE                   FALSE
#> 1.3 0.10                  FALSE     FALSE                   FALSE
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
#> 1.1 WOS:A1996VH04300002           AA        18                     29.879
#> 1.2 WOS:000425564500005           AA         0                      0.022
#> 1.3 WOS:000425532500001            R         0                      0.333
#> 1.4 WOS:000422961700001           AA         0                      0.459
#> 1.5 WOS:000422961000002            R         3                      0.500
#> 1.6 WOS:000422958400008            R         1                      2.182
#>     journal_act_exp_citations impact_factor avg_expected_rate percentile
#> 1.1                      0.60           1.8            18.945       23.7
#> 1.2                      0.00           1.8             0.066      100.0
#> 1.3                      0.00           2.2             0.267      100.0
#> 1.4                      0.00          -1.0             0.519      100.0
#> 1.5                      6.00          -1.0             0.940        9.8
#> 1.6                      0.46          -1.0             3.624       72.8
#>      nci esi_most_cited_article hot_paper is_international_collab
#> 1.1 0.95                  FALSE     FALSE                   FALSE
#> 1.2 0.00                  FALSE     FALSE                   FALSE
#> 1.3 0.00                  FALSE     FALSE                   FALSE
#> 1.4 0.00                  FALSE     FALSE                   FALSE
#> 1.5 3.19                  FALSE     FALSE                   FALSE
#> 1.6 0.28                  FALSE     FALSE                   FALSE
#>     is_institution_collab is_industry_collab oa_flag
#> 1.1                 FALSE              FALSE   FALSE
#> 1.2                 FALSE              FALSE   FALSE
#> 1.3                 FALSE              FALSE   FALSE
#> 1.4                 FALSE              FALSE    TRUE
#> 1.5                 FALSE              FALSE    TRUE
#> 1.6                 FALSE              FALSE    TRUE
```

Learning more
-------------

-   To learn more, head over to `wosr`'s [webpage](https://vt-arc.github.io/wosr/index.html).
