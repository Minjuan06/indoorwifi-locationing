# This file comes after "2_Processing and transforming data for modeling".

pacman::p_load(caret, doParallel, gdata, ggplot2, scales)

### 3.4 Set up parallel processing ----
# Find how many cores are on the machine
detectCores() # result as 4
# Create Cluster with desired number of cores. 
cluster <-
  makeCluster(detectCores() - 1) # convention to leave 1 core for OS
# Register Cluster
registerDoParallel(cluster)
# Confirm how many cores are now "assigned" to R and RStudio
getDoParWorkers()  # result as 3

#  using 10-fold cross validation
fitControl <-
  trainControl(
    method = "repeatedcv",
    number = 10,
    repeats = 3,
    allowParallel = TRUE
  ) # three separate 10-fold cross-validations are used as the resampling scheme

# proceeding to training and validating models 


# Classification - predicting BuildingID and floor, then validation with validation dataset

# 4. Predicting BUILDINGID - try with KNN, Random Forest and Decision Tree C5.0 ----

# 4.1 KNN - BUILDINGID ----

#-Grid of k values to search 
knn_grid <- expand.grid(k = c(1:5))

# Train kNN model to predict BuildingID
knn_fit <- train(
  BUILDINGID ~ .,
  data = DataTrain,
  method = 'knn',
  preProcess
  = c('zv'),
  tuneGrid = knn_grid,
  trControl = fitControl
)

#-Save model
knn_fit_BLD <- saveRDS(knn_fit, 'knn_fit_BLD.rds')

# 4.2 Random Forest- BUILDINGID ----

#-Train Random Forest model to predict BuildingID
rf_fit <- train(
  BUILDINGID ~ .,
  DataTrain,
  method = 'ranger',
  preProcess = c('zv'),
  trControl = fitControl
)

#-Save model
rf_fit_BLD <- saveRDS(rf_fit, 'rf_fit_BLD.rds')


# 4.3 Train decision tree (C5.0) model

#-Train decision tree model to predict BuildingID
dtree_fit <- train(
  BUILDINGID ~ .,
  DataTrain,
  method = 'C5.0',
  preProcess = c('zv'),
  trControl = fitControl
)

#-Save model
dtree_fit_BLD <- saveRDS(dtree_fit, 'dtree_fit_BLD.rds')

# 4.4 Summarize results of predictive models ----
results <- resamples(list(kNN = knn_fit,
                          RF = rf_fit,
                          C5.0 = dtree_fit))
summary(results)
bwplot(results)
# saving plot named as "Kappa and Accuracy_3 models_BLD"

# 4.5 Validating/testing models----
# 4.5.1 ----
# I made a decision for not including KNN: lazy algorithm and can take subtantial time to run it; however, for the curiosity, still running a test

predict_KNN_BLD <- predict(knn_fit, DataValid)
confusionMatrix_knn <-
  confusionMatrix(predict_KNN_BLD, DataValid$BUILDINGID)
confusionMatrix_knn


# Accuracy: 1, Kappa: 1


# 4.5.2 Testing Random Forest ----

predict_RF_BLD <- predict(rf_fit, DataValid)
confusionMatrix_rf <-
  confusionMatrix(predict_RF_BLD, DataValid$BUILDINGID)
confusionMatrix_rf
# Accuracy: 1, Kappa: 1


# 4.5.3 Testing Decision Tree C5.0 ----

predict_dtree_BLD <- predict(dtree_fit, DataValid)
confusionMatrix_dt <-
  confusionMatrix(predict_dtree_BLD, DataValid$BUILDINGID)
confusionMatrix_dt
# Accuracy: 0.9955, Kappa: 0.9929

## Three models all have very high Kappa and Accuracy values, while among all Random Forest has the highest and most stable outcomes (potentially using less computing time than KNN). 

# 5. Predict floors with split datasets by building IDs ----
Datatrain$FLOOR <-
  factor(Datatrain$FLOOR, levels = c("0", "1", "2", "3", "4"))

# 5.0 train RF model with all Train data, no splitting data ----
# Accuracy : 0.9136 Kappa : 0.8789
rf_fit_floor <- train(
  FLOOR ~ .,
  Datatrain,
  method = 'ranger',
  preProcess = c('zv'),
  trControl = fitControl
)

# validating RF model in predicting floors, Accuracy 0.9683, Kappa: 0.955
Datavalid$FLOOR <-
  factor(Datavalid$FLOOR, levels = c("0", "1", "2", "3", "4"))
