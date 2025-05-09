population_data_import <- function(
  population_data = NULL,
  fit
)
{
  is_in_union <- fit %>% purrr::chuck("core_data", "is_in_union")
  division_numeric_code <- fit %>% purrr::chuck("core_data", "units", "division_numeric_code")
  first_year <- fit %>%
    purrr::chuck("core_data","year_sequence_list", "result_seq_years") %>%
    min
  last_year <- fit %>%
    purrr::chuck("core_data","year_sequence_list", "result_seq_years") %>%
    max
  if(!is.null(population_data)) {
    population_data <- population_data %>%
      dplyr::filter(is_in_union == {{is_in_union}}) %>%
      dplyr::filter(division_numeric_code == {{division_numeric_code}}) %>%
      dplyr::filter(mid_year >= first_year) %>%
      dplyr::filter(mid_year <= last_year)
  } else {
    population_data <- population_counts %>%
      dplyr::filter(is_in_union == {{is_in_union}}) %>%
      dplyr::filter(division_numeric_code == {{division_numeric_code}}) %>%
      dplyr::filter(mid_year >= first_year) %>%
      dplyr::filter(mid_year <= last_year)
  }

  # # update LA 2023/3/23, to avoid errors for ALL and
  # # streamline use of user-provided data
  #
  # if(is.null(population_data)) {
  #   population_data <- population_counts
  # }
  # population_data <- population_data %>%
  #   dplyr::filter(division_numeric_code == {{division_numeric_code}}) %>%
  #   dplyr::filter(mid_year >= first_year) %>%
  #   dplyr::filter(mid_year <= last_year)
  #
  # if (is_in_union %in% c("Y", "N")){
  #   population_data <- population_data %>%
  #     dplyr::filter(is_in_union == {{is_in_union}})
  # } else {
  #   population_data <- population_data %>%
  #     tidyr::pivot_wider(names_from =  is_in_union, values_from = population_count) %>%
  #     dplyr::mutate(population_count = Y + N, is_in_union = "ALL") %>%
  #     dplyr::select(-c(Y, N))
  # }

  return(population_data)
}

# # test
# population_data2 <- fpemlocal.unpd.fork::population_counts %>%
#   dplyr::filter(division_numeric_code == 4)
# population_data2 %>%
#   tidyr::pivot_wider(names_from =  is_in_union, values_from = population_count) %>%
#   dplyr::mutate(population_count = Y + N, is_in_union = "ALL") %>%
#   dplyr::select(-c(Y, N))
