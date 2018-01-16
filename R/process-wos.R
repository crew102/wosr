process_wos_apply <- function(df_list) {

  proc_out <- lapply(df_list, function(x) process_wos(x))

  # Pull out data frames in proc_out$author and reorder dfs
  temp_out <- c(
    proc_out[1], # publication
    proc_out$author[1], # author
    proc_out[3], # address
    proc_out$author[2], # author_address
    proc_out[4:length(proc_out)] # rest of columns
  )

  # have to remove _df classes on data frames and add back wos_data class
  # on list of data frames so that printing is nice
  wos_data <- lapply(temp_out, structure, class = "data.frame")
  append_class(wos_data, "wos_data")
}

process_wos <- function(x) UseMethod("process_wos")

process_wos.default <- function(x) x

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
  x$daisng_id <- as.numeric(x$daisng_id)

  splt <- strsplit(x$addr_no, " ")
  times <- vapply(splt, function(x) if (is.na(x[1])) 0 else length(x), numeric(1))
  ut <- rep(x$ut, times)
  author_no <- rep(x$author_no, times)
  addr_no <- unlist(splt[vapply(splt, function(x) !is.na(x[1]), logical(1))])

  if (sum(times) != 0)  # if there is a need for a author_address table b/c data exists
    author_address <- data.frame(
      ut = ut,
      author_no = author_no,
      addr_no = as.numeric(addr_no),
      stringsAsFactors = FALSE
    )
  else
    author_address <- NA

  author_cols <- c(
    "ut", "author_no", "display_name", "first_name", "last_name",
    "email", "daisng_id"
  )
  list(
    author = x[, author_cols],
    author_address = author_address
  )
}

process_wos.address_df <- function(x) {
  x$addr_no <- as.numeric(x$addr_no)
  x[, c("ut", "addr_no", "org_pref", "org", "city", "state", "country")]
}

process_wos.jsc_df <- function(x) {
  # There are duplicate JSC values (differing only in capitalization). Remove these.
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
