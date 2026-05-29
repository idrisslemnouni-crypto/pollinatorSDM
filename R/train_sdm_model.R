#' Train Species Distribution Model
#' @param presence_data data.frame
#' @param background_data data.frame
#' @param method Character
#' @return list with model, train_data, test_data
#' @export
train_sdm_model <- function(presence_data, background_data, method = "rf") {
  presence_data <- as.data.frame(presence_data)
  background_data <- as.data.frame(background_data)
  presence_data <- presence_data[, !sapply(presence_data, is.character)]
  background_data <- background_data[, !sapply(background_data, is.character)]
  presence_data <- presence_data[, !sapply(presence_data, function(x) is.list(x) || inherits(x, "sfc"))]
  background_data <- background_data[, !sapply(background_data, function(x) is.list(x) || inherits(x, "sfc"))]
  presence_data$presence <- 1
  background_data$presence <- 0
  common_cols <- intersect(names(presence_data), names(background_data))
  combined <- rbind(presence_data[, common_cols], background_data[, common_cols])
  combined <- na.omit(combined)
  combined$presence <- factor(combined$presence)

  set.seed(42)
  train_idx <- sample(1:nrow(combined), 0.8 * nrow(combined))
  train_data <- combined[train_idx, ]
  test_data <- combined[-train_idx, ]

  model <- caret::train(presence ~ ., data = train_data, method = method, trControl = caret::trainControl(method = "cv", number = 5))
  list(model = model, train_data = train_data, test_data = test_data)
}
