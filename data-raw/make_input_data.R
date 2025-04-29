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

library(FPEMglobal.aux)
library(here)
library(magrittr)

path_to_global_run <-
    file.path(Sys.getenv("SharePoint_UN", unset = NA),
              "DESA-POP - PDU", "FPEM", "Results", "Released", "2024", "output",
              "240702_173547_15-49_married")
stopifnot(dir.exists(path_to_global_run))

###-----------------------------------------------------------------------------
### * Survey Data

### Record the input file for reproducibility
global_input_file_df <-
    get_used_input_data(output_dir = path_to_global_run, variant = c("raw"))
write.csv(global_input_file_df,
          file = here("data-raw", "FPEMglobal_run_input_file.csv"),
          row.names = FALSE)

### This part is a modified version of code from
### '[fpemlocal]/vignettes/developer_annual_data_updates.Rmd

## Read and impute
contraceptive_use <- FPEMglobal.aux::input_data_2_fpemdata(output_dir = path_to_global_run) %>%
    fpemlocal::impute_packagedata_se() %>%
        purrr::pluck("contraceptive_use_imputed")

## Check the format
fpemlocal_unpd_fork:::format_check(format_list = fpemlocal::contraceptive_use_format,
                        data = contraceptive_use)

## Save as package data if the format is correct
usethis::use_data(contraceptive_use, overwrite = TRUE)




