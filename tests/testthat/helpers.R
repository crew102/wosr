# Taken from https://cran.r-project.org/web/packages/httr/vignettes/secrets.html
skip_if_no_auth <- function() {
  if (!exists("sid")) {
    sid_try <- try(auth(username = NULL, password = NULL), silent = TRUE)
    if (class(sid_try) != "try-error") {
      assign("sid", sid_try, envir = .GlobalEnv)
    }
  }

  if (identical(Sys.getenv("WOS_USERNAME"), "") && class(sid) == "try-error") {
    skip("No authentication available")
  }
}

is_empty_df <- function(x) is.data.frame(x) && nrow(x) == 0
