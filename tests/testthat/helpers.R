# Taken from https://cran.r-project.org/web/packages/httr/vignettes/secrets.html
skip_if_no_auth <- function() {
  if (identical(Sys.getenv("WOS_USERNAME"), "")) {
    skip("No authentication available")
  }
}

is_empty_df <- function(x) is.data.frame(x) && nrow(x) == 0
