#' @export
pull_wos_apply <- function(queries,
                           editions = c("SCI", "SSCI", "AHCI", "ISTP", "ISSHP",
                                        "BSCI", "BHCI", "IC", "CCR", "ESCI"),
                           sid = auth(Sys.getenv("WOS_USERNAME"),
                                      Sys.getenv("WOS_PASSWORD")),
                           ...) {
  if (is.null(names(queries))) {
    names(queries) <- queries
  }
  query_names <- names(queries)
  if (length(query_names) != length(unique(query_names))) {
    stop("The names of your queries must be unique", call. = FALSE)
  }

  res_list <- pbapply::pblapply(
    query_names, one_pull_wos_apply,
    queries = queries,
    editions = editions,
    sid = sid,
    ... = ...
  )

  df_names <- c(unique(schema$df), "query")
  out <- lapply2(
    df_names,
    function(x) unique(do.call(rbind, lapply(res_list, function(y) y[[x]])))
  )

  append_class(out, "wos_data")
}

one_pull_wos_apply <- function(query_name, queries, editions, sid, ...) {
  query <- queries[[query_name]]
  message("\n\nPulling WoS data for the following query: ", query_name, "\n\n")
  wos_out <- pull_wos(query = query, editions = editions, sid = sid, ...)
  uts <- wos_out[["publication"]][["ut"]]
  num_pubs <- length(uts)
  if (num_pubs == 0)
    query_df <- data.frame(
      ut = character(),
      query = character(),
      stringsAsFactors = FALSE
    )
  else
    query_df <- data.frame(
      ut = uts,
      query = rep(query_name, num_pubs),
      stringsAsFactors = FALSE
    )
  wos_out$query <- query_df
  wos_out
}
