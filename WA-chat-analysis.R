# libraries
library(stringr)
library(tidyverse)
library(lubridate)
library(cowplot)
library(rstatix)
library(ggpubr)

message_types=c('text', 'picture', 'audio', 'video', 'gif', 'document', 'sticker', 'deleted')

# import Whatsapp-chat (after exporting into txt-file)
WA_chat <- readLines('/PATH/TO/YOUR/FILE.txt') %>%
  # collapse line breaks and split lines only after [date:time]
  paste(., collapse='\n') %>%
  str_split('(?=\\[[\\d]{2}/[\\d]{2}/[\\d]{4}, [\\d]{2}:[\\d]{2}:[\\d]{2}\\])') %>%
  unlist() %>%
  tibble(chat=.) %>%
  # remove first (empty) line (resulting from line break)
  slice(-1) %>%
  # remove possible messages that were automically sent by the system 
  filter(!str_detect(chat, 'Ende-zu-Ende-verschlüsselt')) %>%
  filter(!str_detect(chat, 'hat die Gruppe .* erstellt')) %>%
  filter(!str_detect(chat, 'hat .* hinzugefügt')) %>%
  # remove initial opening bracket
  mutate(chat = str_remove_all(chat, '^\\[')) %>%
  # separate date and time
  separate(chat, into=c('datetime', 'text'), sep='] ') %>%
  separate(datetime, into=c('date', 'time'), sep=', ') %>%
  mutate(date = as.Date(date, format='%d.%m.%y'),
         month_year = format(date, "%b '%y")) %>%
  # separate name and message
  separate(text, into=c('name', 'message'), sep=': ', extra='merge') %>%
  # create numeric column for count of characters per message
  mutate(characters = str_length(message)) %>%
  # create logical columns for every message type
  mutate(picture = grepl('Bild weggelassen', message)) %>%
  mutate(video = grepl('Video weggelassen', message)) %>%
  mutate(gif = grepl('GIF weggelassen', message)) %>%
  mutate(sticker = grepl('Sticker weggelassen', message)) %>%
  mutate(audio = grepl('Audio weggelassen', message)) %>%
  mutate(document = grepl('Dokument weggelassen', message)) %>%
  mutate(deleted = grepl('(Diese Nachricht wurde gelöscht.)|(Du hast diese Nachricht gelöscht.)', message)) %>%
  # create column for message type
  mutate(type = case_when(picture==TRUE ~ 'picture',
                          video==TRUE ~ 'video',
                          gif==TRUE ~ 'gif',
                          sticker==TRUE ~ 'sticker',
                          audio==TRUE ~ 'audio',
                          document==TRUE ~ 'document',
                          deleted==TRUE ~ 'deleted',
                          TRUE ~ 'text')) %>%
  # set range for messages types
  mutate(type = factor(type, levels=message_types))

# if wanted set prefered colors for messages and/or names
message_colors=c('text'='#cccccc',
                 'picture'='#ff0000',
                 'audio'='#00ff00',
                 'video'='#0000ff',
                 'gif'='#ffff00',
                 'document'='#ff00ff',
                 'sticker'='#00ffff',
                 'deleted'='#000000')
name_colors=c('NAME_1'='#cccccc',
              'NAME_2'='#ff0000',
              'NAME_3'='#00ff00',
              'NAME_4'='#0000ff',
              'NAME_5'='#ffff00',
              'NAME_6'='#ff00ff',
              ...)

# line plot with number of messages sent per day
WA_chat %>%
  group_by(name, date) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  ggplot(aes(x=date, y=count)) +
  geom_line(aes(color=name),
            linewidth=1, alpha=0.7) +
  scale_color_manual(values=name_colors) +
  labs(x='',
       y='messages per day',
       color='') +
  theme_cowplot() +
  theme(axis.text.x=element_text(angle=35,
                                 hjust=1))

# bar plot with total number of messages per message type
WA_chat %>%
  ggplot(aes(x=name)) +
  geom_bar(aes(fill=name)) +
  geom_text(aes(label = after_stat(count)),
            stat='count',
            vjust=1.5) +
  scale_fill_manual(values=name_colors) +
  facet_wrap(~type, ncol=4,
             scales='free') +
  labs(x='',
       y='messages',
       fill='') +
  theme_cowplot() +
  theme(axis.text.x = element_text(angle = 35,
                                   hjust = 1))

