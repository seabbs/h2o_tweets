
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
    libgit2-dev \
    && apt-get clean

ADD . home/h2o_tweets

WORKDIR  home/h2o_tweets

## Install R packages
RUN Rscript -e 'install.packages("packrat"); packrat::restore()'

## Run the bot
CMD Rscript R/stack_tweet_bot.R
