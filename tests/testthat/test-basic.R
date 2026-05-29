make_test_raster <- function() {
  n <- 50 * 50
  ext <- c(-10, 10, 30, 50)
  r1 <- terra::rast(nrows = 50, ncols = 50, crs = "EPSG:4326", extent = ext, vals = rnorm(n, 15, 10))
  r2 <- terra::rast(nrows = 50, ncols = 50, crs = "EPSG:4326", extent = ext, vals = rgamma(n, 2, 0.01))
  r3 <- terra::rast(nrows = 50, ncols = 50, crs = "EPSG:4326", extent = ext, vals = sample(1:5, n, replace = TRUE))
  r4 <- terra::rast(nrows = 50, ncols = 50, crs = "EPSG:4326", extent = ext, vals = runif(n, 0, 3000))
  r <- c(r1, r2, r3, r4)
  names(r) <- c("temperature", "precipitation", "landcover", "elevation")
  r
}

test_that("download works", {
  d <- download_pollinator_data(limit = 10)
  expect_true(nrow(d) > 0)
  expect_true("species" %in% names(d))
})

test_that("clean returns sf", {
  d <- download_pollinator_data(limit = 10)
  expect_s3_class(clean_occurrences(d), "sf")
})

test_that("predictors prepared", {
  occ <- clean_occurrences(download_pollinator_data(limit = 10))
  r <- make_test_raster()
  p <- prepare_predictors(occ, r)
  expect_true("temperature" %in% names(p))
})
