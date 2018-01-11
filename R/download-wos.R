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

  # Function to send a request for WoS data to API
  one_post <- function() {
    httr::POST(
      "http://search.webofknowledge.com/esti/wokmws/ws/WokSearch",
      body = body,
      httr::add_headers("cookie" = paste0("SID=", sid)),
      ua(), ...
    )
  }

  # If you run into throttling error (2 calls per second per SID), just make
  # request again (up to three trys)
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

  full_rnds <- floor(rec_cnt / 100)
  i_pst_rnds <- full_rnds * 100
  left_over <- rec_cnt - i_pst_rnds
  bool_left_over <- left_over > 0
  length_out <- full_rnds + bool_left_over
  all_resps <- vector(mode = "list", length = length_out)

  # change this loop to use pbapply

  # For each "round" of records (i.e., set of 100 publications), we download
  # the data from the API and put it in the all_resps list.
  if (full_rnds > 0) {
    prog_bar <- utils::txtProgressBar(min = 0, max = full_rnds, style = 3)
    for (i in 1:full_rnds) {
      response <- one_pull(
        query_result$query_id,
        first_record = 100 * i - 99,
        count = 100,
        sid = query_result$sid,
        ...
      )
      check_resp(response, message = "") # add message here?
      all_resps[[i]] <- response

      utils::setTxtProgressBar(prog_bar, i)
    }
  }

  # The left_over records are the final records that were not captured in the
  # sets of 100 records
  if (left_over > 0) {
    response <- one_pull(
      query_result$query_id,
      first_record = i_pst_rnds + 1,
      count =  left_over,
      sid = query_result$sid,
      ...
    )
    check_resp(response, message = "Got the following error when downloading data:\n\n")
    all_resps[[length_out]] <- response
  }

  all_resps
}
