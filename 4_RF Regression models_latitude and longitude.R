# This script should follow the "3_Classification_BLD ID and floor" file. 
# install.packages("ROCR")
# install.packages("grDevices")
# Building regression models to predict latitude and longitude, and validate these models.
# loading datasets of each building
pacman::p_load(
  randomForest,
  caret,
  doParallel,
  grDevices,
  gridExtra,
  openxlsx,
  ranger,
  ROCR,
  RColorBrewer
)

detectCores() # result as 4
# Create Cluster with desired number of cores.
cluster <-
  makeCluster(detectCores() - 1) # convention to leave 1 core for OS
# Register Cluster
registerDoParallel(cluster)
# Confirm how many cores are now "assigned" to R and RStudio
getDoParWorkers()

# 6. Building and validating models in predicting longitude----

# 6.0 relevel (specifiy) floors of each building, remove Latitude/longitude
# train datasets
# BLD 0
Building0$FLOOR <-
  factor(Building0$FLOOR, levels = c("0", "1", "2", "3"))
Building0_nolat <- select (Building0,-LATITUDE)
Building0_nolat <- saveRDS(Building0_nolat, "Building0_nolat.rds")

Building0_nolon <- select (Building0,-LONGITUDE)
Building0_nolon <- saveRDS(Building0_nolon, "Building0_nolon.rds")

# BLD 1
Building1$FLOOR <-
  factor(Building1$FLOOR, levels = c("0", "1", "2", "3"))
Building1_nolat <- select (Building1,-LATITUDE)
Building1_nolat <- saveRDS(Building1_nolat, "Building1_nolat.rds")

Building1_nolon <- select (Building1,-LONGITUDE)
Building1_nolon <- saveRDS(Building1_nolon, "Building1_nolon.rds")

# BLD 2
Building2$FLOOR <-
  factor(Building2$FLOOR, levels = c("0", "1", "2", "3", "4"))
Building2_nolat <- select (Building2,-LATITUDE)
Building2_nolat <- saveRDS(Building2_nolat, "Building2_nolat.rds")

Building2_nolon <- select (Building2,-LONGITUDE)
Building2_nolon <- saveRDS(Building2_nolon, "Building2_nolon.rds")

# validation datasets
# BLD 0
Building0valid$FLOOR <-
  factor(Building0valid$FLOOR, levels = c("0", "1", "2", "3"))
Building0valid_nolat <- select (Building0valid,-LATITUDE)
Building0valid_nolat <-
  saveRDS(Building0valid_nolat, "Building0valid_nolat.rds")

Building0valid_nolon <- select (Building0valid,-LONGITUDE)
Building0valid_nolon <-
  saveRDS(Building0valid_nolon, "Building0valid_nolon.rds")


# BLD 1
Building1valid$FLOOR <-
  factor(Building1valid$FLOOR, levels = c("0", "1", "2", "3"))
Building1valid_nolat <- select (Building1valid,-LATITUDE)
Building1valid_nolat <-
  saveRDS(Building1valid_nolat, "Building1valid_nolat.rds")

Building1valid_nolon <- select (Building1valid,-LONGITUDE)
Building1valid_nolon <-
  saveRDS(Building1valid_nolon, "Building1valid_nolon.rds")

# BLD 2
Building2valid$FLOOR <-
  factor(Building2valid$FLOOR, levels = c("0", "1", "2", "3", "4"))
Building2valid_nolat <- select (Building2valid,-LATITUDE)
Building2valid_nolat <-
  saveRDS(Building2valid_nolat, "Building2valid_nolat.rds")

Building2valid_nolon <- select (Building2valid,-LONGITUDE)
Building2valid_nolon <-
  saveRDS(Building2valid_nolon, "Building2valid_nolon.rds")


# 6.1. Using Random Forest for Longitude prediction - Building 0 ----
# 08.04 taking variables of LATITUDE and LONGITUDE out when predicting the other
# Longitude in subset of Building 0

