#' @import methods
#' @import DBI
#' @importFrom utils browseURL download.file head installed.packages tail untar write.csv
NULL

is.installed <- function(package) {
  is.element(package, installed.packages()[,1])
}

is_java_available <- function() {
  java_home <- Sys.getenv("JAVA_HOME", unset = NA)
  if (!is.na(java_home))
    java <- file.path(java_home, "bin", "java")
  else
    java <- Sys.which("java")
  nzchar(java)
}

java_install_url <- function() {
  "https://www.java.com/en/"
}

starts_with <- function(lhs, rhs) {
  if (nchar(lhs) < nchar(rhs))
    return(FALSE)
  identical(substring(lhs, 1, nchar(rhs)), rhs)
}

aliased_path <- function(path) {
  home <- path.expand("~/")
  if (starts_with(path, home))
    path <- file.path("~", substring(path, nchar(home) + 1))
  path
}

transpose_list <- function(list) {
  do.call(Map, c(c, list, USE.NAMES = FALSE))
}

random_string <- function(prefix = "table") {
  basename(tempfile(prefix))
}

"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}

# place for us to store state
.globals <- new.env(parent = emptyenv())

is_spark_v2 <- function(scon) {
  spark_version(scon) >= "2.0.0"
}
