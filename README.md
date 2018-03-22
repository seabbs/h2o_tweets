
<!-- README.md is generated from README.Rmd. Please edit that file -->
H2O Tweets
==========

A [twitter bot](https://twitter.com/h2o_tweets) posting Stack Overflow questions linked to [H2O](https://www.h2o.ai/h2o/) the open source machine learning tool kit. This bot has been built using the [StackTweetBot](https://www.samabbott.co.uk/StackTweetBot/) R package, which provides instructions and tools for setting up a Twitter Stack Overflow bot.

Set-up
------

Set-up the bot using `R/set-up-script.R`. The bot uses `stack_tweet_bot.R` to post tweets as questions are asked and `h2o_tweets_over_time.R` to post a monthly summary of questions. See `stack_tweet_bot.log` and `h2o_tweets_over_time.log` for logs of bot activity.
