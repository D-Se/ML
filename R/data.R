#' @title Object specification of the ML pipeline
#'
#' @description A collection of objects along the critical path of analysis process
#'   useful for model prototyping and verification.
#'
#' @format A list containing three elements
#' \describe{
#'   \item{splits}{an `rsplit` object of the `rsample` package that indicates splitting criteria and data inclusion}
#'   \item{recipes}{assortment of `recipes` package recipe objects describing preprocessing steps}
#'   \item{models}{a list of `parsnip` model specifications to see hyperparameter tuning criteria}
#' }
#' @source \url{https://github.com/D-Se/ML}
"analysis"
# analysis = list(
#   splits = targets::tar_read(init),
#   recipes = targets::tar_read(recipes),
#   models = targets::tar_read(models)
# )




#' @title temporary airquality data for bookdown
#' @format see `airquality`
#' @source New York State Department of Conservation (ozone data) and the National Weather Service (meteorological data).
data <- NULL

