## load libraries
library("tidyr")
library("dplyr")
library("data.table")
library("ggplot2")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## For debugging only
# args[1] <- "test/data/sampleshr22.removed_singletons_and_private.novel.tsv.gz"

## load data
raw.df <- fread(file = args[1],
                sep = "\t", header = T,
                stringsAsFactors = F, na.strings = ".",
                select = c("CHROM","POS","REF","ALT","gnomADg_cov","project_cov"))

## separate SNV data
SNV.df <- raw.df %>% filter(nchar(REF) == nchar(ALT))

## replace NA for 0 in gnomadCov data
SNV.df[is.na(SNV.df$gnomADg_cov), "gnomADg_cov"] <- 0

## add an SNV tag
SNV.df$var_type <- "SNV"

## create a variant ID
SNV.df$variant_id <- paste(SNV.df$CHROM, SNV.df$POS, SNV.df$REF, SNV.df$ALT, sep = "_")

## transform gnomADg_cov to numeric
SNV.df$gnomADg_cov <- as.numeric(SNV.df$gnomADg_cov)
SNV.df$project_cov <- as.numeric(SNV.df$project_cov)

## separate INDEL data
INDEL.df <- raw.df %>% filter(nchar(REF) != nchar(ALT))

## replace NA for 0 in gnomadCov data
INDEL.df[is.na(INDEL.df$gnomADg_cov), "gnomADg_cov"] <- "0"

## add an INDEL tag
INDEL.df$var_type <- "INDEL"

## create a avriant ID
INDEL.df$variant_id <- paste(INDEL.df$CHROM, INDEL.df$POS, INDEL.df$REF, INDEL.df$ALT, sep = "_")

INDEL.df <- INDEL.df %>% group_by(variant_id) %>% mutate(
  mean_cov_gnomad = mean(as.numeric(unlist(strsplit(gnomADg_cov, split = "&")))),
  mean_cov_project = mean(as.numeric(unlist(strsplit(project_cov, split = "&"))))
  )

## replace gnomad and project cov data with means
INDEL.df$gnomADg_cov <- as.numeric(INDEL.df$mean_cov_gnomad)
INDEL.df$project_cov <- as.numeric(INDEL.df$mean_cov_project)

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
  
  ocovfilename <- paste0(ofile,"Cov_comparisson.tif")
  ggsave(filename = ocovfilename, plot = zoom.p, device = "tiff", width = 9, height = 9 , units = "cm", dpi = 300)
  ## another one for legend extraction
  # ocovlegendfilename <- paste0(ofile,"Cov_comparisson_for_legend.tif")
  # ggsave(filename = ocovlegendfilename, plot = base.p, device = "tiff", width = 10.8, height = 7.2 , units = "cm", dpi = 300)
  
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
  barfilename <- paste0(ofile,"bar_ranges.tif")
  ggsave(filename = barfilename, plot = bar.p, device = "tiff", width = 9, height = 9 , units = "cm", dpi = 300)
  
}

## plot all variants
# define prefix for output
outprfx <- gsub(pattern = "\\.tsv\\.gz", replacement = ".all_variants." , x =  args[1])
makeplots(plotable1.df, outprfx)

## plot SNV variants
# define prefix for output
outprfx <- gsub(pattern = "\\.tsv\\.gz", replacement = ".SNV." , x =  args[1])
plotable2.df <- plotable1.df %>% filter(var_type == "SNV")
makeplots(plotable2.df, outprfx)

## plot INDEL variants
# define prefix for output
outprfx <- gsub(pattern = "\\.tsv\\.gz", replacement = ".INDEL." , x =  args[1])
plotable3.df <- plotable1.df %>% filter(var_type == "INDEL")
makeplots(plotable3.df, outprfx)
