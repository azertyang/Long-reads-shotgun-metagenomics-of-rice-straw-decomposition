library(dplyr)
library(ggplot2)
library(stringr)

#load data
df <- read_tsv("magflow/newrice_treatment/final_df_final.tsv")
 
df_mag <- df %>% 
  select(sample, Bin, Dataset, Completeness, Contamination, Genome_Size) %>%
  mutate(Binner = case_when(
    str_detect(sample, "meta") ~ "MetaWGS",
    str_detect(sample, "Hifi") ~ "HiFi-MAG",
    TRUE ~ "Other"
  )) %>%
  filter(Binner %in% c("MetaWGS", "HiFi-MAG"))

# Summary statistics
summary_stats <- df_mag %>%
  group_by(Binner) %>%
  summarise(
    n_bins = n(),
    mean_completeness = mean(Completeness, na.rm = TRUE),
    sd_completeness   = sd(Completeness, na.rm = TRUE),
    mean_contamination = mean(Contamination, na.rm = TRUE),
    sd_contamination   = sd(Contamination, na.rm = TRUE),
    mean_genome_size = mean(Genome_Size, na.rm = TRUE)
  )

print(summary_stats)

# scatter plot: completeness vs contamination
ggplot(df_mag, aes(x = Contamination, y = Completeness, color = Binner, size = Genome_Size)) +
  geom_point(alpha = 0.7) +
  scale_color_manual(values = c("MetaWGS" = "blue", "HiFi-MAG" = "red")) +
  labs(
    x = "Contamination (%)",
    y = "Completeness (%)",
    color = "Pipeline",
    size = "Genome size (Mbp)",
    title = "MAG Quality Comparison: MetaWGS vs HiFi-MAG"
  ) +
  theme_bw()

# MAG quality
df_mag <- df_mag %>%
  mutate(Quality = case_when(
    Completeness >= 90 & Contamination < 5  ~ "High",
    Completeness >= 50 & Contamination < 10 ~ "Medium",
    TRUE ~ "Low"
  ))

# bar plot: MAG quality distribution
ggplot(df_mag, aes(x = Binner, fill = Quality)) +
  geom_bar(position = "fill") +
  labs(y = "Proportion of bins", title = "MAG Quality Distribution by Pipeline") +
  scale_fill_manual(values = c("High" = "green", "Medium" = "orange", "Low" = "red")) +
  theme_bw()

# wilcoxon tests
wilcox.test(Completeness ~ Binner, data = df_mag)
wilcox.test(Contamination ~ Binner, data = df_mag)

summary_stats <- df_mag %>%
  group_by(Binner) %>%
  summarise(
    n_bins = n(),
    mean_completeness = round(mean(Completeness, na.rm = TRUE), 1),
    sd_completeness = round(sd(Completeness, na.rm = TRUE), 1),
    mean_contamination = round(mean(Contamination, na.rm = TRUE), 2),
    sd_contamination = round(sd(Contamination, na.rm = TRUE), 2)
  )

summary_stats


df_summary <- df_mag %>%  
  group_by(Binner) %>%
  summarise(
    n_bins = n(),
    mean_completeness = round(mean(Completeness, na.rm = TRUE), 1),
    sd_completeness = round(sd(Completeness, na.rm = TRUE), 1),
    mean_contamination = round(mean(Contamination, na.rm = TRUE), 2),
    sd_contamination = round(sd(Contamination, na.rm = TRUE), 2)
  ) %>%
  arrange(Binner)

df_summary

