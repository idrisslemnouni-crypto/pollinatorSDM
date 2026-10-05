# Synthetic demonstration; no GBIF observations or field results.
run_spatial_demo <- function(seed = 42L) {
  set.seed(seed)
  grid <- expand.grid(x = seq(-9, -4, length.out = 30), y = seq(31, 36, length.out = 30))
  grid$temperature <- 15 + grid$y / 10 + rnorm(nrow(grid))
  grid$ndvi <- runif(nrow(grid), 0.1, 0.8)
  probability <- plogis(6 * (grid$ndvi - 0.45) - (grid$temperature - 18.3))
  grid$occurrence <- factor(rbinom(nrow(grid), 1, probability), levels = c(0, 1))
  train_rows <- grid$x < -7.2
  validation_rows <- grid$x >= -7.2 & grid$x < -6.2
  test_rows <- grid$x >= -6.2
  predictors <- c("temperature", "ndvi", "occurrence")
  model <- pollinatorSDM::train_sdm_model(grid[train_rows, predictors], ntree = 100)
  threshold <- pollinatorSDM::select_sdm_threshold(model, grid[validation_rows, predictors])
  evaluation <- pollinatorSDM::evaluate_models(model, grid[test_rows, predictors], threshold)
  list(model = model, metrics = evaluation$metrics, evaluation = evaluation,
       splits = list(train = which(train_rows), validation = which(validation_rows), test = which(test_rows)),
       source = "synthetic_seeded_spatial_grid")
}
