# wosr 0.1.1

#### Misc

* The InCites API was updated by Clarivate, including moving to a new endpoint URL and changing the order of fields returned by the "DocumentLevelMetricsByUT" method. Small changes to the internals of `pull_incites()` were made to reflect this.

# wosr 0.1.0

#### New functions

* `auth()` added to get a session ID from WoS API server
* `query_wos()` and `pull_wos()` added to query and download data from the WoS API, respectively
* `pull_incites()` added to pull data from the InCites API
