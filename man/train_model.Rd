% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modelling_keras.R
\name{train_model}
\alias{train_model}
\title{Define, compile, and train a Keras model.}
\usage{
train_model(
  recipe,
  units1 = 16,
  units2 = 16,
  act1 = "relu",
  act2 = "relu",
  act3 = "sigmoid"
)
}
\arguments{
\item{recipe}{A \code{recipe} object from \code{\link[=prepare_recipe]{prepare_recipe()}}.}

\item{units1}{Number of neurons in the first layer.}

\item{units2}{Number of neurons in the second layer.}

\item{act1}{Activation function for layer 1.}

\item{act2}{Activation function for layer 2.}

\item{act3}{Activation function for layer 3.}
}
\value{
A trained Keras model.
}
\description{
Define, compile, and train a Keras model on the training
dataset.
}
\details{
The first time you run Keras in an R session,
TensorFlow usually prints verbose ouput such as
"Your CPU supports instructions that this TensorFlow binary was not compiled to use:"
and "OMP: Info #171: KMP_AFFINITY:". You can safely ignore these messages.
}
