# This script should be run after the script of "4_Regression models_latitude and longitude".

# 7. Predicting longitude and latitude WITH CROSS VALIDATOIN - KNN ----
# Using KNN to train regression models to predict longitude and latitude, and validate these models, AND ADD CROSS VALIDATIONS.
# using data either no latitude or no longitude when predicting the other

# 7.0 Getting ready ----
# Load necessary libraries
pacman::p_load(caret, doParallel)

#  using 10-fold cross validation
fitControl <-
  trainControl(
    method = "repeatedcv",
    number = 10,
    repeats = 3,
    allowParallel = TRUE
  ) # three separate 10-fold cross-validations are used as the resampling scheme

#-Grid of k values to search
knn_grid <- expand.grid(k = c(1:5))


# 7.1 KNN - Longitude, BLD0, no lat ----

# Train kNN model to predict Longitude, BLD0, nolat

knn_fit_BLD0_nolat <- train(
  LONGITUDE ~ .,
  data = Building0_nolat,
  method = 'knn',
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid,
  trControl = fitControl
)

knn_fit_BLD0_nolat <-
  saveRDS(knn_fit_BLD0_nolat, "knn_fit_BLD0_nolat.rds")

# Validating knn model: predicting Longitude - BLD0
predictions_LON0KNN_nolat <-
  predict(knn_fit_BLD0_nolat, Building0valid_nolat)

postRes_LONB0KNN_nolat <-
  postResample(predictions_LON0KNN_nolat, Building0valid_nolat$LONGITUDE)

postRes_LONB0KNN_nolat

# RMSE   Rsquared        MAE
# 9.467573 0.871257 5.775361


# PLOT longitude prediction BLD0
axisRange0 <-
  extendrange(c(predictions_LON0KNN_nolat, Building0valid_nolat$LONTITUDE))

plot(
  predictions_LON0KNN_nolat,
  Building0valid_nolat$LONGITUDE,
  col = "#FF7F00",
  main = "KNN nolat Predicted vs. Actual - Longitude in Building 0",
  ylim = axisRange0,
  xlim = axisRange0,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.lab = 0.6,
  cex.axis = 0.6
)

## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)
# ----------------------

# 7.2 KNN - Longitude, BLD1, nolat


# Train kNN model to predict Longitude, BLD1, nolat
# RMSE   Rsquared        MAE
#
knn_fitLONBLD1_nolat <- train(
  LONGITUDE ~ .,
  data = Building1_nolat,
  method = 'knn',
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid,
  trControl = fitControl
)


knn_fitLONBLD1_nolat <-
  saveRDS(knn_fitLONBLD1_nolat, "knn_fitLONBLD1_nolat.rds")

# Validating knn model: predicting Longitude - BLD1
predictions_LON1KNN_nolat <-
  predict(knn_fitLONBLD1_nolat, Building1valid_nolat)

postRes_LONB1KNN_nolat <-
  postResample(predictions_LON1KNN_nolat, Building1valid_nolat$LONGITUDE)

postRes_LONB1KNN_nolat
# RMSE   Rsquared        MAE
# 12.2778283  0.9335014  7.4424852

# PLOT longitude prediction BLD1
axisRange1 <-
  extendrange(c(predictions_LON1KNN_nolat, Building1valid_nolat$LONTITUDE))

plot(
  predictions_LON1KNN_nolat,
  Building1valid_nolat$LONGITUDE,
  col = "#6A3D9A",
  main = "KNN nolat Predicted vs. Actual - Longitude in Building 1",
  ylim = axisRange1,
  xlim = axisRange1,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.lab = 0.6,
  cex.axis = 0.6
)

## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)



# 7.3 Longitude, knn, BLD 2, nolat----


# Train kNN model to predict Longitude, BLD0, nolat

knn_fitLONBLD2_nolat <- train(
  LONGITUDE ~ .,
  data = Building2_nolat,
  method = 'knn',
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid,
  trControl = fitControl
)

knn_fitLONBLD2_nolat <-
  saveRDS(knn_fitLONBLD2_nolat, "knn_fitLONBLD2_nolat.rds")

# Validating knn model: predicting Longitude - BLD2, nolat
predictions_LON2KNN_nolat <-
  predict(knn_fitLONBLD2_nolat, Building2valid_nolat)

postRes_LONB2KNN_nolat <-
  postResample(predictions_LON2KNN_nolat, Building2valid_nolat$LONGITUDE)

postRes_LONB2KNN_nolat

#      RMSE   Rsquared        MAE
# 14.3005508  0.7976781  8.3648688

# PLOT longitude prediction BLD2, nolat
axisRange2 <-
  extendrange(c(predictions_LON2KNN_nolat, Building2valid_nolat$LONGITUDE))

