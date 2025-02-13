library(tidyverse)

format_samples_id <- function(x) {
    stringr::str_replace_all(x, pattern = " ", replacement = "_") |> 
    stringr::str_replace_all(pattern = "\\(", replacement = "") |> 
    stringr::str_replace_all(pattern = "\\)", replacement = "") |> 
    stringr::str_replace_all(pattern = "Δ", replacement = "delta")
}

make_single_table <- function(dataset) {
    tb <- tibble()
    colnames(tb) <- c("rowname", "name", "value",
                      "treatment", "sample", "table")
    
    for (table_name in names(dataset)){
        tb <- dataset[[table_name]]$results |> 
            mutate(table = table_name) |> 
            bind_rows(tb)
    }
    tb |> filter(sample != "empty")
}

format_investigation <- function() {
    id <- "pefPhenotyping"
    title <- "Phenotyping the `Pef' fungal collection."
    ABSTRACT <- "Test data from the `Pef' collection."
    
    message("Making the Investigation table")
    Investigation <- tribble(~"investigation identifier", ~"investigation title", ~"investigation description", ~"firstname", ~"lastname", ~"email address", ~"orcid", ~"organization", ~"department",
                             id, title, ABSTRACT, "Martin", "Weichert", "martin.weichert@wur.nl", "0000-0002-7484-9520", "Wageningen UR", "Genetics") |>
        mutate("_sheetName" = "Investigation")
}

format_study <- function() {
    message("Making the study table")
    Study  <-  tibble(
        "_sheetName" = "Study",
        "study identifier" = "pefAntiFungalInv",
        "study description" = "Antifungal resistance of varous A fumgatus knockout strains was tested",
        "study title" = "Resistance tests of A. fumgatus",
        "investigation identifier" =  "pefPhenotyping"
    ) |> 
        mutate("_sheetName" = "Study")
}

format_observation_units <- function() {
    tibble(
        "observation unit identifier" = "pefStrains",
        "observation unit name" = "PefStrain collection",
        "observation unit description" = "The Pef collection of Aspergillus fumigatus strains.",
        "study identifier" = "pefAntiFungalInv",
        "culture collection name" = "Pef",
        "maintainer" = "Eveline Snelders",
        "institute" = "Wageningen",
        "culture collection description" = "Strains created by Martin Weichert."
    ) |> mutate("_sheetName" = "ObservationUnit - CultureCollec")
}

#'@description
#' Assumes that all observations are made from strains.
#'
format_strains <- function(dataset) {
    sample_table <- readr::read_csv("sample_data.csv")
    sample_table$`sample identifier` <- str_replace(sample_table$`sample identifier`,
                                                    "delta ", "Δ")
    measurement_data <- make_single_table(dataset)
    sample_names <- measurement_data$sample |> unique()
    Strains <- tibble("sample identifier" = sample_names) |> 
        left_join(sample_table) |>
        filter(type == "strain") |> 
        mutate("ncbi taxonomy id" = 746128,
               "biosafety level" = 2,
               "scientific name" = "Aspergillus fumigatus",
               "observation unit identifier" = "pefStrains",
               `sample description` = stringr::str_c("A culture of ", `sample identifier`),
               strain = `sample identifier`,
               `sample identifier` = format_samples_id(`sample identifier`),
               `sample name` = stringr::str_c(strain, " culture")
               ) |> 
        mutate("_sheetName" = "Sample - Strain",
               `sample identifier` = format_samples_id(`sample identifier`))
    Strains
}

format_controls <- function(dataset) {
    measurement_data <- make_single_table(dataset) |>
        rename(`sample identifier` = sample)
    sample_names <- measurement_data$`sample identifier` |> unique()
    Controls <-
        tibble("sample identifier" = sample_names) |>
        filter(`sample identifier` %in% c("sterile", "empty")) |> 
        mutate("ncbi taxonomy id" = 32644, # none
               "biosafety level" = 1,
               "scientific name" = "none",
               "observation unit identifier" = "pefStrains",
               "sample name" = "Negative control",
               "sample description" = "Sterile medium") |> 
        mutate("_sheetName" = "Sample - Controls")
    Controls
}

format_assay <- function(dataset) {
    tb <- dataset |> make_single_table()
    files <- tb |> pull("table")
    dates <- c()
    concentrations <- c()
    compounts <- c()
    for (f in files) {
        dates <- c(dates, stringr::str_extract(dataset[[f]]$meta$measurement_file, 
                             "(\\d+)-(\\d+)-(\\d+)"))
        compounts <- c(compounts,
                        dataset[[f]]$meta$Compound)
        concentrations <- c(concentrations,
                            dataset[[f]]$meta$Concentration)
    }
    
    tb |>  rename(column = "name",
                  `file name` = "table") |> 
        mutate(`sample identifier` = format_samples_id(sample),
                 facility = "WUR",
                 `assay date` = dates,
                 `treatment molecule` = compounts,
                 treatment = str_c(treatment, " ", concentrations),
                 protocol = "MIC test using photospectrometry on using resazurin.",
                 `assay identifier` = stringr::str_c(`sample identifier`,"_", `treatment molecule`, "_mic_",`assay date` ,"_", rowname, column),
                 `assay description` = "The resauzurin is a metabolic indicator that turns fluorescent when consumed, less signal equates to more killing.") |> 
        select(-sample) |>
        mutate("_sheetName" = "Assay - MIC")
}

format_fairds_data <- function(dataset) {
    Investigation <- format_investigation()
    Study <- format_study()
    Observations <- format_observation_units()
    Strains <- format_strains(dataset = dataset)
    Controls <- format_controls(dataset = dataset)
    Assay <- format_assay(dataset = dataset)
    
    # Formatting
    sheets <- list()
    sheets[Investigation |> pull("_sheetName") |> unique()] <- list(Investigation |> select(-"_sheetName"))
    sheets[Study |> pull("_sheetName") |> unique()] <- list(Study |> select(-"_sheetName"))
    sheets[Observations |> pull("_sheetName") |> unique()] <- list(Observations |> select(-"_sheetName"))
    sheets[Strains |> pull("_sheetName") |> unique()] <- list(Strains |> select(-"_sheetName"))
    sheets[Controls |> pull("_sheetName") |> unique()] <- list(Controls |> select(-"_sheetName"))
    sheets[Assay |> pull("_sheetName") |> unique()] <- list(Assay |> select(-"_sheetName"))
    
    openxlsx::write.xlsx(sheets, file = "pef-data.xlsx")
    
    
}

