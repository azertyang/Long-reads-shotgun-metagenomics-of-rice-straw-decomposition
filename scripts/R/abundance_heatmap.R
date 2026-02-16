library(tidyverse)
library(jsonlite)
library(patchwork)
library(viridis)
library(purrr)

#load data
load_checkm_data <- function(dir_path, assembler_name) {
  json_path <- file.path(dir_path, "stats_binning/genomes_checkm_mqc.json")
  
  
  checkm_json_text <- readLines(json_path, warn = FALSE) %>%
    paste(collapse = "\n") %>%
    gsub("NaN", "null", .)
  
  checkm_data <- fromJSON(checkm_json_text)
  
  checkm_df <- map_dfr(names(checkm_data$data), function(bin_name) {
    bin_data <- checkm_data$data[[bin_name]]
    tibble(
      Bin = bin_name,
      Completeness = ifelse(is.null(bin_data$x), NA, bin_data$x),
      Contamination = ifelse(is.null(bin_data$y), NA, bin_data$y),
      Color = bin_data$color,
      Assembler = assembler_name
    )
  }) %>%
    filter(!is.na(Completeness)) 
  
  return(checkm_df)
}

#load data 
load_abundance_data <- function(dir_path, assembler_name) {
  abundance_path <- file.path(dir_path, "stats_binning/genomes_abundances_mqc.tsv")
  
  abundances <- read_tsv(abundance_path, comment = "#", show_col_types = FALSE) %>%
    mutate(Assembler = assembler_name)
  
  return(abundances)
}

# Load data 
metaflye_dir <- "metawgs_metaflye"
hifiasm_dir <- "metawgs_hifiasm"


checkm_metaflye <- load_checkm_data(metaflye_dir, "metaFlye")
checkm_hifiasm <- load_checkm_data(hifiasm_dir, "hifiasm-meta")

# Combine
checkm_combined <- bind_rows(checkm_metaflye, checkm_hifiasm)

# Load abundance data 
tryCatch({
  abundance_metaflye <- load_abundance_data(metaflye_dir, "metaFlye")
  abundance_hifiasm <- load_abundance_data(hifiasm_dir, "hifiasm-meta")
  abundance_combined <- bind_rows(abundance_metaflye, abundance_hifiasm)
}, error = function(e) {
  message("Could not load abundance data: ", e$message)
  abundance_combined <- NULL
})

# Side-by-side quality comparison

p1 <- ggplot(checkm_combined, aes(x = Completeness, y = Contamination, color = Assembler)) +
  geom_point(size = 5, alpha = 0.8) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_hline(yintercept = 10, linetype = "dashed", color = "orange", alpha = 0.5) +
  geom_vline(xintercept = 90, linetype = "dashed", color = "green", alpha = 0.5) +
  geom_vline(xintercept = 50, linetype = "dashed", color = "orange", alpha = 0.5) +
  scale_color_manual(values = c("metaFlye" = "#8B263E", "hifiasm-meta" = "#aab23d")) +
  labs(
    title = "Bin Quality Comparison: metaFlye vs hifiasm-meta",
    subtitle = "High-quality: >90% complete, <5% contamination | Medium: >50% complete, <10% contamination",
    x = "Completeness (%)",
    y = "Contamination (%)",
    size=5
  ) +
  theme_minimal() +
  theme(legend.position = "top")
print(p1)


#quality plots 

