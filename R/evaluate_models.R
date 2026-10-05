#' Evaluate a binary SDM with a fixed decision threshold
#'
#' Test labels never select the threshold. Select it on independent validation.
#' @param model A trained binary randomForest classifier.
#' @param test_data A data.frame with occurrence labels 0/1 and predictors.
#' @param threshold Fixed probability threshold in [0, 1], default 0.5.
#' @return List of metrics, fixed Threshold, roc_plot and roc_object.
#' @export
evaluate_models <- function(model, test_data, threshold = 0.5) {
  if (!is.numeric(threshold) || length(threshold) != 1L ||
      !is.finite(threshold) || threshold < 0 || threshold > 1) {
    stop("'threshold' must be one finite number in [0, 1].")
  }
  values <- .sdm_evaluation_values(model, test_data)
  obs <- values$obs
  probabilities <- values$probabilities
  roc_obj <- pROC::roc(obs, probabilities, levels = c(0, 1), direction = "<", quiet = TRUE)
  pred_class <- as.integer(probabilities >= threshold)
  sensitivity <- mean(pred_class[obs == 1] == 1)
  specificity <- mean(pred_class[obs == 0] == 0)
  auc_val <- as.numeric(pROC::auc(roc_obj))
  accuracy <- mean(pred_class == obs)
  metrics <- data.frame(AUC = auc_val, Accuracy = accuracy, Sensitivity = sensitivity,
                        Specificity = specificity, Threshold = threshold)
  roc_df <- data.frame(fpr = 1 - roc_obj$specificities, sensitivity = roc_obj$sensitivities)
  roc_plot <- ggplot2::ggplot(roc_df, ggplot2::aes(x = fpr, y = sensitivity)) +
    ggplot2::geom_line(color = "steelblue", linewidth = 1) +
    ggplot2::geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    ggplot2::labs(title = paste0("Held-out ROC (AUC = ", round(auc_val, 3), ")"),
                  x = "False positive rate", y = "Sensitivity") +
    ggplot2::theme_minimal()
  list(AUC = auc_val, Accuracy = accuracy, Sensitivity = sensitivity,
       Specificity = specificity, Threshold = threshold, metrics = metrics,
       roc_plot = roc_plot, roc_object = roc_obj)
}

.sdm_evaluation_values <- function(model, data) {
  if (!inherits(model, "randomForest") || model$type != "classification") {
    stop("'model' must be a binary randomForest classifier.")
  }
  if (!is.data.frame(data) || !"occurrence" %in% names(data) || nrow(data) == 0) {
    stop("Evaluation data must be a non-empty data.frame with 'occurrence'.")
  }
  labels <- as.character(data$occurrence)
  if (anyNA(labels) || !setequal(unique(labels), c("0", "1"))) {
    stop("Evaluation data must contain both classes, labelled 0 and 1.")
  }
  if (!setequal(model$classes, c("0", "1"))) stop("Model classes must be labelled 0 and 1.")
  probabilities <- stats::predict(model, newdata = data, type = "prob")[, "1"]
  if (any(!is.finite(probabilities))) stop("Predictions must be finite.")
  list(obs = as.integer(labels), probabilities = probabilities)
}
