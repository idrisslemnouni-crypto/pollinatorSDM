#' Predict pollinator distribution on raster
#' @param model randomForest model
#' @param rasters SpatRaster
#' @return SpatRaster
#' @export
predict_pollinator_distribution <- function(model, rasters) {
  terra::predict(rasters, model, na.rm = TRUE)
}
