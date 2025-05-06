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

###-----------------------------------------------------------------------------
### ** Libraries

## Check these are installed. 'pkgs_vers' is a vector of package versions, with
## names equal to the package names. Use 'NA' if version is not specified.
pkgs_vers <-
    c("dplyr" = NA, "FPEMglobal.aux" = "1.2.0.9000",
      "fpemlocal.unpd.fork" = NA, "here" = NA, "purrr" = NA,
      "tidyr" = NA, "usethis" = NA)
rlang::check_installed(names(pkgs_vers), version = pkgs_vers)

## Attached these packages
library(magrittr)

###-----------------------------------------------------------------------------
### ** Paths

### Married

path_to_global_run_married <-
    file.path(Sys.getenv("SharePoint_UN", unset = NA),
              "DESA-POP - PDU", "FPEM", "Results", "Released", "2024", "output",
              "240702_173547_15-49_married")
stopifnot(dir.exists(path_to_global_run_married))

### Unmarried

path_to_global_run_unmarried <-
    file.path(Sys.getenv("SharePoint_UN", unset = NA),
              "DESA-POP - PDU", "FPEM", "Results", "Released", "2024", "output",
              "240702_173547_15-49_unmarried")
stopifnot(dir.exists(path_to_global_run_unmarried))

###-----------------------------------------------------------------------------
### * FPEMglobal Input Data

###-----------------------------------------------------------------------------
### ** Survey Data

### Record the input file for reproducibility
file.copy(from = file.path(path_to_global_run_married, "dataCPmodel_input_raw.csv"),
          to = here::here("data-raw", "dataCPmodel_input_raw.csv"),
          overwrite = TRUE)

### This part is a modified version of code from
### '[fpemlocal]/vignettes/developer_annual_data_updates.Rmd

## Read and impute
contraceptive_use <-
    FPEMglobal.aux::input_data_2_fpemdata(output_dir = path_to_global_run_married) %>%
    fpemlocal.unpd.fork::impute_packagedata_se() %>%
        purrr::pluck("contraceptive_use_imputed")

## Save as package data
usethis::use_data(contraceptive_use, overwrite = TRUE)

###-----------------------------------------------------------------------------
### ** Denominators

### Record the input file for reproducibility
denom_fp <- FPEMglobal.aux::get_used_csv_denominators_filepath(path_to_global_run_married)
file.copy(from = denom_fp,
          to = here::here("data-raw", basename(denom_fp)),
          overwrite = TRUE)

population_counts <-
    FPEMglobal.aux::denominators_2_fpemdata(output_dir = path_to_global_run_married)

## Save as package data
usethis::use_data(population_counts, overwrite = TRUE)

###-----------------------------------------------------------------------------
### ** Country Classifications ("Divisions")

### Record the input file for reproducibility
cc_fname <- FPEMglobal::pkg_files_included(result = "filename")$model_run_inputs$region_information
file.copy(from = file.path(path_to_global_run_married, cc_fname),
          to = here::here("data-raw", cc_fname),
          overwrite = TRUE)

division_classifications <-
    FPEMglobal.aux::country_classifications_2_fpemdata(path_to_global_run_married)

## Save as package data
usethis::use_data(division_classifications, overwrite = TRUE)

###-----------------------------------------------------------------------------
### * FPEMglobal Model Run Outputs

###-----------------------------------------------------------------------------
### ** Model Meta Data

### This part is a modified version of code from
### '[fpemlocal]/vignettes/developer_annual_data_updates.Rmd

globalrun_input_m <-
    FPEMglobal.aux::get_model_meta_info(path_to_global_run_married)
globalrun_input_u <-
    FPEMglobal.aux::get_model_meta_info(path_to_global_run_unmarried)

index_area <- fpemlocal.unpd.fork::index_area(globalrun_input_m, run_type = "mwra")
index_datatype <- fpemlocal.unpd.fork::index_datatype(globalrun_input_m)
index_m <- list(index_area_df = index_area,
                index_datatype = index_datatype)

index_area <- fpemlocal.unpd.fork::index_area(globalrun_input_u, run_type = "uwra")
index_datatype <- fpemlocal.unpd.fork::index_datatype(globalrun_input_u)
index_u <- list(index_area_df = index_area,
                index_datatype = index_datatype)

###-----------------------------------------------------------------------------
### ** Posterior Medians

globalrun_output_m <-
    FPEMglobal.aux::get_hierarchical_medians(path_to_global_run_married)
globalrun_output_u <-
    FPEMglobal.aux::get_hierarchical_medians(path_to_global_run_unmarried)

###-----------------------------------------------------------------------------
### ** Prevalence Estimates

### These are only used in plots to compare one-country runs with global runs.

### This part is a modified version of code from
### '[fpemlocal]/vignettes/developer_annual_data_updates.Rmd

mw_perc <-
    FPEMglobal.aux::convert_csv_res_2_fpemdata(output_dir = path_to_global_run_married,
                                               stat = "prop", adjusted = "sub_adj")
uw_perc <-
    FPEMglobal.aux::convert_csv_res_2_fpemdata(output_dir = path_to_global_run_unmarried,
                                               stat = "prop", adjusted = "sub_adj")

global_estimates_married <- mw_perc %>%
  dplyr::mutate(is_in_union = "Y")
global_estimates_unmarried <- uw_perc %>%
  dplyr::mutate(is_in_union = "N")
global_estimates <- dplyr::bind_rows(global_estimates_married,
                 global_estimates_unmarried) %>%
  tidyr::gather(year, value, "1970.5":"2030.5") %>%
  dplyr::mutate(year = as.numeric(year)) %>%
  tidyr::spread(Percentile,  value) %>%
  dplyr::rename(division_numeric_code = Iso,
                indicator = par) %>%
  dplyr::rename_all(tolower) %>%
  dplyr::select(-name) %>%
  dplyr::mutate(indicator = dplyr::recode(indicator,
                                          unmet = "unmet_need_any",
                                          modern = "contraceptive_use_modern",
                                          traditional = "contraceptive_use_traditional")) %>%
  dplyr::rename("2.5%" = "0.025",
                "10%" = "0.1",
                "50%" = "0.5",
                "90%" = "0.9",
                "97.5%" = "0.975") %>%
    dplyr::mutate(model = "global")

## Save as package data
usethis::use_data(global_estimates, overwrite = TRUE)
