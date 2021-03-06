# https://github.com/wlandau/targets-keras/blob/main/R/functions.R

#' @title Define and run the preprocesing recipe.
#' @description Define a recipe to preprocess the data
#'   and run it on the test data.
#' @return A `recipe` object with the preprocessing steps
#'   and the preprocessed test data.
#' @param data An `rsplit` object.
#'   with the training and test customer churn data.
#'   @import recipes
#' @export
prepare_recipe <- function(data) {
  data |>
    recipe(compressive_strength ~ .) |> 
    step_center(all_predictors(), -all_outcomes()) |>
    step_scale(all_predictors(), -all_outcomes()) |>
    prep()
}

#' @title Define a Keras model.
#' @description Define a Keras model for the customer churn data.
#' @return A Keras model. Not compiled or run yet.
#' @param recipe A `recipe` object from [prepare_recipe()].
#' @param units1 Number of neurons in the first layer.
#' @param units2 Number of neurons in the second layer.
#' @param act1 Activation function for layer 1.
#' @param act2 Activation function for layer 2.
#' @param act3 Activation function for layer 3.
#' 
#' @import keras 
#' @import recipes
#' @export
define_model <- function(recipe, units1, units2, act1, act2, act3) {
  input_shape <- ncol(juice(recipe, all_predictors(), composition = "matrix"))
  keras_model_sequential() |>
    layer_dense(
      units = units1,
      kernel_initializer = "uniform",
      activation = act1,
      input_shape = input_shape
    ) |>
    layer_dropout(rate = 0.1) |>
    layer_dense(
      units = units2,
      kernel_initializer = "uniform",
      activation = act2
    ) |>
    layer_dropout(rate = 0.1) |>
    layer_dense(
      units = 1,
      kernel_initializer = "uniform",
      activation = act3
    )
}

#' @title Define, compile, and train a Keras model.
#' @description Define, compile, and train a Keras model on the training
#'   dataset.
#' @details The first time you run Keras in an R session,
#'   TensorFlow usually prints verbose ouput such as
#'   "Your CPU supports instructions that this TensorFlow binary was not compiled to use:"
#'   and "OMP: Info #171: KMP_AFFINITY:". You can safely ignore these messages.
#' @return A trained Keras model.
#' @inheritParams define_model
#' @import keras
#' @importFrom dplyr pull
#' @export
train_model <- function(
  recipe,
  units1 = 16,
  units2 = 16,
  act1 = "relu",
  act2 = "relu",
  act3 = "sigmoid"
) {
  model <- define_model(recipe, units1, units2, act1, act2, act3)
  compile(
    model,
    optimizer = "adam",
    loss = "binary_crossentropy",
    metrics = c("accuracy")
  )
  x_train_tbl <- recipes::juice(
    recipe,
    recipes::all_predictors(),
    composition = "matrix"
  )
  y_train_vec <- recipes::juice(recipe, recipes::all_outcomes()) |>
    pull()
  fit(
    object = model,
    x = x_train_tbl,
    y = y_train_vec,
    batch_size = 32,
    epochs = 32,
    validation_split = 0.3,
    verbose = 0
  )
  model
}

#' @title Test accuracy.
#' @description Compute the classification accuracy of a trained Keras model
#'   on the test dataset.
#' @return Classification accuracy of a trained Keras model on the test
#'   dataset.
#' @param data a matrix.
#' @param recipe a `recipe` object from the `recipes` packages.
#' @param model a `keras` model to assess.
#' @import keras
#' @import dplyr
#' @importFrom recipes bake
#' @importFrom rsample testing
#' @importFrom yardstick conf_mat
#' @importFrom stats predict
#' @export
test_accuracy <- function(data, recipe, model) {
  # silencing non-standard evaluation NOTE from R CMD check
  # https://stackoverflow.com/questions/8096313/no-visible-binding-for-global-variable-note-in-r-cmd-check
  truth=estimate=.metric=.estimate=compressive_strength=NULL
  
  testing_data <- bake(recipe, testing(data))
  x_test_tbl <- testing_data |>
    select(-compressive_strength) |>
    as.matrix()
  y_test_vec <- testing_data |>
    select(compressive_strength) |>
    pull()
  yhat_keras_class_vec <- model |>
    predict(x_test_tbl) |>
    (\(.) . > 0.5)() |>
    as.integer() |>
    as.factor() #|>
    #fct_recode(yes = "1", no = "0")
  yhat_keras_prob_vec <-
    model |>
    predict(x_test_tbl) |>
    as.vector()
  test_truth <- y_test_vec |>
    as.factor() #|>
    #fct_recode(yes = "1", no = "0")
  estimates_keras_tbl <- tibble(
    truth = test_truth,
    estimate = yhat_keras_class_vec,
    class_prob = yhat_keras_prob_vec
  )
  estimates_keras_tbl |>
    conf_mat(truth, estimate) |>
    summary() |>
    filter(.metric == "accuracy") |>
    pull(.estimate)
}

#' @title Benchmark a Keras model.
#' @description Define, compile, and train a Keras model on the training
#'   dataset. Then, benchmark it on the test dataset and return summaries.
#' @details The first time you run Keras in an R session,
#'   TensorFlow usually prints verbose ouput such as
#'   "Your CPU supports instructions that this TensorFlow binary was not compiled to use:"
#'   and "OMP: Info #171: KMP_AFFINITY:". You can safely ignore these messages.
#' @return A data frame with one row and the following columns:
#'   * `accuracy`: classification accuracy on the test dataset.
#'   * `units1`: number of neurons in layer 1.
#'   * `units2`: number of neurons in layer 2.
#'   * `act1`: number of neurons in layer 1.
#'   * `act2`: number of neurons in layer 2.
#'   * `act3`: number of neurons in layer 3.
#' @inheritParams define_model
#' @inheritParams test_accuracy
#' @importFrom dplyr tibble
#' @export
test_model <- function(
  data,
  recipe,
  units1 = 16,
  units2 = 16,
  act1 = "relu",
  act2 = "relu",
  act3 = "sigmoid"
) {
  model <- train_model(recipe, units1, units2, act1, act2, act3)
  accuracy <- test_accuracy(data, recipe, model)
  tibble(
    accuracy = accuracy,
    units1 = units1,
    units2 = units2,
    act1 = act1,
    act2 = act2,
    act3 = act3
  )
}

#' @title Retrain the best model.
#' @description After we find the model with the best accuracy,
#'   retrain it and return the trained model given a row of output
#'   from [test_model()].
#' @details The first time you run Keras in an R session,
#'   TensorFlow usually prints verbose ouput such as
#'   "Your CPU supports instructions that this TensorFlow binary was not compiled to use:"
#'   and "OMP: Info #171: KMP_AFFINITY:". You can safely ignore these messages.
#' @return A trained Keras model.
#' @param best_run blabla.
#' @param recipe a recipe.
#' @export
train_best_model <- function(best_run, recipe) {
  train_model(
    recipe,
    best_run$units1,
    best_run$units2,
    best_run$act1,
    best_run$act2,
    best_run$act3
  )
}