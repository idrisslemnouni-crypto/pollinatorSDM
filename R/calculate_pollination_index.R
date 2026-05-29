#' Calculate pollination service index
#'
#' Multiplie la suitability des pollinisateurs par la demande agricole
#' (dépendance pollinisation × surface cultivée).
#'
#' @param prediction_raster SpatRaster, suitability des pollinisateurs
#' @param crop_demand_raster SpatRaster, demande agricole
#' @return SpatRaster
#' @export
calculate_pollination_index <- function(prediction_raster, crop_demand_raster) {
  pollination_index <- prediction_raster * crop_demand_raster
  names(pollination_index) <- "pollination_index"
  pollination_index
}
