library(testthat)
library(pollinatorSDM)

test_that("clean_occurrences errors if env_rasters is missing", {
  x <- data.frame(
    decimalLongitude = c(-6.8, -7.1, -6.9),
    decimalLatitude = c(34.0, 33.9, 34.1),
    species = c("Apis mellifera", "Apis mellifera", "Bombus terrestris")
  )

  expect_error(clean_occurrences(x))
})

test_that("generate_background_points errors if presence_sf is missing", {
  r <- terra::rast(
    nrows = 10, ncols = 10,
    xmin = -10, xmax = -5,
    ymin = 30, ymax = 35,
    crs = "EPSG:4326",
    vals = runif(100)
  )
  names(r) <- "var1"

  expect_error(generate_background_points(r, n = 50))
})

test_that("plot_pollinator_map runs without error on a simple raster", {
  r <- terra::rast(
    nrows = 10, ncols = 10,
    xmin = -10, xmax = -5,
    ymin = 30, ymax = 35,
    crs = "EPSG:4326",
    vals = runif(100)
  )
  names(r) <- "suitability"

  expect_no_error(plot_pollinator_map(r))
})
