# class incites data and make single processor
process_incites <- function(incites_df) {
  if (!is.data.frame(incites_df)) return(NULL)
  colnames(incites_df) <- tolower(colnames(incites_df))
  colnames(incites_df)[1] <- "ut"
  incites_df$ut <- paste0("WOS:", incites_df$ut)
  incites_df[, 3:15] <- apply(incites_df[, 3:15], MARGIN = 2, FUN = as.numeric)
  incites_df[, 10:15] <- apply(
    incites_df[, 10:15], MARGIN = 2, FUN = function(x) ifelse(x == 1, TRUE, FALSE)
  )
  incites_df
}
