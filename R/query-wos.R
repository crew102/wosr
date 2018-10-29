#' Query the Web of Science
#'
#' Returns the number of records that match a given query. It's best to call
#' this function before calling \code{\link{pull_wos}} so that you know how
#' many records you're trying to download before attempting to do so.
#'
#' @param query Query string. See the \href{https://images.webofknowledge.com/images/help/WOK/hs_search_operators.html#dsy863-TRS_search_operator_precedence}{WoS query documentation} page
#' for details on how to write a query as well as this list of \href{http://images.webofknowledge.com.ezproxy.lib.vt.edu/WOKRS527R13/help/WOS/hp_advanced_examples.html}{example queries}.
#' @param editions Web of Science editions to query. Possible values are listed
#' \href{http://ipscience-help.thomsonreuters.com/wosWebServicesLite/dbEditionsOptionsGroup/databaseEditionsWos.html}{here}.
#' @param sid Session identifier (SID). The default setting is to get a fresh
#' SID each time you query WoS via a call to \code{\link{auth}}. However,
#' you should try to reuse SIDs across queries so that you don't run into the
#' throttling limits placed on new sessions.
#' @param ... Arguments passed along to \code{\link[httr]{POST}}.
#'
#' @return An object of class \code{query_result}. This object contains the number
#' of publications that are returned by your query (\code{rec_cnt}), as well as
#' some info that \code{\link{pull_wos}} uses when it calls \code{query_wos}
#' internally.
#'
#' @examples
#' \dontrun{
#'
#' # Get session ID and reuse it across queries:
#' sid <- auth("some_username", password = "some_password")
#'
#' query_wos("TS = (\"dog welfare\") AND PY = (1990-2007)", sid = sid)
#'
#' # Finds records in which Max Planck appears in the address field.
#' query_wos("AD = Max Planck", sid = sid)
#'
#' # Finds records in which Max Planck appears in the same address as Mainz
#' query_wos("AD = (Max Planck SAME Mainz)", sid = sid)
#' }
#' @export
query_wos <- function(query,
                      editions = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP",
                                   "BSCI", "BHCI", "IC", "CCR", "ESCI"),
                      sid = auth(Sys.getenv("WOS_USERNAME"),
                                 Sys.getenv("WOS_PASSWORD")),
                      ...) {

  # Create XML body to POST to server
  body <- paste0(
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:woksearch="http://woksearch.v3.wokmws.thomsonreuters.com">
    <soapenv:Header/>
    <soapenv:Body>
    <woksearch:search>
    <queryParameters>
    <databaseId>WOS</databaseId>
    <userQuery> ', escape_query(query), ' </userQuery>',
    paste_eds(editions),
    '<queryLanguage>en</queryLanguage>
    </queryParameters>
    <retrieveParameters>
    <firstRecord>1</firstRecord>
    <count>0</count>
    </retrieveParameters>
    </woksearch:search>
    </soapenv:Body>
    </soapenv:Envelope>'
  )

  # Send HTTP request
  response <- httr::POST(
    "http://search.webofknowledge.com/esti/wokmws/ws/WokSearch",
    body = body,
    httr::add_headers("cookie" = sprintf("SID=%s", sid)),
    ua(),
    ...
  )

  # Confirm server didn't throw an error
  check_resp(response)

  # Pull out metadata from XML
  doc <- get_xml(response)
  query_id <- parse_el_txt(doc, xpath = "//queryid")
  rec_cnt <- parse_el_txt(doc, xpath = "//recordsfound")

  structure(
    list(
      query_id = as.numeric(query_id),
      rec_cnt = as.numeric(rec_cnt),
      sid = sid
    ),
    class = "query_result"
  )
}

# Create part of XML body that contains the WOS editions that should be searched
# for a given query
paste_eds <- function(editions) {

  edition_vec <- sprintf(
    "<editions>
    <collection>WOS</collection>
    <edition>%s</edition>
    </editions>", editions
  )

  paste(edition_vec, collapse = " ")
}

escape_query <- function(query) gsub("&", "&amp;", query)

#' Create a vector of UT-based queries
#'
#' Use this function when you have a bunch of UTs whose data you want to pull
#' and you need to write a series of UT-based queries to do so (i.e., queries
#' in the form "UT = (WOS:000186387100005 OR WOS:000179260700001)").
#'
#' @param uts UTs that will be placed inside the UT-based queries.
#' @param uts_per_query Number of UTs to include in each query. Note, there is
#' a limit on how long your query can be, so you probably want to keep this set
#' to around 200.
#'
#' @return A vector of queries. You can feed these queries to
#' \code{\link{pull_wos_apply}} to download data for each query.
#'
#' @examples
#' \dontrun{
#'
#' data <- pull_wos('TS = ("animal welfare") AND PY = (2002-2003)')
#' queries <- create_ut_queries(data$publication$ut)
#' pull_wos_apply(queries)
#'}
#' @export
create_ut_queries <- function(uts, uts_per_query = 200) {
  ut_list <- split(uts, ceiling(seq_along(uts) / uts_per_query))
  vapply(
    ut_list,
    function(x) sprintf("UT = (%s)", paste0(x, collapse = " OR ")),
    character(1)
  )
}

