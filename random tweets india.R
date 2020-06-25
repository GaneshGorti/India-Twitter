library(rtweet)
library(dplyr)
library(tidytext)
library(readr)

# store api keys
api_key <- "API KEY"
api_secret_key <- "API SECRET KEY"
access_token <- "ACCESS TOKEN"
access_token_secret <- "SECRET ACCESS TOKEN"

# authenticate via web browser
token <- create_token(
  app = "APP NAME",
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

# check to see if the token is loaded
#get_token() 

#old code at the end

#collecting 2mil tweets from the past seven days 
indiarandom7days <- search_tweets("lang:en",
                           geocode = lookup_coords("india", apikey = "API KEY"),
                           until= "2020-06-12",
                           n = 2000000, 
                           retryonratelimit = TRUE)
save(indiarandom7days, file=paste("H:/Twitter/13062020_2mil.RData")) #change path here

load(file = "H:/Twitter/13062020_2mil.RData")

randomhandles <- indiarandom7days %>% 
  group_by(as.Date(created_at)) %>%  #grouping by date of creation 
  sample_n(20000)

randomhandles <- randomhandles[,c("user_id")] #picking only user-id variable

length(unique(randomhandles$user_id)) == nrow(randomhandles) #unique ids returns False; need to delete duplicates 

randomhandles <- distinct(randomhandles, user_id) #you can also use this code to get all unique user ids
names(randomhandles)[1] <- "users"

#randomhandles <- data.frame(table(randomhandles$screen_name)) #gives all ids with the number of times they have occurred and hence aggregates the user-ids. can be considered as teh final list of user ids that are unique
#randomhandles <- randomhandles[,c("Var1")] #picking only user-id variable
#randomhandlesfull <- data.frame(randomhandles)

users <- as.vector(randomhandles$users) #creating a vector to specify in the get_timelines command
n <- length(users) 
data <- vector("list", n) #vector for the for loop and the tibble with usernames

#creating the loop to run through each of the userids
for (i in seq_along(data)) {
  data[[i]] <- get_timeline(users[i], n = 3200)
  rl <- rate_limit(token, "statuses/user_timeline")
  #if rate limit is exhausted, the below line waits for the rate limit to reset
  if (rl$remaining == 0L) {
    Sys.sleep(as.numeric(rl$reset, "secs"))
  }
}

save(data, file=paste("H:/Twitter/timelines.RData")) #change path here