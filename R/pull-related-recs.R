#' Pull related records
#'
#' Pull the records that have at least one citation in common with a publication
#' of interest
#'
#' @inheritParams query_wos
#' @param num_recs Number of related records to pull for each UT
#'
#' @return A data frame with the following columns:
#'  \describe{
#'    \item{ut}{The publications that you passed into \code{pull_related_rds}.
#'    If one of your publications doesn't have any related records, it won't
#'    appear here.}
#'
#'    \item{related_rec}{The publication that is related to \code{ut}.}
#'
#'    \item{rec_num}{The related record's ordering in the result set returned
#'    by the API. Records that share more citations with your UTs will have
#'    lower \code{rec_num}s.}
#'  }
#'
#' @examples
#' \dontrun{
#'
#' sid <- auth("your_username", password = "your_password")
#' uts <- c("WOS:000272877700013", "WOS:000272366800025")
#' out <- pull_related_recs(uts, 5, sid = sid)
#'}
#' @export
pull_related_recs <- function(uts,
                              num_recs,
                              editions = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP",
                                           "BSCI", "BHCI", "IC", "CCR", "ESCI"),
                              sid = auth(Sys.getenv("WOS_USERNAME"),
                                         Sys.getenv("WOS_PASSWORD")),
                              ...) {

  if (num_recs > 100) {
    stop("num_recs cannot be greater than 100", call. = FALSE)
  }
  uts <- trim_uts(uts)
  out <- pbapply::pblapply(
    uts, pull_one_ut_of_related_recs,
    num_recs = num_recs,
    editions = editions,
    sid = sid,
    ... = ...
  )
  full_mat <- do.call(rbind, out)
  cast_related_recs(full_mat)
}

pull_one_ut_of_related_recs <- function(ut, num_recs, editions, sid, ...) {
  body <- get_rr_body(ut, num_recs, editions)
  response <- retry_throttle(wok_search(body, sid, ...))

  # if the record doesn't have any citations, the API will return an HTTP error
  # starting with "Exception occurred processing request"
  c_resp <- try(check_resp(response), silent = TRUE)
  if ("try-error" %in% class(c_resp)) {
    msg <- attributes(c_resp)$condition$message
    if (grepl("Exception occurred processing request", msg, ignore.case = TRUE)) {
      Sys.sleep(1)
      return(NULL)
    } else {
      stop(msg)
    }
  }

  doc <- get_xml(response)
  rfound <- parse_el_txt(doc, "//recordsfound")
  if (is.na(rfound) || rfound == "0") {
    out <- NULL
  } else {
    uts <- parse_el_txt(doc, '//optionvalue/value')
    ut <- paste0("WOS:", rep(ut, length(uts)))
    out <- matrix(c(ut, uts, seq_along(uts)), ncol = 3)
  }
  Sys.sleep(1)
  out
}

get_rr_body <- function(ut, num_recs, editions) {
  paste0(
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:woksearch="http://woksearch.v3.wokmws.thomsonreuters.com">
    <soapenv:Header/>
    <soapenv:Body>
    <woksearch:relatedRecords>
    <databaseId>WOS</databaseId>
    <uid>', ut, '</uid>',
    paste_eds(editions),
    '<queryLanguage>en</queryLanguage>
    <retrieveParameters>
    <firstRecord>1</firstRecord>
    <count>', num_recs, '</count>
    <option>
    <key>RecordIDs</key>
    <value>On</value>
    </option>
    </retrieveParameters>
    </woksearch:relatedRecords>
    </soapenv:Body>
    </soapenv:Envelope>'
  )
}

cast_related_recs <- function(full_mat) {

  df <- as.data.frame(full_mat, stringsAsFactors = FALSE)
  if (!nrow(df)) {
    df <- data.frame(matrix(ncol = 3, nrow = 0), stringsAsFactors = FALSE)
  }
  colnames <- c("ut", "related_rec", "rec_num")
  colnames(df) <- colnames

  df$ut <- as.character(df$ut)
  df$related_rec <- as.character(df$related_rec)
  df$rec_num <- as.numeric(df$rec_num)

  df
}
