# Evaluation protocol and limitations

The October 2026 maintenance removes unverified hard-coded README scores and replaces broken example signatures. Evaluation now uses a caller-supplied fixed threshold (default 0.5); select_sdm_threshold chooses Youden only from an explicitly supplied independent validation frame. ROC direction is fixed to increasing occurrence probability.

The bundled demonstration uses seeded synthetic predictors/labels on 900 cells and three longitude blocks. It validates software execution and data-partition separation, without certifying generalisation on ecological observations. Unit tests check that changing test labels cannot change the threshold and cannot cause an automatic ROC direction flip.

For real data: fix source licence/CRS/units and acquisition dates; deduplicate and identify observations; define buffered spatial train/validation/test partitions; derive correlation/VIF choices on training only; freeze model/threshold selection before the final test. Presence/background outputs do not establish abundance or measured crop-service deficit. The background-distance approximation and missing-landcover zero fallback are known limitations.

Historical metrics and illustrative images are not retained as verified results. No source or metric is relabelled as field evidence. AI assisted this maintenance; the CI verifies package execution, not the author's personal proficiency.