# bar plot with number of messages sent per month
WA_chat %>%
  ggplot(aes(x=name)) +
  geom_bar(aes(fill=type)) +
  geom_text(aes(label = after_stat(count)),
            stat='count',
            vjust=1.5) +
  scale_fill_manual(values=message_colors) +
  labs(x='',
       y='messages',
       fill='') +
  facet_wrap(~month_year, ncol=4) +
  theme_cowplot() +
  theme(axis.text.x=element_text(angle=35,
                                 hjust=1))

# Wilcoxon-Test to test for significant difference between number of messages sent per month
stat.test_1 = WA_chat %>%
  group_by(month_year, name) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  wilcox_test(count ~ name,
              exact=TRUE,
              p.adjust.method='fdr') %>%
  add_xy_position(x='name') %>%
  mutate(p.signif = case_when(p > 0.05 ~ 'n.s.',
                              p <= 0.05 & p >= 0.01 ~ '*',
                              p < 0.01 & p >= 0.001 ~ '**',
                              p < 0.001 ~ '***'))

# box plot with number of messages sent per month (with result of Wilcoxon-Test)
WA_chat %>%
  group_by(month_year, name) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  ggplot(aes(x=name, y=count)) +
  geom_boxplot(aes(fill=name)) +
  scale_fill_manual(values=name_colors) +
  stat_pvalue_manual(stat.test_1) +
  labs(x='',
       y='messages per month',
       fill='') +
  theme_cowplot() +
  theme(axis.text.x=element_text(angle=35,
                                 hjust=1))

# bar plot with number of characters (summarised across all text messages) sent per month
WA_chat %>%
  filter(type=='text') %>%
  group_by(month_year, name) %>%
  summarise(characters_sum = sum(characters)) %>%
  ungroup() %>%
  ggplot(aes(x=name, y=characters_sum)) +
  geom_bar(aes(fill=name),
           position='dodge',
           stat='identity') +
  geom_text(aes(label=characters_sum),
            vjust=1.5) +
  scale_fill_manual(values=name_colors) +
  labs(x='',
       y='characters',
       fill='') +
  facet_wrap(~month_year, ncol=4) +
  theme_cowplot() +
  theme(axis.text.x=element_text(angle=35, hjust=1))

# Wilcoxon-Test to test for significant difference between number of characters sent per month
stat.test_2 = WA_chat %>%
  filter(type=='text') %>%
  wilcox_test(characters ~ name,
              exact=TRUE,
              p.adjust.method='fdr') %>%
  add_xy_position(x='name') %>%
  mutate(p.signif = case_when(p > 0.05 ~ 'n.s.',
                              p <= 0.05 & p >= 0.01 ~ '*',
                              p < 0.01 & p >= 0.001 ~ '**',
                              p < 0.001 ~ '***'))

# box plot with number of characters sent per month (with result of Wilcoxon-Test)
WA_chat %>%
  filter(type=='text') %>%
  ggplot(aes(x=name, y=characters)) +
  geom_boxplot(aes(fill=name)) +
  scale_fill_manual(values=name_colors) +
  #scale_y_continuous(limits=c(0,350)) +
  stat_pvalue_manual(stat.test_2) +
  labs(x='',
       y='characters per text message',
       fill='') +
  theme_cowplot() +
  theme(axis.text.x=element_text(angle=35,
                                 hjust=1))

# horizontal bar plot with total number of characters per person (sorted descendingly)
WA_chat %>%
  filter(type=='text') %>%
  group_by(name) %>%
  summarise(characters_sum = sum(characters)) %>%
  ungroup() %>%
  arrange(characters_sum) %>%
  mutate(name = factor(name, unique(name))) %>%
  ggplot(aes(x=name, y=characters_sum)) +
  geom_bar(aes(fill=name),
           position='dodge',
           stat='identity') +
  geom_text(aes(label=characters_sum),
            hjust=1.5) +
  coord_flip() +
  scale_fill_manual(values=name_colors) +
  guides(fill='none') +
  labs(x='',
       y='characters',
       fill='') +
  theme_cowplot() +
  theme(axis.text.x=element_text(angle=35, hjust=1))
