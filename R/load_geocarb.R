get_py_geocarb_path <- function() {
  system.file("py_scripts", "geocarb_varco2.py", package = "geocarb")
}


#' check_dependencies
#'
#' Check that a reasonable version of python is installed.
#'
#' @return Logical indicating success.
#' @keywords internal
#'
check_dependencies <- function() {
  reticulate::use_miniconda()
  if (! 'geocarb' %in% reticulate::conda_list()$name) {
    reticulate::conda_create("geocarb")
    reticulate::conda_install("geocarb", "numpy")
    reticulate::conda_install("geocarb", "pandas")
  }
  reticulate::use_miniconda("geocarb")
  TRUE
}

#' load_geocarb
#'
#' Load the geocarb module.
#'
#' @param python_script Which script to load.
#'
#' @return Logical indicating success.
#'
#' @export
load_geocarb = function(python_script = get_py_geocarb_path()) {
  check_dependencies()
  reticulate::use_miniconda("geocarb")
  reticulate::use_condaenv("geocarb")
  path = dirname(python_script)
  module = basename(python_script) %>% stringr::str_split("\\.", n = 2) %>%
    purrr::simplify() %>% utils::head(1)
  geocarb_module <- reticulate::import_from_path(module, path)
  assign("geocarb_module", geocarb_module, envir = .geocarb)
}

