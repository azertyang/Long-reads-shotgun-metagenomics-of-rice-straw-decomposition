library(tidyverse)

#load data
df <- read_tsv("magflow/old_rice_treatment/final_df.tsv")
df <- df %>%
  mutate(
    Completeness = as.numeric(Completeness),
    Contamination = as.numeric(Contamination),
    N50 = as.numeric(N50),
    Genome_Size = as.numeric(Genome_Size)
  )
a <- ggplot(df, aes(x = Contamination, y = Completeness, color = sample)) +
  geom_point(size = 3) +
  facet_wrap(~ sample) +
  theme_bw() +
  labs(
    title = "Bin quality comparison",
    x = "Contamination (%)",
    y = "Completeness (%)"
  )
busco_long <- df %>%
  select(sample, Bin, Complete, Fragmented, Missing, Duplicated) %>%
  pivot_longer(
    cols = c(Complete, Fragmented, Missing, Duplicated),
    names_to = "category",
    values_to = "percent"
  )

# Plot 1 completness 
b <- ggplot(busco_long, aes(x = Bin, y = percent, fill = category)) +
  geom_col() +
  facet_wrap(~ sample, scales = "free_x") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(
    title = "Bin completeness composition",
    y = "Percentage"
  )


# Plot 2 N50 boxplot
c <- ggplot(df, aes(x = sample, y = N50)) +
  geom_boxplot() +
  geom_jitter(width = 0.2) +
  theme_bw() +
  labs(title = "N50 distribution across samples")
print(d)
#Plot 3 Bin quality
d <- ggplot(df, aes(x = `# contigs`, y = Completeness, color = sample)) +
  geom_point(size = 3) +
  theme_bw()
ggsave("semi_old_trea_boxplot_bin_qual.png", a, width = 7, height = 5, dpi = 300)
ggsave("semi_old_treat_scatter_bin_quality_by_sample.png", b, width = 8, height = 6, dpi = 300)
ggsave("semi_old_trea_scatter_bin_quality_allinOne.png", c, width = 6, height = 5, dpi = 300)
#ggsave("newrice__notreatment_n50_boxplot.png", p4, width = 6, height = 5, dpi = 300)

df2 <- df %>%
  mutate(
    quality = case_when(
      Completeness >= 90 & Contamination <= 5 ~ "High-quality",
      Completeness >= 50 & Contamination <= 10 ~ "Medium-quality",
      TRUE ~ "Low-quality"
    )
  )

# Plot 4:  bin quality %
ggplot(df2, aes(x = sample, fill = quality)) +
  geom_bar(position = "fill") +
  theme_bw() +
  labs(y = "Proportion of bins", title = "MAG quality per sample")




df <- df %>%
  mutate(
    binner = case_when(
      str_detect(sample, "SemiBin2") ~ "SemiBin2",
      str_detect(sample, "lorbin")  ~ "lorbin",
      TRUE                           ~ NA_character_
    )
  ) %>%
  filter(!is.na(binner))

# plot 5 : Completeness vs Contamination 
ggplot(df, aes(x = Contamination, y = Completeness, color = binner)) +
  geom_point(alpha = 0.6, size = 3) +
  theme_bw() +
  labs(
    title = "Bin quality by binner",
    x = "Contamination (%)",
    y = "Completeness (%)"
  )
# Plot 6: same then 5 sample specific
ggplot(df, aes(x = Contamination, y = Completeness, color = binner)) +
  geom_point(alpha = 0.7, size = 3) +
  facet_wrap(~ sample) +
  theme_bw()


df <- df %>%
  mutate(
    mag_quality = case_when(
      Completeness >= 90 & Contamination <= 5  ~ "High-quality",
      Completeness >= 50 & Contamination <= 10 ~ "Medium-quality",
      TRUE                                     ~ "Low-quality"
    )
  )



 
 
library(viridis)

 
df <- df %>%
  mutate(
    binner = case_when(
      str_detect(sample, "SemiBin2") ~ "SemiBin2",
      str_detect(sample, "lorbin")  ~ "lorbin",
      TRUE                           ~ NA_character_
    )
  ) %>%
  filter(!is.na(binner)) %>%
  mutate(binner = factor(binner, levels = c("SemiBin2", "lorbin")))

# Plot 7 Scatter plot- completeness vs contamination   binner specific
p1 <- ggplot(df, aes(x = Contamination, y = Completeness, color = binner)) +
  geom_point(alpha = 0.7, size = 3) +
  scale_color_manual(values = c("SemiBin2" = "#2E4057", "lorbin" = "#B59E7D")) +
  theme_bw(base_size = 14) +
  labs(
    title = "Bin Quality by Binner",
    x = "Contamination (%)",
    y = "Completeness (%)",
    color = "Binner"
  ) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold")
  )

# plot 8:  scatter plot by sample
p2 <- ggplot(df, aes(x = Contamination, y = Completeness, color = binner)) +
  geom_point(alpha = 0.7, size = 2.5) +
  scale_color_manual(values = c("HifiMAG" = "#2E4057", "MetaWGS" = "#B59E7D")) +
  facet_wrap(~ sample, ncol = 2, scales = "free") +
  theme_bw(base_size = 13) +
  labs(
    title = "Bin Quality by Sample",
    x = "Contamination (%)",
    y = "Completeness (%)",
    color = "Binner"
  ) +
  theme(
    legend.position = "top",
    strip.text = element_text(face = "bold")
  )

 
df <- df %>%
  mutate(
    mag_quality = case_when(
      Completeness >= 90 & Contamination <= 5  ~ "High-quality",
      Completeness >= 50 & Contamination <= 10 ~ "Medium-quality",
      TRUE                                     ~ "Low-quality"
    ),
    mag_quality = factor(mag_quality, levels = c("High-quality", "Medium-quality", "Low-quality"))
  )

# Plot 9: Barplit mag quality
p3 <- ggplot(df, aes(x = binner, fill = mag_quality)) +
  geom_bar(position = "fill", width = 0.6) +
  scale_fill_manual(
    values = c(
      "High-quality" = "#2E4057",
      "Medium-quality" = "#B59E7D",
      "Low-quality" = "#A9CCE3"
    ),
    name = "MAG Quality"
  ) +
  theme_bw(base_size = 14) +
  labs(
    y = "Proportion of Bins",
    x = "Binner",
    title = "MAG Quality Comparison Across Binners"
  ) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold")
  )

# plot 10:  Boxplot of assembly contiguity  
p4 <- ggplot(df, aes(x = binner, y = N50, fill = binner)) +
  geom_boxplot(alpha = 0.7, width = 0.6) +
  scale_fill_manual(values = c("SemiBin2" = "#2E4057", "lorbin" = "#B59E7D")) +
  theme_bw(base_size = 14) +
  labs(
    title = "Assembly Contiguity (N50) by Binner",
    x = "Binner",
    y = "N50 (bp)",
    fill = "Binner"
  ) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold")
  )

# Save  
ggsave("semi_old_trea_scatter_bin_quality.png", p1, width = 7, height = 5, dpi = 300)
ggsave("semi_old_trea_scatter_bin_quality_by_sample.png", p2, width = 8, height = 6, dpi = 300)
ggsave("semi_old_trea_mag_quality_comparison.png", p3, width = 6, height = 5, dpi = 300)
ggsave("semi_old_trea_n50_boxplot.png", p4, width = 6, height = 5, dpi = 300)
print(p3)

