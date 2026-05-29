library(terra)
r <- rast(ncols=100, nrows=100, nlyrs=4, crs="EPSG:4326",
          xmin=-15, xmax=25, ymin=25, ymax=55,
          names=c("temperature", "precipitation", "landcover", "elevation"))
set.seed(123)
values(r[[1]]) <- rnorm(ncell(r), 15, 10)
values(r[[2]]) <- rgamma(ncell(r), 2, 0.01)
values(r[[3]]) <- sample(1:5, ncell(r), replace = TRUE)
values(r[[4]]) <- runif(ncell(r), 0, 3000)
env_rasters <- r
usethis::use_data(env_rasters, overwrite = TRUE)
