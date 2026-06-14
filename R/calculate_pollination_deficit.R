#' Calculate pollination deficit
#'
#' Computes the pollination deficit as the difference between crop pollination
#' demand (pollination index) and pollinator supply (suitability raster).
#' Negative values are clamped to zero. The result is also classified into
#' three deficit classes: low, moderate, and high.
#'
#' @param prediction_raster A \code{SpatRaster} of pollinator suitability (0-1).
#' @param pollination_index A \code{SpatRaster} of crop pollination demand (0-1).
#' @return A \code{SpatRaster} with two layers:
#'   \describe{
#'     \item{pollination_deficit}{Continuous deficit values (0-1).}
#'     \item{deficit_class}{Classified deficit: 1 = low, 2 = moderate, 3 = high.}
#'   }
#' @export
#' @examples
#' \dontrun{
#'   deficit <- calculate_pollination_deficit(suitability_raster, pollination_index)
#'   terra::plot(deficit[["pollination_deficit"]])
#' }
calculate_pollination_deficit <- function(prediction_raster, pollination_index) {
  deficit <- pollination_index - prediction_raster
  deficit[deficit < 0] <- 0
  names(deficit) <- "pollination_deficit"

  # Classify into three classes: 1 = low, 2 = moderate, 3 = high
  deficit_class <- terra::classify(
    deficit,
    rcl = matrix(c(
      0,    0.33, 1,
      0.33, 0.66, 2,
      0.66, 1.01, 3
    ), ncol = 3, byrow = TRUE),
    include.lowest = TRUE
  )
  names(deficit_class) <- "deficit_class"

  c(deficit, deficit_class)
}
