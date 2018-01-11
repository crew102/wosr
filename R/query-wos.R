#' Query the Web of Science
#'
#' Returns the number of records that match a given query. It's best to call
#' this function before calling \code{\link{pull_wos}}, so that you know how
#' many records you are trying to download before you attempt to download them.
#'
#' @param query Query string. See the \href{https://images.webofknowledge.com/images/help/WOK/hs_search_operators.html#dsy863-TRS_search_operator_precedence}{WoS query documentation} page
#' for details on how to write a query and the list of \href{http://images.webofknowledge.com.ezproxy.lib.vt.edu/WOKRS527R13/help/WOS/hp_advanced_examples.html}{example queries}.
#' @param editions Web of Science editions to query. Possible values are listed
#' \href{http://ipscience-help.thomsonreuters.com/wosWebServicesLite/dbEditionsOptionsGroup/databaseEditionsWos.html}{online}.
#' @param sid Session identifier (SID). The default setting is to get a fresh
#' SID each time you query the WoS, via a call to \code{\link{auth}}. However,
#' you should try to reuse SID values over multiple queries so that you don't
#' run into the throttling limits placed on new sessions.
#' @param ... Arguments passed along to \code{\link[httr]{POST}}
#'
#' @return An object of class \code{query_result}. This object has the number
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
#' # The following queries were taken from the online examples:
#'
#' # Finds records in which Max Planck appears in the Address field.
#' query_wos("AD = Max Planck", sid = sid)
#'
#' # Finds records in which Max Planck appears in the same address as Mainz
#' query_wos("AD = (Max Planck SAME Mainz)", sid = sid)
#'
#' # Finds records in which this grant number appears in the Grant Number field
#' # within the Funding Acknowledgment table
#' query_wos("FG = IRG-58-00*", sid = sid)
#' }
#'
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
  check_resp(response, message = "Download threw the following error:\n\n")

  # Pull out metadata from XML
  doc <- get_xml(response)
  query_id <- parse_el_txt(doc, xpath = "//queryid")
  rec_cnt <- parse_el_txt(doc, xpath = "//recordsfound")

  # need to add print method
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

# make sure this works
escape_query <- function(query) gsub("&", "&amp;", query)
