<!-- badges: start -->
[![R-CMD-check](https://github.com/idrisslemnouni-crypto/pollinatorSDM/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/idrisslemnouni-crypto/pollinatorSDM/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R version](https://img.shields.io/badge/R-%3E%3D%204.1-blue.svg)](https://cran.r-project.org)
<!-- badges: end -->

# pollinatorSDM

> **Modèles de Distribution d'Espèces pour les Pollinisateurs et Évaluation du Déficit de Pollinisation**

`pollinatorSDM` est un package R qui propose un workflow complet et reproductible
pour modéliser la suitabilité d'habitat des pollinisateurs et détecter les zones
de déficit de pollinisation dans les paysages agricoles.

Il intègre l'acquisition des données d'occurrence, le traitement de rasters
environnementaux, l'entraînement de modèles SDM (Random Forest et GLM), la
prédiction spatiale et la génération automatique de rapports dans un pipeline
cohérent.

---

## Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Installation](#installation)
- [Structure du package](#structure-du-package)
- [Démarrage rapide](#démarrage-rapide)
- [Workflow complet](#workflow-complet)
- [Référence des fonctions](#référence-des-fonctions)
- [Données intégrées](#données-intégrées)
- [Dépendances](#dépendances)
- [Auteur](#auteur)

---

## Vue d'ensemble

Les pollinisateurs sont essentiels pour la reproduction de plus de 75 % des
plantes à fleurs et d'environ 35 % de la production alimentaire mondiale.
`pollinatorSDM` répond au besoin d'un outil intégré et open-source pour :

- **Télécharger** les occurrences de pollinisateurs depuis GBIF
- **Nettoyer** les données spatiales (doublons, coordonnées nulles, points hors zone)
- **Préparer** les prédicteurs raster (variables bioclimatiques WorldClim, NDVI)
- **Entraîner** des SDM avec Random Forest (`"rf"`) ou régression logistique (`"glm"`)
- **Prédire** la suitabilité d'habitat sur la zone d'étude
- **Quantifier** les services de pollinisation et le déficit (3 classes)
- **Visualiser** les résultats sous forme de cartes prêtes à la publication
- **Générer** des rapports HTML automatiques avec recommandations

---

## Installation

Installer la version de développement depuis GitHub :

```r
# Installer devtools si nécessaire
install.packages("devtools")

# Installer pollinatorSDM
devtools::install_github("idrisslemnouni-crypto/pollinatorSDM")
```

Puis charger le package :

```r
library(pollinatorSDM)
```

---

## Structure du package

```
pollinatorSDM/
├── R/                          # 22 fichiers de fonctions R
│   ├── download_pollinator_data.R
│   ├── clean_occurrences.R
│   ├── download_environmental_layers.R
│   ├── prepare_predictors.R
│   ├── generate_background_points.R
│   ├── train_sdm_model.R       # Random Forest + GLM
│   ├── evaluate_models.R
│   ├── predict_pollinator_distribution.R
│   ├── calculate_pollination_index.R
│   ├── calculate_pollination_deficit.R  # 3 classes : faible/modéré/élevé
│   ├── analyze_landscape.R
│   ├── summarize_risk_by_region.R
│   ├── plot_pollinator_map.R
│   ├── plot_pollination_deficit.R
│   ├── generate_recommendations.R
│   ├── generate_report.R
│   ├── import_crop_data.R
│   ├── import_crop_map.R
│   ├── download_crop_map_real.R
│   ├── crop_dependencies.R
│   ├── data.R
│   └── utils.R
├── man/                        # Documentation Roxygen2 (fichiers .Rd)
├── data/                       # Jeux de données intégrés
│   ├── pollinator_occurrences.rda
│   └── crop_dependencies.rda
├── data-raw/                   # Scripts de génération des données
├── tests/testthat/             # Tests unitaires (testthat 3.0)
│   └── test-basic.R            # 18 tests
├── vignettes/
│   └── pollinatorSDM.Rmd       # Vignette reproductible complète
├── inst/rmarkdown/templates/   # Modèle de rapport
├── DESCRIPTION
├── NAMESPACE
└── .github/workflows/
    └── R-CMD-check.yaml        # CI/CD GitHub Actions
```

---

## Démarrage rapide

Exemple minimal reproductible avec données synthétiques (aucune connexion
Internet requise) :

```r
library(pollinatorSDM)
library(terra)
library(sf)

# 1. Charger les données intégrées
data(pollinator_occurrences)

# 2. Créer un raster environnemental synthétique
set.seed(42)
env <- terra::rast(nrows = 30, ncols = 30,
                   xmin = -9, xmax = -4,
                   ymin = 31, ymax = 36, crs = "EPSG:4326")
terra::values(env) <- cbind(
  bio1  = rnorm(900, 18, 4),
  bio12 = rnorm(900, 350, 80),
  ndvi  = runif(900, 0.1, 0.8)
)
names(env) <- c("bio1", "bio12", "ndvi")

# 3. Nettoyer les occurrences
occ_clean <- clean_occurrences(pollinator_occurrences, env)
cat(nrow(occ_clean$data), "occurrences retenues\n")

# 4. Générer pseudo-absences et préparer les données
bg        <- generate_background_points(env,
               presence_sf = occ_clean$data, n_points = 100)
pred_data <- prepare_predictors(occ_clean$data, bg, env)

# 5. Entraîner et évaluer le modèle (Random Forest)
pred_data$occurrence <- as.factor(pred_data$occurrence)
model   <- train_sdm_model(pred_data, method = "rf", ntree = 100)
metrics <- evaluate_models(model, pred_data)
cat(sprintf("AUC = %.3f | Accuracy = %.3f\n", metrics$AUC, metrics$Accuracy))

# 6. Prédire et visualiser
pred_raster <- predict_pollinator_distribution(model, env)
plot_pollinator_map(pred_raster)
```

---

## Workflow complet

```r
library(pollinatorSDM)

# ── Acquisition des données ───────────────────────────────────────────────────
occ <- download_pollinator_data()
env <- download_environmental_layers()

# ── Préparation ───────────────────────────────────────────────────────────────
occ_clean  <- clean_occurrences(occ, env)
bg         <- generate_background_points(env,
                presence_sf = occ_clean$data, n_points = 1000)
pred_data  <- prepare_predictors(occ_clean$data, bg, env)

# ── Modélisation ──────────────────────────────────────────────────────────────
pred_data$occurrence <- as.factor(pred_data$occurrence)

# Random Forest
model_rf  <- train_sdm_model(pred_data, method = "rf",  ntree = 500)

# GLM (régression logistique)
pred_glm              <- pred_data
pred_glm$occurrence   <- as.numeric(as.character(pred_glm$occurrence))
model_glm <- train_sdm_model(pred_glm, method = "glm")

# Évaluation
eval_rf  <- evaluate_models(model_rf,  pred_data)
eval_glm <- evaluate_models(model_glm, pred_glm)
cat(sprintf("RF  AUC = %.3f | GLM AUC = %.3f\n",
            eval_rf$AUC, eval_glm$AUC))

# ── Prédiction spatiale ───────────────────────────────────────────────────────
pred_raster <- predict_pollinator_distribution(model_rf, env)

# ── Analyse de la pollinisation ───────────────────────────────────────────────
crop_map     <- download_crop_map_real(env)
poll_index   <- calculate_pollination_index(pred_raster, crop_map)
deficit      <- calculate_pollination_deficit(pred_raster, poll_index)
landscape    <- analyze_landscape(env)
risk_summary <- summarize_risk_by_region(
                  deficit[["pollination_deficit"]], crop_map)

# ── Visualisation ─────────────────────────────────────────────────────────────
plot_pollinator_map(pred_raster)
plot_pollination_deficit(deficit)

# ── Recommandations et rapport ────────────────────────────────────────────────
reco <- generate_recommendations(pred_raster, deficit, landscape)
generate_report(
  pollinator_data     = occ_clean$data,
  model               = model_rf,
  prediction_raster   = pred_raster,
  pollination_deficit = deficit[["pollination_deficit"]],
  recommendations     = reco,
  output_file         = "pollinator_report.html"
)
```

---

## Référence des fonctions

### Acquisition des données

| Fonction | Description |
|---|---|
| `download_pollinator_data()` | Télécharge les occurrences GBIF pour 3 espèces au Maroc |
| `download_environmental_layers()` | Télécharge les rasters WorldClim + ESA Land Cover |
| `download_crop_map_real()` | Crée une carte vectorielle des cultures depuis ESA WorldCover |
| `import_crop_data()` | Importe le tableau de dépendance à la pollinisation |
| `import_crop_map()` | Importe une carte vectorielle de cultures (GeoPackage, Shapefile) |

### Préparation des données

| Fonction | Description |
|---|---|
| `clean_occurrences()` | Supprime doublons, NA, points marins, outliers géographiques |
| `prepare_predictors()` | Extrait les valeurs raster, supprime variables corrélées (VIF) |
| `generate_background_points()` | Génère des pseudo-absences avec contrôle spatial |

### Modélisation et évaluation

| Fonction | Description |
|---|---|
| `train_sdm_model()` | Entraîne un SDM : `"rf"` (Random Forest) ou `"glm"` (logistique) |
| `evaluate_models()` | Calcule AUC, Accuracy, Sensibilité, Spécificité + courbe ROC |
| `predict_pollinator_distribution()` | Prédit la suitabilité sur un raster environnemental |

### Analyse de la pollinisation

| Fonction | Description |
|---|---|
| `calculate_pollination_index()` | Suitabilité × demande agricole → indice normalisé |
| `calculate_pollination_deficit()` | Demande − offre → déficit (continu + 3 classes) |
| `analyze_landscape()` | Métriques paysagères (patches, fragmentation, distance) |
| `summarize_risk_by_region()` | Synthèse du risque par région + score de vulnérabilité |

### Visualisation et rapports

| Fonction | Description |
|---|---|
| `plot_pollinator_map()` | Carte ggplot2 de la suitabilité (palette viridis) |
| `plot_pollination_deficit()` | Carte ggplot2 classifiée (vert/jaune/rouge) |
| `generate_recommendations()` | Recommandations textuelles basées sur le déficit et le paysage |
| `generate_report()` | Rapport HTML automatique via R Markdown |

---

## Données intégrées

### `pollinator_occurrences`

30 occurrences simulées pour trois espèces (*Apis mellifera*, *Bombus terrestris*,
*Bombus lapidarius*) au Maroc (WGS84).

```r
data(pollinator_occurrences)
head(pollinator_occurrences)
#>              species decimalLongitude decimalLatitude year
#> 1     Apis mellifera        -7.231456        33.12341 2019
#> 2  Bombus terrestris        -6.834521        34.45231 2020
#> 3 Bombus lapidarius         -5.912341        32.87654 2021
```

### `crop_dependencies`

Dépendance à la pollinisation pour 5 cultures (d'après Klein et al., 2007).

```r
data(crop_dependencies)
print(crop_dependencies)
#>       crop dependency                    notes
#> 1   tomato       0.45     Moderately dependent
#> 2   almond       0.90         Highly dependent
#> 3    maize       0.00          Not dependent
#> 4   orange       0.30      Slightly dependent
#> 5 sunflower       0.65  Substantially dependent
```

---

## Dépendances

| Package | Rôle |
|---|---|
| `terra` | Manipulation raster et prédiction spatiale |
| `sf` | Données spatiales vectorielles |
| `randomForest` | Entraînement SDM Random Forest |
| `ggplot2` | Cartes et visualisations |
| `dplyr` | Manipulation des données |
| `pROC` | Calcul AUC et courbes ROC |
| `rmarkdown` + `knitr` | Génération du rapport HTML |

Suggérés : `rgbif`, `geodata`

---

## Vignette

```r
vignette("pollinatorSDM")
```

---

## Citation

> Lemnouni I. (2026). *pollinatorSDM: Species Distribution Models for
> Pollinators and Pollination Deficit*. R package version 0.1.0.
> <https://github.com/idrisslemnouni-crypto/pollinatorSDM>

---

## Auteur

**Idriss Lemnouni**  
Étudiant ingénieur – Data Science Appliquée à l'Agriculture  
Institut Agronomique et Vétérinaire Hassan II, Rabat, Maroc

[![GitHub](https://img.shields.io/badge/GitHub-idrisslemnouni--crypto-181717?logo=github)](https://github.com/idrisslemnouni-crypto)

---

## Licence

MIT © 2026 Idriss Lemnouni. Voir [`LICENSE`](LICENSE) pour les détails.
