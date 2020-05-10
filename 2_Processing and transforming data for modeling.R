# This script comes after "1_wifi locationing data upload and initial viz".
# load library
pacman::p_load(caret, dplyr, gdata, lubridate, tidyr)

# 23.03.20
# 2. Data cleaning and feature engineering ----

# 2.1. Remove duplicate (non-unique) observations ----
# Remove duplicate rows in DataTrain and DataValid             

DataTrain<-distinct(original_traindf)   #<- 19937 to 19300

DataValid<-distinct(original_validdf)   #<- zero repeated row found in V dt

# 2.2. Transformations ----
# Combining datasets for speeding-up the transformations and add ID

Data_Full<-gdata::combine(DataTrain, DataValid)

Data_Full <- Data_Full %>% mutate(ID = row_number()) # turned out later that creating a variable of ID wasn't necessary


## transfer data types
# Transforming some variables to factor/numeric/datetime 
factors <-
  c("FLOOR",
    "BUILDINGID",
    "SPACEID",
    "RELATIVEPOSITION",
    "USERID",
    "PHONEID",
    "source")
Data_Full[, factors] <- lapply(Data_Full[, factors], as.factor)
rm(factors)

numeric <- c("LONGITUDE", "LATITUDE")
Data_Full[, numeric] <- lapply(Data_Full[, numeric], as.numeric)
rm(numeric)



Data_Full$TIMESTAMP <-
  as_datetime(Data_Full$TIMESTAMP, origin = "1970-01-01", tz = "UTC") # turned out later that this variable (timestamp) isn't useful for predicting locations

# Changing the value of RSSI = 100 to -110
WAPS <- grep("WAP", names(Data_Full), value = T)
Data_Full[, WAPS] <-
  sapply(Data_Full[, WAPS], function(x)
    ifelse(x == 100, -110, x))

# 2.3. Selecting relevant WAPS ----
# Removing those "near-zero variance" predictors and registers: "Zero or near zero variance variables refer to constant and almost constant predictors across samples. These kind of predictors are not only non-informative, but also it can break some models. Therefore, we need to throw them away before feeding into the models."
WAPS_VarTrain <-
  nearZeroVar(Data_Full[Data_Full$source == "DataTrain", WAPS], saveMetrics =
                TRUE)
WAPS_VarValid <-
  nearZeroVar(Data_Full[Data_Full$source == "DataValid", WAPS], saveMetrics =
                TRUE)
# remove columns that contain only constants
# remove variables with zero and near zero variance - constants don't tell much

Data_Full <- Data_Full[-which(WAPS_VarTrain$zeroVar == TRUE |
                                WAPS_VarValid$zeroVar == TRUE)]   # 529 -> 323 variables

rm(WAPS_VarTrain, WAPS_VarValid)

#2.4. Remove rows with no variance 
# 3. Feature engineering ----
# 3.1 create a single identifier that combines BUILDINGID, FLOOR, SPACEID and RELATIVEPOSITION (tidyr::unite) ----

Data_Fullnew <-
  unite(
    Data_Full,
    "Building_floor",
    c(BUILDINGID, FLOOR),
    remove = FALSE,
    sep = "-"
  )
Data_Fullnew$Building_floor <-
  as.factor(Data_Fullnew$Building_floor)
nlevels(Data_Fullnew$Building_floor) # 13 levels
nlevels(Data_Fullnew$SPACEID)

Data_Fullnew <- saveRDS(Data_Fullnew, "Data_Fullnew.rds")
# I later didn't use this variable after making the decision to predict buildingID, floor, latitude and longitude separately. But I wonder whether this "single identifier" is necessary? - this is something for future work when time allows

# 3.2 remove variables that have little values in terms of validating models/data ----
# SPACEID (all value of SPACEID are 0 in validation dt)
# Relativeposition (same reason as above)
# USERID and PHONEID: USERID have value of "0" in most cases. 
# TIMESTAMP: showed the period of time when data were collected but do not contribute to forecast/validation

Data_tidy <-
  select(
    Data_Fullnew,
    -RELATIVEPOSITION,
    -USERID,
    -PHONEID,
    -TIMESTAMP,
    -SPACEID,
    -Building_floor,
    -ID
  )

Datatidy <- saveRDS(Data_tidy, "Datatidy.rds")

# removing latitude in the dataset to predict longitude
Data_noLatitude <-
  select (
    Data_Fullnew,
    -RELATIVEPOSITION,
    -USERID,
    -PHONEID,
    -TIMESTAMP,
    -SPACEID,
    -Building_floor,
    -ID,
    -LATITUDE
  )
Data_noLatitude <- saveRDS(Data_noLatitude, "Data_noLatitude.rds")
# removing longitude in the dataset to predict latitude

Data_noLongitude <-
  select (
    Data_Fullnew,
    -RELATIVEPOSITION,
    -USERID,
    -PHONEID,
    -TIMESTAMP,
    -SPACEID,
    -Building_floor,
    -ID,
    -LONGITUDE
  )
Data_noLongitude <-
  saveRDS(Data_noLongitude, "Data_noLongitude.rds")

# 3.3 Split Data before modeling ----
Data_FullSplit <- split(Data_tidy, Data_tidy$source)
list2env(Data_FullSplit, envir = .GlobalEnv)
rm(Data_FullSplit)
Datatrain <- select(DataTrain,-source)
Datavalid <- select(DataValid,-source)

Datatrain <- saveRDS(Datatrain, 'Datatrain.rds')
Datavalid <- saveRDS(Datavalid, 'Datavalid.rds')


# 3.4 Split Data (for regression) before modeling ----
Data_noLatitudelist <- split(Data_noLatitude, Data_noLatitude$source)

list2env(Data_noLatitudelist, envir = .GlobalEnv)

rm(Data_noLatitudelist)

Datatrain_nolat <- select(DataTrain,-source)
Datavalid_nolat <- select(DataValid,-source)

Datatrain_nolat <- saveRDS(Datatrain_nolat, 'Datatrain_nolat.rds')
Datavalid_nolat <- saveRDS(Datavalid_nolat, 'Datavalid_nolat.rds')



Data_noLongitudelist <-
  split(Data_noLongitude, Data_noLongitude$source)

list2env(Data_noLongitudelist, envir = .GlobalEnv)

rm(Data_noLongitudelist)

Datatrain_nolon <- select(DataTrain,-source)
Datavalid_nolon <- select(DataValid,-source)

Datatrain_nolon <- saveRDS(Datatrain_nolon, 'Datatrain_nolon.rds')
Datavalid_nolon <- saveRDS(Datavalid_nolon, 'Datavalid_nolon.rds')
