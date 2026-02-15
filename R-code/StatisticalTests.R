library(tidyverse)

#dtaa needed
df_mag <- df %>% 
  select(sample, Bin, Dataset, Completeness, Contamination, Genome_Size) %>%
  mutate(Binner = case_when(
    str_detect(sample, "Semi") ~ "SemiBin2",
    str_detect(sample, "lorbin")  ~ "LorBin",
    TRUE ~ "Other"
  )) %>%
  filter(Binner %in% c("SemiBin2", "LorBin"))
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
#contamination vs Completness + genome size
ggplot(df_mag, aes(x = Contamination, y = Completeness, color = Binner, size = Genome_Size)) +
  geom_point(alpha = 0.7) +
  scale_color_manual(values = c("SemiBin2" = "blue", "LorBin" = "red")) +
  labs(
    x = "Contamination (%)",
    y = "Completeness (%)",
    color = "Binner",
    size = "Genome size (Mbp)",
    title = "MAG Quality Comparison: SemiBin2 vs LorBin"
  ) +
  theme_bw()
df_mag <- df_mag %>%
  mutate(Quality = case_when(
    Completeness >= 90 & Contamination < 5  ~ "High",
    Completeness >= 50 & Contamination < 10 ~ "Medium",
    TRUE ~ "Low"
  ))


 

# Wilcoxon test for completeness
wilcox.test(Completeness ~ Binner, data = df_mag)

# Wilcoxon test for contamination
wilcox.test(Contamination ~ Binner, data = df_mag)

