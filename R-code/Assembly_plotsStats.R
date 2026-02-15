library(tidyverse)
library(jsonlite)
library(patchwork)
library(viridis)




# Load 
bins_stats <- read_tsv("metawgs_metaflye/stats_binning/bins_general_stats_mqc.tsv")
abundances <- read_tsv("metawgs_metaflye/stats_binning/genomes_abundances_mqc.tsv")
checkm_json_text <- readLines("metawgs_metaflye/stats_binning/genomes_checkm_mqc.json", warn = FALSE) %>%
  paste(collapse = "\n") %>%
  gsub("NaN", "null", .)
checkm_data <- fromJSON(checkm_json_text)
#  data frame 
checkm_df <- checkm_data$data %>% as.data.frame()


# Plot 1: Completeness vs Contamination 

p1 <- ggplot(checkm_df, aes(x = Contamination, y = Completeness)) +
  geom_point(aes(size = `Genome Size`, color = Completeness), alpha = 0.7) +
  geom_hline(yintercept = 90, linetype = "dashed", color = "green", alpha = 0.5) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "orange", alpha = 0.5) +
  geom_vline(xintercept = 5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_vline(xintercept = 10, linetype = "dashed", color = "orange", alpha = 0.5) +
  scale_color_viridis(option = "plasma") +
  labs(
    title = "Bin Quality Assessment",
    subtitle = "High-quality MAGs: >90% complete, <5% contamination",
    x = "Contamination (%)",
    y = "Completeness (%)",
    size = "Genome Size (Mb)"
  ) +
  theme_minimal() +
  theme(legend.position = "right")

#  Plot 2: Community Composition 

abundances_long <- abundances %>%
  pivot_longer(-1, names_to = "Sample", values_to = "Abundance") %>%
  rename(Genome = 1)

p2 <- ggplot(abundances_long, aes(x = Sample, y = Abundance, fill = Genome)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_viridis(discrete = TRUE, option = "turbo") +
  labs(
    title = "Community Composition Across Samples",
    x = "Sample",
    y = "Relative Abundance",
    fill = "Genome"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )

# Plot 3: Bin Statistics Overview

p3a <- ggplot(bins_stats, aes(x = reorder(Sample, -`Total length`), y = `Total length`/1e6)) +
  geom_col(fill = "steelblue") +
  labs(title = "Bin Sizes", x = "", y = "Size (Mb)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p3b <- ggplot(bins_stats, aes(x = reorder(Sample, -N50), y = N50/1000)) +
  geom_col(fill = "coral") +
  labs(title = "Bin N50", x = "", y = "N50 (kb)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p3c <- ggplot(bins_stats, aes(x = reorder(Sample, -`GC (%)`), y = `GC (%)`)) +
  geom_col(fill = "darkgreen") +
  labs(title = "GC Content", x = "Bin", y = "GC (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p3d <- ggplot(bins_stats, aes(x = `# contigs`)) +
  geom_histogram(bins = 30, fill = "purple", alpha = 0.7) +
  labs(title = "Contigs per Bin", x = "Number of Contigs", y = "Count") +
  theme_minimal()

p3 <- (p3a | p3b) / (p3c | p3d) +
  plot_annotation(title = "Bin Statistics Overview")

# Plot 4: Abundance Heatmap

abundance_matrix <- abundances %>%
  column_to_rownames(var = colnames(.)[1]) %>%
  as.matrix()

p4 <- abundances_long %>%
  ggplot(aes(x = Sample, y = Genome, fill = Abundance)) +
  geom_tile() +
  scale_fill_viridis(option = "magma") +
  labs(
    title = "Genome Abundance Heatmap",
    x = "Sample",
    y = "Genome",
    fill = "Abundance"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 8)
  )

 
 
print(p1)
print(p2)
print(p3)
print(p4)

# Save plots
ggsave("bin_quality.png", p1, width = 10, height = 7, dpi = 300)
ggsave("community_composition.png", p2, width = 12, height = 7, dpi = 300)
ggsave("bin_statistics.png", p3, width = 12, height = 10, dpi = 300)
ggsave("abundance_heatmap.png", p4, width = 10, height = 8, dpi = 300)

# statistics


cat("\nBin Quality Categories:\n")
checkm_df %>%
  mutate(
    Quality = case_when(
      Completeness >= 90 & Contamination < 5 ~ "High-quality",
      Completeness >= 50 & Contamination < 10 ~ "Medium-quality",
      TRUE ~ "Low-quality"
    )
  ) %>%
  count(Quality) %>%
  print()

cat("\nTotal number of bins:", nrow(bins_stats), "\n")
cat("Total number of samples:", ncol(abundances) - 1, "\n")
cat("Mean bin size (Mb):", mean(bins_stats$`Total length`/1e6, na.rm = TRUE) %>% round(2), "\n")
cat("Mean N50 (kb):", mean(bins_stats$N50/1000, na.rm = TRUE) %>% round(2), "\n")