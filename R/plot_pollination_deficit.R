#' Plot pollination deficit map
#' @param r SpatRaster
#' @param title Character
#' @return ggplot
#' @export
plot_pollination_deficit <- function(r, title = "Pollination Deficit") {
  df <- as.data.frame(r, xy = TRUE)
  names(df)[3] <- "value"
  df$class <- cut(df$value, breaks = c(0, 1, 2, 3), labels = c("Faible", "Modere", "Eleve"))
  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = class)) +
    ggplot2::geom_raster() +
    ggplot2::scale_fill_manual(values = c("Faible" = "green", "Modere" = "orange", "Eleve" = "red")) +
    ggplot2::ggtitle(title) +
    ggplot2::theme_minimal()
}