p2 <- ggplot(checkm_combined, aes(x = Completeness, y = Contamination)) +
  geom_point(aes(color = Completeness), size = 3, alpha = 0.7) +
  geom_text(aes(label = Bin), size = 3, hjust = -0.1, vjust = 0.7, check_overlap = TRUE) +
  geom_hline(yintercept = 5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_hline(yintercept = 10, linetype = "dashed", color = "orange", alpha = 0.5) +
  geom_vline(xintercept = 90, linetype = "dashed", color = "green", alpha = 0.5) +
  geom_vline(xintercept = 50, linetype = "dashed", color = "orange", alpha = 0.5) +
  scale_color_viridis(option = "plasma") +
  facet_wrap(~Assembler, ncol = 2) +
  labs(
    title = "Bin Quality by Assembler",
    x = "Completeness (%)",
    y = "Contamination (%)",
    color = "Completeness (%)"
  ) +
  theme_minimal() +
  theme(legend.position = "right")
print(p2)

#  statistics comparison

quality_summary <- checkm_combined %>%
  mutate(
    Quality = case_when(
      Completeness >= 90 & Contamination < 5 ~ "High-quality",
      Completeness >= 50 & Contamination < 10 ~ "Medium-quality",
      TRUE ~ "Low-quality"
    )
  ) %>%
  group_by(Assembler, Quality) %>%
  summarise(Count = n(), .groups = "drop")

p3 <- ggplot(quality_summary, aes(x = Assembler, y = Count, fill = Quality)) + geom_col(position = "dodge") + geom_text(aes(label = Count), position = position_dodge(width = 0.9), vjust = -0.5, size =5) + scale_fill_manual( values = c("High-quality" = "#2F4156", "Medium-quality" = "#B59E7D", "Low-quality" = "#C8D9E6"), limits = c("High-quality", "Medium-quality", "Low-quality") ) + labs( title = "Bin Quality Distribution by Assembler", x = "Assembler", y = "Number of Bins", fill = "Quality Category" ) + theme_minimal() + theme(legend.position = "top")
print(p3)


# Box plots: completeness and contamination

big_text_theme <- theme_minimal(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text.x  = element_text(size = 14),
    axis.text.y  = element_text(size = 14)
  )

p4a <- ggplot(checkm_combined, aes(x = Assembler, y = Completeness, fill = Assembler)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  scale_fill_manual(values = c("metaflye" = "#B59E7D", "hifiasm-meta" = "#2F4156")) +
  labs(title = "Completeness Distribution", y = "Completeness (%)") +
  big_text_theme +
  theme_minimal() +
  theme(legend.position = "none")

p4b <- ggplot(checkm_combined, aes(x = Assembler, y = Contamination, fill = Assembler)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  scale_fill_manual(values = c("metaflye" = "#B59E7D", "hifiasm-meta" = "#2F4156")) +
  labs(title = "Contamination Distribution", y = "Contamination (%)") +
  big_text_theme +
  theme_minimal() +
  theme(legend.position = "none")

p4 <- p4a | p4b
print(p4)

# summary assembler stats



cat("Total bins per assembler:\n")
checkm_combined %>%
  count(Assembler) %>%
  print()

cat("\n\nQuality distribution:\n")
print(quality_summary)

cat("\n\nCompleteness statistics:\n")
checkm_combined %>%
  group_by(Assembler) %>%
  summarise(
    Mean = mean(Completeness),
    Median = median(Completeness),
    SD = sd(Completeness),
    Min = min(Completeness),
    Max = max(Completeness)
  ) %>%
  print()

cat("\n\nContamination statistics:\n")
checkm_combined %>%
  group_by(Assembler) %>%
  summarise(
    Mean = mean(Contamination),
    Median = median(Contamination),
    SD = sd(Contamination),
    Min = min(Contamination),
    Max = max(Contamination)
  ) %>%
  print()

# Statistical tests
cat("\n\nWilcoxon test for Completeness difference:\n")
wilcox_completeness <- wilcox.test(
  Completeness ~ Assembler, 
  data = checkm_combined
)
print(wilcox_completeness)

cat("\nWilcoxon test for Contamination difference:\n")
wilcox_contamination <- wilcox.test(
  Contamination ~ Assembler, 
  data = checkm_combined
)
print(wilcox_contamination)



print(p1)
print(p2)
print(p3)
print(p4)

# Save plots
ggsave("comparison_quality_overlay_bleu.png", p1, width = 10, height = 7, dpi = 300)
ggsave("comparison_quality_faceted_bleu.png", p2, width = 14, height = 7, dpi = 300)
ggsave("comparison_quality_counts_bleu.png", p3, width = 8, height = 6, dpi = 300)
ggsave("comparison_distributions_bleu.png", p4, width = 12, height = 6, dpi = 300)

cat("\n\nPlots saved successfully!\n")
cat("- comparison_quality_overlay.png: Side-by-side quality comparison\n")
cat("- comparison_quality_faceted.png: Separate panels with bin labels\n")
cat("- comparison_quality_counts.png: Bar chart of quality categories\n")
cat("- comparison_distributions.png: Box plots of completeness and contamination\n")

# color and aestitics changes: 

quality_summary <- checkm_combined %>%
  mutate(
    Quality = case_when(
      Completeness >= 90 & Contamination < 5 ~ "High-quality",
      Completeness >= 50 & Contamination < 10 ~ "Medium-quality",
      TRUE ~ "Low-quality"
    )
  ) %>%
  group_by(Assembler, Quality) %>%
  summarise(Count = n(), .groups = "drop") %>%
  group_by(Assembler) %>%
  mutate(
    Total = sum(Count),
    Percent = round(Count / Total * 100, 1)
  ) %>%
  ungroup()
quality_summary$Quality <- factor(
  quality_summary$Quality,
  levels = c("High-quality", "Medium-quality", "Low-quality")
)
library(ggplot2)

p3 <- ggplot(quality_summary, aes(x = Assembler, y = Count, fill = Quality)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = paste0(Count)),
            position = position_dodge(width = 0.8),
            vjust = -0.2,
            size = 4.5) +
  scale_fill_manual(
    values = c(
      "High-quality" = "#2F4156",
      "Medium-quality" = "#B59E7D",
      "Low-quality" = "#C8D9E6"
    ),
    limits = c("High-quality", "Medium-quality", "Low-quality")
  ) +
  labs(
    title = "Bin Quality Distribution by Assembler",
    x = "Assembler",
    y = "Number of Bins",
    fill = "Quality Category"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p3)


p2 <- ggplot(checkm_combined, aes(x = Completeness, y = Contamination)) +
  geom_point(aes(color = Completeness), size = 3, alpha = 0.8) +
  geom_text(aes(label = Bin), size = 2.8, check_overlap = TRUE, hjust = 0.5, vjust = -0.55) +
 
  geom_hline(yintercept = 5, linetype = "dashed", color = "#E63946", alpha = 0.7) +   # High-quality contamination
  geom_hline(yintercept = 10, linetype = "dashed", color = "#F4A261", alpha = 0.7) +  # Medium-quality contamination
  geom_vline(xintercept = 90, linetype = "dashed", color = "#2A9D8F", alpha = 0.7) +  # High-quality completeness
  geom_vline(xintercept = 50, linetype = "dashed", color = "#F4A261", alpha = 0.7) +  # Medium-quality completeness
   
  scale_color_viridis(option = "plasma", direction = -1, name = "Completeness (%)") +
   
  facet_wrap(~Assembler, ncol = 2, scales = "free") +
   
  labs(
    title = "Bin Quality by Assembler",
    subtitle = "Completeness vs Contamination for all bins; dashed lines indicate quality thresholds",
    x = "Completeness (%)",
    y = "Contamination (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "right",
    strip.text = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 11),
    axis.title = element_text(size = 12),
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 12)
  )


ggsave("bin_quality_scatter.png", p2, width = 10, height = 7, dpi = 300)

print(p2)