predict_rf <- predict(rf_fit_floor, Datavalid)
confusionMatrix_rf <- confusionMatrix(predict_rf, Datavalid$FLOOR)
cmf <- confusionMatrix_rf

# creating a cm plot

ggplotConfusionMatrix <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "steelblue") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix(cmf)


# train KNN model with data of all buildings
knn_fitall_floor <- train(
  FLOOR ~ .,
  Datatrain,
  method = 'knn',
  trControl = fitControl,
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid
)

knn_fitall_floor <-
  saveRDS(knn_fitall_floor, "knn_fitall_floor.rds")

# Predicting floor in all buildings : Accuracy 0.8065, Kappa: 0.7316
predict_knn_all <- predict(knn_fitall_floor, Datavalid)
confusionMatrix_knn_all <-
  confusionMatrix(predict_knn_all, Datavalid$FLOOR)
confusionMatrix_knn_all

# viz floor prediction - BLD0
# "KNN CM all BLDs floor prediction"
ggplotConfusionMatrixall <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "steelblue") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrixall(confusionMatrix_knn_all)



# 6.0 Random Forest - splitting data by building ID----

# Split DataTrain per Building, using Randorm Forest
Buildings <- split(Datatrain, Datatrain$BUILDINGID)
names(Buildings) <- c("Building0", "Building1", "Building2")
list2env(Buildings, envir = .GlobalEnv)

# 6.1 relevel (specifiy) floors of BLD0----
Building0$FLOOR <-
  factor(Building0$FLOOR, levels = c("0", "1", "2", "3"))
Building0 <- saveRDS(Building0, "Building0.rds")

# train RF model by buildings
rf_fitBLD0_floor <- train(
  FLOOR ~ .,
  Building0,
  method = 'ranger',
  preProcess = c('zv'),
  trControl = fitControl
)

#------------
# train KNN model by buildings
knn_fitBLD0_floor <- train(
  FLOOR ~ .,
  Building0,
  method = 'knn',
  trControl = fitControl,
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid
)

knn_fitBLD0_floor <-
  saveRDS(knn_fitBLD0_floor, "knn_fitBLD0_floor.rds")

# Predicting floor in BLD 0 : Accuracy 0.819 , Kappa: 0.746
predict_knn_BLD0 <- predict(knn_fitBLD0_floor, Building0valid)
confusionMatrix_knn_BLD0 <-
  confusionMatrix(predict_knn_BLD0, Building0valid$FLOOR)
confusionMatrix_knn_BLD0

# viz floor prediction - BLD0
# "KNN CM BLD0 floor prediction"
ggplotConfusionMatrix0 <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#FF7F00") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix0(confusionMatrix_knn_BLD0)


# 6.2 relevel (specifiy) floors of BLD1 ----
Building1$FLOOR <-
  factor(Building1$FLOOR, levels = c("0", "1", "2", "3"))
Building1 <- saveRDS(Building1, "Building1.rds")

rf_fitBLD1_floor <- train(
  FLOOR ~ .,
  Building1,
  method = 'ranger',
  preProcess = c('zv'),
  trControl = fitControl
)

#------------
# train KNN model by buildings
knn_fitBLD1_floor <- train(
  FLOOR ~ .,
  Building1,
  method = 'knn',
  trControl = fitControl,
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid
)

knn_fitBLD1_floor <-
  saveRDS(knn_fitBLD1_floor, "knn_fitBLD1_floor.rds")

# Predicting floor in BLD 1 : Accuracy 0.7199 , Kappa: 0.6018
predict_knn_BLD1 <- predict(knn_fitBLD1_floor, Building1valid)
confusionMatrix_knn_BLD1 <-
  confusionMatrix(predict_knn_BLD1, Building1valid$FLOOR)
confusionMatrix_knn_BLD1

# viz floor prediction - BLD1
# "KNN CM BLD1 floor prediction"
ggplotConfusionMatrix1 <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#6A3D9A") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix1(confusionMatrix_knn_BLD1)



# 6.3 relevel (specifiy) floors of BLD2----
Building2$FLOOR <-
  factor(Building2$FLOOR, levels = c("0", "1", "2", "3", "4"))
Building2 <- saveRDS(Building2, "Building2.rds")

