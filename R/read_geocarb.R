
#' read_geocarb
#'
#' Read a GEOCARB output file.
#'
#' @param filename The file to read.
#'
#' @return A tibble containing the results of the GEOCARB simulation.
#'   See [run_geocarb] for details.
#'
#' @seealso run_geocarb
#'
#'@export
read_geocarb <- function(filename) {
  f <- file(filename,"r")
  lines <- readLines(f, warn=F)
  close(f)
  lines %>% stringr::str_trim() %>% stringr::str_replace_all('[ \t]+', ',') %>%
    stringr::str_c(collapse = "\n") %>% readr::read_csv() -> df
  names(df) <- .geocarb$column_names[names(df)]
  invisible(df)
}
