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
    species          = sample(c("Apis mellifera", "Bombus terrestris"), n, replace = TRUE),
    stringsAsFactors = FALSE
  )
}

# ─── clean_occurrences ───────────────────────────────────────────────────────
test_that("clean_occurrences errors if env_rasters is missing", {
  x <- make_occurrences(5)
  expect_error(clean_occurrences(x))
})

test_that("clean_occurrences returns list with data and report", {
  set.seed(1)
  x <- make_occurrences(15)
  r <- make_raster()
  result <- clean_occurrences(x, r)
  expect_type(result, "list")
  expect_true("data" %in% names(result))
  expect_true("report" %in% names(result))
  expect_s3_class(result$data, "sf")
  expect_s3_class(result$report, "data.frame")
})

# ─── generate_background_points ─────────────────────────────────────────────
test_that("generate_background_points errors if presence_sf is missing", {
  r <- make_raster()
  expect_error(generate_background_points(r, n_points = 50))
})

test_that("generate_background_points returns sf object", {
  set.seed(42)
  r <- make_raster(20, 20)
  occ <- make_occurrences(5)
  pres_sf <- sf::st_as_sf(occ, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
  bg <- generate_background_points(r, presence_sf = pres_sf, n_points = 30)
  expect_s3_class(bg, "sf")
  expect_gt(nrow(bg), 0)
})

# ─── train_sdm_model ─────────────────────────────────────────────────────────
test_that("train_sdm_model errors if occurrence column is missing", {
  df <- data.frame(var1 = runif(20), var2 = runif(20))
  expect_error(train_sdm_model(df))
})

test_that("train_sdm_model returns a randomForest object", {
  set.seed(99)
  df <- data.frame(
    occurrence = factor(rep(c(0, 1), each = 25)),
    var1 = c(rnorm(25, 10, 2), rnorm(25, 15, 2)),
    var2 = c(rnorm(25, 5, 1),  rnorm(25, 8, 1))
  )
  model <- train_sdm_model(df, ntree = 50)
  expect_s3_class(model, "randomForest")
})

# ─── calculate_pollination_deficit ───────────────────────────────────────────
test_that("calculate_pollination_deficit returns raster with non-negative values", {
  set.seed(5)
  r1 <- make_raster(10, 10, 1)
  r2 <- make_raster(10, 10, 1)
  names(r1) <- "suitability"
  names(r2) <- "pollination_index"
  result <- calculate_pollination_deficit(r1, r2)
  expect_s4_class(result, "SpatRaster")
  expect_equal(names(result), "pollination_deficit")
  expect_gte(terra::global(result, "min", na.rm = TRUE)[[1]], 0)
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

# ─── plot_pollinator_map ──────────────────────────────────────────────────────
test_that("plot_pollinator_map runs without error on a simple raster", {
  r <- make_raster(10, 10, 1)
  names(r) <- "suitability"
  expect_no_error(plot_pollinator_map(r))
})

# ─── predict_pollinator_distribution ─────────────────────────────────────────
test_that("predict_pollinator_distribution errors if model is not randomForest", {
  r <- make_raster()
  expect_error(predict_pollinator_distribution(list(), r))
})

test_that("predict_pollinator_distribution errors if rasters is not SpatRaster", {
  set.seed(99)
  df <- data.frame(
    occurrence = factor(rep(c(0, 1), each = 25)),
    var1 = c(rnorm(25, 10, 2), rnorm(25, 15, 2)),
    var2 = c(rnorm(25, 5, 1),  rnorm(25, 8, 1))
  )
  model <- train_sdm_model(df, ntree = 50)
  expect_error(predict_pollinator_distribution(model, data.frame()))
})