# Random Forest -Building 0, trying to find the best mtry by tuning ntreeTry = 100 and 501, resulting the mytry as 210 (obtained smallest OOB error = 0.03943354 0.6482876 0.05) when ntree = 501

# Builiding 0
bestmtry_LON_BO_RF2 <-
  tuneRF(
    Building0,
    Building0$LONGITUDE,
    ntreeTry = 100,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

bestmtry_LON_B0_RF3 <-
  tuneRF(
    Building0,
    Building0$LONGITUDE,
    ntreeTry = 501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

# eventually choosing mtry = 210, ntree = 501
LONPredict_BLD0_RF <-
  randomForest(
    LONGITUDE ~ .,
    data = Building0_nolat,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 210,
    allowParalel = TRUE
  ) # changed data to exclude latitude on 08.04

LONPredict_BLD0_RF_nolat <- LONPredict_BLD0_RF



# Validating RF model: predicting Longitude - BLD0
predictions_LONB0RF_nolat <-
  predict(LONPredict_BLD0_RF_nolat, Building0valid_nolat)

postRes_LONB0RF_nolat <-
  postResample(predictions_LONB0RF_nolat, Building0valid_nolat$LONGITUDE)

postRes_LONB0RF_nolat
# RMSE   Rsquared        MAE
# 7.1021124 0.9282857 4.6139655

# Importance of variables
varImpPlot(LONPredict_BLD0_RF_nolat)


# visualising longitude prediction - BLD0

axisRange0 <-
  extendrange(c(predictions_LONB0RF_nolat, Building0valid_nolat$LONGITUDE))
plot(
  predictions_LONB0RF_nolat,
  Building0valid_nolat$LONGITUDE,
  col = "#FF7F00",
  main = "RF nolat predicted vs. actual Longitude in Building 0",
  ylim = axisRange0,
  xlim = axisRange0,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.axis = 0.6,
  cex.lab = 0.6
)
## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)

# 6.2 Using Random Forest for Longitude prediction - Building 1----
# Building 1 -  Using Random Forest for Longitude prediction - Building 1
# Longitude in subset of Building 1

# mtry = 210 producing the best result OOB error = 0.2202315 0.3264096 0.05
bestmtry_LON_B1_RF <-
  tuneRF(
    Building1,
    Building1$LONGITUDE,
    ntreeTry = 501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

# eventually choosing mtry = 210, ntree = 501
LONPredict_BLD1_RF_nolat <-
  randomForest(
    LONGITUDE ~ .,
    Building1_nolat,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 210,
    allowParalel = TRUE
  )

LONPredict_BLD1_RF_nolat <-
  saveRDS(LONPredict_BLD1_RF_nolat, "LONPredict_BLD1_RF_nolat.rds")

# Validating RF model: predicting Longitude - BLD1
predictions_LONB1RF_nolat <-
  predict(LONPredict_BLD1_RF_nolat, Building1valid_nolat)

postRes_LONB1RF_nolat <-
  postResample(predictions_LONB1RF_nolat, Building1valid_nolat$LONGITUDE)

postRes_LONB1RF_nolat
# RMSE   Rsquared        MAE
# 10.7463464  0.9479903  7.3630844

varImpPlot(LONPredict_BLD1_RF_nolat)

# visualising longitude prediction - BLD1, no lat

axisRange1 <-
  extendrange(c(predictions_LONB1RF_nolat, Building1valid_nolat$LONGITUDE))
plot(
  predictions_LONB1RF_nolat,
  Building1valid_nolat$LONGITUDE,
  col = "#6A3D9A",
  main = "RF nolat Predicted vs. Actual - Longitude in Building 1",
  ylim = axisRange1,
  xlim = axisRange1,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.axis = 0.6,
  cex.lab = 0.6
)
## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)


# 6.3 Using Random Forest for Longitude prediction - Building 2----
# Building 2 - same approach - RF, trying to find out the best mtry, nolat
bestmtry_LON_B2_RF <-
  tuneRF(
    BUILDING2,
    Building2$LONGITUDE,
    ntreeTry = 501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )
#same result of mtry = 210
LONPredict_BLD2_RF_nolat <-
  randomForest(
    LONGITUDE ~ .,
    Building2_nolat,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 210,
    allowParalel = TRUE
  )

LONPredict_BLD2_RF_nolat <-
  saveRDS(LONPredict_BLD2_RF_nolat, "LONPredict_BLD2_RF_nolat.rds")

# Validating RF model: predicting Longitude - BLD2
predictions_LONB2RF_nolat <-
  predict(LONPredict_BLD2_RF_nolat, Building2valid_nolat)

postRes_LONB2RF_nolat <-
  postResample(predictions_LONB2RF_nolat, Building2valid_nolat$LONGITUDE)

postRes_LONB2RF_nolat
# RMSE        Rsquared        MAE
# 11.3796597  0.8709871  7.1960577

varImpPlot(LONPredict_BLD2_RF_nolat)

# visualising longitude prediction - BLD2, nolat

axisRange2 <-
  extendrange(c(predictions_LONB2RF_nolat, Building2valid_nolat$LONGITUDE))

plot(
  predictions_LONB2RF_nolat,
  Building2valid_nolat$LONGITUDE,
  col = "#E31A1C",
  main = "RF nolat Predicted vs. Actual - Longitude in Building 2",
  ylim = axisRange2,
  xlim = axisRange2,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.axis = 0.6,
  cex.lab = 0.6
)
## Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)



# 7. Building and validating models in predicting latitude----

# 7.1. Using Random Forest for Langitude prediction - Building 0----
# Latitude in subset of Building 0

# 08.04 remove the variable of ongitude, nolon

# Random Forest -Building 0, trying to find the best mtry by tuning ntreeTry = 100 and 501, resulting the mytry as 164 (obtained smallest OOB error = 0.2150174 0.2372326 0.05 ) when ntree = 501

# Builiding 0
bestmtry_LAT_B0_RF <-
  tuneRF(
    Building0,
    Building0$LATITUDE,
    ntreeTry = 100,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

bestmtry_LAT_B0_RF2 <-
  tuneRF(
    Building0,
    Building0$LATITUDE,
    ntreeTry = 501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

bestmtry_LAT_B0_RF2 <-
  tuneRF(
    Building0,
    Building0$LATITUDE,
    ntreeTry = 1501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )
# (mtry = 82  OOB error = 0.1072795
# Searching left ...
# mtry = 41 	OOB error = 0.399726 -2.726025 0.05
# Searching right ...
# mtry = 164 	OOB error = 0.05178977 0.5172443 0.05

# eventually choosing mtry = 164, ntree = 501
LATPredict_BLD0_RF_nolon <-
  randomForest(
    LATITUDE ~ .,
    data = Building0_nolon,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 164,
    allowParalel = TRUE
  )

LATPredict_BLD0_RF_nolon <-
  saveRDS(LATPredict_BLD0_RF_nolon, "LATPredict_BLD0_RF_nolon.rds")

# Validating RF model: predicting Latitude - BLD0
predictions_LATB0RF_nolon <-
  predict(LATPredict_BLD0_RF_nolon, Building0valid_nolon)

postRes_LATB0RF_nolon <-
  postResample(predictions_LATB0RF_nolon, Building0valid_nolon$LATITUDE)

postRes_LATB0RF_nolon
#      RMSE  Rsquared       MAE
# 2.7879531 0.9928656 1.8295444

varImpPlot(LATPredict_BLD0_RF_nolon)

axisRange0 <-
  extendrange(c(predictions_LATB0RF_nolon, Building0valid_nolon$LATITUDE))
plot(
  predictions_LATB0RF_nolon,
  Building0valid_nolon$LATITUDE,
  col = "#FF7F00",
  main = "RF nolon Predicted vs. Actual - Latitude in Building 0",
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


# 7.1. Using Random Forest for Latitude prediction - Building 0----
# Latitude in subset of Building 0

# 08.04 remove the variable of ongitude, nolon

# Random Forest -Building 0, trying to find the best mtry by tuning ntreeTry = 100 and 501, resulting the mytry as 164 (obtained smallest OOB error = 0.2150174 0.2372326 0.05 ) when ntree = 501

# Builiding 0
bestmtry_LAT_B0_RF <-
  tuneRF(
    Building0,
    Building0$LATITUDE,
    ntreeTry = 100,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

bestmtry_LAT_B0_RF2 <-
  tuneRF(
    Building0,
    Building0$LATITUDE,
    ntreeTry = 501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )

bestmtry_LAT_B0_RF2 <-
  tuneRF(
    Building0,
    Building0$LATITUDE,
    ntreeTry = 1501,
    stepFactor = 2,
    improve = 0.05,
    trace = TRUE,
    plot = T
  )
# (mtry = 82  OOB error = 0.1072795
# Searching left ...
# mtry = 41 	OOB error = 0.399726 -2.726025 0.05
# Searching right ...
# mtry = 164 	OOB error = 0.05178977 0.5172443 0.05

# eventually choosing mtry = 164, ntree = 501
LATPredict_BLD0_RF_nolon <-
  randomForest(
    LATITUDE ~ .,
    data = Building0_nolon,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 164,
    allowParalel = TRUE
  )

LATPredict_BLD0_RF_nolon <-
  saveRDS(LATPredict_BLD0_RF_nolon, "LATPredict_BLD0_RF_nolon.rds")

# Validating RF model: predicting Latitude - BLD0
predictions_LATB0RF_nolon <-
  predict(LATPredict_BLD0_RF_nolon, Building0valid_nolon)

postRes_LATB0RF_nolon <-
  postResample(predictions_LATB0RF_nolon, Building0valid_nolon$LATITUDE)

postRes_LATB0RF_nolon
#      RMSE  Rsquared       MAE
# 2.7879531 0.9928656 1.8295444

varImpPlot(LATPredict_BLD0_RF_nolon)

axisRange0 <-
  extendrange(c(predictions_LATB0RF_nolon, Building0valid_nolon$LATITUDE))
plot(
  predictions_LATB0RF_nolon,
  Building0valid_nolon$LATITUDE,
  col = "#FF7F00",
  main = "RF nolon Predicted vs. Actual - Latitude in Building 0",
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


# 7.2 Using Random Forest for Latitude prediction - Building 1----
# LAT, RF, BLD1, nolon

LATPredict_BLD1_RF_nolon <-
  randomForest(
    LATITUDE ~ .,
    data = Building1_nolon,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 164,
    allowParalel = TRUE
  )

LATPredict_BLD1_RF_nolon <-
  saveRDS(LATPredict_BLD1_RF_nolon, "LATPredict_BLD1_RF_nolon.rds")

# Validating RF model: predicting Latitude - BLD1
predictions_LATB1RF_nolon <-
  predict(LATPredict_BLD1_RF_nolon, Building1valid_nolon)

postRes_LATB1RF_nolon <-
  postResample(predictions_LATB1RF_nolon, Building1valid_nolon$LATITUDE)

postRes_LATB1RF_nolon

# RMSE   Rsquared        MAE
# 4.3502805 0.9861122 3.0708664

varImpPlot(LATPredict_BLD1_RF_nolon)

axisRange1 <-
  extendrange(c(predictions_LATB1RF_nolon, Building1valid_nolon$LATITUDE))
plot(
  predictions_LATB1RF_nolon,
  Building1valid_nolon$LATITUDE,
  col = "#6A3D9A",
  main = "RF nolon Predicted vs. Actual - Latitude in Building 1",
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

# 7.3 Using Random Forest for Latitude prediction - Building 2----
# LAT, RF, BLD2, nolon

LATPredict_BLD2_RF_nolon <-
  randomForest(
    LATITUDE ~ .,
    data = Building2_nolon,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 164,
    allowParalel = TRUE
  )

Latitude_BLD2_RF <-
  saveRDS(LATPredict_BLD2_RF, "LATPredict_BLD2_RF.rds")

# Validating RF model: predicting Latitude - BLD2
predictions_LATB2RF_nolon <-
  predict(LATPredict_BLD2_RF_nolon, Building2valid_nolon)


postRes_LATB2RF_nolon <-
  postResample(predictions_LATB2RF_nolon, Building2valid_nolon$LATITUDE)

postRes_LATB2RF_nolon
# RMSE   Rsquared        MAE
#9.475073 0.893413 6.497230

varImpPlot(LATPredict_BLD2_RF_nolon)

# try plotting
# Ploting residues
axisRange2 <-
  extendrange(c(predictions_LATB2RF_nolon, Building2valid_nolon$LATITUDE))

plot(
  predictions_LATB2RF_nolon,
  Building2valid_nolon$LATITUDE,
  col = "#E31A1C",
  main = "RF nolon Predicted vs. Actual - Latitude in Building 2",
  ylim = axisRange2,
  xlim = axisRange2,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.axis = 0.6,
  cex.lab = 0.6
)
# Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)

# LAT, RF, BLD1, nolon

LATPredict_BLD1_RF_nolon <-
  randomForest(
    LATITUDE ~ .,
    data = Building1_nolon,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 164,
    allowParalel = TRUE
  )

LATPredict_BLD1_RF_nolon <-
  saveRDS(LATPredict_BLD1_RF_nolon, "LATPredict_BLD1_RF_nolon.rds")

# Validating RF model: predicting Latitude - BLD1
predictions_LATB1RF_nolon <-
  predict(LATPredict_BLD1_RF_nolon, Building1valid_nolon)

postRes_LATB1RF_nolon <-
  postResample(predictions_LATB1RF_nolon, Building1valid_nolon$LATITUDE)

postRes_LATB1RF_nolon

# RMSE   Rsquared        MAE
# 4.3502805 0.9861122 3.0708664

varImpPlot(LATPredict_BLD1_RF_nolon)

axisRange1 <-
  extendrange(c(predictions_LATB1RF_nolon, Building1valid_nolon$LATITUDE))
plot(
  predictions_LATB1RF_nolon,
  Building1valid_nolon$LATITUDE,
  col = "#6A3D9A",
  main = "RF nolon Predicted vs. Actual - Latitude in Building 1",
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


# LAT, RF, BLD2, nolon

LATPredict_BLD2_RF_nolon <-
  randomForest(
    LATITUDE ~ .,
    data = Building2_nolon,
    importance = T,
    maximize = T,
    method = "rf",
    trControl = fitControl,
    ntree = 501,
    mtry = 164,
    allowParalel = TRUE
  )

Latitude_BLD2_RF <-
  saveRDS(LATPredict_BLD2_RF, "LATPredict_BLD2_RF.rds")

# Validating RF model: predicting Latitude - BLD2
predictions_LATB2RF_nolon <-
  predict(LATPredict_BLD2_RF_nolon, Building2valid_nolon)


postRes_LATB2RF_nolon <-
  postResample(predictions_LATB2RF_nolon, Building2valid_nolon$LATITUDE)

postRes_LATB2RF_nolon
# RMSE   Rsquared        MAE
#9.475073 0.893413 6.497230

varImpPlot(LATPredict_BLD2_RF_nolon)

# try plotting
# Ploting residues
axisRange2 <-
  extendrange(c(predictions_LATB2RF_nolon, Building2valid_nolon$LATITUDE))

plot(
  predictions_LATB2RF_nolon,
  Building2valid_nolon$LATITUDE,
  col = "#E31A1C",
  main = "RF nolon Predicted vs. Actual - Latitude in Building 2",
  ylim = axisRange2,
  xlim = axisRange2,
  ylab = 'Predicted',
  xlab = 'Observed',
  las = 1,
  cex.axis = 0.6,
  cex.lab = 0.6
)
# Adding reference line
abline(0, 1, col = "darkgrey", lty = 2)
