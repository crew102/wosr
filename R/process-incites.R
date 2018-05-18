process_incites <- function(incites_df) {
  if (!is.data.frame(incites_df)) return(NULL)
  colnames(incites_df) <- tolower(colnames(incites_df))
  cols <- c(
    "isi_loc", "article_type", "tot_cites", "journal_expected_citations",
    "journal_act_exp_citations", "impact_factor", "avg_expected_rate",
    "category_expected_rate", "percentile", "nci", "esi_most_cited_article",
    "hot_paper", "is_international_collab", "is_institution_collab",
    "is_industry_collab", "oa_flag"
  )
  incites_df <- incites_df[, cols]
  colnames(incites_df)[1] <- "ut"
  incites_df$ut <- paste0("WOS:", incites_df$ut)
  incites_df[, 3:16] <- apply(incites_df[, 3:16], MARGIN = 2, FUN = as.numeric)
  incites_df[, 11:16] <- apply(
    incites_df[, 11:16], MARGIN = 2, FUN = function(x) x == 1
  )
  incites_df
}
