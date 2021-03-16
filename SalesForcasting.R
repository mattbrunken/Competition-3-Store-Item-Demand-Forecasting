##
## Store Item Demand
##

## Libraries
library(forecast)
library(tidyverse)
library(lubridate)

## Read in the data
store.train <- vroom::vroom("/Users/matthewbrunken/Winter2021/Kaggle/competition3/train.csv")
store.test <- vroom::vroom("/Users/matthewbrunken/Winter2021/Kaggle/competition3/test.csv")
store <- bind_rows(store.train, store.test, .id = 'set')
store$set <- ifelse(store$set == 1, 'train', 'test')

## Number of stores/items
with(store, table(item, store))

## Sales by Month
ggplot(data=store.train %>% filter(item==1),
       mapping=aes(x=month(date) %>% as.factor(), y=sales)) + 
  geom_boxplot()

## Sales by Weekday
ggplot(data=store %>% filter(set == 'train') %>% filter(item==1),
       mapping=aes(x = weekday %>% as.factor(), y=sales)) + 
  geom_boxplot()

## Create month variable
store <- store %>% mutate(month=as.factor(month(date)))

## Create weekday variable
store <- store %>% mutate(weekday = as.factor(wday(date)))

## Sales of item by store
## ggplot(data=store.train %>% filter(item==17),
    ##   mapping=aes(x=date, y=sales, color=as.factor(store))) +
  ## geom_line()

## store <- store %>% mutate(year=as.factor(year(date)),
   ##                       time=year(date)+yday(date)/365)
## ggplot(data=store %>% filter(item==17, store==7),
   ##    mapping=aes(x=time, y=sales)) +
  ## geom_line() + geom_smooth(method='lm')

## Weekend effect
## ggplot(data=store.train %>% filter(item==1),
  ##     mapping=aes(x=wday(date, label=TRUE) %>% as.factor(), y=sales)) + 
  ## geom_boxplot()


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
  pull(month)
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

plot(preds)

sales <- append(sales, preds$mean)

    
  }
  
    
  }

# save put sales in the test dataset

store.test$sales <- sales

submission <- store.test[, c('id', 'sales')]

write.csv(submission, file = '/Users/matthewbrunken/Winter2021/Kaggle/competition3/sales_predictions1.csv', row.names = FALSE)

