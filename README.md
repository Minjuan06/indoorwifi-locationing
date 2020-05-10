# Introduction

This project has the purpose to assist developing a system to be deployed on large industrial campuses, in shopping malls, et cetera to help people to navigate a complex, unfamiliar interior space without getting lost. While GPS works fairly reliably outdoors, it generally doesn't work indoors, so a different technology is necessary. 

The feasibility of using "wifi fingerprinting" is investigated to determine a person's location in indoor spaces. Wifi fingerprinting uses the signals from multiple wifi hotspots within the building to determine location, analogously to how GPS uses satellite signals. We have been provided with a large database of wifi fingerprints for a multi-building industrial campus with a location (building, floor, and location ID) associated with each fingerprint. 

This task also includes evaluations of multiple machine learning models to evaluate which produces the best result.

## 1. Loading the data
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

### Performing EDA

Preliminary exploration was performed as part of familiarization process.

**3D-mapping the footprints**

<img src="/images/Frequency%20of%20occurrence%20of%20WAPs%20values_train.png"  width="240" height="190">   <img src="/images/Frequency%20of%20occurrence%20of%20WAPs%20values_valid.png"  width="240" height="190"> 

<img src="/images/Frequency%20of%20occurence%20of%20WAPs%20both%20dt.png"  width="340" height="200"> 

**The distribution and occurrences of WAPs**

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

- classification models to predict building numbers
- regression models to predict floor, longitude and latitude values

After revisiting and revising your process, you will build and test a range potential models that could work to find the location value you are required to find. As the data analyst you will need to make principled choices based on your past experiences. Potential candidates could include C5.0, SVM/SVR, KNN, LM, Model Trees, RandomForest, etc. but you will make the choices; be prepared to justify your decision, if asked. You must test at least three algorithms.
