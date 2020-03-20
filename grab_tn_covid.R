library(pacman)
p_load(magrittr, tidyverse, lubridate, janitor, naniar, rvest)



#' grab_tn_covid
#'
#' Scrape COVID testing data from the Tennessee Department of Health web site.
#'
#' @return A list of three data frames:
#'
#'   * `testing`: Tests performed, by laboratory type and test result.

#'     Three columns:
#'     * `lab_class`: factor with levels "public" and "private",
#'     * `total_tests`: the total number of tests administered (only available
#'       for public labs).
#'     * `negative`: Number of negative test results (only available for public
#'       labs).
#'     * `positive`: Number of positive test results (both public and private
#'       labs).
#'   * `counties`: county-level case counts:
#'     * `county`: County name (factor)
#'     * `case_count`: Number of confirmed cases in the county.
#'   * `ages`: Age distribution
#'     * `age_range`: Age range (as an ordered factor with levels `0-10`,
#'       `11-20`, `21-30`, `31-40`, `41-50`, `51-60`, `61-70`, `71-80`, and
#'       `80+`).
#'     * `case_count`: Number of confirmed cases.
grab_tn_covid <- function() {
  url <- "https://www.tn.gov/health/cedep/ncov.html"
  page <- read_html(url)
  dom <- html_nodes(page, ".tn-col-ctrl table")

  tests <- dom[[1]]
  county <- dom[[2]]
  age <- dom[[3]]

  test_df <- tests %>% html_table(trim = TRUE, fill = TRUE) %>%
    clean_names() %>% as_tibble() %>% head(2) %>%
    replace_with_na_at(vars(matches("total|number")),
                       ~!str_detect(.x, "^-?[0-9]+$")) %>%
    mutate(testing_location = testing_location %>% str_to_lower() %>%
             str_detect("public") %>% ifelse("public", "private")) %>%
    mutate_at(vars(matches("total|number")), as.integer) %>%
    rename(lab_class = testing_location,
           total_tests = total_covid_19_tests_completed,
           negative = number_negative, positive = number_positive)

  county_df <- county %>% html_table(trim = TRUE, fill = TRUE) %>%
    clean_names() %>% as_tibble() %>%
    replace_with_na_at("case_count",
                       ~!str_detect(.x, "^-?[0-9]+$")) %>%
    mutate(county = factor(county),
           case_count = as.integer(case_count))

  age_df <- age %>% html_table() %>%
    set_names(c("age_range", "case_count")) %>%
    as_tibble() %>%
    replace_with_na_at("case_count",
                       ~!str_detect(.x, "^-?[0-9]+$")) %>%
    filter(! is.na(case_count)) %>%
    mutate(age_range = ordered(age_range, levels = age_range))
  invisible(list(testing = test_df, counties = county_df, ages = age_df))
}
