plot_pollination_deficit <- function(deficit_raster, title = "Pollination Deficit") {
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
    breaks = c(-Inf, 0.33, 0.66, Inf),
    labels = c("Low deficit", "Moderate deficit", "High deficit"),
    include.lowest = TRUE,
    right = TRUE
  )

  df$deficit_class <- as.character(df$deficit_class)

  ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = deficit_class)) +
    ggplot2::geom_raster() +
    ggplot2::scale_fill_manual(
      values = c(
        "Low deficit" = "#2ca25f",
        "Moderate deficit" = "#fec44f",
        "High deficit" = "#de2d26"
      ),
      breaks = c("Low deficit", "Moderate deficit", "High deficit"),
      limits = c("Low deficit", "Moderate deficit", "High deficit"),
      na.value = "transparent",
      drop = FALSE,
      name = "Deficit class"
    ) +
    ggplot2::labs(title = title, x = "Longitude", y = "Latitude") +
    ggplot2::theme_minimal()
}
