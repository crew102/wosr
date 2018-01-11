one_incites_req <- function(one_batch, key, ...) {
  ut_string <- paste0(one_batch, collapse = ",")
  url <- paste0(
    "https://api.thomsonreuters.com/incites_ps/v1/DocumentLevelMetricsByUT/json?X-TR-API-APP-ID=",
    key, "&UT=", ut_string
  )
  resp <- httr::GET(url, ua(), ...)
  raw_txt <- httr::content(resp, as = "text", encoding = "UTF-8")
  if (grepl("rate limit quota violation", raw_txt, ignore.case = TRUE))
    stop("limit")
  json_resp <- jsonlite::fromJSON(raw_txt)
  temp_out <- json_resp$api$rval[[1]]
  if (is.data.frame(temp_out)) temp_out else NULL
}

#' Pull data from the InCites API
#'
#' @param uts A vector of UTs whose InCites data you would like to get from the
#' API's server. Each UT is a 15-digit identifier for a given publication. You
#' can specify the UT using only these 15 digits, or you can append the 15 digits
#' with "WOS:" (e.g., "000346263300011" or "WOS:000346263300011").
#' @param key The developer key that the server will use to authenticate your
#' account.
#' @param ... Arguments passed along to \code{\link[httr]{GET}}
#'
#' @return A data frame where each row corresponds to a different publication.
#' The definitions for the columns in this data frame can be found online at
#' the API's documentation \href{http://about.incites.thomsonreuters.com/api/#!/InCites_API_Methods/get_DocumentLevelMetricsByUT_format}{page} (thought note that the column names are all
#' converted to lower case by \code{pull_incites} and 0/1 flag variables
#' converted to booleans). Also note that not all publications that are indexed
#' in WoS are also indexed in InCites, so you may not receive data back for
#' some UTs.
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

  l <- length(uts)
  num_tot <- ceiling(l / 100)

  # requests are made in batches of 100...use trick of appending any batches
  # that aren’t 100 in size so they are, then calling unique on ut_vec...this
  # makes it easy to index ut_vec in a single fashion
  needs_uts <- num_tot * 100 - l
  if (needs_uts != 0) {
    to_add <- rep(uts[1], needs_uts)
    uts <- c(uts, to_add)
  }

  out_list <- vector(mode = "list", length = num_tot)

  if (num_tot != 0) {
   prog_bar <- utils::txtProgressBar(min = 0, max = num_tot, style = 3)
  }

  for (i in 1:num_tot) {

    start <- ((i - 1) * 100) + 1
    end <- i * 100
    one_batch <- unique(uts[start:end])

    tryCatch({
      out_list[[i]] <- one_incites_req(one_batch, key = key, ...)
    }, error = function(m) {
      msg <- paste0(m$message, collapse = " ")
      message("\nRan into the following error: '", msg, "'\n")
      if (grepl(pattern = "limit", x = msg, ignore.case = TRUE)) {
        message(
          "Pausing execution and retrying in 30 minutes. ",
          "Will restart execution at ", format(Sys.time() + 1800, "%X"), ".\n"
        )
        Sys.sleep(1800)
      }
      out_list[[i]] <<- try(one_incites_req(one_batch, key = key, ...))
    })

    if (num_tot != 0) {
      utils::setTxtProgressBar(prog_bar, i)
    }

    Sys.sleep(2)
  }

  unique(process_incites(do.call("rbind", out_list)))
}
