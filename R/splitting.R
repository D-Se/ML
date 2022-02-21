#' construct rsample splits from data in an environment
#'
#' @param ... arguments passed to initial_split
#' @param env environment
#' @export
add_splits <- function(..., env = new.env()) {
  set.seed(1L)
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

#' construct rsample splits from data in an environment
#'
#' @param env environment
#' @param ... arguments passed to initial_split
#' @export
ML_add <- function(env, ...) {
  args <- list(...)
  name <- deparse(substitute(name))
  set_in_env(
    env, {
      recop <- !!!args
    }
  )
  env
}

# add_recipes <- function() {
#   list(
#     normalized_rec = 
#       recipe(mpg ~ ., splits$train) |> 
#       step_normalize(all_predictors()),
#     poly_recipe = 
#       recipe(mpg ~ ., splits[["train"]]) |> 
#       step_normalize(all_predictors()) |>
#       step_poly(all_predictors())
#   )
# }
# ML_add <- function(env, ..., name) {
#   args <- list(...)
#   if(missing(name)) name <- targets::tar_name()
#   return(name)
#   #name <- deparse(substitute(name))
#   set_in_env(
#     env, {
#       !!name <- !!!args
#     }
#   )
#   env
# }

# add_folds <- function(env, ...) {
#   args <- list(...)
#   set.seed(pi)
#   set_in_env(
#     env, {
#       folds <- vfold_cv(env$train, !!!args)
#     }
#   )
#   env
# }
# 
# 
# s <- list(
#   init = expression(
#     rsample::initial_split(data)
#   ),
#   train = expression(
#     rsample::training(init)
#   )
# )
# 
# data <- mtcars
# 
# s
# 
# eval(s$init)
# s$train
