# ML?

#' Null-coalescing operator
#' @noRd
`%null%` <- function(x, y) if (is.null(x)) y else x

text_col <- function(x) {
  # If RStudio not available, messages already printed in black
  if (!rstudioapi::isAvailable()) return(x)
  if (!rstudioapi::hasFun("getThemeInfo")) return(x)
  theme <- rstudioapi::getThemeInfo()
  if (isTRUE(theme$dark)) crayon::green(x) else crayon::black(x)
}

#' Evaluate a set of expression and assign to an environment
#' @param expr an expression
#' @param env an environment object
#' @param ... used to pass objects to the expression
#' @noRd
set_in_env <- function(env, expr, ...) {
  expr <- rlang::enexpr(expr)
  rlang::eval_bare(expr, env)
}
