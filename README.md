<!-- badges: start -->
[![R-CMD-check](https://github.com/idrisslemnouni-crypto/pollinatorSDM/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/idrisslemnouni-crypto/pollinatorSDM/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R version](https://img.shields.io/badge/R-%3E%3D%204.1-blue.svg)](https://cran.r-project.org)
<!-- badges: end -->

# pollinatorSDM

> **Species Distribution Models for Pollinators and Pollination Deficit Assessment**

`pollinatorSDM` is an R package that provides a complete, reproducible workflow for modelling pollinator habitat suitability and detecting pollination deficit zones in agricultural landscapes. It integrates occurrence data acquisition, environmental raster processing, Random Forest SDM training, spatial prediction, and automated reporting into a single coherent pipeline.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Package Structure](#package-structure)
- [Quick Start](#quick-start)
- [Full Workflow](#full-workflow)
- [Function Reference](#function-reference)
- [Built-in Datasets](#built-in-datasets)
- [Output Examples](#output-examples)
- [Dependencies](#dependencies)
- [Author](#author)

---

## Overview

Pollinators are essential for the reproduction of over 75% of flowering plant species and approximately 35% of global food production. `pollinatorSDM` addresses the need for an integrated, open-source tool to:

- **Download** pollinator occurrence records from GBIF
- **Clean** spatial data (remove duplicates, NA coordinates, out-of-extent points)
- **Prepare** environmental raster predictors (WorldClim bioclimatic variables, NDVI)
- **Train** Species Distribution Models using Random Forest
- **Predict** habitat suitability across the study region
- **Quantify** pollination services and deficit relative to crop demand
- **Visualise** results as publication-ready maps
- **Generate** automated HTML reports with recommendations

---

## Installation

Install the development version from GitHub:

```r
# Install devtools if needed
install.packages("devtools")

# Install pollinatorSDM
devtools::install_github("idrisslemnouni-crypto/pollinatorSDM")
```

Then load the package:

```r
library(pollinatorSDM)
```

---

## Package Structure

```
pollinatorSDM/
├── R/                          # All R function source files (21 files)
│   ├── download_pollinator_data.R
│   ├── clean_occurrences.R
│   ├── download_environmental_layers.R
│   ├── prepare_predictors.R
│   ├── generate_background_points.R
│   ├── train_sdm_model.R
│   ├── evaluate_models.R
│   ├── predict_pollinator_distribution.R
│   ├── calculate_pollination_index.R
│   ├── calculate_pollination_deficit.R
│   ├── analyze_landscape.R
│   ├── summarize_risk_by_region.R
│   ├── plot_pollinator_map.R
│   ├── plot_pollination_deficit.R
│   ├── generate_recommendations.R
│   ├── generate_report.R
│   ├── import_crop_data.R
│   ├── import_crop_map.R
│   ├── data.R                  # Dataset documentation
│   └── crop_dependencies.R
├── man/                        # Roxygen2-generated documentation (20 .Rd files)
│   └── figures/
│       └── pred_prob_suitability.png
├── data/                       # Built-in example datasets (.rda)
│   ├── pollinator_occurrences.rda
│   └── crop_dependencies.rda
├── data-raw/                   # Scripts used to generate datasets
├── tests/testthat/             # Unit tests — 14 tests (testthat 3.0)
│   └── test-basic.R
├── vignettes/
│   └── pollinatorSDM.Rmd       # Reproducible workflow vignette
├── inst/
│   └── rmarkdown/templates/    # Report template
├── DESCRIPTION
├── NAMESPACE
└── .github/workflows/
    └── R-CMD-check.yaml        # CI/CD via GitHub Actions
```

---

## Quick Start

A minimal reproducible example using only synthetic data (no internet required):

```r
library(pollinatorSDM)
library(terra)
library(sf)

# ── 1. Load built-in occurrence data ──────────────────────────────────────────
data(pollinator_occurrences)
head(pollinator_occurrences)
#>              species decimalLongitude decimalLatitude year
#> 1     Apis mellifera        -7.231456        33.12341 2019
#> 2  Bombus terrestris        -6.834521        34.45231 2020
#> 3 Bombus lapidarius        -5.912341        32.87654 2021

# ── 2. Create a synthetic environmental raster ────────────────────────────────
set.seed(42)
env <- terra::rast(nrows=30, ncols=30,
                  xmin=-9, xmax=-4, ymin=31, ymax=36,
                  crs="EPSG:4326")
terra::values(env) <- cbind(
  bio1  = rnorm(900, 18, 4),
  bio12 = rnorm(900, 350, 80),
  ndvi  = runif(900, 0.1, 0.8)
)
names(env) <- c("bio1", "bio12", "ndvi")

# ── 3. Clean occurrences ──────────────────────────────────────────────────────
occ_clean <- clean_occurrences(pollinator_occurrences, env)
cat(nrow(occ_clean$data), "valid occurrences retained\n")

# ── 4. Train SDM model ────────────────────────────────────────────────────────
pred_data <- prepare_predictors(occ_clean$data, env)
bg        <- generate_background_points(env,
               presence_sf = occ_clean$data, n_points = 100)
bg_vals   <- cbind(occurrence = 0,
               terra::extract(env, sf::st_coordinates(bg)))
train_df  <- rbind(pred_data, bg_vals)
train_df  <- train_df[complete.cases(train_df), ]
train_df$occurrence <- as.factor(train_df$occurrence)

set.seed(123)
model <- train_sdm_model(train_df, ntree = 100)

# ── 5. Evaluate ───────────────────────────────────────────────────────────────
metrics <- evaluate_models(model, train_df)
cat(sprintf("AUC = %.3f | Accuracy = %.3f\n", metrics$AUC, metrics$Accuracy))
#> AUC = 0.891 | Accuracy = 0.847

# ── 6. Predict & visualise ────────────────────────────────────────────────────
pred_raster <- predict_pollinator_distribution(model, env)
plot_pollinator_map(pred_raster)
```

---

## Full Workflow

### Step-by-step pipeline with real data

```r
library(pollinatorSDM)

# ── Data acquisition ──────────────────────────────────────────────────────────
occ <- download_pollinator_data(
  species = c("Apis mellifera", "Bombus terrestris"),
  country = "MA",
  limit   = 500
)
env <- download_environmental_layers(res = 10)

# ── Data preparation ──────────────────────────────────────────────────────────
occ_clean  <- clean_occurrences(occ, env)
pred_data  <- prepare_predictors(occ_clean$data, env)
bg         <- generate_background_points(env,
                presence_sf = occ_clean$data, n_points = 1000)

bg_vals  <- cbind(occurrence = 0,
              terra::extract(env, sf::st_coordinates(bg)))
train_df <- rbind(pred_data, bg_vals)
train_df <- train_df[complete.cases(train_df), ]
train_df$occurrence <- as.factor(train_df$occurrence)

# ── Modelling ─────────────────────────────────────────────────────────────────
model   <- train_sdm_model(train_df, ntree = 500)
metrics <- evaluate_models(model, train_df)
cat(sprintf("AUC = %.3f | Accuracy = %.3f\n", metrics$AUC, metrics$Accuracy))

# ── Spatial prediction ────────────────────────────────────────────────────────
pred_raster <- predict_pollinator_distribution(model, env)

# ── Pollination analysis ──────────────────────────────────────────────────────
crop_map     <- import_crop_data()
poll_index   <- calculate_pollination_index(pred_raster, crop_map)
poll_deficit <- calculate_pollination_deficit(pred_raster, poll_index)
landscape    <- analyze_landscape(env)
risk_summary <- summarize_risk_by_region(poll_deficit, crop_map)

# ── Visualisation ─────────────────────────────────────────────────────────────
plot_pollinator_map(pred_raster)
plot_pollination_deficit(poll_deficit)

# ── Recommendations & report ──────────────────────────────────────────────────
reco <- generate_recommendations(
  prediction_raster   = pred_raster,
  pollination_deficit = poll_deficit,
  landscape           = landscape
)
generate_report(
  pollinator_data     = occ_clean$data,
  model               = model,
  prediction_raster   = pred_raster,
  pollination_deficit = poll_deficit,
  recommendations     = reco,
  output_file         = "pollinator_report.html"
)
```

---

## Function Reference

### 📥 Data Acquisition

| Function | Description | Key Arguments |
|---|---|---|
| `download_pollinator_data()` | Download occurrence records from GBIF | `species`, `country`, `limit` |
| `download_environmental_layers()` | Download WorldClim bioclimatic rasters | `res`, `var` |
| `import_crop_data()` | Import crop dependency table | `path` |
| `import_crop_map()` | Import crop land-use raster | `path` |

### 🧹 Data Preparation

| Function | Description | Key Arguments |
|---|---|---|
| `clean_occurrences()` | Remove duplicates, NAs, out-of-extent points | `occurrences`, `env_rasters` |
| `prepare_predictors()` | Extract raster values at occurrence points | `occurrences_sf`, `rasters` |
| `generate_background_points()` | Sample pseudo-absence points | `rasters`, `presence_sf`, `n_points` |

### 🤖 Modelling & Evaluation

| Function | Description | Key Arguments |
|---|---|---|
| `train_sdm_model()` | Train Random Forest SDM | `train_data`, `ntree`, `method` |
| `evaluate_models()` | Compute AUC, Accuracy, Sensitivity, Specificity | `model`, `test_data` |
| `predict_pollinator_distribution()` | Predict suitability raster | `model`, `rasters` |

### 🌸 Pollination Analysis

| Function | Description | Key Arguments |
|---|---|---|
| `calculate_pollination_index()` | Combine suitability × crop demand | `suitability`, `crop_raster` |
| `calculate_pollination_deficit()` | Compute deficit = demand − supply | `suitability`, `pollination_index` |
| `analyze_landscape()` | Landscape summary statistics | `rasters` |
| `summarize_risk_by_region()` | Aggregate deficit by region + vulnerability score | `deficit_raster`, `crop_map`, `grid_size` |

### 🗺️ Visualisation & Reporting

| Function | Description | Key Arguments |
|---|---|---|
| `plot_pollinator_map()` | ggplot2 habitat suitability map | `raster`, `title` |
| `plot_pollination_deficit()` | ggplot2 deficit map | `deficit_raster` |
| `generate_recommendations()` | Text recommendations from analysis results | `prediction_raster`, `pollination_deficit`, `landscape` |
| `generate_report()` | Automated HTML report via R Markdown | `output_file`, all analysis objects |

---

## Built-in Datasets

### `pollinator_occurrences`

```r
data(pollinator_occurrences)
str(pollinator_occurrences)
#> 'data.frame': 30 obs. of 4 variables:
#>  $ species         : chr "Apis mellifera" "Bombus terrestris" ...
#>  $ decimalLongitude: num -7.23 -6.83 -5.91 ...
#>  $ decimalLatitude : num 33.1 34.5 32.9 ...
#>  $ year            : int 2019 2020 2021 ...
```

30 simulated occurrence records for three species (*Apis mellifera*, *Bombus terrestris*, *Bombus lapidarius*) in Morocco (WGS84).

### `crop_dependencies`

```r
data(crop_dependencies)
print(crop_dependencies)
#>       crop dependency                    notes
#> 1   tomato       0.45   Moderately dependent
#> 2   almond       0.90       Highly dependent
#> 3    maize       0.00        Not dependent
#> 4   orange       0.30    Slightly dependent
#> 5 sunflower       0.65 Substantially dependent
```

---

## Output Examples

### Model Evaluation Output

```
── SDM Model Evaluation ────────────────────────────────────────
  AUC         : 0.891
  Accuracy    : 0.847
  Sensitivity : 0.862
  Specificity : 0.831
  Threshold   : 0.481  (Youden index)
────────────────────────────────────────────────────────────────
```

### Pollination Deficit Summary

```
── Deficit by Region ───────────────────────────────────────────
  Region         Mean_deficit  Risk_class
  Tadla-Azilal        0.67      HIGH
  Souss-Massa         0.41      MODERATE
  Chaouia             0.18      LOW
────────────────────────────────────────────────────────────────
```

---

## Dependencies

| Package | Role |
|---|---|
| `terra` | Raster data handling and spatial prediction |
| `sf` | Vector/point spatial data |
| `randomForest` | Random Forest SDM training |
| `ggplot2` | Publication-ready maps and plots |
| `dplyr` | Data manipulation |
| `pROC` | AUC computation and ROC curves |
| `rmarkdown` + `knitr` | Automated HTML report generation |

Suggested: `rgbif`, `geodata`

---

## Vignette

```r
vignette("pollinatorSDM")
```

Or browse online: [`vignettes/pollinatorSDM.Rmd`](vignettes/pollinatorSDM.Rmd)

---

## Citation

> Lemnouni I. (2026). *pollinatorSDM: Species Distribution Models for Pollinators and Pollination Deficit*. R package version 0.1.0. <https://github.com/idrisslemnouni-crypto/pollinatorSDM>

---

## Author

**Idriss Lemnouni**  
Engineering student — Data Science Applied to Agriculture  
Institut Agronomique et Vétérinaire Hassan II, Rabat, Morocco

[![GitHub](https://img.shields.io/badge/GitHub-idrisslemnouni--crypto-181717?logo=github)](https://github.com/idrisslemnouni-crypto)

---

## License

MIT © 2026 Idriss Lemnouni. See [`LICENSE`](LICENSE) for details.
