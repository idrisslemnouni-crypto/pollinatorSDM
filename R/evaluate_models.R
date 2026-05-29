#' Evaluate SDM models
#' @param model Fitted model
#' @param test_data Test dataset
#' @return data.frame
#' @export
evaluate_models <- function(model, test_data) {
  test_data <- as.data.frame(test_data)
  test_data <- test_data[, !sapply(test_data, is.character)]
  test_data <- test_data[, !sapply(test_data, function(x) is.list(x) || inherits(x, "sfc"))]
  test_data <- na.omit(test_data)
  pred <- predict(model, test_data)
  obs <- test_data$presence
  if(is.factor(obs)) obs <- as.numeric(as.character(obs))
  cm <- table(obs, pred > 0.5)
  auc <- tryCatch({
    r <- rank(c(pred[obs==1], pred[obs==0]))
    (sum(r[1:sum(obs==1)]) - sum(obs==1)*(sum(obs==1)+1)/2) / (sum(obs==1)*sum(obs==0))
  }, error = function(e) NA)
  data.frame(
    AUC = auc,
    Accuracy = sum(diag(cm)) / sum(cm),
    Sensitivity = tryCatch(cm[2,2] / sum(cm[2,]), error = function(e) NA),
    Specificity = tryCatch(cm[1,1] / sum(cm[1,]), error = function(e) NA)
  )
}
