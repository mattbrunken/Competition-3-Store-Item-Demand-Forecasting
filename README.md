# Competition-3-Store-Item-Demand-Forecasting

-a) The purpose of this project is to predict 3 months of sales for 50 different items at 10 different stores. 

-b) The SalesForcasting.R file contains my Rscript for my first submission, and the sales_predictions1.csv file contains the corresponding predictions. The SalesForcasting2.R file contains my Rscript for my second submission, and the sales_predictions2.csv file contains the corresponding predictions. The SalesForcasting3.R file contains my Rscript for my third submission, and the sales_predictions3.csv contains the corresponding predictions. The train.csv and test.csv files contain the data provieded by Kaggle.

-c) There was very little necessary data cleaning necessary for this competition, however there was some feature engineering necessary to create explanatroy variables for some of my models as well as some data manipulation to get the data in a date format suitable for the models I used. All of the feature engineering data manipulation are in the same Rscripts as the models/ predictions they belong to.

-d) In SalesForcasting.R and SalesForcasting2.R, I used auto.arima models to generate predictions, and in SalesForcasting3.R, I used XGboost to generate predictions. 
