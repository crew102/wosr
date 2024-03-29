% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apply.R
\name{query_wos_apply}
\alias{query_wos_apply}
\title{Run \code{query_wos} across multiple queries}
\usage{
query_wos_apply(
  queries,
  editions = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP", "BSCI", "BHCI", "IC", "CCR",
    "ESCI"),
  sid = auth(Sys.getenv("WOS_USERNAME"), Sys.getenv("WOS_PASSWORD")),
  ...
)
}
\arguments{
\item{queries}{Vector of queries run.}

\item{editions}{Web of Science editions to query. Possible values are listed
\href{http://ipscience-help.thomsonreuters.com/wosWebServicesLite/dbEditionsOptionsGroup/databaseEditionsWos.html}{here}.}

\item{sid}{Session identifier (SID). The default setting is to get a fresh
SID each time you query WoS via a call to \code{\link{auth}}. However,
you should try to reuse SIDs across queries so that you don't run into the
throttling limits placed on new sessions.}

\item{...}{Arguments passed along to \code{\link[httr]{POST}}.}
}
\value{
A data frame which lists the number of records returned by each of
your queries.
}
\description{
Run \code{query_wos} across multiple queries
}
\examples{
\dontrun{

queries <- c('TS = "dog welfare"', 'TS = "cat welfare"')
query_wos_apply(queries)
}
}
