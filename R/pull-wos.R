#' "Pull" data from the WoS API.
#'
#' This function wraps the process of querying, downloading, parsing, and processing
#' the data that the API gives.
#'
#' @inheritParams query_wos
#'
#' @export
pull_wos <- function(query,
                     edition = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP",
                                  "BSCI", "BHCI", "IC", "CCR", "ESCI"),
                     sid = auth(Sys.getenv("WOS_USERNAME"),
                                Sys.getenv("WOS_PASSWORD")),
                     ...) {

  # First send the query to the API and get back the metadata we'll need to set
  # up the downloading of the data
  qr_out <- query_wos(
    query,
    edition = edition,
    email = email,
    sid = sid
  )

  # Return NA if query didn't match any results
  if (qr_out$rec_cnt == 0) return(NA)

  # Download the raw XML and put it in a list
  message("Downloading data\n")
  all_resps <- download_wos(qr_out, ...)
  all_resps <- all_resps[vapply(all_resps, length, numeric(1)) > 1]

  # Parse out various fields
  message("\nParsing XML\n")
  parse_list <- parse_wos(all_resps)

  # Create data frames from list of parsed fields
  dfs <- data_frame_wos(parse_list)
  process_wos_apply(dfs)
}
