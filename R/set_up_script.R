## Get required packages
install.packages("devtools")
install.packages("cronR")
devtools::install_github("seabbs/StackTweetBot")

# Load StackTweetBot
library(StackTweetBot)

## Add twitter API access
add_twitter_api()

## Add stack overflow api access
add_stack_api()

## Restart R and check API
add_twitter_api()
add_stack_api()

## Set up, save and schedule h2o bot
set_up_stack_tweet_bot(extracted_tags = "h2o",
                       excluded_tags = NULL,
                       time_window = 60,
                       add_process_fn = NULL, 
                       hashtags = c("datascience", "stackoverflow"),
                       run = TRUE, 
                       schedule = TRUE,
                       save = TRUE, 
                       post = TRUE,
                       dir = "R",
                       verbose = TRUE,
                       frequency = "hourly")

## Check the job has been set correctly
cronR::cron_ls()
