#' @title Plot ozone from the preprocessed air quality data.
#' @description Plot a histogram of ozone concentration.
#' @return A ggplot histogram showing ozone content.
#' @param data Data frame, preprocessed air quality dataset.
#' @import ggplot2
#' @export
create_plot <- function(data) {
  Ozone = NULL
  ggplot(data) +
    geom_histogram(aes(x = Ozone), bins = 12) +
    theme_gray(24)
}

#' @title Change extension from md to Rmd
#' @param file a Rmarkdown file to convert to regular markdown
#' @param inext file extension to replace
#' @param outext file extention to replace with
#' @export
change_ext <- function(file, inext, outext) {
  # Change extension from md to Rmd
  #  since (at the moment) bookdown ignores md files unless explicitly stated in
  #  rmd_files
  #  https://github.com/rstudio/bookdown/issues/956
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