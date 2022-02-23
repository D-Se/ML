#### Bookdown ####

#' @title Change extension from md to Rmd
#' @param file a Rmarkdown file to convert to regular markdown
#' @param inext file extension to replace
#' @param outext file extention to replace with
#' @export
change_ext <- function(file, inext, outext) {
  # bookdown ignores md files
  # https://github.com/rstudio/bookdown/issues/956
  newfile <- gsub(inext, outext, file)
  file.rename(file, newfile)
  newfile
}

#' @title Bookdown render with explicit defined dependencies
#' @param index file to index and render
#' @param deps dependencies
#' @export
render_with_deps <- function(index, deps) {
  bookdown::render_book(index)
}