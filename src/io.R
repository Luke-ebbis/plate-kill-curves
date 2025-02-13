read_plate_result_file <- function(file_path) {
    message(file_path)
    results <- read.csv(file_path,
                        skip = 7)[, -1]
    colnames(results) <- as.character(1:12)
    rownames(results) <- LETTERS[1:8]
    
    output <- list()
    output$results <- results
    
    
    metadata <- read.csv(file_path, header = FALSE)[1:5, 1:3]
    metadata_list <- list(
        "user" = gsub("User: ", "", metadata[1,1]),
        "date" = gsub("Date: ", "", metadata[2,2]),
        "time" = gsub("Time: ", "", metadata[2,3]),
        "name" = gsub("Test name: ", "", metadata[2,1])
    )
    output$metadata <- metadata_list
    return(output)
}


read_metadata_file <- function(file_path) {
    message(file_path)
    results <- read.csv(file_path,
                        header = FALSE,
                        encoding = "UTF-8")
    results
    results_metadata <- list()
    for (index in 1:dim(results)[1]) {
        row <- results[index, ]
        results_metadata[row$V1] <- list(row$V2)
    }
    results_metadata
}

read_plate <- function(file_path) {
    results <- read.csv(file_path)[, -1]
    colnames(results) <- as.character(1:12)
    rownames(results) <- LETTERS[1:8]
    results
}



read_plateset <- function(plateset_folder_path, metadata_file_path) {
    require(tidyverse)
    folder <- plateset_folder_path
    files <- dir(folder)
    metadata_file <- files[grepl(pattern = metadata_file_path, x = files,
                                 ignore.case = TRUE)]
    meta <- read_metadata_file(file_path = paste0(folder,
                                                  metadata_file, 
                                                  collapse = "/"))
    message(as.character(str(meta)))
    plate_results <- read_plate_result_file(paste0(folder, meta$measurement_file, 
                                                   collapse = "/"))
    measures <- plate_results$results |> 
        rownames_to_column() |> 
        pivot_longer(cols = as.character(1:12))
    
    treatments <- read_plate(paste0(folder, meta$treatment_file, 
                                    collapse = "/")) |>
        rownames_to_column() |> 
        pivot_longer(cols = as.character(1:12)) |> 
        rename(treatment = "value")
    
    
    samples <- read_plate(paste0(folder, meta$sample_file, 
                                 collapse = "/")) |>
        rownames_to_column() |> 
        pivot_longer(cols = as.character(1:12)) |> 
        rename(sample = "value")
    
    plateSet <- measures |> 
        left_join(treatments,
                  by = join_by(rowname, name)) |> 
        left_join(samples,
                  by = join_by(rowname, name)) |> 
        mutate(value = as.numeric(value))
    
    out <- list()
    out$results <- plateSet
    out$meta <- meta
    return(out)
}
