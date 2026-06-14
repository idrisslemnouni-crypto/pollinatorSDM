library(testthat)
library(pollinatorSDM)

# ─── Helpers ─────────────────────────────────────────────────────────────────
make_raster <- function(nrows = 10, ncols = 10, n_layers = 3) {
  r <- terra::rast(
    nrows = nrows, ncols = ncols,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs = "EPSG:4326"
  )
  vals <- matrix(runif(nrows * ncols * n_layers), ncol = n_layers)
  terra::values(r) <- vals
  names(r) <- paste0("var", seq_len(n_layers))
  r
}

make_occurrences <- function(n = 10) {
  data.frame(
    decimalLongitude = runif(n, -8.5, -4.5),
    decimalLatitude  = runif(n, 31.5, 35.5),
    species          = sample(c("Apis mellifera", "Bombus terrestris"),
                              n, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

make_train_df <- function(n_per_class = 25, seed = 99) {
  set.seed(seed)
  data.frame(
    occurrence = factor(rep(c(0, 1), each = n_per_class)),
    var1 = c(rnorm(n_per_class, 10, 2), rnorm(n_per_class, 15, 2)),
    var2 = c(rnorm(n_per_class,  5, 1), rnorm(n_per_class,  8, 1))
  )
}

# ─── clean_occurrences ───────────────────────────────────────────────────────
test_that("clean_occurrences errors if env_rasters is missing", {
  x <- make_occurrences(5)
  expect_error(clean_occurrences(x))
})

test_that("clean_occurrences returns list with data and report", {
  set.seed(1)
  x      <- make_occurrences(15)
  r      <- make_raster()
  result <- clean_occurrences(x, r)
  expect_type(result, "list")
  expect_true("data"   %in% names(result))
  expect_true("report" %in% names(result))
  expect_s3_class(result$data,   "sf")
  expect_s3_class(result$report, "data.frame")
})

# ─── generate_background_points ─────────────────────────────────────────────
test_that("generate_background_points errors if presence_sf is missing", {
  r <- make_raster()
  expect_error(generate_background_points(r, n_points = 50))
})

test_that("generate_background_points returns sf object with positive rows", {
  set.seed(42)
  r       <- make_raster(20, 20)
  occ     <- make_occurrences(5)
  pres_sf <- sf::st_as_sf(occ,
               coords = c("decimalLongitude", "decimalLatitude"),
               crs    = 4326)
  bg <- generate_background_points(r, presence_sf = pres_sf, n_points = 30)
  expect_s3_class(bg, "sf")
  expect_gt(nrow(bg), 0)
})

# ─── train_sdm_model ─────────────────────────────────────────────────────────
test_that("train_sdm_model errors if occurrence column is missing", {
  df <- data.frame(var1 = runif(20), var2 = runif(20))
  expect_error(train_sdm_model(df))
})

test_that("train_sdm_model returns a randomForest object with method rf", {
  df    <- make_train_df()
  model <- train_sdm_model(df, ntree = 50)
  expect_s3_class(model, "randomForest")
})

test_that("train_sdm_model returns a glm object with method glm", {
  df    <- make_train_df()
  model <- train_sdm_model(df, method = "glm")
  expect_s3_class(model, "glm")
})

test_that("train_sdm_model errors on unknown method", {
  df <- make_train_df()
  expect_error(train_sdm_model(df, method = "maxent"))
})

# ─── evaluate_models ─────────────────────────────────────────────────────────
test_that("evaluate_models returns a list with AUC and Accuracy", {
  df    <- make_train_df()
  model <- train_sdm_model(df, ntree = 50)
  eval  <- evaluate_models(model, df)
  expect_type(eval, "list")
  expect_true("AUC"      %in% names(eval))
  expect_true("Accuracy" %in% names(eval))
  expect_gte(eval$AUC,      0)
  expect_lte(eval$AUC,      1)
  expect_gte(eval$Accuracy, 0)
  expect_lte(eval$Accuracy, 1)
})

test_that("evaluate_models works with glm model", {
  df    <- make_train_df()
  model <- train_sdm_model(df, method = "glm")
  eval  <- evaluate_models(model, df)
  expect_gte(eval$AUC, 0)
  expect_lte(eval$AUC, 1)
})

# ─── calculate_pollination_deficit ───────────────────────────────────────────
test_that("calculate_pollination_deficit returns two-layer raster with non-negative deficit", {
  set.seed(5)
  r1 <- make_raster(10, 10, 1)
  r2 <- make_raster(10, 10, 1)
  names(r1) <- "suitability"
  names(r2) <- "demand"
  result <- calculate_pollination_deficit(r1, r2)
  expect_s4_class(result, "SpatRaster")
  expect_equal(terra::nlyr(result), 2)
  expect_true("pollination_deficit" %in% names(result))
  expect_true("deficit_class"       %in% names(result))
  expect_gte(terra::global(result[["pollination_deficit"]], "min", na.rm = TRUE)[[1]], 0)
})

# ─── calculate_pollination_index ─────────────────────────────────────────────
test_that("calculate_pollination_index returns raster named pollination_index", {
  set.seed(6)
  r1 <- make_raster(10, 10, 1)
  r2 <- make_raster(10, 10, 1)
  result <- calculate_pollination_index(r1, r2)
  expect_s4_class(result, "SpatRaster")
  expect_equal(names(result), "pollination_index")
})

test_that("calculate_pollination_index errors on non-SpatRaster input", {
  r <- make_raster(10, 10, 1)
  expect_error(calculate_pollination_index(data.frame(), r))
  expect_error(calculate_pollination_index(r, data.frame()))
})

# ─── predict_pollinator_distribution ─────────────────────────────────────────
test_that("predict_pollinator_distribution errors if model is not randomForest", {
  r <- make_raster()
  expect_error(predict_pollinator_distribution(list(), r))
})

test_that("predict_pollinator_distribution errors if rasters is not SpatRaster", {
  df    <- make_train_df()
  model <- train_sdm_model(df, ntree = 50)
  expect_error(predict_pollinator_distribution(model, data.frame()))
})

test_that("predict_pollinator_distribution returns SpatRaster with values in [0,1]", {
  df    <- make_train_df()
  model <- train_sdm_model(df, ntree = 50)
  r     <- make_raster(n_layers = 2)
  names(r) <- c("var1", "var2")
  pred  <- predict_pollinator_distribution(model, r)
  expect_s4_class(pred, "SpatRaster")
  expect_gte(terra::global(pred, "min", na.rm = TRUE)[[1]], 0)
  expect_lte(terra::global(pred, "max", na.rm = TRUE)[[1]], 1)
})

# ─── plot functions ───────────────────────────────────────────────────────────
test_that("plot_pollinator_map runs without error", {
  r        <- make_raster(10, 10, 1)
  names(r) <- "suitability"
  expect_no_error(plot_pollinator_map(r))
})

test_that("plot_pollination_deficit runs without error", {
  r        <- make_raster(10, 10, 1)
  names(r) <- "deficit"
  terra::values(r) <- runif(100, 0, 1)
  expect_no_error(plot_pollination_deficit(r))
})

# ─── utils ────────────────────────────────────────────────────────────────────
test_that("normalise_01 returns values between 0 and 1", {
  x      <- c(2, 4, 6, 8, 10)
  result <- pollinatorSDM:::normalise_01(x)
  expect_gte(min(result), 0)
  expect_lte(max(result), 1)
})

test_that("check_raster_layers stops on missing layers", {
  r <- make_raster(n_layers = 2)
  names(r) <- c("bio1", "bio12")
  expect_error(pollinatorSDM:::check_raster_layers(r, c("bio1", "ndvi")))
  expect_invisible(pollinatorSDM:::check_raster_layers(r, c("bio1", "bio12")))
})

# ─── built-in datasets ───────────────────────────────────────────────────────
test_that("pollinator_occurrences dataset has required columns", {
  data(pollinator_occurrences, package = "pollinatorSDM")
  expect_s3_class(pollinator_occurrences, "data.frame")
  expect_true(all(c("species", "decimalLongitude",
                    "decimalLatitude") %in% names(pollinator_occurrences)))
  expect_gt(nrow(pollinator_occurrences), 0)
})

test_that("crop_dependencies dataset has dependency column in [0,1]", {
  data(crop_dependencies, package = "pollinatorSDM")
  expect_s3_class(crop_dependencies, "data.frame")
  expect_true("dependency" %in% names(crop_dependencies))
  expect_true(all(crop_dependencies$dependency >= 0 &
                    crop_dependencies$dependency <= 1))
})
