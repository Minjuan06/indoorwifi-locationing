# indoorwifi-locationing
This project has the purpose to assist developing a system to be deployed on large industrial campuses, in shopping malls, et cetera to help people to navigate a complex, unfamiliar interior space without getting lost. While GPS works fairly reliably outdoors, it generally doesn't work indoors, so a different technology is necessary. 

The feasibility of using "wifi fingerprinting" is investigated to determine a person's location in indoor spaces. Wifi fingerprinting uses the signals from multiple wifi hotspots within the building to determine location, analogously to how GPS uses satellite signals. We have been provided with a large database of wifi fingerprints for a multi-building industrial campus with a location (building, floor, and location ID) associated with each fingerprint. 

This task also includes evaluations of multiple machine learning models to see which produces the best result.

## Loading the data and performing EDA
Load the Indoor Locationing Dataset (http://archive.ics.uci.edu/ml/datasets/UJIIndoorLoc) into RStudio and study the data documentation. 

### Getting familiar with the topic
To understand what the attributes are and what they mean helps revising the approach of this task, and leads to some suggestions of how to simplify the problem.

![](image/3D%20indoor%20training)

### Performing EDA
perform some preliminary exploration as part of your familiarization process.


### Data cleaning

### Decision on ML approach - classificaiton or regression?
After becoming familiar with the data, (re)formalize the process via which you will use the provided data to construct machine learning models for predicting location in the validation dataset. You will need to decide if this problem is best-solved using classification or another approach.

TIP:
The dataset is very large, so a key part of your process might involve defining an approach to sampling the data. There are, at least, two possibilities: (1) Restrict the models to fewer buildings or even individual buildings or (2) Use a reasonable random sample of the data.

TIP:
You will quite probably want to devise a single unique identifier for each location in the dataset or your sample(s). Think about how best to combine the building, floor, and specific location attributes into a single unique identifier for each instance. Also think about the appropriate type for this "composite" attribute: Should it be numeric, a factor, or something else? Convert the composite location attribute if appropriate.

After revisiting and revising your process, you will build and test a range potential models that could work to find the location value you are required to find. As the data analyst you will need to make principled choices based on your past experiences. Potential candidates could include C5.0, SVM/SVR, KNN, LM, Model Trees, RandomForest, etc. but you will make the choices; be prepared to justify your decision, if asked. You must test at least three algorithms.
