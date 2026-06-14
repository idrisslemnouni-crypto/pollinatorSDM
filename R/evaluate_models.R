#' Evaluate SDM models
#'
#' Calcule AUC, Accuracy, Sensibilité, Spécificité, et génère la courbe ROC.
#'
#' @param model modèle entraîné (randomForest)
#' @param test_data data.frame de test avec occurrence et prédicteurs
#' @return list(metrics = data.frame, roc_plot = ggplot, roc_object = pROC::roc)
#' @export
evaluate_models <- function(model, test_data) {
  pred_prob <- stats::predict(model, test_data, type = "prob")[, "1"]
  obs <- as.numeric(as.character(test_data$occurrence))

  # ROC et AUC
  roc_obj <- pROC::roc(obs, pred_prob, quiet = TRUE)
  auc_val <- pROC::auc(roc_obj)

  # Seuil optimal (Youden)
  optimal <- pROC::coords(roc_obj, "best", ret = c("threshold", "specificity", "sensitivity"))
  thresh <- optimal$threshold[1]

  # Classification binaire
  pred_class <- ifelse(pred_prob >= thresh, 1, 0)

  # Matrice de confusion
  tp <- sum(pred_class == 1 & obs == 1)
  tn <- sum(pred_class == 0 & obs == 0)
  fp <- sum(pred_class == 1 & obs == 0)
  fn <- sum(pred_class == 0 & obs == 1)

  accuracy <- (tp + tn) / length(obs)
  sensitivity <- if ((tp + fn) > 0) tp / (tp + fn) else NA_real_
  specificity <- if ((tn + fp) > 0) tn / (tn + fp) else NA_real_

  metrics <- data.frame(
    AUC = as.numeric(auc_val),
    Accuracy = accuracy,
    Sensitivity = sensitivity,
    Specificity = specificity,
    Threshold = thresh
  )

  # Plot ROC avec ggplot2
  roc_df <- data.frame(
    specificity = roc_obj$specificities,
    sensitivity = roc_obj$sensitivities
  )

  roc_plot <- ggplot2::ggplot(roc_df, ggplot2::aes(x = 1 - specificity, y = sensitivity)) +
    ggplot2::geom_line(color = "steelblue", linewidth = 1) +
    ggplot2::geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey50") +
    ggplot2::labs(
      title = paste("ROC Curve (AUC =", round(as.numeric(auc_val), 3), ")"),
      x = "1 - Specificity (False Positive Rate)",
      y = "Sensitivity (True Positive Rate)"
    ) +
    ggplot2::theme_minimal(base_size = 12)

  list(metrics = metrics, roc_plot = roc_plot, roc_object = roc_obj)
}
