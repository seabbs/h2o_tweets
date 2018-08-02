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
library(scales)

## Set work directory (not ideal but seems neccessary for CRON)
message("Current work directory is ", getwd())

if (!grepl("h2o_tweets", getwd())) {
  if (dir.exists("h2o_tweets")) {
    setwd("h2o_tweets")
    }else{
      message("Assumed in correct directory")
    }
  
}

message("Work directory set to ", getwd())

## Get questions using stackr
questions <- get_stack_questions(extracted_tags = 'h2o',
                                 excluded_tags = NULL,
                                 time_window = 60 * 24 * 365 * 5,
                                 add_process_fn = NULL,
                                 num_pages = 200);


message("Getting questions")

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

message("Saving plot")

## Save plot
ggsave("h2o_tag_plot.png", h2o_tag_plot, path = "img", dpi = 330, width = 12, height = 8)

## Filter questions from the last month
monthly_questions <- questions_tidy %>% 
  filter(creation_date > Sys.Date() - months(1)) %>% 
  count(tags, wt = questions)

h2o_questions_plot <- monthly_questions %>% 
  mutate(n = n / filter(monthly_questions, tags %in% "h2o") %>% 
           pull(n)) %>% 
  mutate(tags = tags %>% 
           factor(levels = monthly_questions %>% 
                    arrange(desc(n)) %>% 
                    pull(tags) %>% 
                    rev)) %>% 
  filter(n > 0.05) %>% 
  filter(!tags %in% "h2o") %>% 
  ggplot(aes(x = tags, y = n, fill = "hold")) +
  geom_bar(stat = "identity", alpha = 0.8) +
  geom_label(aes(label = paste0(round(n*100, digits = 0), "%")), nudge_y = -0.02, fill = "white") +
  coord_flip() +
  theme_minimal() +
  scale_fill_manual(values = "#4191E4") +
  scale_y_continuous(labels = percent) +
  theme(legend.position = "none") +
  labs(y = "Percentage of Questions",
       x = "Tag",
       caption = "Only tags that are used in at least 5% of questions are included. @seabbs Source: Stack Overflow",
       title = "H2O Stack Overflow Questions By Tag",
       subtitle = paste0("For the previous month relative to the ", Sys.Date()))
  
## Save plot
ggsave("h2o_questions_plot.png", h2o_questions_plot, path = "img", dpi = 330, width = 12, height = 8)


## Make message
tweet_content <- "Stack Overflow questions over time for @h2oai - follow for tweet updates as questions are asked. #datascience #machinelearning #stackoverflow"

## Post the tweet
post_tweet(tweet_content, media =  c("img/h2o_tag_plot.png", "img/h2o_questions_plot.png"))
