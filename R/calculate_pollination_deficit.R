#' Calculate pollination deficit
#'
#' Déficit = index de pollinisation - offre (suitability).
#' Valeurs négatives sont forcées à zéro (excès, pas déficit).
#'
#' @param prediction_raster SpatRaster, offre (suitability)
#' @param pollination_index SpatRaster, index calculé
#' @return SpatRaster
#' @export
calculate_pollination_deficit <- function(prediction_raster, pollination_index) {
  deficit <- pollination_index - prediction_raster
  deficit[deficit < 0] <- 0
  names(deficit) <- "pollination_deficit"
  deficit
}
