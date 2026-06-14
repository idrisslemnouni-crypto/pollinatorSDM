test_that("calculate_pollination_deficit retourne un SpatRaster", {
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

  idx     <- calculate_pollination_index(r, demand)
  deficit <- calculate_pollination_deficit(r, idx)
  expect_true(inherits(deficit, "SpatRaster"))
})

test_that("calculate_pollination_deficit valeurs non negatives", {
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

  idx     <- calculate_pollination_index(r, demand)
  deficit <- calculate_pollination_deficit(r, idx)
  vals    <- as.numeric(terra::values(deficit, na.rm = TRUE))
  expect_true(all(vals >= 0))
})
