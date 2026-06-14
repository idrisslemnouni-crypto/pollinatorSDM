test_that("evaluate_models retourne AUC entre 0 et 1", {
  set.seed(42)
  n  <- 100
  df <- data.frame(
    occurrence = factor(rep(c("1","0"), each = n/2)),
    bio1       = rnorm(n, mean = c(rep(20, n/2), rep(15, n/2)), sd = 3),
    bio12      = rnorm(n, mean = c(rep(400, n/2), rep(250, n/2)), sd = 60),
    ndvi       = runif(n, 0.1, 0.8)
  )
  model <- train_sdm_model(df, method = "rf", ntree = 50)
  perf  <- evaluate_models(model, df)

  expect_true(is.list(perf) || is.data.frame(perf))
  auc_val <- if (is.data.frame(perf)) perf$AUC[1] else perf$AUC
  if (!is.null(auc_val)) {
    expect_gte(as.numeric(auc_val), 0)
    expect_lte(as.numeric(auc_val), 1)
  }
})

test_that("evaluate_models inclut des metriques nommees", {
  set.seed(7)
  n  <- 80
  df <- data.frame(
    occurrence = factor(rep(c("1","0"), each = n/2)),
    bio1       = rnorm(n, mean = c(rep(18, n/2), rep(12, n/2)), sd = 2),
    bio12      = rnorm(n, mean = c(rep(380, n/2), rep(220, n/2)), sd = 50),
    ndvi       = runif(n, 0.1, 0.8)
  )
  model <- train_sdm_model(df, method = "rf", ntree = 50)
  perf  <- evaluate_models(model, df)
  nms   <- if (is.data.frame(perf)) names(perf) else names(perf)
  expect_true(any(grepl("(?i)acc|auc|sens|spec", nms, perl = TRUE)))
})
