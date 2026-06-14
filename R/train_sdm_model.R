#' Train SDM model
#'
#' Trains a Species Distribution Model using Random Forest or GLM
#' (logistic regression).
#'
#' @param predictor_data A \code{data.frame} with predictor variables and an
#'   \code{occurrence} column (0/1).
#' @param method Character. \code{"rf"} for Random Forest or \code{"glm"} for
#'   logistic regression. Default is \code{"rf"}.
#' @param ntree Integer. Number of trees for Random Forest. Default is 500.
#' @return A trained model object (\code{randomForest} or \code{glm}).
#' @importFrom randomForest randomForest
#' @importFrom stats glm binomial as.formula
#' @export
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   occurrence = factor(rep(c(0, 1), each = 25)),
#'   var1 = c(rnorm(25, 10, 2), rnorm(25, 15, 2)),
#'   var2 = c(rnorm(25,  5, 1), rnorm(25,  8, 1))
#' )
#' model_rf  <- train_sdm_model(df, method = "rf",  ntree = 100)
#' model_glm <- train_sdm_model(df, method = "glm")
#' }
train_sdm_model <- function(predictor_data, method = "rf", ntree = 500) {
  if (!"occurrence" %in% names(predictor_data)) {
    stop("Column 'occurrence' required in predictor_data.")
  }

  if (method == "rf") {
    predictor_data$occurrence <- as.factor(predictor_data$occurrence)
    model <- randomForest::randomForest(
      occurrence ~ .,
      data       = predictor_data,
      ntree      = ntree,
      importance = TRUE
    )
  } else if (method == "glm") {
    predictor_data$occurrence <- as.numeric(as.character(predictor_data$occurrence))
    f     <- stats::as.formula("occurrence ~ .")
    model <- stats::glm(f, data = predictor_data, family = stats::binomial())
  } else {
    stop("'method' must be \"rf\" or \"glm\".")
  }

  model
}
