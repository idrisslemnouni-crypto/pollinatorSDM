#' Evaluate SDM models
#' @param model Fitted model
#' @param test_data Test dataset
#' @return list with metrics and plot
#' @export
evaluate_models <- function(model, test_data) {
  test_data <- as.data.frame(test_data)
  test_data <- test_data[, !sapply(test_data, is.character)]
  test_data <- test_data[, !sapply(test_data, function(x) is.list(x) || inherits(x, "sfc"))]
  test_data <- na.omit(test_data)

  pred_prob <- predict(model, test_data, type = "prob")[,2]
  pred_class <- ifelse(pred_prob > 0.5, 1, 0)
  obs <- test_data$presence
  if(is.factor(obs)) obs <- as.numeric(as.character(obs))

  cm <- table(obs, pred_class)
  auc <- tryCatch({
    p <- pred_prob[obs==1]; a <- pred_prob[obs==0]
    r <- rank(c(p, a))
    (sum(r[1:length(p)]) - length(p)*(length(p)+1)/2) / (length(p)*length(a))
  }, error = function(e) NA)

  roc_df <- data.frame(
    threshold = seq(0, 1, by = 0.05),
    sens = sapply(seq(0, 1, by = 0.05), function(t) {
      p <- ifelse(pred_prob > t, 1, 0)
      sum(p==1 & obs==1) / max(sum(obs==1), 1)
    }),
    spec = sapply(seq(0, 1, by = 0.05), function(t) {
      p <- ifelse(pred_prob > t, 1, 0)
      sum(p==0 & obs==0) / max(sum(obs==0), 1)
    })
  )
  roc_df$fpr <- 1 - roc_df$spec

  roc_plot <- ggplot2::ggplot(roc_df, ggplot2::aes(x = fpr, y = sens)) +
    ggplot2::geom_line(color = "blue", linewidth = 1) +
    ggplot2::geom_abline(linetype = "dashed", color = "gray") +
    ggplot2::labs(title = paste("ROC Curve (AUC =", round(auc, 3), ")"),
                  x = "False Positive Rate", y = "Sensitivity") +
    ggplot2::theme_minimal()

  metrics <- data.frame(AUC = auc,
                        Accuracy = sum(diag(cm))/sum(cm),
                        Sensitivity = cm[2,2]/sum(cm[2,]),
                        Specificity = cm[1,1]/sum(cm[1,]))

  list(metrics = metrics, roc_plot = roc_plot)
}
