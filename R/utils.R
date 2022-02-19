# ML?

#' Null-coalescing operator
#' @keywords internal
`%null%` <- function(x, y) if(is.null(x)) y else x
