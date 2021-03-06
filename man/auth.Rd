% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auth.R
\name{auth}
\alias{auth}
\title{Authenticate user credentials}
\usage{
auth()
}
\value{
A length-1 character vector containing a session ID.
}
\description{
\code{auth} asks the API server for a session ID (SID), which will later be
passed to either \code{\link{query_wos}} or \code{\link{pull_wos}}. Note,
there are limits on how many SIDs you can get in a given period of time
(roughly 5 SIDs in a 5 minute time period).
}
