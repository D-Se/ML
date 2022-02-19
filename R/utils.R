# ML?

#' Null-coalescing operator
#' @keywords internal
`%null%` <- function(x, y) if(is.null(x)) y else x

text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) return(x)
  if (!rstudioapi::hasFun("getThemeInfo")) return(x)
  theme <- rstudioapi::getThemeInfo()
  if (isTRUE(theme$dark)) crayon::green(x) else crayon::black(x)
}

