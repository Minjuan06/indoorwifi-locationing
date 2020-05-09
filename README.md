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

<img src="/images/Frequency%20of%20occurrence%20of%20WAPs%20values_train.png"  width="240" height="200">   <img src="/images/Frequency%20of%20occurrence%20of%20WAPs%20values_valid.png"  width="240" height="200">   <img src="/images/Frequency%20of%20occurence%20of%20WAPs%20both%20dt.png"  width="300" height="200"> 

**The distribution and occurrences of WAPs**

<img src="/images/3D%20indoor%20training.png"  width="240" height="240"> <img src="/images/3D%20indoor%20validation.png"  width="240" height="240">


### Data cleaning

### Decision on ML approach - classificaiton or regression?
After becoming familiar with the data, (re)formalize the process via which you will use the provided data to construct machine learning models for predicting location in the validation dataset. You will need to decide if this problem is best-solved using classification or another approach.

TIP:
The dataset is very large, so a key part of your process might involve defining an approach to sampling the data. There are, at least, two possibilities: (1) Restrict the models to fewer buildings or even individual buildings or (2) Use a reasonable random sample of the data.

TIP:
You will quite probably want to devise a single unique identifier for each location in the dataset or your sample(s). Think about how best to combine the building, floor, and specific location attributes into a single unique identifier for each instance. Also think about the appropriate type for this "composite" attribute: Should it be numeric, a factor, or something else? Convert the composite location attribute if appropriate.

After revisiting and revising your process, you will build and test a range potential models that could work to find the location value you are required to find. As the data analyst you will need to make principled choices based on your past experiences. Potential candidates could include C5.0, SVM/SVR, KNN, LM, Model Trees, RandomForest, etc. but you will make the choices; be prepared to justify your decision, if asked. You must test at least three algorithms.
