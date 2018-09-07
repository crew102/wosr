#' Write WoS data
#'
#' Writes each of the data frames in an object of class \code{wos_data} to its
#' own csv file. Each file will be named after the name of the data frame.
#'
#' @param wos_data An object of class \code{wos_data}, created by calling
#' \code{\link{pull_wos}}.
#' @param dir Path to the directory where you want to write the files.
#'
#' @return Nothing. Files are written to disk.
#'
#' @examples
#' \dontrun{
#'
#' sid <- auth("your_username", password = "your_password")
#' wos_data <- pull_wos("TS = (dog welfare) AND PY = 2010", sid = sid)
#'
#' # Write files to working directory
#' write_wos_data(wos_data, ".")
#'
#' # Write files to "wos-data" dir
#' dir.create("wos-data")
#' write_wos_data(wos_data, "wos-data")
#'}
#'
#' @export
write_wos_data <- function(wos_data, dir) {

  if (!dir.exists(dir))
    stop(
      "Directory ", normalizePath(dir),
      " doesn't exists. Create it and try again."
    )

  if (!("wos_data" %in% class(wos_data)))
    stop("You must pass an object of class `wos_data` into write_wos_data")

  lapply(
    names(wos_data),
    function(x) utils::write.csv(
      wos_data[[x]], full_path(dir, x), row.names = FALSE
    )
  )
  invisible()
}

full_path <- function(dir, x) file.path(dir, paste0(x, ".csv"))

#' Read WoS data
#'
#' Reads in a series of CSV files (which were written via
#' \code{\link{write_wos_data}}) and places the data in an object of class
#' \code{wos_data}.
#'
#' @param dir Path the directory where you wrote the CSV files.
#'
#' @return An object of class \code{wos_data}.
#'
#' @examples
#' \dontrun{
#'
#' sid <- auth("your_username", password = "your_password")
#' wos_data <- pull_wos("TS = (dog welfare) AND PY = 2010", sid = sid)
#'
#' # Write files to working directory
#' write_wos_data(wos_data, ".")
#' # Read data back into R
#' wos_data <- read_wos_data(".")
#' }
#'
#' @export
read_wos_data <- function(dir) {

  files <- list.files(dir)
  dfs <- unique(schema$df)
  have_all_files <- all(dfs %in% gsub("\\.csv$", "", files))
  if (!have_all_files)
    stop(
      "Directory ", normalizePath(dir),
      " doesn't have all of the following files: ",
      paste0(paste0(dfs, ".csv"), collapse = ", ")
    )

  wos_data <- lapply2(
    dfs, function(x)
      utils::read.csv(full_path(dir, x), stringsAsFactors = FALSE)
  )
  wos_data <- enforce_schema(wos_data)
  append_class(wos_data, "wos_data")
}
