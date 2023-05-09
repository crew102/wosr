enforce_schema <- function(wos_unenforced) {
  lapply2(names(wos_unenforced), function(name) {

    maybe_df <- wos_unenforced[[name]]
    is_df <- is.data.frame(maybe_df)
    is_null <- is.null(maybe_df)

    # have to run these logical tests in wonky way b/c don't want warning about
    # is.na(NULL), etc
    df_has_no_rows <- if (is_df) nrow(maybe_df) == 0 else FALSE
    na_or_empty <- if (!is_null) df_has_no_rows || all(is.na(maybe_df)) else FALSE

    df <- if (na_or_empty || is_null) make_df(name) else maybe_df
    cast_fields(df, name)
  })
}

make_df <- function(df_name) {
  fields <- schema[schema$df == df_name, "field"]
  df <- data.frame(matrix(ncol = length(fields), nrow = 0))
  colnames(df) <- fields
  df
}

cast_fields <- function(df, df_name) {
  df_schema <- schema[schema$df == df_name, ]
  col_list <- lapply(df_schema$field, function(x) {
    dtype <- df_schema[df_schema$field == x, "dtype"]
    cast_fun <- switch(
      dtype,
      "character" = as.character,
      "date" = as.Date,
      "integer" = as.integer
    )
    cast_fun(df[[x]])
  })
  as.data.frame(col_list, stringsAsFactors = FALSE, col.names = df_schema$field)
}
