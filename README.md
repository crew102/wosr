wosr 
================

> R clients to the Web of Science and Incites APIs

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Linux Build Status](https://travis-ci.org/vt-arc/wosr.svg?branch=master)](https://travis-ci.org/vt-arc/wosr)

Introduction
----------------

The `wosr` R package contains functions that make downloading WoS/InCites data easy.

Installation
------------

You can get the development version from GitHub:

``` r
if (!require(devtools)) install.packages("devtools")

devtools::install_github("vt-arc/wosr")
```

Basic usage
---------------

### Web of Science

``` r
library(wosr)

# Save your WoS API username and password in envionrment variables
Sys.setenv(WOS_USERNAME = "your_username", WOS_PASSWORD = "your_password")

# Get session ID:
sid <- auth()

# Query WoS to see how many results there are for a particular query:
query <- 'TS = ("animal welfare")'
query_wos(query = query, sid = sid)

# Now download data (this may take some time):
data <- pull_wos(query = query, sid = sid)
```

### InCites

``` r
# Save your InCites developer key in an envionrment variable
Sys.setenv(INCITES_KEY = "your_key")

# Vector of UTs (publications) to get InCites data for:
uts <- c("000272272000015", "000272366800025", "000272877700013")

# Download InCites data for those UTs:
data <- pull_incites(uts)
```

### Web of Science and Incites

``` r
# Pull WoS data
wos <- pull_wos(query = 'TS=("animal welfare")')

# Download InCites data for those publications:
data <- pull_incites(uts = wos$publication$ut)
```
