# Prepare needed packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,readr,tidyr,lubridate,ggplot2)

# Load packages
library(tidyverse)
library(readr)
library(tidyr)
library(lubridate)
library(ggplot2)

# Import data
cvrs <- paste("https://raw.githubusercontent.com/CSSEGISandData/",
              "COVID-19/master/csse_covid_19_data/",
              "csse_covid_19_time_series/",
              "time_series_covid19_confirmed_global.csv", sep="")
cvrs_df <- read_csv(cvrs)

# Explore data

# first 6 rows of the data
head(cvrs_df)

# dimensions, datatypes, sample of the data
glimpse(cvrs_df)

# daily average cases per province
summary(cvrs_df)

# NOTE: No correlation matrix or proportion tables needed in exploratory data analysis  
# as in this case we are dealing with the same variable over time.

# Restructure dataset

# Vector is province, country_region, Lat, Long
# Date columns moved under a single column
# Associated values as cumulative_cases
# Filter to China
# Group by the province, country_region, and Date to summarise cumulative infections up to a given date
# Take one lagged difference to get the number of new cases each day

# China
cvrs_china <- cvrs_df %>% 
  rename(province = "Province/State", country_region = "Country/Region")%>%
  pivot_longer(-c(province, country_region, Lat, Long), names_to = "Date", values_to = "cumulative_cases") %>%
  filter(country_region == 'China') %>%
  group_by(province, country_region, Date) %>%
  summarise(cumulative_cases = sum(cumulative_cases)) %>%
  mutate(Date = mdy(Date) - days(1),  new_cases = c(0, diff(cumulative_cases))) %>%
  arrange(country_region, Date)

# Visualize the data

# Cumulative cases by provinces over time
cvrs_china %>% 
  filter(Date > '2020-02-10') %>%
  ggplot(aes(x = Date, y = cumulative_cases, col = province))+
  labs(title = "China")+
  geom_line(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90))
ggsave("cn_cum.png")
# Curve cannot go downward as we are tracking cumulative cases, and appears to be flattening, which is good.

# New cases by provinces over time
cvrs_china %>% 
  filter(Date > '2020-02-10') %>%
  ggplot(aes(x = Date, y = new_cases, col = province))+
  labs(title = "China")+
  geom_line(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90))
ggsave("cn_new.png")

# New cases for Hubei (province of Wuhan)
cvrs_china %>% 
  filter(Date > '2020-02-10' & province == 'Hubei') %>%
  ggplot(aes(x = Date, y = new_cases, col = province, fill = province))+
  labs(title = "Hubei")+
  geom_bar(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90))
ggsave("cn_new_hubei.png")
# Three spikes followed by a consistent drop, which is good.

#==================================================================

# USA

cvrs_usa <- cvrs_df %>% 
  rename(province = "Province/State", country_region = "Country/Region")%>%
  pivot_longer(-c(province, country_region, Lat, Long), names_to = "Date", values_to = "cumulative_cases") %>%
  filter(country_region == 'US') %>%
  group_by(province, country_region, Date) %>%
  summarise(cumulative_cases = sum(cumulative_cases)) %>%
  mutate(Date = mdy(Date) - days(1),  new_cases = c(0, diff(cumulative_cases))) %>%
  arrange(country_region, Date)

# Cumulative cases
cvrs_usa %>% 
  filter(Date > '2020-03-10') %>%
  ggplot(aes(x = Date, y = cumulative_cases))+
  labs(title = "USA")+
  geom_line(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90))
ggsave("us_cum.png")

# New cases line
cvrs_usa %>% 
  filter(Date > '2020-03-10') %>%
  ggplot(aes(x = Date, y = new_cases))+
  labs(title = "USA")+
  geom_line(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90))
ggsave("us_new.png")

# New cases bar
cvrs_usa %>% 
  filter(Date > '2020-03-10') %>%
  ggplot(aes(x = Date, y = new_cases))+
  labs(title = "USA")+
  geom_bar(stat = 'identity')+
  theme(axis.text.x = element_text(angle = 90))
ggsave("us_new2.png")
