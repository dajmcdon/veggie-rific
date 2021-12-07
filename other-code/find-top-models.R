theme_set(theme_bw())
library(lubridate)
url_hosp <- "https://forecast-eval.s3.us-east-2.amazonaws.com/score_cards_state_hospitalizations.rds"
download.file(url_hosp, here::here("eval_hospitalizations.rds")) # download to disk

hub <- readRDS("eval_hospitalizations.rds") %>%
  select(ahead:forecast_date, target_end_date,
         actual, wis, ae, cov_80, value_50) %>%
  mutate(forecast_date = target_end_date - days(ahead))

baseline <- hub %>% filter(forecaster == "COVIDhub-baseline") %>%
  select(target_end_date, ahead, geo_value, wis, ae) %>%
  rename(baseline_wis = wis, baseline_ae = ae)
for (i in 0:6) {
  vname <- paste0("ahead_", i)
  baseline <- baseline %>% mutate(!!vname := ahead - i)
}
baseline <- baseline %>%
  select(-ahead) %>%
  pivot_longer(starts_with("ahead_"), names_to = "a", values_to = "ahead") %>%
  select(-a) %>%
  filter(ahead > 0) %>%
  mutate(forecast_date = target_end_date - ahead)


hub <- left_join(
  hub %>% filter(forecaster != "COVIDhub-baseline"),
  baseline)

Mean <- function(x) mean(x, na.rm = TRUE)
GeoMean <- function(x) exp(Mean(log(x)))

summaries <- hub %>% group_by(forecaster, ahead) %>%
  summarise(MeanWis = Mean(wis) / Mean(baseline_wis),
            GeoWis = GeoMean(wis+1) / GeoMean(baseline_wis+1),
            n = n())

summaries %>%
  ggplot(aes(ahead, MeanWis, color = forecaster)) +
  geom_line() +
  geom_hline(yintercept = 1, size = 1.5) +
  scale_color_viridis_d() +
  theme(legend.position = "bottom")

library(plotly)
ggplotly()

# top models appear to be
top <- c("COVIDhub-ensemble", "USC-SI_kJalpha", "MOBS-GLEAM_COVID", "Karlen-pypm",
  "JHUAPL-SLPHospEns")
