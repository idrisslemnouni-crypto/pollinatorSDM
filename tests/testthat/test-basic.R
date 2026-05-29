library(testthat)
library(pollinatorSDM)

test_that("data download works", {
  d <- download_pollinator_data(limit = 10)
  expect_true(nrow(d) > 0)
  expect_true(all(c("species", "decimalLongitude", "decimalLatitude") %in% names(d)))
})

test_that("clean returns sf", {
  d <- download_pollinator_data(limit = 10)
  cleaned <- clean_occurrences(d)
  occ_clean <- cleaned$cleaned
  expect_s3_class(occ_clean, "sf")
})

test_that("predictors prepared", {
  d <- download_pollinator_data(limit = 10)
  occ <- clean_occurrences(d)$cleaned
  r <- terra::rast(nrows = 10, ncols = 10, crs = "EPSG:4326", vals = runif(100))
  names(r) <- "var1"
  p <- prepare_predictors(occ, r)
  expect_true("var1" %in% names(p))
  expect_true(nrow(p) > 0)
})

test_that("background generated", {
  r <- terra::rast(nrows = 10, ncols = 10, crs = "EPSG:4326", vals = runif(100))
  names(r) <- "var1"
  bg <- generate_background_points(r, n = 50)
  expect_equal(nrow(bg), 50)
})
