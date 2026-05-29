#' Plot pollinator suitability map
#' @param r SpatRaster
#' @param title Character
#' @return ggplot
#' @export
plot_pollinator_map <- function(r, title = "Pollinator Suitability") {
  df <- as.data.frame(r, xy = TRUE)
  names(df)[3] <- "value"
  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = value)) +
    ggplot2::geom_raster() +
    ggplot2::scale_fill_viridis_c() +
    ggplot2::ggtitle(title) +
    ggplot2::theme_minimal()
}
