# wosr 0.2.0

## New functions

* `query_wos_apply()` and `pull_wos_apply()` added to issue multiple queries to the WoS API and pull the data for those queries, respectively

## Misc

* `pull_wos()` now returns empty data frames instead of `NA` if the user's query returns no results
* `pull_wos()` explicitly casts all string fields to be character vectors, and `pull_incites()` now correctly casts the `esi_most_cited_article` field to be a logical vector (instead of a numeric)

# wosr 0.1.2

## New functions

* `write_wos_data()` and `read_wos_data()` added to write the data returned by `pull_wos()` as a series of CSVs and to read those CSVs back into R

## Bug fixes

* `pull_wos()` now sleeps one second whenever it encounters a throttling limit 

# wosr 0.1.1

## Misc

* The InCites API was updated by Clarivate, including moving to a new endpoint URL and changing the order of fields returned by the "DocumentLevelMetricsByUT" method. Small changes to the internals of `pull_incites()` were made to reflect this.

# wosr 0.1.0

## New functions

* `auth()` added to get a session ID from WoS API server
* `query_wos()` and `pull_wos()` added to query and download data from the WoS API, respectively
* `pull_incites()` added to pull data from the InCites API
