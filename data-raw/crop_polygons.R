library(sf)

crop_polygons <- st_as_sf(data.frame(
  id = 1:5,
  crop = c("amandier", "pommier", "tournesol", "colza", "tomate"),
  pollination_dependence = c("elevee", "elevee", "moderee", "moderee", "faible"),
  surface_ha = c(100, 200, 150, 300, 80),
  lon = c(-2, 0, 5, 8, 3),
  lat = c(38, 40, 42, 37, 45)
), coords = c("lon", "lat"), crs = 4326)

crop_polygons <- st_buffer(crop_polygons, dist = 0.5)

usethis::use_data(crop_polygons, overwrite = TRUE)
