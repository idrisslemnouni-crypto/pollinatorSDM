#' Predict pollinator distribution on raster
#'
#' Projette le modèle SDM sur un raster environnemental pour produire
#' une carte de suitabilité. Retourne la probabilité de présence (classe "1").
#'
#' @param model randomForest model entraîné avec train_sdm_model()
#' @param rasters SpatRaster avec les mêmes variables que celles utilisées à l'entraînement
#' @return SpatRaster avec valeurs de probabilité entre 0 et 1
#' @export
predict_pollinator_distribution <- function(model, rasters) {
  if (!inherits(model, "randomForest")) {
    stop("'model' must be a randomForest object trained with train_sdm_model()")
  }
  if (!inherits(rasters, "SpatRaster")) {
    stop("'rasters' must be a SpatRaster object")
  }

  pred <- terra::predict(rasters, model, type = "prob", na.rm = TRUE, index = 2)
  names(pred) <- "suitability"
  pred
}
