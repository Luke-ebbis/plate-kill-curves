plot_plate <- function(platedata) {
    meta <- platedata$meta
    # Sterile is to be substracted. Then div by null condition
    # TODO remove the background.
    res <- platedata$results |> 
        mutate(treatment = as.numeric(treatment)) |> 
        filter(!(sample %in% c("empty", "sterile")))
    sterile <- platedata$results |> 
        filter((sample %in% c("sterile"))) |> pull(value) |> mean()
    untreated <- res |> filter(treatment == 0) |> 
        mutate(zeroValue = (value-sterile)) |> 
        select(-rowname, -name, -treatment, -value) 

    
    processed <- res |> 
        left_join(untreated, by = "sample") |> 
        mutate(metabolic_activity = (value-sterile)/zeroValue)
    
    ggplot(processed, aes(x = treatment, 
                          y = metabolic_activity,
                          group = sample,
                          col = sample)) +
        geom_line() +
        geom_point() +
        geom_hline(yintercept = 0) + 
        labs(y = "metabolic activity [%]",
             x = str_c("Concentration of ", meta$Compound,
                       " [", meta$Concentration, "]"))
}

analyse_from_rdf <- function(rdf_file) {
    source("https://raw.githubusercontent.com/Luke-ebbis/script/main/databases/sparql-query.R")
    library(tidyverse)
    
    query <-  "
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX schema: <http://schema.org/>
PREFIX geo: <http://www.opengis.net/ont/geosparql#> 
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX geof: <http://www.opengis.net/def/function/geosparql/>
PREFIX uom: <http://www.opengis.net/def/uom/OGC/1.0/>
PREFIX fair: <http://fairbydesign.nl/ontology/>
PREFIX jerm: <http://jermontology.org/ontology/JERMOntology#> 
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT ?sample ?name ?storage ?measureParts ?fluor ?c ?molecule 
       ?file ?fluorControl ?controlParts ?cC ?concentrationControl ?unit
WHERE {
    # Get the sample units from the database
    ?sample rdf:type jerm:Sample ;
        schema:name ?name ;
        fair:packageName 'Strain';
        fair:storage_date ?storageDate .
    ?control rdf:type jerm:Sample ;
        schema:name ?nameSample ;
        fair:packageName 'Controls';
        schema:identifier 'sterile' .
    
    ?control jerm:hasPart ?controlParts .
    ?controlParts fair:value ?fluorControl ;
        fair:treatment ?concentrationControl ;
        fair:file_name ?fileControl ;
        fair:treatment_molecule ?moleculeControl .
    
    
    ?sample jerm:hasPart ?measureParts .
    ?measureParts rdf:type jerm:Assay ;
                  schema:dateCreated ?assayDate ;
                  fair:packageName 'MIC' ;
                  fair:value ?fluor ;
                  fair:file_name ?file ;
                  fair:treatment_molecule ?molecule ;
                  fair:treatment ?concentration .
    
    FILTER(regex(?file, '48h')).
    FILTER(regex(?fileControl, '48h')).
    BIND(xsd:double(REPLACE(?concentration, '(.+) (.+)', '$1')) as ?c)
    BIND(xsd:double(REPLACE(?concentrationControl, '(.+) (.+)', '$1')) as ?cC)
    BIND(xsd:double(REPLACE(?concentrationControl, '(.+) (.+)', '$2')) as ?unit)
   	BIND(xsd:date(?assayDate) AS ?date)
    BIND(day(?storageDate - ?date) AS ?storage)
}
    "
    d <- query_fuseki(query = query) |> tibble()

    untreated <- d |> group_by(file, name) |> 
        filter(c == 0) |> 
        rename(zeroValue = fluor) |> 
        select(zeroValue, name) |> 
        unique()

    mean_value_negative_query <- d |> 
        group_by(file, name, sample) |> 
        rename(null = fluorControl) |> 
        summarise(mean = mean(null)) |> 
        select(mean, name) |> 
        unique()
    
    
    m <- d |> left_join(untreated) |> 
        left_join(mean_value_negative_query) |> 
        mutate(metabolic_activity = ((fluor) / (zeroValue)))
    
    m |> ggplot(aes(x = c, y = metabolic_activity, group = name,
                    colour = name)) +
        geom_line() + 
        geom_point() +
        facet_wrap(molecule ~., scales = 'free') +
        labs(x = str_c("concentration ", unique(m$unit)),
             y = "metabolic activity") 
    # TODO centre to 0.
}

# row name, name, val, treat, sample, mol