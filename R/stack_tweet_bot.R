library(StackTweetBot);
questions <- get_stack_questions(extracted_tags = 'h2o',
                                 excluded_tags = NULL,
                                 time_window = 15,
                                 add_process_fn = NULL);

posts <- post_stack_tweets(questions, hashtags = c('datascience', 'machinelearning', 'stackoverflow'),
                           post = TRUE);