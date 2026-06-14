#' Calculate pollination service index
#'
#' Computes a pollination service index by multiplying pollinator suitability
#' by crop pollination demand. Optionally normalises the result to [0, 1].
#'
#' @param prediction_raster A \code{SpatRaster} of pollinator suitability (0-1).
#' @param crop_demand_raster A \code{SpatRaster} of crop pollination demand,
#'   typically the product of crop area and pollination dependence weight.
#' @param normalise Logical. If \code{TRUE} (default), the index is scaled to
#'   [0, 1] using min-max normalisation.
#' @return A \code{SpatRaster} named \code{"pollination_index"}.
#' @export
#' @examples
#' \dontrun{
#'   idx <- calculate_pollination_index(suitability_raster, crop_demand_raster)
#'   terra::plot(idx)
#' }
calculate_pollination_index <- function(prediction_raster,
                                        crop_demand_raster,
                                        normalise = TRUE) {
  if (!inherits(prediction_raster, "SpatRaster")) {
    stop("'prediction_raster' must be a SpatRaster.")
  }
  if (!inherits(crop_demand_raster, "SpatRaster")) {
    stop("'crop_demand_raster' must be a SpatRaster.")
  }

  # Align extents if needed
  if (!terra::compareGeom(prediction_raster, crop_demand_raster,
                          stopOnError = FALSE)) {
    crop_demand_raster <- terra::resample(crop_demand_raster,
                                          prediction_raster,
                                          method = "bilinear")
  }

  pollination_index <- prediction_raster * crop_demand_raster

  if (normalise) {
    mn <- terra::global(pollination_index, "min",  na.rm = TRUE)[1, 1]
    mx <- terra::global(pollination_index, "max",  na.rm = TRUE)[1, 1]
    if (!is.na(mx) && (mx - mn) > 0) {
      pollination_index <- (pollination_index - mn) / (mx - mn)
    }
  }

  names(pollination_index) <- "pollination_index"
  pollination_index
}
