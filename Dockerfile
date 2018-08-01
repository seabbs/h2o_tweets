## Start rocker r image
FROM rocker/r-ver:3.4.4

MAINTAINER "Sam Abbott" contact@samabbott.co.uk

## Get cron for scheduling
RUN apt-get update && apt-get -y install cron

## Get libs required by packages
RUN apt-get update \
  && apt-get install -y \
	libssl-dev \
    libcurl4-openssl-dev \
    git \
    && apt-get clean

RUN apt-get update \
  && apt-get install -y \
	libgit2-dev \
    && apt-get clean

ADD . home/h2o_tweets

WORKDIR  home/h2o_tweets

## Install R packages
RUN Rscript -e 'install.packages(c("dplyr", "stringr", "purrr", "tidyr"))'

RUN Rscript -e 'install.packages(c("lubridate", "ggplot2", "forcats", "viridis"))'

RUN Rscript -e 'install.packages(c("scales", "devtools", "cronR", "rtweet"))'

RUN Rscript -e 'devtools::install_github("seabbs/StackTweetBot")'

## Make a directory for auth
RUN mkdir ../auth

## Run the bot
CMD Rscript R/stack_tweet_bot.R
