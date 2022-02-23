#' @title Plot ozone from the preprocessed air quality data.
#' @description Plot a histogram of ozone concentration.
#' @return A ggplot histogram showing ozone content.
#' @param data Data frame, preprocessed air quality dataset.
#' @import ggplot2
#' @export
create_plot <- function(data) {
  Ozone = NULL
  ggplot(data) +
    geom_histogram(aes(x = Ozone), bins = 12) +
    theme_gray(24)
}
