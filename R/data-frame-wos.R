# Wrapper around creation of data frames from (list of) list of parse fields
data_frame_wos <- function(parse_list) {
  # Create list of data frame sets, one set of dfs for each round of downloading
  df_list <- lapply(parse_list, get_dfs)
  # bind data frames together
  wos_data <- suppressWarnings(bind_dfs(df_list))
  structure(wos_data, class = c(class(wos_data), "wos_data"))
}

# Create various data frames
get_dfs <- function(one_set) {

  publication <- get_pub_df(one_set$pub_parselist)
  ut_value_dfs <- get_ut_value_dfs(one_set$pub_parselist)

  ut_vec <- publication$ut
  author <- nested_list_to_df(one_set$author_parselist, ut_vec = ut_vec)
  address <- nested_list_to_df(one_set$address_parselist, ut_vec = ut_vec)
  grant <- nested_list_to_df(one_set$grant_parselist, ut_vec = ut_vec)

  list(
    publication = publication,
    author = author,
    address = address,
    jsc = ut_value_dfs$jsc,
    keyword = ut_value_dfs$keyword,
    keywords_plus = ut_value_dfs$keywords_plus,
    grant = grant
  )
}

# Get publication-level data frame from parsed field list
get_pub_df <- function(pub_list) {

  pub_level <- c(
    "ut", "title", "journal", "sortdate", "doc_type", "value", "local_count"
  )

  cols <- lapply(pub_list, function(x) {
    vec <- unlist(x[pub_level])
    if (length(vec) != length(pub_level)) return(NA)
    abstract <- x[["abstract"]]
    abs2 <- if (is.na(abstract[1])) NA else paste0(abstract, collapse = " ")
    names(abs2) <- "abstract"
    c(vec, abs2)
  })

  as.data.frame(do.call(rbind, cols), stringsAsFactors = FALSE)
}

# Get "UT-value" data frames (e.g., data frames with key value pairs, with the
# key being UT and value being some field)
get_ut_value_dfs <- function(pub_parselist) {
  n_df <- lapply(pub_parselist, one_ut_value_df)
  lapply2(ut_val_flds, function(f)
    do.call(rbind, lapply(n_df, function(x) x[[f]]))
  )
}

one_ut_value_df <- function(one_list) {
  lapply2(ut_val_flds, function(f) {
      vec <- one_list[[f]]
      if (is.na(vec[1]) || length(vec) == 0) return(NULL)
      len <- length(vec)
      ut <- rep(one_list$ut, len)
      df <- data.frame(
        ut = ut,
        f = vec,
        stringsAsFactors = FALSE
      )
      colnames(df)[2] <- f
      df
    }
  )
}

ut_val_flds <- c("jsc", "keyword", "keywords_plus", "grant_number", "grant_agency")

nested_list_to_df <- function(list, ut_vec) {
  times <- vapply(list, function(x) if (is.matrix(x)) nrow(x) else 0, numeric(1))
  ut <- rep(ut_vec, times)
  binded <- do.call(rbind, list)
  df <- as.data.frame(binded, stringsAsFactors = FALSE)
  cbind.data.frame(ut, df, stringsAsFactors = FALSE)
}

bind_dfs <- function(df_batchs) {
  lapply2(names(df_batchs[[1]]), function(x) {
    structure(
     do.call(rbind, lapply(df_batchs, function(y) replace_if_0_rows(y[[x]]))),
     class = c("data.frame", paste0(x, "_df"))
    )
  })
}
