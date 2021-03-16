## this script is for simplex 3 batch processing 

library(forecast)
library(tidyverse)
library(lubridate)


# read in data
# working directory for batch processing: /home/brunkenm/competition3

store.train <- vroom::vroom("/home/brunkenm/competition3/train.csv")
store.test <- vroom::vroom("/home/brunkenm/competition3/test.csv")
store <- bind_rows(store.train, store.test, .id = 'set')
store$set <- ifelse(store$set == 1, 'train', 'test')


## Create month variable
store <- store %>% mutate(month=as.factor(month(date)))

## Create weekday variable
store <- store %>% mutate(weekday = as.factor(wday(date)))


## nested loop for i in # 
items <- 1:50
stores <- 1:10
sales <- numeric()

for(i in items){
  
  for(j in stores){
    
    

    y <- store.train %>% filter(item == i, store == j) %>%
  pull(sales) %>% ts(data=., start=1, frequency=365)

# create matrix of explanatory variables
x <- store %>% filter(item == i, store == j, set == 'train') %>% 
  pull(month, weekday)
X <- model.matrix(~x)[,-1] # this creates a matrix of 1s and 0s 

arima.mod <- auto.arima(y=y, 
                        max.p=2, 
                        max.q=2,
                        xreg = X)


Xpred <- cbind(c(rep(0, 31), rep(1, 28), rep(0, 31)),
               c(rep(0, 31), rep(0, 28), rep(1, 31)),
               matrix(0, nrow=90, ncol=9))
colnames(Xpred) <- colnames(X)

preds <- forecast(arima.mod, h=90, xreg=Xpred)

# plot(preds)

sales <- append(sales, preds$mean)

    
  }
  
    
  }


# save put sales in the test dataset

store.test$sales <- sales

submission <- store.test[, c('id', 'sales')]

write.csv(submission, file = '/home/brunkenm/competition3/sales_predictions2.csv', row.names = FALSE)

