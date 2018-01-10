#' @export
print.wos_data <- function(x, ...) {
  utils::str(
    x, vec.len = 1, max.level = 2, give.attr = FALSE, strict.width = "cut"
  )
}

#' @export
print.query_result <- function(x, ...) {
  cat("Matching records:", format_num(x$rec_cnt))
}
