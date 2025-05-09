################################################################################
###
### DATE CREATED: 2025-05-06
###
### AUTHOR: Mark Wheldon
###
### PROJECT: FPEMcountry
###
### DESCRIPTION: Test fpemlocal.unpd.fork. Compare its results with global
### results.
###
###-----------------------------------------------------------------------------
###
################################################################################

###-----------------------------------------------------------------------------
### * Set Up

library(fpemlocal.unpd.fork)

###-----------------------------------------------------------------------------
### * Examples

###-----------------------------------------------------------------------------
### ** Saudi Arabia

fit <- fit_fp_c(
    is_in_union = "Y",
    division_numeric_code = 682,
    first_year = 1970,
    last_year = 2030,
    diagnostic = TRUE
)

results <- calc_fp_c(fit)

plot_fp_c(
    fit,
    results,
    indicators = c(
        "unmet_need_any",
        "contraceptive_use_modern",
        "contraceptive_use_traditional",
        "contraceptive_use_any"
    ),
    compare_to_global = TRUE
)
