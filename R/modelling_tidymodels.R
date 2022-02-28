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
  ### TODO: rewrite to use lists instead - cleaner and smaller object size.
  # but careful of copy-on-modification semantics of lists!
  args <- list(...)
  name <- deparse(substitute(name))
  set_in_env(
    env, {
      recop <- !!!args
    }
  )
  env
}

#' Create `parsnip` model specifications
#' @param fun a `parsnip` function
#' @param engine a `parsnip` engine specification
#' @param ... arguments passed to `parsnip` model specificatin constructors.
#'   Empty arguments get converted to `tune::tune()`
#' @param mode character of length 1, one of *regression* or *classification*
#@importFrom tune tune
#' @export
mod <- function(fun, engine, ..., mode = "regression") {
  engine <- deparse(substitute(engine))
  # get relevant parsnip function
  eval(str2lang(paste0("parsnip::", deparse(substitute(fun))))) |>
    do.call(
      # replace empty argument with tune()
      lapply(substitute(...()), function(x){
        if(is.name(x)) str2lang("tune::tune()") else x
      })) |>
    parsnip::set_engine(engine) |>
    parsnip::set_mode(mode)
}
### FIXME: x$eng_args == <list_of<quosure>> but expected method = NULL
# 
# make_models <- function() {
#   list(
#     linear_reg_spec = mod(linear_reg, glmnet, penalty=,mixture=),
#     mars_spec = mod(mars, earth, prod_degree=),
#     svm_r_spec = mod(svm_rbf, kernlab, cost=, rbf_sigma=),
#     svm_p_spec = mod(svm_poly, kernlab, cost=, degree=),
#     knn_spec = mod(nearest_neighbor, kknn, neighbors=,dist_power=,weight_fun=),
#     cart_spec = mod(decision_tree, rpart, cost_complexity=,min_n=),
#     bag_cart_spec = baguette::bag_mars() |> 
#       parsnip::set_engine("earth", time = 50L) |>
#       parsnip::set_mode("regression"),
#     rf_spec = mod(rand_forest, ranger, mtry=, min_n=, trees = 1000),
#     xgb_spec = mod(boost_tree, xgboost,
#                    tree_depth=, learn_rate=, loss_reduction=,
#                    min_n=, sample_size=, trees=),
#     cubist_spec =
#       rules::cubist_rules(committees = tune(), neighbors = tune()) |>
#       parsnip::set_engine("Cubist")
#   )
# }


#' @title Recipe constructor
#' @description Make preprocessor specifations using the `recipes` package. Each
#'   recipe specifies different steps to be applied during the analysis process, 
#'   depending on the type of model to be used.
#' @param formula a model formula. No in-line function should be used here, and 
#'   no minus signs are allowed. For high dimensional sets avoid this function.
#' @param data A data frame or tibble.
#' @importFrom recipes recipe
#' @importFrom recipes all_predictors
#' @importFrom recipes all_outcomes
#' @importFrom recipes step_normalize
#' @importFrom recipes step_poly
#' @importFrom recipes step_interact
#' @export
make_recs <- function(formula, data) {
  list(
    normalized_recipe =
      recipe(formula, data) |>
      step_normalize(all_predictors()),
    poly_recipe = 
      recipe(formula, data) |>
      step_normalize(all_predictors()) |>
      step_poly(all_predictors()) |> 
      step_interact(~all_predictors():all_predictors()),
    keras_recipe = 
      recipe(formula, data) |> 
      step_normalize(all_predictors(), - all_outcomes()) |>
      prep()
  )
}

