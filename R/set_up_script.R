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
set_up_stack_tweet_bot(extracted_tags = c("h2o"),
                       excluded_tags = NULL,
                       time_window = 15,
                       add_process_fn = NULL, 
                       hashtags = c("datascience", 
                                    "machinelearning", 
                                    "stackoverflow"),
                       run = TRUE, 
                       schedule = TRUE,
                       save = TRUE, 
                       post = TRUE,
                       dir = "R",
                       verbose = TRUE,
                       frequency = "*/15 * * * *")


## Schedule monthly updates on the number of questions 
monthly_update_path <- file.path(getwd(), "R/h2o_tweets_over_time.R")
monthly_update_cmd <- cronR::cron_rscript(monthly_update_path, log_append = TRUE)
cronR::cron_add(monthly_update_cmd, "monthly", at = "12AM")


## Check the jobs have been set correctly
cronR::cron_ls()
