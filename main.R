
library(argparse)

# Set up argument parser
parser <- ArgumentParser(description = "Process experimental plate reader data and generate plots.")
parser$add_argument("data_folder", help = "Path to the data folder containing experimental results.")
subparsers <- parser$add_subparsers(dest = "command", help = "Available subcommands")

# Subcommand: format
parser_format <- subparsers$add_parser("format", help = "Format the dataset for FAIR principles.")

# Subcommand: plot
parser_plot <- subparsers$add_parser("plot", help = "Generate and save plots from the dataset.")

# Parse arguments
args <- parser$parse_args()
data_folder <- args$data_folder


# Load required libraries
suppressMessages(source("src/libs.R"))

# Get folders inside the data directory
folders <- dir(data_folder)

dataset <- list()
for (folder in folders) {
    dataset[folder] <- read_plateset(file.path(data_folder, folder, ""), "metadata") |> list()
}

# Format data
# format_fairds_data(dataset = dataset)

# Generate and save plots
for (ds in dataset) {
    plot_plate(ds)
    ggplot2::ggsave(filename = file.path("results", paste0(ds$meta$Compound, "-", ds$meta$`Incubation time`, ".png")))
}
