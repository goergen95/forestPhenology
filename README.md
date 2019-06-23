**Exploration of accuracy impacts on tree species classification**



This repository hosts our code to generate insights into the impacts determining the accuracy of tree species classification which uses UAV-based collected RGB time-series of temperate mixed forest in Caldern, Germany. 

We implement an experimental procedure testing the impact of following parameters:

(1.) Accuracy gain/loss by using phenological predictors based on the whole time-series vs. mono-temporal predictors only

(2.) Accuracy gain/loss of different sampling strategies of which pixels of a tree object will be part of the training process

(3.) Accuracy gain/loss of different levels of spatial aggregation/resolution

(4.) Suitability of different  machine learning algorithms to model tree species based on the different data levels of (1.-3.)

