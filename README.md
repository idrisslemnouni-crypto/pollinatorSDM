
# pollinatorSDM

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

## Description

`pollinatorSDM` est un package R complet pour la modélisation de la
distribution des pollinisateurs et l’évaluation des services de
pollinisation. Il combine données d’occurrence, modèles de distribution
d’espèces (SDM), analyse paysagère et cartographie du déficit de
pollinisation pour l’agroécologie.

## Installation

``` r
# Installer depuis GitHub
devtools::install_github("idrisslemnouni-crypto/pollinatorSDM")
```

## Utilisation

``` r
library(pollinatorSDM)

# Télécharger des occurrences
occ <- download_pollinator_data(limit = 50)

# Nettoyer
occ_clean <- clean_occurrences(occ)$cleaned

# Variables environnementales
env <- download_environmental_layers()

# Prédicteurs
preds <- prepare_predictors(occ_clean, env)

# Points de fond
bg <- generate_background_points(env, n = 1000)
bg$presence <- 0

# Modèle SDM
model_obj <- train_sdm_model(preds, bg)
model <- model_obj$model

# Prédiction
pred <- predict_pollinator_distribution(model, env)

# Carte
plot_pollinator_map(pred)
```

<figure>
<img src="README-example.png"
alt="Carte de suitabilité des pollinisateurs" />
<figcaption aria-hidden="true">Carte de suitabilité des
pollinisateurs</figcaption>
</figure>

## Cultures dépendantes de la pollinisation

``` r
# Données agricoles
crops <- import_crop_data()
crops

# Indice de pollinisation
pollination_index <- calculate_pollination_index(pred, env)
```

## Fonctions principales

- **Acquisition** : `download_pollinator_data()`,
  `download_environmental_layers()`, `import_crop_data()`
- **Nettoyage** : `clean_occurrences()`, `prepare_predictors()`,
  `generate_background_points()`
- **Modélisation** : `train_sdm_model()`, `evaluate_models()`,
  `predict_pollinator_distribution()`
- **Analyse** : `calculate_pollination_index()`,
  `calculate_pollination_deficit()`, `analyze_landscape()`,
  `summarize_risk_by_region()`
- **Visualisation** : `plot_pollinator_map()`,
  `plot_pollination_deficit()`
- **Rapport** : `generate_recommendations()`, `generate_report()`

## Auteur

Idriss Lemnouni — Étudiant ingénieur, IAV Hassan II
