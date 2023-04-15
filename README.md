This project is an analysis of data collected from temperature, pressure, and humidity sensors. Its goal is to predict indoor temperature given the remaining conditions. These include relative humidity, atmospheric pressure, both inside and outside the house, as well as outdoor temperature.

This project was based on a project by Bosch Services in collaboration with the University of Aveiro that took place between 2016 and 2020.

Inside the dataverse_files folder, you can find the dataset used in this project as well as a paper that describes what was done in that stage. It is worth noting that the project presented here is different from what was originally done in the paper, where the goal was to predict a comfortable temperature for the user.

Inside this folder, you can also find a README.md file, referring to the type of data found in the dataset.

Outside the folder containing the dataset, you can find several files. There is a Jupyter Notebook called Data Extraction and Exportation, which is used to extract information from the dataset and organize it before being exported to the final-project.sql file. In this file, you can find several tables, including those imported from the Jupyter Notebook. The remaining tables are created from those tables, some with the help of 2 procedures.

Most of the data cleaning takes place in SQL, as it was easier to manipulate the data there through joining tables and limiting values.

Once these tables are arranged, they are exported to another Jupyter Notebook called EDA & MODELING, where the rest of the data analysis takes place. Here you can find calls to plotting functions defined in the .py file. Given the thp_data table, which contains data on temperature, humidity, and pressure for both indoors and outdoors – referred to as in_temp, in_hum, in_pre, out_temp, out_hum, and out_pre throughout the project.

We also have data from two more types of sensors that have been cleaned: motion and light detection sensors and contact sensors for doors or windows in the rooms that were analyzed. There is no information about the rooms that were analyzed.

There is not much information on user feedback data, which made it impossible, in the case of this project, to predict a comfortable temperature for each tenant.

It is worth noting that the outdoor atmospheric data was not measured with the same sensors that collected the indoor data. The outdoor data comes from a table with weather conditions from various cities in Portugal, from which the closest to the majority of tenants was chosen.

Three machine learning models were applied: linear regression, decision trees, and random forest. The latter two had the best results.

Given that the R2 of the random forest model was 0.99, the possibility of overfitting was evaluated, and its hyperparameterization was adjusted using RandomizedSearchCV, obtaining an R2 of 0.98.

The goal after using these metrics to predict indoor temperature was to apply the same logic to the remaining variables, allowing for the filling of the null values that originally come with the dataset and reduce the data.

In this way, fewer data would be lost, and the prediction of a comfortable temperature would be improved, as well as the control of the values of the remaining variables since correlations exist between them.

For more information on the sensor readings and the dates when the study took place for each tenant, please refer to the README.md file in the dataverse_files folder.