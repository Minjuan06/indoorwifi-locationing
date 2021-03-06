# Introduction

This project has the purpose to assist developing a system to be deployed on large industrial campuses, in shopping malls, et cetera to help people to navigate a complex, unfamiliar interior space without getting lost. While GPS works fairly reliably outdoors, it generally doesn't work indoors, so a different technology is necessary. 

The feasibility of using "wifi fingerprinting" is investigated to determine a person's location in indoor spaces. Wifi fingerprinting uses the signals from multiple wifi hotspots within the building to determine location, analogously to how GPS uses satellite signals. We have been provided with a large database of wifi fingerprints for a multi-building industrial campus with a location (building, floor, and location ID) associated with each fingerprint. 

This task also includes evaluations of multiple machine learning models to evaluate which produces the best result.

## 1. Loading the data and EDA
Load the Indoor Locationing Dataset (http://archive.ics.uci.edu/ml/datasets/UJIIndoorLoc) into RStudio and study the data documentation. 

**Dataset Info**
- This UJIIndoorLoc database was stored in UCI machining learning Repository.
- The database covers three buildings of Universitat Jaume I with 4 or more floors and almost 110m2 in Valencia, Spain. It was created in 2013 by means of more than 20 different users and 25 Android devices.
- The database of wifi fingerprints for a multi-building industrial campus with a location (building, floor, and location ID) associated with each fingerprint.
- The database consists of 19937 training records and 1111 validation/test records.

**Attributes include:**

- WAP001- WAP520: Intensity value for WAP. Negative integer values from -104 to 0 and +100. Positive value 100 used if any WAP was not detected.
- 9 Position-related attributes:
- FLOOR, BUILDINGID, SPACEID, RELATIVEPOSITION
- LONGITUDE, LATITUDE
- USERID, PHONEID, TIMESTAMP

The 529 attributes contain the WiFi fingerprint, the coordinates where it was taken, and other useful information.

##### Map of the UJI Riu Sec Campus where wifi signals were collected

<img src="/images/Buildings_Wifi%20signals%20collected%20from.png"  width="80%" height="80%">


Preliminary exploration was performed as part of familiarization process.

**The distribution and occurrences of WAPs**

<img src="/images/Frequency%20of%20occurrence%20of%20WAPs%20values_train.png"  width="240" height="190">   <img src="/images/Frequency%20of%20occurrence%20of%20WAPs%20values_valid.png"  width="240" height="190"> 

<img src="/images/Frequency%20of%20occurence%20of%20WAPs%20both%20dt.png"  width="340" height="200"> 


**3D-mapping the footprints**

<img src="/images/3D%20indoor%20training.png"  width="240" height="240"> <img src="/images/3D%20indoor%20validation.png"  width="240" height="240">


### 2. Data cleaning
A few actions have been taken in terms of data cleaning and transformation:

- remove duplicate (non-unique) observations 
- the training and validation data sets were combined together to speed up the transformation process
- change certain variables'data type to appropriate ones
- change the value of RSSI = 100 to -110
- remove those "near-zero variance" predictors and registers (including those columns that contain only constants and rows with no variance)
- remove variables that have little values in terms of validating models/data
- split data before modelling


### 3. Decision on ML approach - classificaiton or regression?

The dataset is very large, so a key part of the process involves defining an approach to sampling the data. Decisions were made to use:

- classification models to predict building ID and floor numbers
- regression models to predict longitude and latitude values by each building

Parallel processing was set up. 


### 4. Predicting building ID

KNN, Random Forest and Decision Tree C5.0 were deployed. Results can ben seen in below:

<img src="/images/Kappa%20and%20Accuracy_3 models_BLD.png"  width="45%" height="45%">  

There is large amount of information that independent variables carry in this dataset, which can well explain why all models have very good results in terms of predicting Building IDs. 


### 5. Predicting floor numbers

Random Forest and KNN algorithms have been employed in predicting floor numbers. In predicting floor numbers, the data was subset by each building. Nevertheless, an attempt has also been made to use all data without subsetting by building ID. The latter approach showed a slightly better result when predicting floor numbers in the Building 1 as shown in below group of confusion matrices.  

**Confusion matrices of predicting floor numbers - using Random Forest**

**<em>Confusion Matrix - subsetting data by building IDs (BLD0, BLD1, BLD2)</em>**

<img src="/images/CM%20-%20prediction%20of%20floors%20with%20data%20BLD0.png"  width="30%" height="30%">  <img src="/images/CM%20-%20prediction%20of%20floors%20with%20BLD1.png"  width="30%" height="30%">  <img src="/images/CM%20-%20prediction%20of%20floors%20with%20BLD2.png"  width="30%" height="30%">  


**<em>Confusion Matrix - without subsetting data</em>**

<img src="/images/CM%20-%20prediction%20of%20floors%20with%20all%20buildings.png"  width="30%" height="30%"> 

Further investigation should be taken in understanding why the prediction of floor numbers in Building 1 has much worse results than those in the other two buildings. 

**Confusion matrices of predicting floor numbers - using KNN**

**<em>Confusion Matrix - subsetting data by building IDs (BLD0, BLD1, BLD2)</em>**

<img src="/images/KNN%20CM%20BLD0%20floor%20prediction.png"  width="30%" height="30%">  <img src="/images/KNN%20CM%20BLD1%20floor%20prediction.png"  width="30%" height="30%">  <img src="/images/KNN%20CM%20BLD2%20floor%20prediction.png"  width="30%" height="30%">  


**<em>Confusion Matrix - without subsetting data</em>**

<img src="/images/KNN%20CM%20all%20BLDs%20floor%20prediction.png"  width="30%" height="30%"> 


### 6. Predicting latitude and longitude values

Random Forest regression algorithm and KNN regression algorithm were deployed in predicting latitude and longitude values. In an earlier attempt, both variables were included in the training and the validation dataset. When examining the variable importance, both variables ranked as the most important variable when predicting the other. Given the context that this task is to predict latitude/longitude in neighboring buildings, each latitude value has only a relatively small range of longitude values. This may lead to the high importance score they appear to each other. Therefore, latitude and longitude values were taken out in predicting longitude and latitude. 

The system processing time: RF - on average between 30m to 1h and KNN took much shorter time. By releveling floor number, improved results in R-squared were achieved.


#### 6.1 Random Forest - predicting longitude 

**Predicted vs. Actual Longitude Values - Random Forest Algorithm (BLD0, BLD1, BLD2)**

<img src="/images/RF%20nolat%20predicted%20vs.%20actual%20Longitude%20in%20Building%200.png"  width="30%" height="30%">  <img src="/images/RF%20nolat%20Predicted%20vs.%20Actual%20-%20Longitude%20in%20Building%201.png"  width="30%" height="30%">  <img src="/images/RF%20nolat%20Predicted%20vs.%20Actual%20-%20Longitude%20in%20Building%202.png"  width="30%" height="30%">  

**List of important variables in predicting longitude values (Random Forest)**

<img src="/images/LON_BLD0_RF_nolat.png"  width="30%" height="30%">  <img src="/images/LONPredict_BLD1_RF_nolat.png"  width="30%" height="30%">  <img src="/images/LONPredict_BLD2_RF_nolat.png"  width="30%" height="30%">


#### 6.2 Random Forest - predicting latitude 

**Predicted vs. Actual Longitude Values - Random Forest Algorithm (BLD0, BLD1, BLD2)**

<img src="/images/RF%20nolon%20Predicted%20vs.%20Actual%20-%20Latitude%20in%20Building%200.png"  width="30%" height="30%">  <img src="/images/RF%20nolon%20Predicted%20vs.%20Actual%20-%20Latitude%20in%20Building%201.png"  width="30%" height="30%">  <img src="/images/RF%20nolon%20Predicted%20vs.%20Actual%20-%20Latitude%20in%20Building%202.png"  width="30%" height="30%">  


**List of important variables in predicting latitude values (Random Forest)**

<img src="/images/LATPredict_BLD0_RF_nolon.png"  width="30%" height="30%">  <img src="/images/LATPredict_BLD1_RF_nolon.png"  width="30%" height="30%">  <img src="/images/LATPredict_BLD2_RF_nolon.png"  width="30%" height="30%">

#### 6.3 KNN - predicting longitude 

**Predicted vs. Actual Longitude Values - KNN Algorithm (BLD0, BLD1, BLD2)**

<img src="/images/KNN%20nolat%20Predicted%20vs.%20Actual%20-%20Longitude%20in%20Building%200.png"  width="30%" height="30%">  <img src="/images/KNN%20nolat%20Predicted%20vs.%20Actual%20-%20Longitude%20in%20Building%201.png"  width="30%" height="30%">  <img src="/images/KNN%20nolat%20Predicted%20vs.%20Actual%20-%20Longitude%20in%20Building%202.png"  width="30%" height="30%">


#### 6.4 KNN - predicting latitude 

**Predicted vs. Actual Longitude Values - KNN Algorithm (BLD0, BLD1, BLD2)**

<img src="/images/KNN%20nolon%20Predicted%20vs.%20Actual%20-%20Latitude%20in%20Building%200.png"  width="30%" height="30%">  <img src="/images/KNN%20nolon%20Predicted%20vs.%20Actual%20-%20Latitude%20in%20Building%201.png"  width="30%" height="30%">  <img src="/images/KNN%20%20nolon%20Predicted%20vs.%20Actual%20-%20Latitude%20in%20Building%202.png"  width="30%" height="30%">  


### 7. Summary

The algorithm to be best for this data: Random Forest. 

<img src="/images/summary_of_model_performance.png"  width="100%" height="100%">


**Recommendations in how to improve results**

- Further investigations should be take to look at how to achieve better results in predicting floor numbers in Building 1
- Latitude and longitude prediction for Building 2: BLD 2’s data are disproportionate – more than 9000 observations in training dataset, but only around 200 in the validation dataset.
- Random forest algorithm performed better in terms of accuracy and errors: 
    * less false prediction in floor numbers
    * latitude and longitude “combined” MAEs
    <img src="/images/LAT_LON_combinedMAE.png"  width="40%" height="40%">

- In terms of running time: 
    * KNN was in general faster – when RF models took on average 30mins above to run each one, KNN needed 15-30 mins to run. 
some specific models were super faster and only took a few seconds to get results.
In addition, RF's mtry were set to be around 160 and 200 when predicting latitude and longitude with Random Forest regression, which could lead to model overfit – this should be investigated when time allows. 

### 8. Learning experience to share

Given that this project is part of the learning process, results and processes are not perfect due to time and resources limitation
Consideration/further research and learning. I also share some learning experiece as below: 

- Omitted variables – how can these variables impact the prediction when included: SPACEID, Relative position, User ID, etc. 
- Investigating the potential over-fit of Random Forest algorithm 
- Running time to be considered
- Certain problem: e.g. why the errors of floor prediction is high in Building 1
- It is a process of running and readjustiung – e.g. removing latitude, decision of how to subset data, etc.

