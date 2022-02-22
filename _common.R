knitr::opts_chunk$set(
  comment = "#",
  collapse = TRUE,
  #cache = TRUE, # set cache = TRUE when developing
  out.width = "70%",
  fig.align = "center",
  fig.width = 6,
  fig.asp = 0.618,
  fig.show = "hold"
)

#' #' Processing steps for chapter citation
#' #' 
#' #' @param 
#' #' @export
#' get_ch_authors <- function(chapter){
#'   
#' }
#' 
#' df <- readLines("dev/counts.txt")
#' df
#' trimws(df)

#' Create tables of package information
#'
#' @param pkgs character vector of packages
#' @param caption possibly html / latex formatted character string
#' @export
#' @examples
#' pkg_tabler(c("MASS", "keras"), "<b>Test</b>")
pkg_tabler <- function(pkgs, caption = NULL) {
  purrr::map_dfr(pkgs,
                 ~list2DF(utils::packageDescription(.x)[c(
                   "Package", "Title", "Version")])) |>
    kableExtra::kbl(col.names = c("Package", "Description", "Version"),
                    align = "c",
                    caption = caption) |>
    kableExtra::row_spec(0, bold = T) |>
    kableExtra::kable_classic_2(full_width = F,
                                position = "center")
}

#' author statistics
stat_tabler <- function(df, tidyverse = F) {
  if (tidyverse) df <- tibble::as_tibble(df)
  df |>
    kableExtra::kbl() |>
    kableExtra::row_spec(0, bold = T) |>
    kableExtra::kable_classic_2(full_width = F,
                                position = "center")
}