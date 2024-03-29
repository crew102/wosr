% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pull-wos.R
\name{pull_wos}
\alias{pull_wos}
\title{Pull data from the Web of Science}
\usage{
pull_wos(
  query,
  editions = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP", "BSCI", "BHCI", "IC", "CCR",
    "ESCI"),
  sid = auth(Sys.getenv("WOS_USERNAME"), Sys.getenv("WOS_PASSWORD")),
  ...
)
}
\arguments{
\item{query}{Query string. See the \href{https://images.webofknowledge.com/images/help/WOK/hs_search_operators.html#dsy863-TRS_search_operator_precedence}{WoS query documentation} page
for details on how to write a query as well as this list of \href{http://images.webofknowledge.com.ezproxy.lib.vt.edu/WOKRS527R13/help/WOS/hp_advanced_examples.html}{example queries}.}

\item{editions}{Web of Science editions to query. Possible values are listed
\href{http://ipscience-help.thomsonreuters.com/wosWebServicesLite/dbEditionsOptionsGroup/databaseEditionsWos.html}{here}.}

\item{sid}{Session identifier (SID). The default setting is to get a fresh
SID each time you query WoS via a call to \code{\link{auth}}. However,
you should try to reuse SIDs across queries so that you don't run into the
throttling limits placed on new sessions.}

\item{...}{Arguments passed along to \code{\link[httr]{POST}}.}
}
\value{
A list of the following data frames:
 \describe{
   \item{publication}{A data frame where each row corresponds to a different
   publication. Note that each publication has a distinct \code{ut}. There is
   a one-to-one relationship between a \code{ut} and each of the columns
   in this table.}

   \item{author}{A data frame where each row corresponds to a different
   publication/author pair (i.e., a \code{ut}/\code{author_no} pair). In
   other words, each row corresponds to a different author on a publication.
   You can link the authors in this table to the \code{address} and
   \code{author_address} tables to get their addresses (if they exist). See
   example in FAQs for details.}

   \item{address}{A data frame where each row corresponds to a different
   publication/address pair (i.e., a \code{ut}/\code{addr_no} pair). In
   other words, each row corresponds to a different address on a publication.
   You can link the addresses in this table to the \code{author} and
   \code{author_address} tables to see which authors correspond to which
   addresses. See example in FAQs for details.}

   \item{author_address}{A data frame that specifies which authors correspond
   to which addresses on a given publication. This data frame is meant to
   be used to link the \code{author} and \code{address} tables together.}

   \item{jsc}{A data frame where each row corresponds to a different
   publication/jsc (journal subject category) pair. There is a many-to-many
   relationship between \code{ut}'s and \code{jsc}'s.}

   \item{keyword}{A data frame where each row corresponds to a different
   publication/keyword pair. These are the author-assigned keywords.}

   \item{keywords_plus}{A data frame where each row corresponds to a different
   publication/keywords_plus pair. These keywords are the keywords assigned
   by Clarivate Analytics through an automated process.}

   \item{grant}{A data frame where each row corresponds to a different
   publication/grant agency/grant ID triplet. Not all publications acknowledge
   a specific grant number in the funding acknowledgement section, hence the
   \code{grant_id} field can be \code{NA}.}

   \item{doc_type}{A data frame where each row corresponds to a different
   publication/document type pair.}
 }
}
\description{
\code{pull_wos} wraps the process of querying, downloading, parsing, and
processing Web of Science data.
}
\examples{
\dontrun{

sid <- auth("your_username", password = "your_password")
pull_wos("TS = (dog welfare) AND PY = 2010", sid = sid)

# Re-use session ID. This is best practice to avoid throttling limits:
pull_wos("TI = \"dog welfare\"", sid = sid)

# Get fresh session ID:
pull_wos("TI = \"pet welfare\"", sid = auth("your_username", "your_password"))

# It's best to see how many records your query matches before actually
# downloading the data. To do this, call query_wos before running pull_wos:
query <- "TS = ((cadmium AND gill*) NOT Pisces)"
query_wos(query, sid = sid) # shows that there are 1,611 matching publications
pull_wos(query, sid = sid)
}
}
