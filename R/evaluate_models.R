#' Evaluate SDM models
#'
#' Calcule AUC, Accuracy, Sensibilité, Spécificité, et génère la courbe ROC.
#'
#' @param model modèle entraîné (randomForest)
#' @param test_data data.frame de test avec occurrence et prédicteurs
#' @return list(metrics = data.frame, roc_plot = ggplot)
#' @export
evaluate_models <- function(model, test_data) {
  if (!requireNamespace("pROC", quietly = TRUE)) {
    install.packages("pROC")
  }

  pred_prob <- predict(model, test_data, type = "prob")[, "1"]
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
  sensitivity <- tp / (tp + fn)
  specificity <- tn / (tn + fp)

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
    ggplot2::geom_line(color = "blue", size = 1) +
    ggplot2::geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
    ggplot2::labs(
      title = paste("ROC Curve (AUC =", round(as.numeric(auc_val), 3), ")"),
      x = "1 - Specificity",
      y = "Sensitivity"
    ) +
    ggplot2::theme_minimal()

  list(metrics = metrics, roc_plot = roc_plot, roc_object = roc_obj)
}
