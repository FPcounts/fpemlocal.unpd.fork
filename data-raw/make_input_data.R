################################################################################
###
### DATE CREATED: 2025-04-28
###
### AUTHOR: Mark Wheldon
###
### PROJECT: fpemlocal_unpd_fork
###
### DESCRIPTION: Make input data for this package from the latest FPEMglobal
### revision.
###
###-----------------------------------------------------------------------------
###
################################################################################

###-----------------------------------------------------------------------------
### * Setup

### Libraries

## Check these are installed
rlang::check_installed(c("FPEMglobal.aux", "fpemlocal", "here", "purrr",
                         "usethis"),
                       version = c("1.2.0", rep(NA, 4)))

## Attached these packages
library(magrittr)

### Paths

path_to_global_run_mwra <-
    file.path(Sys.getenv("SharePoint_UN", unset = NA),
              "DESA-POP - PDU", "FPEM", "Results", "Released", "2024", "output",
              "240702_173547_15-49_married")
stopifnot(dir.exists(path_to_global_run_mwra))

###-----------------------------------------------------------------------------
### * Survey Data

### Record the input file for reproducibility
file.copy(from = file.path(path_to_global_run_mwra, "dataCPmodel_input_raw.csv"),
          to = here::here("data-raw", "dataCPmodel_input_raw.csv"),
          overwrite = TRUE)

### This part is a modified version of code from
### '[fpemlocal]/vignettes/developer_annual_data_updates.Rmd

## Read and impute
contraceptive_use <-
    FPEMglobal.aux::input_data_2_fpemdata(output_dir = path_to_global_run_mwra) %>%
    fpemlocal::impute_packagedata_se() %>%
        purrr::pluck("contraceptive_use_imputed")

## Save as package data
usethis::use_data(contraceptive_use, overwrite = TRUE)

###-----------------------------------------------------------------------------
### * Denominators

### Record the input file for reproducibility
denom_fp <- FPEMglobal.aux::get_used_csv_denominators_filepath(path_to_global_run_mwra)
file.copy(from = denom_fp,
          to = here::here("data-raw", basename(denom_fp)),
          overwrite = TRUE)

population_counts <-
    FPEMglobal.aux::denominators_2_fpemdata(output_dir = path_to_global_run_mwra)

## Save as package data
usethis::use_data(population_counts, overwrite = TRUE)

###-----------------------------------------------------------------------------
### * Country Classifications ("Divisions")

### Record the input file for reproducibility
cc_fname <- FPEMglobal::pkg_files_included(result = "filename")$model_run_inputs$region_information
file.copy(from = file.path(path_to_global_run_mwra, cc_fname),
          to = here::here("data-raw", cc_fname),
          overwrite = TRUE)

division_classifications <-
    FPEMglobal.aux::country_classifications_2_fpemdata(path_to_global_run_mwra)

## Save as package data
usethis::use_data(division_classifications, overwrite = TRUE)

###-----------------------------------------------------------------------------
### * Global Run Results

## These are only used in plots to compare one-country runs with global runs.

!!!!!!!!!!!!!!!!!!!!!!!!! HERE HERE HERE

global_estimates <-
    FPEMglobal.aux::convert_csv_res_2_fpemdata(output_dir = path_to_global_run_mwra,
                                               stat = "prop", adjusted = "sub_adj")

