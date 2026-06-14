# pollinatorSDM

> **Distribution des Pollinisateurs & Déficit en Services de Pollinisation**

<!-- badges: start -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

`pollinatorSDM` est un package R complet pour modéliser la distribution de pollinisateurs importants, analyser les habitats favorables, estimer les services de pollinisation pour les cultures agricoles, et détecter les zones de déficit de pollinisation.

## 🐝 Espèces modèles

| Espèce | Groupe | Rôle pollinisateur |
|--------|--------|--------------------|
| *Apis mellifera* | Abeille domestique | Cultures fruitières, oléagineux |
| *Bombus terrestris* | Bourdon | Légumes, fruitiers |
| *Bombus lapidarius* | Bourdon des pierres | Prairie, cultures diverses |

## 🌻 Cultures cibles

Amandier · Pommier · Tournesol · Colza · Tomate · Fraisier · Cerisier

## 📦 Installation

```r
# Depuis GitHub
devtools::install_github("idrisslemnouni-crypto/pollinatorSDM")
```

## 🚀 Utilisation rapide

```r
library(pollinatorSDM)

# 1. Télécharger les occurrences GBIF
occ <- download_pollinator_data(
  species = c("Apis mellifera", "Bombus terrestris"),
  country = "FR", limit = 500
)

# 2. Nettoyer les données
clean  <- clean_occurrences(occ, thin_km = 10)
occ_sf <- clean$data

# 3. Couches environnementales
env <- download_environmental_layers(extent = c(-5, 10, 41, 52))

# 4. Dataset SDM
bg      <- generate_background_points(env, n = 1000)
dataset <- prepare_predictors(occ_sf, bg, env)

# 5. Entraîner Random Forest + MaxEnt
sdm_rf <- train_sdm_model(dataset, method = "rf",     ntree = 500)
sdm_mx <- train_sdm_model(dataset, method = "maxent")

# 6. Évaluer
metrics <- evaluate_models(sdm_rf)

# 7. Prédiction spatiale
suitability <- predict_pollinator_distribution(sdm_rf, env)

# 8. Indice de pollinisation
crops <- import_crop_data()
index <- calculate_pollination_index(suitability, crops)

# 9. Déficit de pollinisation
deficit <- calculate_pollination_deficit(index, crops)

# 10. Cartes
plot_pollinator_map(suitability, occ_sf)
plot_pollination_deficit(deficit)

# 11. Analyse paysagère
lc_metrics <- analyze_landscape(env[["landcover"]])

# 12. Synthèse + recommandations
risk_table <- summarize_risk_by_region(deficit)
recs       <- generate_recommendations(deficit, lc_metrics)

# 13. Rapport HTML
generate_report(list(metrics=metrics, suitability=suitability,
  deficit=deficit, risk_table=risk_table, recommendations=recs))
```

## 📋 Fonctions du package

### Données
| Fonction | Description |
|----------|-------------|
| `download_pollinator_data()` | Téléchargement occurrences GBIF multi-espèces |
| `clean_occurrences()` | Nettoyage spatial → objet `sf` + rapport |
| `import_crop_data()` | Import cultures avec dépendance pollinisation |
| `download_environmental_layers()` | Couches WorldClim + occupation du sol |

### Modélisation SDM
| Fonction | Description |
|----------|-------------|
| `generate_background_points()` | Génération pseudo-absences |
| `prepare_predictors()` | Extraction valeurs + suppression corrélations |
| `train_sdm_model()` | Random Forest **et** MaxEnt |
| `evaluate_models()` | AUC, Accuracy, TSS, courbes ROC |
| `predict_pollinator_distribution()` | Carte de suitabilité raster |

### Analyse
| Fonction | Description |
|----------|-------------|
| `calculate_pollination_index()` | Indice composite pondéré (0-1) |
| `calculate_pollination_deficit()` | Déficit 3 niveaux (faible/modéré/élevé) |
| `analyze_landscape()` | Métriques paysagères (fragmentation, patches) |
| `summarize_risk_by_region()` | Ranking zones vulnérables |

### Visualisation & Rapports
| Fonction | Description |
|----------|-------------|
| `plot_pollinator_map()` | Carte ggplot2 de suitabilité |
| `plot_pollination_deficit()` | Carte déficit (vert/orange/rouge) |
| `generate_recommendations()` | Recommandations agroécologiques auto |
| `generate_report()` | Rapport HTML/PDF complet |

## 📊 Données intégrées

```r
data(crop_dependencies)
head(crop_dependencies)
#>        crop  crop_type poll_dependency  area_ha region
#> 1  Amandier   fruitier            1.00    12000 France
#> 2   Pommier   fruitier            0.65    45000 France
#> 3 Tournesol oleagineux            0.25   650000 France
```

## 🔬 Méthodologie

**Indice de pollinisation :**

$$I_{poll} = w_1 \cdot \bar{S}_{pollinisateurs} + w_2 \cdot \bar{D}_{cultures} + w_3 \cdot P_{habitats}$$

Avec $w = (0.5, 0.3, 0.2)$ par défaut.

**Déficit :** $D = D_{demande} - S_{offre}$, classifié en 3 niveaux (seuils 0.33 et 0.66).

## 📚 Références

- Klein, A.M. et al. (2007). *Proceedings of the Royal Society B*, 274, 303-313.
- Phillips, S.J. et al. (2006). *Ecological Modelling*, 190, 231-259.
- Breiman, L. (2001). *Machine Learning*, 45(1), 5-32.

## 👤 Auteur

**Lemnouni Idriss** — Package développé dans le cadre du cours de programmation R, Juin 2026

## 📄 Licence

MIT © 2026 Lemnouni Idriss
