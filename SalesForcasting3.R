## packages

library(forecast)
library(tidyverse)
library(lubridate)
library(xgboost)
library(caret)

# read in data

store.train <- vroom::vroom("/Users/matthewbrunken/Winter2021/Kaggle/competition3/train.csv")
store.test <- vroom::vroom("/Users/matthewbrunken/Winter2021/Kaggle/competition3/test.csv")
store <- bind_rows(store.train, store.test, .id = 'set')
store$set <- ifelse(store$set == 1, 'train', 'test')

# give the dataset a month variable to accommodate xgboost's forcasting
test_mod <- store %>%
    dplyr::mutate(., 
                  months = lubridate::month(date),
                  years = lubridate::year(date))

# put in a for loop, loop by item and store

items <- 1:50
stores <- 1:10
preds <- numeric()

for(i in items){
  
  for(j in stores) {

# subset the data by item

test_mod2 <- test_mod %>% 
  filter(item == i, store == j)

# train and test matrix
x_train <- xgboost::xgb.DMatrix(as.matrix(test_mod2 %>% 
                                            filter(set == 'train') %>% 
                                dplyr::select(months, years)))

x_pred <- xgboost::xgb.DMatrix(as.matrix(test_mod2 %>% 
                                           filter(set == 'test') %>% 
                                dplyr::select(months, years)))

y_train <- test_mod2 %>% 
  filter(set == 'train') %>% 
  pull(sales)


## set up xgboost
xgb_trcontrol <- caret::trainControl(
   method = "cv", 
   number = 5,
   allowParallel = TRUE, 
   verboseIter = FALSE, 
   returnData = FALSE)

xgb_grid <- base::expand.grid(
   list(
    nrounds = c(100, 200),
    max_depth = c(10, 15, 20), # maximum depth of a tree
    colsample_bytree = seq(0.5), # subsample ratio of columns when construction each tree
    eta = 0.1, # learning rate
    gamma = 0, # minimum loss reduction
    min_child_weight = 1,  # minimum sum of instance weight (hessian) needed ina child
    subsample = 1 # subsample ratio of the training instances
))

# build model
xgb_model <- caret::train(
   x_train, y_train,
   trControl = xgb_trcontrol,
   tuneGrid = xgb_grid,
   method = "xgbTree",
   nthread = 1)

# look at tuned paramaters
xgb_model$bestTune

# make predictions
xgb_pred <- xgb_model %>% stats::predict(x_pred)

preds <- append(preds, xgb_pred)

  }
  
}

# put predictions in store.test dataframe

store.test$sales <- preds

submission <- store.test[, c('id', 'sales')]

write.csv(submission, file = '/Users/matthewbrunken/Winter2021/Kaggle/competition3/sales_predictions3.csv', row.names = FALSE)

