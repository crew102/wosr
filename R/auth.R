#' Authenticate user credentials
#'
#' \code{auth} asks the API server for a session ID (SID), which will later be
#' passed to either \code{\link{query_wos}} or \code{\link{pull_wos}}. Note,
#' there are limits on how many SIDs you can get in a given period of time
#' (roughly 5 SIDs in a 5 minute time period).
#'
#' @return A length-1 character vector containing a session ID.
#'
#' @export
auth <- function() {

  body <-
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:auth="http://auth.cxf.wokmws.thomsonreuters.com">
    <soapenv:Header/>
    <soapenv:Body>
    <auth:authenticate/>
    </soapenv:Body>
    </soapenv:Envelope>'

  # add headers

  # Send HTTP POST request
  response <- httr::POST(
    url = 'http://search.webofknowledge.com/esti/wokmws/ws/WOKMWSAuthenticate',
    body = body,
    httr::authenticate('XXX', password = 'XXX'),
    httr::timeout(30)
  )

  # Confirm server didn't throw an error
  check_resp(
    response,
    message = "Received the following error when authenticating with server:\n\n"
  )

  # Pull out SID from XML
  doc <- get_xml(response)
  parse_el_txt(doc, "//return")
}