rf_fitBLD2_floor <- train(
  FLOOR ~ .,
  Building2,
  method = 'ranger',
  preProcess = c('zv'),
  trControl = fitControl
)

# 6.4 summarising the results of model training----
results_floorpredic <- resamples(
  list(
    RF_BLDALL = rf_fit_floor,
    RF_BLD0 = rf_fitBLD0_floor,
    RF_BLD1 = rf_fitBLD1_floor,
    RF_BLD2 = rf_fitBLD2_floor
  )
)
summary(results_floorpredic)
bwplot(results_floorpredic) # produced a plot named "Kappa and Accuracy_RF_floor by each BLD"


# train KNN model by buildings
knn_fitBLD2_floor <- train(
  FLOOR ~ .,
  Building2,
  method = 'knn',
  trControl = fitControl,
  preProcess = c("center", "scale"),
  tuneGrid = knn_grid
)

knn_fitBLD2_floor <-
  saveRDS(knn_fitBLD2_floor, "knn_fitBLD2_floor.rds")

# Predicting floor in BLD 2 : Accuracy 0.806, Kappa:  0.7345
predict_knn_BLD2 <- predict(knn_fitBLD2_floor, Building2valid)
confusionMatrix_knn_BLD2 <-
  confusionMatrix(predict_knn_BLD2, Building2valid$FLOOR)
confusionMatrix_knn_BLD2

# viz floor prediction - BLD2
# "KNN CM BLD2 floor prediction"
ggplotConfusionMatrix2 <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#E31A1C") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix2(confusionMatrix_knn_BLD2)


# 6.5 Validating RF models in predicting floors----

Buildingsvalid <- split(Datavalid, Datavalid$BUILDINGID)
names(Buildingsvalid) <-
  c("Building0valid", "Building1valid", "Building2valid")
list2env(Buildingsvalid, envir = .GlobalEnv)

# relevel variable of "floor" in each dataset
Building0valid$FLOOR <-
  factor(Building0valid$FLOOR, levels = c("0", "1", "2", "3"))
Building1valid$FLOOR <-
  factor(Building1valid$FLOOR, levels = c("0", "1", "2", "3"))
Building2valid$FLOOR <-
  factor(Building2valid$FLOOR, levels = c("0", "1", "2", "3", "4"))

Building0valid <- saveRDS(Building0valid, "Building0valid.rds")

Building1valid <- saveRDS(Building1valid, "Building1valid.rds")

Building2valid <- saveRDS(Building2valid, "Building2valid.rds")

# validating RF model in predicting floors

# Building 0: Accuracy 0.9683, Kappa: 0.955
predict_rf_BLD0 <- predict(rf_fitBLD0_floor, Building0valid)
confusionMatrix_rf_BLD0 <-
  confusionMatrix(predict_rf_BLD0, Building0valid$FLOOR)
confusionMatrix_rf_BLD0

# viz floor prediction - BLD0

ggplotConfusionMatrix0 <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#FF7F00") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix0(confusionMatrix_rf_BLD0)

# Building 1: Accuracy 0.7948, Kappa: 0.7035- the results of Accuracy and Kappa are relatively lower than other builidngs, why? Will explore and try to improve when time allows.
predict_rf_BLD1 <- predict(rf_fitBLD1_floor, Building1valid)
confusionMatrix_rf_BLD1 <-
  confusionMatrix(predict_rf_BLD1, Building1valid$FLOOR)
confusionMatrix_rf_BLD1

# viz floor prediction - BLD1

ggplotConfusionMatrix1 <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#6A3D9A") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix1(confusionMatrix_rf_BLD1)

# Building 2: Accuracy 0.9254, Kappa: 0.8984
predict_rf_BLD2 <- predict(rf_fitBLD2_floor, Building2valid)
confusionMatrix_rf_BLD2 <-
  confusionMatrix(predict_rf_BLD2, Building2valid$FLOOR)
confusionMatrix_rf_BLD2

# viz floor prediction - BLD2

ggplotConfusionMatrix2 <- function(m) {
  mytitle <- paste("Accuracy",
                   percent_format()(m$overall[1]),
                   "Kappa",
                   percent_format()(m$overall[2]))
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = Prediction)) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#E31A1C") +
    geom_text(aes(x = Reference, y = Prediction, label = Freq)) +
    theme(legend.position = "none") +
    ggtitle(mytitle)
  return(p)
}

ggplotConfusionMatrix2(confusionMatrix_rf_BLD2)
