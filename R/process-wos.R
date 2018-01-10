process_wos <- function(x) UseMethod("process_wos")

process_wos.default <- function(x) x

process_wos.wos_data <- function(x) {

  proc_out <- lapply(x, function(y)
    process_wos(replace_if_0_rows(y, replace = NA))
  )
  author_address <- proc_out$author[[2]]
  proc_out$author <- proc_out$author[[1]]

  temp_out <- c(
    proc_out[1:3],
    author_address = NA,
    proc_out[4:length(proc_out)]
  )
  temp_out$author_address <- author_address

  # have to remove _df classes on data frames and add back wos_data class
  # on list of data frames so that printing is nice
  wos_data <- lapply(temp_out, function(y) structure(y, class = "data.frame"))
  structure(wos_data, class = c("list", "wos_data"))
}

process_wos.publication_df <- function(x) {
  colnames(x)[colnames(x) == "local_count"] <- "tot_cites"
  colnames(x)[colnames(x) == "value"] <- "doi"
  colnames(x)[colnames(x) == "sortdate"] <- "date"
  x$journal <- to_title_case(x$journal)
  x$date <- as.Date(x$date)
  x$tot_cites <- as.numeric(x$tot_cites)
  x
}

# Have to convert to lower first if you want to use toTitleCase for strings that
# are in all caps
to_title_case <- function(x) tools::toTitleCase(tolower(x))

process_wos.author_df <- function(x) {

  colnames(x)[colnames(x) == "seq_no"] <- "author_no"
  x$author_no <- as.numeric(x$author_no)

  splt <- strsplit(x$addr_no, " ")
  times <- vapply(splt, function(x) if (is.na(x[1])) 0 else length(x), numeric(1))
  ut <- rep(x$ut, times)
  author_no <- rep(x$author_no, times)
  addr_no <- unlist(splt[vapply(splt, function(x) !is.na(x[1]), logical(1))])

  author_address_link <- data.frame(
    ut = ut,
    author_no = author_no,
    addr_no = as.numeric(addr_no),
    stringsAsFactors = FALSE
  )

  x$addr_no <- NULL
  author_cols <- c(
    "ut", "author_no", "display_name", "first_name", "last_name",
    "email", "daisng_id"
  )
  list(
    x[, author_cols],
    replace_if_0_rows(author_address_link, replace = NA)
  )
}

process_wos.address_df <- function(x) {
  x$addr_no <- as.numeric(x$addr_no)
  x[, c("ut", "addr_no", "org_pref", "org", "city", "state", "country")]
}

process_wos.jsc_df <- function(x) {
  # There are duplicate JSC values (differing only in capitilization). Remove these.
  x$jsc <- to_title_case(x$jsc)
  unique(x)
}

process_wos.keywords_plus_df <- function(x) {
  # "keywords plus" keywords are in upper-case, but regular keywords are in
  # lower case. standardize to one case (lower).
  x$keywords_plus <- tolower(x$keywords_plus)
  x
}

process_wos.keyword_df <- function(x) {
  x$keyword <- tolower(x$keyword)
  x
}
