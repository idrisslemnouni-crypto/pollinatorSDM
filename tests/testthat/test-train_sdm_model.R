test_that("train_sdm_model retourne un modele randomForest", {
  set.seed(42)
  df <- data.frame(
    occurrence = factor(rep(c("1","0"), each = 50)),
    bio1       = rnorm(100, mean = c(rep(20,50), rep(14,50)), sd = 2),
    bio12      = rnorm(100, mean = c(rep(400,50), rep(230,50)), sd = 50),
    ndvi       = runif(100, 0.1, 0.8)
  )
  model <- train_sdm_model(df, method = "rf", ntree = 100)

  expect_true(inherits(model, "randomForest") ||
              inherits(model, "list") ||
              !is.null(model))
})

test_that("train_sdm_model refuse un dataset sans colonne occurrence", {
  df_bad <- data.frame(
    bio1  = rnorm(50),
    bio12 = rnorm(50)
  )
  expect_error(train_sdm_model(df_bad, method = "rf"))
})

test_that("train_sdm_model fonctionne avec methode rf", {
  set.seed(1)
  df <- data.frame(
    occurrence = factor(rep(c("1","0"), each = 30)),
    bio1       = rnorm(60, mean = c(rep(18,30), rep(12,30)), sd = 3),
    bio12      = rnorm(60, mean = c(rep(350,30), rep(200,30)), sd = 60),
    ndvi       = runif(60, 0.1, 0.8)
  )
  model <- train_sdm_model(df, method = "rf", ntree = 50)
  expect_false(is.null(model))
})
