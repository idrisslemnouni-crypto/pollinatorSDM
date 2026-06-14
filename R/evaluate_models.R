#' Evaluate SDM models
#'
#' Computes AUC, Accuracy, Sensitivity, Specificity and generates a ROC curve
#' for a trained Random Forest SDM model.
#'
#' @param model A trained \code{randomForest} model object.
#' @param test_data A \code{data.frame} with an \code{occurrence} column
#'   (factor with levels \code{"0"} and \code{"1"}) and predictor columns.
#' @return A named list with:
#'   \describe{
#'     \item{AUC}{Numeric scalar. Area Under the ROC curve (0-1).}
#'     \item{Accuracy}{Numeric scalar. Overall classification accuracy (0-1).}
#'     \item{Sensitivity}{Numeric scalar. True positive rate at optimal threshold.}
#'     \item{Specificity}{Numeric scalar. True negative rate at optimal threshold.}
#'     \item{Threshold}{Numeric scalar. Optimal decision threshold (Youden index).}
#'     \item{metrics}{data.frame summarising all metrics above.}
#'     \item{roc_plot}{A \code{ggplot2} ROC curve.}
#'     \item{roc_object}{The \code{pROC::roc} object for further analysis.}
#'   }
#' @importFrom stats predict
#' @importFrom ggplot2 ggplot aes geom_line geom_abline labs theme_minimal
#' @export
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   occurrence = factor(rep(c(0, 1), each = 25)),
#'   var1 = c(rnorm(25, 10, 2), rnorm(25, 15, 2)),
#'   var2 = c(rnorm(25,  5, 1), rnorm(25,  8, 1))
#' )
#' model <- train_sdm_model(df, ntree = 50)
#' result <- evaluate_models(model, df)
#' cat("AUC:", result$AUC, "\n")
#' print(result$roc_plot)
#' }
evaluate_models <- function(model, test_data) {

  if (!inherits(model, "randomForest")) {
    stop("'model' must be a randomForest object.")
  }
  if (!"occurrence" %in% names(test_data)) {
    stop("'test_data' must contain an 'occurrence' column.")
  }

  test_data$occurrence <- as.factor(test_data$occurrence)

  pred_prob <- stats::predict(model, test_data, type = "prob")[, "1"]
  obs       <- as.numeric(as.character(test_data$occurrence))

  # ROC curve and AUC
  roc_obj <- pROC::roc(obs, pred_prob, quiet = TRUE)
  auc_val <- as.numeric(pROC::auc(roc_obj))

  # Optimal threshold (Youden index)
  optimal <- pROC::coords(roc_obj, "best",
                          ret = c("threshold", "specificity", "sensitivity"))
  thresh      <- optimal$threshold[1]
  sens_opt    <- optimal$sensitivity[1]
  spec_opt    <- optimal$specificity[1]

  # Binary classification at optimal threshold
  pred_class <- ifelse(pred_prob >= thresh, 1, 0)

  tp <- sum(pred_class == 1 & obs == 1)
  tn <- sum(pred_class == 0 & obs == 0)
  fp <- sum(pred_class == 1 & obs == 0)
  fn <- sum(pred_class == 0 & obs == 1)

  accuracy    <- (tp + tn) / length(obs)
  sensitivity <- if ((tp + fn) > 0) tp / (tp + fn) else NA_real_
  specificity <- if ((tn + fp) > 0) tn / (tn + fp) else NA_real_

  metrics <- data.frame(
    AUC         = auc_val,
    Accuracy    = accuracy,
    Sensitivity = sensitivity,
    Specificity = specificity,
    Threshold   = thresh
  )

  # ROC plot
  roc_df <- data.frame(
    fpr         = 1 - roc_obj$specificities,
    sensitivity = roc_obj$sensitivities
  )
  roc_plot <- ggplot2::ggplot(
    roc_df,
    ggplot2::aes(x = fpr, y = sensitivity)
  ) +
    ggplot2::geom_line(color = "steelblue", linewidth = 1) +
    ggplot2::geom_abline(intercept = 0, slope = 1,
                         linetype = "dashed", color = "grey50") +
    ggplot2::labs(
      title = paste0("ROC Curve  (AUC = ", round(auc_val, 3), ")"),
      x     = "1 - Specificity  (False Positive Rate)",
      y     = "Sensitivity  (True Positive Rate)"
    ) +
    ggplot2::theme_minimal(base_size = 12)

  # Return both flat scalars (for easy $AUC access) AND the full metrics df
  list(
    AUC         = auc_val,
    Accuracy    = accuracy,
    Sensitivity = sensitivity,
    Specificity = specificity,
    Threshold   = thresh,
    metrics     = metrics,
    roc_plot    = roc_plot,
    roc_object  = roc_obj
  )
}
