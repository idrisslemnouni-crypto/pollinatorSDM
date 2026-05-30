#' Train SDM model
#'
#' Entraîne un modèle RandomForest avec présences et background points.
#'
#' @param predictor_data data.frame avec variables prédicteurs et occurrence
#' @param method character, "rf" uniquement supporté
#' @param ntree integer, nombre d'arbres
#' @return modèle randomForest
#' @export
train_sdm_model <- function(predictor_data, method = "rf", ntree = 500) {
  if (!"occurrence" %in% names(predictor_data)) {
    stop("Column 'occurrence' required in predictor_data")
  }

  # occurrence doit être factor pour classification
  predictor_data$occurrence <- as.factor(predictor_data$occurrence)

  if (method == "rf") {
    model <- randomForest::randomForest(
      occurrence ~ .,
      data = predictor_data,
      ntree = ntree,
      importance = TRUE
    )
  } else {
    stop("Only 'rf' method is currently supported.")
  }

  model
}
