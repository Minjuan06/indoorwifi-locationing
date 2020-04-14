# 19.03.2020 Ubiqum / Home office during Covid-19 crisis

# install.packages("doParallel")
# install.packages("pacman")
# install.packages("plot3D")
# load and update library using pacman::p_load

pacman::p_load(class, dplyr, ggplot2, readr, plot3D, plotly, openxlsx)
 
# 1. Loading and observing data - EDA ----

#Tasks: Visualizing and imputing missing values
#       doParallel - parallel processing to allocate multiple cores in order to reduce the computing time.

# 1.1 load wifi locationing indoor data

original_traindf <- read_csv("C:\\Users\\minju\\Ubiqum\\Module 3\\indoorwifi-locationing\\UJIndoorLoc\\trainingData.csv")

original_traindf <- saveRDS(original_traindf, "original_traindf.rds")

original_validdf<-read_csv("C:\\Users\\minju\\Ubiqum\\Module 3\\indoorwifi-locationing\\UJIndoorLoc\\validationData.csv")
original_validdf <- saveRDS(original_validdf, "original_validdf.rds")

# observing data

dim(original_traindf)
glimpse(original_traindf [,510:529])
str(original_traindf)
tail(original_traindf, n=5)[520:529]
head(original_traindf, n=5)[1:10]
head(original_traindf, n=5)[520:529]
class(original_traindf)
sapply(original_traindf, class)


# 1.2 Visualising the distribution / occurrences of WAPs 
# Plotting occurrences of WAP values - creating a new data table with only WAPs
WAPdf_train <- select(original_traindf, starts_with("WAP"))
countWAP_train <- data.frame(table(unlist(WAPdf_train)))

#dropping the count of RSSI = 100, only keep counts for -104 to 0, so the distribution of WAPs wont' be skewed by a large amount of occurrences of 100 
countWAP_train <- countWAP_train[1:100,]

## do the same (dropping of RSSI = 100) in the validation dataset
WAPdf_valid <- select(original_validdf, starts_with("WAP"))
countWAP_valid <- data.frame(table(unlist(WAPdf_valid)))

#drop the count of 100, only keep counts for -104 to 0 in validation dt
countWAP_valid <- countWAP_valid[1:69,] #validation set has less detected signals

# Using ggplot - producing a plot named as "Frequency of occurrence of WAPs values_train"
countWAP_train$Var1 = as.numeric(as.character(countWAP_train$Var1))
p<-ggplot(countWAP_train, aes(Var1, Freq)) + geom_bar(stat = "identity", color = "white", fill = "#B2DF8A") +  xlab("WAP values in training dataset") + ylab("Frequency of occurrence")
p

# Using ggplot - producing a plot named as "Frequency of occurrence of WAPs values_valid"
countWAP_valid$Var1 = as.numeric(as.character(countWAP_valid$Var1))
q<-ggplot(countWAP_valid, aes(Var1, Freq)) + geom_bar(stat = "identity", color = "white", fill = "#1F78B4") +  xlab("WAP values in validation dataset") + ylab("Frequency of occurrence") 
q

# combine two dt (keeping source info) to create a combined plot named as "Frequency of occurence of WAPs both dt". Instead of using dplyr::union which does not automatically creat a column showing sources, here used gdata::combine( ) to indicating sources. 
combinedcountWAP <- gdata::combine(countWAP_train, countWAP_valid)


o <- ggplot(combinedcountWAP, aes(Var1, Freq, fill = source)) + 
  geom_bar(stat="identity", color = "white", position = "stack") + scale_fill_manual(values = c("#B2DF8A","#1F78B4"), labels = c("WAPs in training dataset", "WAPs in validation dataset")) + xlab("WAP values in training and validation datasets") + ylab("Frequency of occurrence") 
o

### 31.3 Producing 3D plotting to map out how wifi footprints are observed/detected in each building and each floor - in both training and validation datasets

# producing 3D plot of wifi footprints in training data
original_traindf$FLOOR <- as.numeric(as.character(original_traindf$FLOOR))

x <- original_traindf$LONGITUDE
y <-original_traindf$LATITUDE
z <- original_traindf$FLOOR

scatter3D(x, y, z, colvar = NULL, col = "#B2DF8A", xlab = "Longitude",ylab ="Latitude", zlab = "Floor", bty = "b2", main ="Wifi indoor footprints (based on training data)", pch = 19, cex = 0.5, theta = -30, phi = 30, ticktype= "detailed", cex.axis = 0.5, cex.lab = 0.7)

# producing 3D plot of wifi footprints in validation data
original_validdf$FLOOR <- as.numeric(as.character(original_validdf$FLOOR))

x <- original_validdf$LONGITUDE
y <-original_validdf$LATITUDE
z <- original_validdf$FLOOR

scatter3D(x, y, z, colvar = NULL, col = "#1F78B4", xlab = "Longitude",ylab ="Latitude", zlab = "Floor", bty = "b2", main ="Wifi indoor footprints (based on validation data)", pch = 19, cex = 0.5, theta = -30, phi = 30, ticktype= "detailed", cex.axis = 0.5, cex.lab = 0.7)

