## load libraries
library("tidyr")
library("dplyr")
library("data.table")
library("ggplot2")
library("svglite")
library("scales")
library("viridis")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/sampleshr22.removed_singletons_and_private.novel.tsv.gz"
# args[2] <- "test/data/sampleshr22.removed_singletons_and_private.novel.ALL_ANALYSIS"

## For Coverage plots ----
## load variants data
variants.df <- fread(file = args[1],
                sep = "\t", header = T,
                stringsAsFactors = F, na.strings = ".",
                select = c("CHROM","POS","REF","ALT","AF_natmx","Consequence","gnomADg_cov","project_cov"))

## replace NA for 0 in gnomadCov data
variants.df[is.na(variants.df$gnomADg_cov), "gnomADg_cov"] <- "0"

## generate variant ids
variants.df$variant_id <- paste(variants.df$CHROM, variants.df$POS, variants.df$REF, variants.df$ALT, sep = "_")

## separate SNV dataframe
SNV.df <- variants.df %>% filter(nchar(REF) == nchar(ALT))
SNV.df$var_type <- "SNV"
## convert covs to numeric
SNV.df$gnomADg_cov <- as.numeric(SNV.df$gnomADg_cov)
SNV.df$project_cov <- as.numeric(SNV.df$project_cov)

## separate indel dataframe
INDEL.df <- variants.df %>% filter(nchar(REF) != nchar(ALT))
INDEL.df$var_type <- "INDEL"

## calculate dept means for indels
INDEL.df <- INDEL.df %>% group_by(variant_id) %>% mutate(
  mean_cov_gnomad = mean(as.numeric(unlist(strsplit(gnomADg_cov, split = "&")))),
  mean_cov_project = mean(as.numeric(unlist(strsplit(project_cov, split = "&"))))
)

## replace gnomad and project cov data with means
INDEL.df$gnomADg_cov <- INDEL.df$mean_cov_gnomad
INDEL.df$project_cov <- INDEL.df$mean_cov_project
## remove mean cov before rbinding
INDEL.df <- INDEL.df %>% select(-mean_cov_gnomad, -mean_cov_project)


## Join dataframes with snv and indel info
plotable1.df <- bind_rows(SNV.df, INDEL.df)

## lets make a function to simplify SNV and INDEL separation
makeplots <- function(x, ofile){

  ## plot 2 scatter for novel y = conv in 100GMX, x = cov in gnomAD ----
  ## Add tag
  x$TAG <- ifelse(x$var_type == "SNV", "novel SNV", "novel INDEL")
  # add gnomad range of cov tag
  x$gnomAD_ranges <- ifelse( x$gnomADg_cov == 0, "no coverage", NA)
  x$gnomAD_ranges <- ifelse( x$gnomADg_cov > 0 & x$gnomADg_cov < 10, "0 - 10 X", x$gnomAD_ranges)
  x$gnomAD_ranges <- ifelse( x$gnomADg_cov >= 10 & x$gnomADg_cov < 20, "10 - 20 X", x$gnomAD_ranges)
  x$gnomAD_ranges <- ifelse( x$gnomADg_cov >= 20 & x$gnomADg_cov < 30, "20 - 30 X", x$gnomAD_ranges)
  x$gnomAD_ranges <- ifelse( x$gnomADg_cov >= 30, "> 30 X", x$gnomAD_ranges)

  # add cov comparison tag
  x$cov_comparison <- ifelse( x$gnomADg_cov == x$project_cov, "equal coverage", NA)
  x$cov_comparison <- ifelse( x$gnomADg_cov < x$project_cov, "higher cov in project", x$cov_comparison)
  x$cov_comparison <- ifelse( x$gnomADg_cov > x$project_cov, "lower cov in project", x$cov_comparison)

  # plot
  base.p <- ggplot(data = x,
                   aes( x= gnomADg_cov,
                        y=project_cov,
                        fill = gnomAD_ranges,
                        shape = cov_comparison
                   )
  ) +
    geom_point( size = 0.5,
                alpha = 0.5,
                # shape = 21,
                stroke = 0.1) +
    # scale_fill_manual(values = c("novel SNV" = "darkorange", "novel INDEL" = "#53687E") ) +
    scale_shape_manual(values = c("equal coverage" = 20, "higher cov in project" = 24 , "lower cov in project" = 21) ) +
    ggtitle(label = "NGS Coverage comparison in Novel variants between 100GMX and gnomAD") +
    scale_x_continuous( name = "Coverage in gnomAD", limits = c(0,1e4), breaks = seq(0,110,by = 5)) +
    scale_y_continuous( name = "Coverage in 100GMX", limits = c(0,1e4), breaks = seq(0,110,by = 5)) +
    coord_cartesian(xlim = c(0,110), ylim = c(0,110)) +
    theme_classic()

  ## give format to theme
  zoom.p <- base.p +
    theme(legend.title = element_blank(),
          legend.position = "none",
          plot.title = element_blank(),
          axis.title = element_text(size = 5),
          axis.text = element_text(size=3)
    )

  ocovfilename <- paste0(ofile,"Cov_comparisson.svg")
  ggsave(filename = ocovfilename, plot = zoom.p, device = "svg", width = 9, height = 9 , units = "cm", dpi = 300)
  ## another one for legend extraction
  # ocovlegendfilename <- paste0(ofile,"Cov_comparisson_for_legend.svg")
  # ggsave(filename = ocovlegendfilename, plot = base.p, device = "svg", width = 10.8, height = 7.2 , units = "cm", dpi = 300)

  ## create a barplot datframe
  bar.df <- x %>% group_by(gnomAD_ranges) %>% summarize( total_variants = n() )
  ## reorder levels
  bar.df$gnomAD_ranges <- factor( bar.df$gnomAD_ranges, levels = c("no coverage", "0 - 10 X", "10 - 20 X", "20 - 30 X", "> 30 X") )
  ## calculate fraction of variants
  bar.df$fraction <- round(bar.df$total_variants / sum(bar.df$total_variants), digits = 4)
  ## make plot
  bar.p <- ggplot(data=bar.df, aes(x=gnomAD_ranges, y= fraction)) +
    geom_bar(stat="identity", fill="steelblue")+
    geom_text(aes(label=fraction), vjust=-0.3, size=3.5) +
    scale_y_continuous(limits = c(0,1)) +
    theme_bw() +
    theme(axis.text.x = element_text(size = 5))

  # save bar plot
  barfilename <- paste0(ofile,"bar_ranges.svg")
  ggsave(filename = barfilename, plot = bar.p, device = "svg", width = 9, height = 9 , units = "cm", dpi = 300)

}

