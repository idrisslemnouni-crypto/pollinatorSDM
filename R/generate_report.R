#' Generate HTML report
#' @param output_file Character
#' @return Path to report
#' @export
generate_report <- function(output_file = "pollinator_report.html") {
  rmarkdown::render(
    input = system.file("templates/report_template.Rmd", package = "pollinatorSDM"),
    output_file = output_file
  )
  output_file
}
