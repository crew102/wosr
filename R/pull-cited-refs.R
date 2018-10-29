#' Pull cited references
#'
#' @inheritParams query_wos
#' @param uts Vector of UTs (i.e., publications) whose cited references you want.
#'
#' @return A data frame with the following columns:
#'  \describe{
#'    \item{ut}{The publication that is doing the citing. These are the UTs that
#'    you submitted to \code{pull_cited_refs}. If one of your publications
#'    doesn't have any cited refs, it will not appear in this column.}
#'
#'    \item{doc_id}{The cited ref's document identifier (similar to a UT).}
#'
#'    \item{title}{Roughly equivalent to the cited ref's title.}
#'
#'    \item{journal}{Roughly equivalent to the cited ref's journal.}
#'
#'    \item{author}{The cited ref's first author.}
#'
#'    \item{tot_cites}{The total number of citations the cited ref has received.}
#'
#'    \item{year}{The cited ref's publication year.}
#'
#'    \item{page}{The cited ref's page number.}
#'
#'    \item{volume}{The cited ref's journal volume.}
#'  }
#'
#' @examples
#' \dontrun{
#'
#' sid <- auth("your_username", password = "your_password")
#' uts <- c("WOS:000362312600021", "WOS:000439855300030", "WOS:000294946900020")
#' pull_cited_refs(uts, sid)
#'}
#' @export
pull_cited_refs <- function(uts,
                            sid = auth(Sys.getenv("WOS_USERNAME"),
                                       Sys.getenv("WOS_PASSWORD")),
                            ...) {
  uts <- trim_uts(uts)
  out <- pbapply::pblapply(uts, pull_one_ut_of_cited_refs, sid = sid, ... = ...)
  full_df <- do.call(rbind, out)
  cast_cited_ref_df(full_df)
}

pull_one_ut_of_cited_refs <- function(ut, sid, ...) {

  qry_res <- try(retry_throttle(query_cited_refs(ut, sid, ...)), silent = TRUE)
  if ("try-error" %in% class(qry_res)) {
    msg <- attributes(qry_res)$condition$message
    if (grepl("No document found for requested UID", msg, ignore.case = TRUE)) {
      Sys.sleep(1)
      return(NULL)
    } else {
      stop(msg)
    }
  }
  if (qry_res$rec_cnt == 0) {
    Sys.sleep(1)
    return(NULL)
  }

  first_records <- (ceiling(qry_res$rec_cnt / 100) - 1) * 100 + 1
  list_of_lists <- lapply(first_records, function(x, ...) {
    retry_throttle(pull_one_set_of_cited_refs(qry_res$query_id, x, sid, ...))
  })

  res_list <- do.call(c, list_of_lists)
  res_df <- do.call(rbind, lapply(res_list, unlist))
  res_df <- cbind(rep(paste0("WOS:", ut), nrow(res_df)), res_df)
  colnames(res_df)[1] <- "ut"

  # have to sleep here to avoid throttling error
  Sys.sleep(1)
  res_df
}

query_cited_refs <- function(ut, sid, ...) {
  body <- paste0(
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:woksearch="http://woksearch.v3.wokmws.thomsonreuters.com">
    <soapenv:Header/>
    <soapenv:Body>
    <woksearch:citedReferences>
    <databaseId>WOS</databaseId>
    <uid>', ut, '</uid>
    <queryLanguage>en</queryLanguage>
    <retrieveParameters>
    <firstRecord>1</firstRecord>
    <count>1</count>
    </retrieveParameters>
    </woksearch:citedReferences>
    </soapenv:Body>
    </soapenv:Envelope>'
  )
  response <- wok_search(body, sid, ...)
  check_resp(response)

  doc <- get_xml(response)
  query_id <- parse_el_txt(doc, xpath = "//queryid")
  rec_cnt <- parse_el_txt(doc, xpath = "//recordsfound")
  list(
    query_id = as.numeric(query_id),
    rec_cnt = as.numeric(rec_cnt)
  )
}

pull_one_set_of_cited_refs <- function(query_id, first_record, sid, ...) {
  body <- paste0(
    '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Header/>
    <soap:Body>
    <woksearch:citedReferencesRetrieve xmlns:woksearch="http://woksearch.v3.wokmws.thomsonreuters.com">
    <queryId>', query_id, '</queryId>
    <retrieveParameters>
    <firstRecord>', first_record, '</firstRecord>
    <count>100</count>
    </retrieveParameters>
    </woksearch:citedReferencesRetrieve>
    </soap:Body>
    </soap:Envelope>'
  )
  response <- wok_search(body, sid, ...)
  check_resp(response)

  doc <- get_xml(response)
  doc_list <- xml_find_all(doc, xpath = "//return")

  xpath <- c(
    doc_id = ".//docid[1]",
    title = ".//citedtitle[1]",
    journal = ".//citedwork[1]",
    author = ".//citedauthor[1]",
    tot_cites = ".//timescited[1]",
    year = ".//year[1]",
    page = ".//page[1]",
    volume = ".//volume[1]"
  )
  parse_els_apply(doc_list, xpath = xpath)
}

cast_cited_ref_df <- function(df) {
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  if (!nrow(df)) {
    cols <- c(
      "ut", "doc_id", "title", "journal", "author",
      "tot_cites", "year", "page", "volume"
    )
    lst <- vector("list", length(cols))
    names(lst) <- cols
    df <- as.data.frame(lapply(lst, as.character), stringsAsFactors = FALSE)
  }
  df$tot_cites <- as.numeric(df$tot_cites)
  df$year <- as.numeric(df$year)
  df
}