## plot all variants
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.01type_ALL.fullset\\.")
makeplots(plotable1.df, output_name)

#low freq cutoff
plotable1_low.df <- plotable1.df %>% filter(AF_natmx < 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.02type_ALL.low_freq\\.")
makeplots(plotable1_low.df, output_name)

#common freq cutoff
plotable1_common.df <- plotable1.df %>% filter(AF_natmx >= 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.03type_ALL.common_freq\\.")
makeplots(plotable1_common.df, output_name)

## plot SNV variants
plotable2.df <- plotable1.df %>% filter(var_type == "SNV")
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.04type_SNV.fullset\\.")
makeplots(plotable2.df, output_name)

#low freq cutoff
plotable2_low.df <- plotable2.df %>% filter(AF_natmx < 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.05type_SNV.low_freq\\.")
makeplots(plotable2_low.df, output_name)

#common freq cutoff
plotable2_common.df <- plotable2.df %>% filter(AF_natmx >= 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.06type_SNV.common_freq\\.")
makeplots(plotable2_common.df, output_name)

## plot INDEL variants
plotable3.df <- plotable1.df %>% filter(var_type == "INDEL")
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.07type_INDEL.fullset\\.")
makeplots(plotable3.df, output_name)

#low freq cutoff
plotable3_low.df <- plotable3.df %>% filter(AF_natmx < 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.08type_INDEL.low_freq\\.")
makeplots(plotable3_low.df, output_name)

#common freq cutoff
plotable3_common.df <- plotable3.df %>% filter(AF_natmx >= 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.09type_INDEL.common_freq\\.")
makeplots(plotable3_common.df, output_name)

## clear everything but plotable1 data frame ----
rm(list=setdiff(ls(), c("plotable1.df","args") ))

## For consequence plots and tables ----
tag_table <- "Category_tagging.tsv" ## a tsv for relating specific and general VEP consequences

consequence_summarizer <- function( base.df, tag_file, o_file_prefix ) {

  base.df <- base.df %>% select("Consequence")

  ## read consequence cataloguer reference
  consequence_cataloguer.df <- read.table(file = tag_file,
                                          header = T,
                                          sep = "\t",
                                          stringsAsFactors = F)

  ## count consequences
  consequences.df <- base.df %>%
    group_by(Consequence) %>%
    summarise(number_of_variants = n())

  ## tag consequences
  consequences.df <- merge(x = consequences.df,
                           y = consequence_cataloguer.df,
                           by = "Consequence", all = T)

  ## save dataframe
  write.table(x = consequences.df,
              file = paste0(o_file_prefix,"all_VEP_consequences.tsv"),
              append = F, quote = F, sep = "\t",
              row.names = F, col.names = T)

  ## summarize by First specific consequence
  consequences.df <- consequences.df %>%
    group_by(Type, First_specific_consequence) %>%
    summarize(total_variants = sum(number_of_variants, na.rm = T))

  ## save dataframe
  write.table(x = consequences.df,
              file = paste0(o_file_prefix,"summarized_VEP_consequences.tsv"),
              append = F, quote = F, sep = "\t",
              row.names = F, col.names = T)

  ## remove complex consequences seen with low ocurrences
  consequences.df <- consequences.df %>%
    filter(First_specific_consequence != "Coding sequence") %>%
    filter(First_specific_consequence != "Protein altering") %>%
    filter(First_specific_consequence != "Mature miRNA")

  ## reorder levels for easy plotting
  consequences.df$First_specific_consequence <- factor(consequences.df$First_specific_consequence,
                                                       levels = c("Intron",
                                                                  "Intergenic",
                                                                  "Upstream gene variant",
                                                                  "Downstream gene",
                                                                  "Regulatory region",
                                                                  "3 prime UTR",
                                                                  "Noncoding transcript",
                                                                  "TF binding site",
                                                                  "5 prime UTR",
                                                                  "Splice region",
                                                                  "Missense",
                                                                  "Synonymous",
                                                                  "Start | stop codon",
                                                                  "Inframe ins | del",
                                                                  "Frameshift"))

  ## create plot
  polar.p <- ggplot(data = consequences.df,
                    aes(x = First_specific_consequence,
                        y = log10(total_variants),
                        fill = Type ) ) +
    geom_bar(stat = "identity",
             colour = "black",
             lwd = 0.2,
             alpha = 0.7) +
    scale_fill_manual(values = c("#FD776E", "#6F88A7")) +
    # labs(caption = o_file_prefix) +
    scale_y_continuous(limits = c(0,7),
                       breaks = seq(0,7,by = 1),
                       labels = seq(0,7,by = 1)) +
    coord_polar() +
    theme_light() +
    theme(
      axis.title = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_text( size = 3),
      axis.ticks = element_line(size = 0.1),
      legend.position = "none",
      title = element_text(size = 5)
    )

  ## save the basic plot
  ggsave(filename = paste0(o_file_prefix,"general_consequences.svg"),
         plot = polar.p,
         device = "svg",
         width = 9, height = 9, units = "cm", dpi = 300)

  ## recreate plot, but with legends
  polar2.p <- polar.p +
    geom_text(aes(label = First_specific_consequence, y = 7), color = "black", size = 1.5) +
    geom_text(aes(label = total_variants, y = 6), color = "black", size = 1)

  ## save the labeled plot
  ggsave(filename = paste0(o_file_prefix,"general_consequences_WITHLABELS.svg"),
         plot = polar2.p,
         device = "svg",
         width = 9, height = 9, units = "cm", dpi = 300)

}

## plot all variants
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A1type_ALL.fullset\\.")
consequence_summarizer(plotable1.df, tag_table, output_name)

#low freq cutoff
plotable1_low.df <- plotable1.df %>% filter(AF_natmx < 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A2type_ALL.low_freq\\.")
consequence_summarizer(plotable1_low.df, tag_table, output_name)

#common freq cutoff
plotable1_common.df <- plotable1.df %>% filter(AF_natmx >= 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A3type_ALL.common_freq\\.")
consequence_summarizer(plotable1_common.df, tag_table, output_name)

## plot SNV variants
plotable2.df <- plotable1.df %>% filter(var_type == "SNV")
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A4type_SNV.fullset\\.")
consequence_summarizer(plotable2.df, tag_table, output_name)

#low freq cutoff
plotable2_low.df <- plotable2.df %>% filter(AF_natmx < 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A5type_SNV.low_freq\\.")
consequence_summarizer(plotable2_low.df, tag_table, output_name)

#common freq cutoff
plotable2_common.df <- plotable2.df %>% filter(AF_natmx >= 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A6type_SNV.common_freq\\.")
consequence_summarizer(plotable2_common.df, tag_table, output_name)

## DEBUGG save dataframe
# write.table(x = plotable2_common.df,
#             file = "DEBUG_commonSNV.tsv",
#             append = F, quote = F, sep = "\t",
#             row.names = F, col.names = T)

## plot INDEL variants
plotable3.df <- plotable1.df %>% filter(var_type == "INDEL")
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A7type_INDEL.fullset\\.")
consequence_summarizer(plotable3.df, tag_table, output_name)

#low freq cutoff
plotable3_low.df <- plotable3.df %>% filter(AF_natmx < 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A8type_INDEL.low_freq\\.")
consequence_summarizer(plotable3_low.df, tag_table, output_name)

#common freq cutoff
plotable3_common.df <- plotable3.df %>% filter(AF_natmx >= 0.05)
output_name <- gsub(args[2], pattern = "\\.ALL_ANALYSIS", replacement = "\\.A9type_INDEL.common_freq\\.")
consequence_summarizer(plotable3_common.df, tag_table, output_name)
