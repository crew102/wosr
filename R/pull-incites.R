#' Pull data from the InCites API
#'
#' \strong{Important note:} The throttling limits on the InCites API are not
#' documented anywhere and are difficult to determine from experience. As such,
#' whenever \code{pull_incites} receives a throttling error from the
#' server, it sleeps for 1 minute then retries the request. It does this up
#' to 30 times for each unique HTTP request it makes to the server.
#'
#' @param uts A vector of UTs whose InCites data you would like to get from the
#' API's server. Each UT is a 15-digit identifier for a given publication. You
#' can specify the UT using only these 15 digits, or you can append the 15 digits
#' with "WOS:" (e.g., "000346263300011" or "WOS:000346263300011").
#' @param key The developer key that the server will use to authenticate your
#' account.
#' @param ... Arguments passed along to \code{\link[httr]{GET}}.
#'
#' @return A data frame where each row corresponds to a different publication.
#' The definitions for the columns in this data frame can be found online at
#' the API's documentation \href{http://about.incites.thomsonreuters.com/api/#/}{page}
#' (see the \code{DocumentLevelMetricsByUT} method details for definitions).
#' Note that the column names are all converted to lower case by
#' \code{pull_incites} and the 0/1 flag variables converted to booleans). Also note
#' that not all publications that are indexed in WoS are also indexed in
#' InCites, so you may not receive data back for some UTs.
#'
#' @examples
#' \dontrun{
#'
#' uts <- c(
#' "WOS:000346263300011", "WOS:000362312600021", "WOS:000279885800004",
#' "WOS:000294667500003", "WOS:000294946900020", "WOS:000412659200006"
#' )
#' pull_incites(uts, key = "some_key")
#'
#' pull_incites(c("000346263300011", "000362312600021"), key = "some_key")
#'}
#'
#' @export
pull_incites <- function(uts, key = Sys.getenv("INCITES_KEY"), ...) {
  uts <- gsub("^WOS:", "", uts)
  urls <- get_urls(uts = gsub("^WOS:", "", uts), key = key)
  out_list <- pbapply::pblapply(urls, try_incites_req, ... = ...)
  unique(process_incites(do.call("rbind", out_list)))
}

get_urls <- function(uts, key) {
  ut_list <- split_uts(uts)
  lapply(ut_list, get_url, key = key)
}

split_uts <- function(uts) {
  len <- seq_along(uts)
  f <- ceiling(len / 100)
  split(uts, f = f)
}

get_url <- function(uts, key) {
  paste0(
    "https://api.thomsonreuters.com/incites_ps/v1/DocumentLevelMetricsByUT/json?X-TR-API-APP-ID=",
    key,
    "&UT=",
    paste0(uts, collapse = ",")
  )
}

try_incites_req <- function(url, ...) {

  # Try making the HTTP request up to 30 times (spaced 1 minute apart)
  for (i in 1:30) {
    maybe_data <- try(one_incites_req(url, ...), silent = TRUE)
    if (!("try-error" %in% class(maybe_data))) {
      Sys.sleep(2)
      return(maybe_data)
    } else {
      if (grepl("limit", maybe_data[1])) {
        message("\nRan into throttling limit. Retrying request in 1 minute.")
        Sys.sleep(60)
      } else {
        stop(maybe_data[1])
      }
    }
  }

  stop("\n\nRan into throttling limit 30 times, stopping")
}

one_incites_req <- function(url, ...) {
  response <- httr::GET(url, ua(), ...)
  raw_txt <- httr::content(response, as = "text", encoding = "UTF-8")
  if (grepl("rate limit quota violation", raw_txt, ignore.case = TRUE))
    stop("limit")
  if (httr::http_error(response))
    stop(httr::http_status(response))
  json_resp <- jsonlite::fromJSON(raw_txt)
  maybe_data_frame <- json_resp$api$rval[[1]]
  if (is.data.frame(maybe_data_frame)) maybe_data_frame else NULL
}
