test_that("calculate_pollination_index retourne un SpatRaster", {
  r <- terra::rast(
    nrows = 10, ncols = 10,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs  = "EPSG:4326"
  )
  terra::values(r) <- runif(100, 0, 1)
  names(r) <- "suitability"

  demand <- terra::rast(r)
  terra::values(demand) <- runif(100, 0.3, 0.9)
  names(demand) <- "crop_demand"

  idx <- calculate_pollination_index(r, demand)
  expect_true(inherits(idx, "SpatRaster"))
  vals <- terra::values(idx, na.rm = TRUE)
  expect_true(all(vals >= 0))
})

test_that("calculate_pollination_index valeurs bornees entre 0 et 1", {
  r <- terra::rast(
    nrows = 10, ncols = 10,
    xmin = -9, xmax = -4,
    ymin = 31, ymax = 36,
    crs  = "EPSG:4326"
  )
  terra::values(r) <- runif(100, 0, 1)
  names(r) <- "suitability"

  demand <- terra::rast(r)
  terra::values(demand) <- runif(100, 0, 1)
  names(demand) <- "crop_demand"

  idx  <- calculate_pollination_index(r, demand)
  vals <- as.numeric(terra::values(idx, na.rm = TRUE))
  expect_true(all(vals >= 0 & vals <= 1 + 1e-6))
})
