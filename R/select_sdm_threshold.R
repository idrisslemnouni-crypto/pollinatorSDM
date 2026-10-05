#' Select a decision threshold using independent validation data
#'
#' Youden selection with fixed ROC direction. Keep validation independent of
#' training and final evaluation. Ties use proximity to 0.5 then smaller value.
#' @param model A trained binary randomForest classifier.
#' @param validation_data Independent labelled validation data.
#' @return One numeric threshold in [0, 1]; 0.5 for constant scores.
#' @export
select_sdm_threshold <- function(model, validation_data) {
  values <- .sdm_evaluation_values(model, validation_data)
  roc <- pROC::roc(values$obs, values$probabilities, levels = c(0, 1), direction = "<", quiet = TRUE)
  choices <- pROC::coords(roc, "best", ret = "threshold", transpose = FALSE)$threshold
  choices <- choices[is.finite(choices) & choices >= 0 & choices <= 1]
  if (!length(choices)) return(0.5)
  choices[order(abs(choices - 0.5), choices)][1]
}
