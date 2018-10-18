#' Pull data from the Web of Science
#'
#' \code{pull_wos} wraps the process of querying, downloading, parsing, and
#' processing the Web of Science data that the API serves.
#'
#' @inheritParams query_wos
#'
#' @return A list of the following data frames:
#'  \describe{
#'    \item{publication}{A data frame where each row corresponds to a different
#'    publication. Note that each publication has a distinct \code{ut}. There is
#'    a one-to-one relationship between a \code{ut} and each of the fields
#'    in this table.}
#'
#'    \item{author}{A data frame where each row corresponds to a different
#'    publication/author pair (i.e., a \code{ut}/\code{author_no} pair). In
#'    other words, each row corresponds to a different author on a publication.
#'    You can link the authors in this table to the \code{address} and
#'    \code{author_address} tables to get their addresses (if they exist). See
#'    example in vignette for details.}
#'
#'    \item{address}{A data frame where each row corresponds to a different
#'    publication/address pair (i.e., a \code{ut}/\code{addr_no} pair). In
#'    other words, each row corresponds to a different address on a publication.
#'    You can link the addresses in this table to the \code{author} and
#'    \code{author_address} tables to see which authors correspond to which
#'    addresses. See example in vignette for details.}
#'
#'    \item{author_address}{A data frame that specifies which authors correspond
#'    to which addresses on a given publication. This data frame is meant to
#'    be used to link the \code{author} and \code{address} tables together.}
#'
#'    \item{jsc}{A data frame where each row corresponds to a different
#'    publication/jsc (journal subject category) pair. There is a many-to-many
#'    relationship between \code{ut}'s and \code{jsc}'s.}
#'
#'    \item{keyword}{A data frame where each row corresponds to a different
#'    publication/keyword pair. These keywords are the author-assigned keywords.}
#'
#'    \item{keywords_plus}{A data frame where each row corresponds to a different
#'    publication/keywords_plus pair. These keywords are the keywords assigned
#'    by the Web of Science through an automated process.}
#'
#'    \item{grant}{A data frame where each row corresponds to a different
#'    publication/grant agency/grant ID triplet. Not all publications acknowledge
#'    a specific grant number in the funding acknowledgement section, hence the
#'    \code{grant_id} field can be \code{NA}.}
#'
#'    \item{doc_type}{A data frame where each row corresponds to a different
#'    publication/document type pair.}
#'  }
#'
#' @examples
#' \dontrun{
#'
#' sid <- auth("your_username", password = "your_password")
#' pull_wos("TS = (dog welfare) AND PY = 2010", sid = sid)
#'
#' # Re-use session ID. This is best practice to avoid throttling limits:
#' pull_wos("TI = \"dog welfare\"", sid = sid)
#'
#' # Get fresh session ID:
#' pull_wos("TI = \"pet welfare\"", sid = auth("your_username", "your_password"))
#'
#' # It's best to see how many records your query matches before actually
#' # downloading the data. To do this, call query_wos before running pull_wos:
#' query <- "TS = ((cadmium AND gill*) NOT Pisces)"
#' query_wos(query, sid = sid) # shows that there are 1,611 matching publications
#' pull_wos(query, sid = sid)
#'}
#' @export
pull_wos <- function(query,
                     editions = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP",
                                  "BSCI", "BHCI", "IC", "CCR", "ESCI"),
                     sid = auth(Sys.getenv("WOS_USERNAME"),
                                Sys.getenv("WOS_PASSWORD")),
                     ...) {

  # First send the query to the API and get back the metadata we'll need to set
  # up the downloading of the data
  qr_out <- query_wos(query, editions = editions, sid = sid, ...)

  # Create empty list enforce_schema will fill with empty data frames
  if (qr_out$rec_cnt == 0) {
    dfs <- unique(schema$df)
    wos_unenforced <- vector("list", length = length(dfs))
    names(wos_unenforced) <- dfs
  } else {
    # Download the raw XML and put it in a list
    message("Downloading data\n")
    all_resps <- download_wos(qr_out, ...)
    all_resps <- all_resps[vapply(all_resps, length, numeric(1)) > 1]

    # Parse out various fields
    message("\nParsing XML\n")
    parse_list <- parse_wos(all_resps)

    # Create data frames from list of parsed fields
    df_list <- data_frame_wos(parse_list)
    wos_unenforced <- process_wos_apply(df_list)
  }
  wos_data <- enforce_schema(wos_unenforced)
  append_class(wos_data, "wos_data")
}
