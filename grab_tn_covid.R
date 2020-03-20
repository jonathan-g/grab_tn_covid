library(pacman)
p_load(magrittr, tidyverse, lubridate, janitor, naniar, rvest)

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
    mutate_at(vars(matches("total|number")), as.integer)

  county_df <- county %>% html_table(trim = TRUE, fill = TRUE) %>%
    clean_names() %>% as_tibble() %>%
    replace_with_na_at("case_count",
                       ~!str_detect(.x, "^-?[0-9]+$")) %>%
    mutate(county = factor(county) %>%
             fct_recode(other = "Residents of Other States/Countries",
                        unknown = "Unknown", total = "Grand Total"),
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
