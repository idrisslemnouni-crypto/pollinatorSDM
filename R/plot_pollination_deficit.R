#' Plot pollination deficit map
#'
#' Generates a classified ggplot2 map of the pollination deficit with three
#' deficit classes: low (< 0.33), moderate (0.33-0.66), and high (> 0.66).
#'
#' @param deficit_raster A \code{SpatRaster} of pollination deficit values
#'   (0-1 range). If the raster has two layers (as produced by
#'   \code{\link{calculate_pollination_deficit}}), the first layer is used.
#' @param title Character string. Plot title. Default:
#'   \code{"Pollination Deficit"}.
#' @return A \code{ggplot2} object.
#' @importFrom ggplot2 ggplot aes geom_raster scale_fill_manual labs theme_minimal
#' @export
#' @examples
#' \dontrun{
#'   p <- plot_pollination_deficit(deficit_raster)
#'   print(p)
#' }
plot_pollination_deficit <- function(deficit_raster,
                                     title = "Pollination Deficit") {
  # Use first layer if multi-layer raster
  if (terra::nlyr(deficit_raster) > 1) {
    deficit_raster <- deficit_raster[[1]]
  }

  df <- as.data.frame(deficit_raster, xy = TRUE, na.rm = TRUE)
  names(df)[3] <- "value"
  df <- df[!is.na(df$value), , drop = FALSE]

  if (nrow(df) == 0) {
    warning("Pollination deficit raster has only NA/NaN values. Nothing to plot.")
    return(
      ggplot2::ggplot() +
        ggplot2::labs(
          title = paste0(title, " (no non-missing values)"),
          x = "Longitude", y = "Latitude"
        ) +
        ggplot2::theme_minimal()
    )
  }

  df$deficit_class <- cut(
    as.numeric(df$value),
    breaks         = c(-Inf, 0.33, 0.66, Inf),
    labels         = c("Low deficit", "Moderate deficit", "High deficit"),
    include.lowest = TRUE,
    right          = TRUE
  )

  df$deficit_class <- as.character(df$deficit_class)

  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = deficit_class)) +
    ggplot2::geom_raster() +
    ggplot2::scale_fill_manual(
      values = c(
        "Low deficit"      = "#2ca25f",
        "Moderate deficit" = "#fec44f",
        "High deficit"     = "#de2d26"
      ),
      breaks    = c("Low deficit", "Moderate deficit", "High deficit"),
      limits    = c("Low deficit", "Moderate deficit", "High deficit"),
      na.value  = "transparent",
      drop      = FALSE,
      name      = "Deficit class"
    ) +
    ggplot2::labs(title = title, x = "Longitude", y = "Latitude") +
    ggplot2::theme_minimal()
}