plot(
  predictions_LON2KNN_nolat,
  Building2valid_nolat$LONGITUDE,
  col = "#E31A1C",
  main = "KNN nolat Predicted vs. Actual - Longitude in Building 2",
  ylim = axisRange2,
  xlim = axisRange2,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.lab = 0.6,
  cex.axis = 0.6
)

## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)


# 7.4 KNN - Latitude, BLD0, nolon----

# Train kNN model to predict Latitude, BLD0, nolon


knn_fitLATBLD0_nolon <- train(
  LATITUDE ~ .,
  data = Building0_nolon,
  method = 'knn',
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid,
  trControl = fitControl
)

knn_fitLATBLD0_nolon <-
  saveRDS(knn_fitLATBLD0_nolon, "knn_fitLATBLD0_nolon.rds")
# Validating knn model: predicting Latitude - BLD0
predictions_LAT0KNN_nolon <-
  predict(knn_fitLATBLD0_nolon, Building0valid_nolon)

postRes_LONB0KNN_nolon <-
  postResample(predictions_LAT0KNN_nolon, Building0valid_nolon$LATITUDE)

postRes_LONB0KNN_nolon

#     RMSE  Rsquared       MAE
# 5.7766551 0.9676765 3.8599257

# PLOT latitude prediction BLD0
axisRange0 <-
  extendrange(c(predictions_LAT0KNN_nolon, Building0valid_nolon$LATITUDE))

plot(
  predictions_LAT0KNN_nolon,
  Building0valid_nolon$LATITUDE,
  col = "#FF7F00",
  main = "KNN nolon Predicted vs. Actual - Latitude in Building 0",
  ylim = axisRange0,
  xlim = axisRange0,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.lab = 0.6,
  cex.axis = 0.6
)

## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)


# 7.5 KNN - Latitude, BLD1, nolon----


# Train kNN model to predict Longitude, BLD1, nolon


knn_fitLATBLD1_nolon <- train(
  LATITUDE ~ .,
  data = Building1_nolon,
  method = 'knn',
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid,
  trControl = fitControl
)


knn_fitLATBLD1_nolon <-
  saveRDS(knn_fitLATBLD1_nolon, "knn_fitLATBLD1__nolon.rds")

# Validating knn model: predicting Latitude - BLD1
predictions_LAT1KNN_nolon <-
  predict(knn_fitLATBLD1_nolon, Building1valid_nolon)

postRes_LATB1KNN_nolon <-
  postResample(predictions_LAT1KNN_nolon, Building1valid_nolon$LATITUDE)

postRes_LATB1KNN_nolon

#     RMSE  Rsquared       MAE
# 8.3810700 0.9435328 5.7132799

# PLOT longitude prediction BLD1
axisRange1 <-
  extendrange(c(predictions_LAT1KNN_nolon, Building1valid_nolon$LATITUDE))

plot(
  predictions_LAT1KNN_nolon,
  Building1valid_nolon$LATITUDE,
  col = "#6A3D9A",
  main = "KNN nolon Predicted vs. Actual - Latitude in Building 1",
  ylim = axisRange1,
  xlim = axisRange1,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.lab = 0.6,
  cex.axis = 0.6
)

## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)


# 7.5 Latitude, knn, BLD 2, nolon ----


# Train kNN model to predict Latitude, BLD2, nolon

knn_fitLATBLD2_nolon <- train(
  LATITUDE ~ .,
  data = Building2_nolon,
  method = 'knn',
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid,
  trControl = fitControl
)

knn_fitLATBLD2_nolon <-
  saveRDS(knn_fitLATBLD2_nolon, "knn_fitLATBLD2_nolon.rds")
# Validating knn model: predicting Latitude - BLD2
predictions_LAT2KNN_nolon <-
  predict(knn_fitLATBLD2_nolon, Building2valid_nolon)

postRes_LATB2KNN_nolon <-
  postResample(predictions_LAT2KNN_nolon, Building2valid_nolon$LATITUDE)

postRes_LATB2KNN_nolon
# RMSE   Rsquared        MAE
# 12.2914682  0.8292684  7.6542600

# PLOT longitude prediction BLD2
axisRange2 <-
  extendrange(c(predictions_LAT2KNN_nolon, Building2valid_nolon$LATITUDE))

plot(
  predictions_LAT2KNN_nolon,
  Building2valid_nolon$LATITUDE,
  col = "#E31A1C",
  main = "KNN  nolon Predicted vs. Actual - Latitude in Building 2",
  ylim = axisRange2,
  xlim = axisRange2,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.lab = 0.6,
  cex.axis = 0.6
)

## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)
