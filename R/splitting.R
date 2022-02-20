#' construct rsample splits from data in an environment
#'
#' @param env environment
#' @param ... arguments passed to initial_split
#' @export
add_splits <- function(env, ...) {
  args <- list(...)
  set_in_env(
    env, {
      init <- rsample::initial_split(!!!args)
      train <- rsample::training(init)
      test <- rsample::testing(init)
    }
  )
  env
}