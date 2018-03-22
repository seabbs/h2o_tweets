library(StackTweetBot)
library(dplyr)
library(stringr)
library(purrr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(forcats)
library(viridis)
library(rtweet)


## Get questions using stackr
questions <- get_stack_questions(extracted_tags = 'h2o',
                                 excluded_tags = NULL,
                                 time_window = 60 * 24 * 365 * 5,
                                 add_process_fn = NULL,
                                 num_pages = 200);


## Tidy questions by tag
questions_tidy <- questions %>% 
  as_tibble %>% 
  mutate(tags = map(tags, ~tibble(tags = str_split(., ",") %>% unlist, value = 1))) %>% 
  mutate(tags = map(tags, ~spread(., key = "tags", value = "value"))) %>% 
  unnest() %>% 
  mutate_if(is.numeric, .funs = funs(replace_na(., 0))) %>% 
  mutate(month = floor_date(creation_date, "month")) %>% 
  gather(key = "tags", value = "questions", -title, -creation_date, -link, -month)

## Summarise questions by tag
questions_sum <- questions_tidy %>% 
group_by(month, tags) %>% 
  summarise(questions = sum(questions, na.rm = TRUE)) %>% 
  ungroup %>% 
  mutate(h2o = case_when(tags %in% "h2o"~"All questions",
                         TRUE~"Top 5 tags also used"))

## Get the most common tags (top 5)
common_tags <- questions_sum %>% 
  group_by(tags) %>% 
  count(wt = questions, sort = TRUE) %>% 
  ungroup %>% 
  slice(1:6) %>% 
  pull(tags)

## Sort tags by how common they are
questions_coll <- questions_sum %>% 
  mutate(tags = as.character(tags)) %>% 
  mutate(tags = ifelse(tags %in% common_tags, tags, "Other")) %>% 
  mutate(tags = tags %>% factor(levels = c(common_tags, "Other")))


## Plot tags over time
h2o_tag_plot <- questions_coll %>%
  filter(!tags %in% "Other") %>% 
  mutate(`Tag (H2O plus the 5 most common other tags used)` = tags) %>% 
  ggplot(aes(x = month, y = questions, 
             col =`Tag (H2O plus the 5 most common other tags used)`,
             group = `Tag (H2O plus the 5 most common other tags used)`)) +
  geom_line(size = 1.1) +
  facet_wrap(~h2o, scales = "free_y", ncol = 1) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_colour_viridis(discrete = TRUE) +
  labs(y = "Number of Questions",
       x = "Date (aggregated to month)",
       caption = "@seabbs Source: Stack Overflow",
       title = "H2O Stack Overflow Questions Over Time",
       subtitle = paste0("For the previous 5 years relative to the ", Sys.Date()))

## Save plot
ggsave("h2o_tag_plot.png", h2o_tag_plot, path = "../img", dpi = 330, width = 12, height = 8)


## Make message
tweet_content <- "Stack Overflow questions over time for @h2oai - follow for tweet updates as questions are asked. #datascience #machinelearning #stackoverflow"

## Post the tweet
post_tweet(tweet_content, media = "../img/h2o_tag_plot.png")
