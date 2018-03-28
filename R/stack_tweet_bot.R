library(StackTweetBot);

message('Getting Stack Overflow questions at ', Sys.time());

questions <- get_stack_questions(extracted_tags = 'h2o',
                                 excluded_tags = NULL,
                                 time_window = 15,
                                 add_process_fn = NULL);

message('Extracted ', length(questions$title), ' questions');

message('Posting questions as tweets');

posts <- post_stack_tweets(questions, hashtags = c('datascience', 'machinelearning', 'stackoverflow'),
                           post = TRUE);