download_wos <- function(query_result, ...) {

  # Make sure query didn't return more than 100,000 results. The API doesn't
  # allow you to download a data set that is more than 100,000 records in size
  rec_cnt <- query_result$rec_cnt
  if (rec_cnt >= 100000) {
    stop(
        "Can't download result sets that have 100,000 or more records.
        Break your query into pieces using the PY tag." # add pointer to documentation
    )
  }

  # Return NA if no pubs matched the query
  if (rec_cnt == 0) return(NA)

  from <- seq(1, to = rec_cnt, by = 100)
  count <- rep(100, times = length(from))
  count[length(count)] <- rec_cnt - from[length(count)] + 1

  pbapply::pblapply(seq_len(length(from)), function(x) {
    response <- one_pull(
      query_result$query_id,
      first_record = from[x],
      count = count[x],
      sid = query_result$sid,
      ...
    )
    check_resp(
      response,
      message = "Got the following error when downloading data:\n\n"
    )
    response
  })

}

one_pull <- function(query_id, first_record, count, sid, ...) {

  # Create body of HTTP request, which asks for data for a given number of records
  # (count), starting at record number first_record. This allows paginated
  # download of results. Also note that you are passing along the ID for a
  # particular query, so that the server knows which result set to look in.
  body <- paste0(
    '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
    <ns2:retrieve xmlns:ns2="http://woksearch.v3.wokmws.thomsonreuters.com">
    <queryId>', query_id, '</queryId>
    <retrieveParameters>
    <firstRecord>', first_record, '</firstRecord>
    <count>', count, '</count></retrieveParameters>
    </ns2:retrieve>
    </soap:Body>
    </soap:Envelope>'
  )

  # Function to send a request to the API
  one_post <- function() {
    httr::POST(
      "http://search.webofknowledge.com/esti/wokmws/ws/WokSearch",
      body = body,
      httr::add_headers("cookie" = paste0("SID=", sid)),
      ua(), ...
    )
  }

  # If you run into throttling error (2 calls per second per SID), just make
  # request again (up to three tries)
  for (i in 1:3) {
    response <- one_post()
    maybe_error <- try(check_resp(response, ""), silent = TRUE)
    if (!("try-error" %in% class(maybe_error))) {
      return(response)
    } else {
      if (!grepl("throttle", maybe_error[1], ignore.case = TRUE))
        return(response)
    }
  }
}
