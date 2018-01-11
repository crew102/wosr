make_df <- function(df_name) {
  fields <- schema[schema$df == df_name, "field"]
  df <- as.data.frame(matrix(NA, nrow = 1, ncol = length(fields)))
  colnames(df) <- fields
  df
}

enforce_schema <- function(wos_unenforced) {
  lapply2(names(wos_unenforced), function(name) {
    maybe_df <- wos_unenforced[[name]]
    is_df <- is.data.frame(maybe_df)
    df_has_no_rows <- if (is_df) nrow(maybe_df) == 0 else FALSE
    if (df_has_no_rows || is.na(maybe_df) || is.null(maybe_df))
      make_df(name)
    else
      maybe_df
  })
}
