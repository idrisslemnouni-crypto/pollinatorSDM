#' Plot pollinator distribution map
#' @param prediction_raster SpatRaster
#' @param title Character
#' @return ggplot object
#' @export
plot_pollinator_map <- function(prediction_raster, title = "Pollinator Suitability") {
  df <- as.data.frame(prediction_raster, xy = TRUE)
  names(df)[3] <- "value"

  uniq <- unique(na.omit(df$value))

  if (length(uniq) <= 5) {
    df$value <- as.factor(df$value)
    scale_fill <- ggplot2::scale_fill_viridis_d(name = "Suitability")
  } else {
    scale_fill <- ggplot2::scale_fill_viridis_c(name = "Suitability")
  }

  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = value)) +
    ggplot2::geom_raster() +
    scale_fill +
    ggplot2::labs(title = title, x = "Longitude", y = "Latitude") +
    ggplot2::theme_minimal()
}
