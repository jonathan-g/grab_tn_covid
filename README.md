# grab_tn_covid
Scrape COVID testing results for the state of Tennessee from the TN Department of Health web site.

 [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Function:

* `grab_tn_covid()`

## Return value:

* A list of three data frames:
  * `testing`: Tests performed, by laboratory type and test result.
    * `lab_class`: factor with levels "public" and "private",
    * `total_tests`: the total number of tests administered (only available
      for public labs).
    * `negative`: Number of negative test results (only available for public
      labs).
    * `positive`: Number of positive test results (both public and private
      labs).
  * `counties`: county-level case counts:
    * `county`: County name (factor)
    * `case_count`: Number of confirmed cases in the county.
  * `ages`: Age distribution
    * `age_range`: Age range (as an ordered factor with levels `0-10`,
      `11-20`, `21-30`, `31-40`, `41-50`, `51-60`, `61-70`, `71-80`, and
      `80+`).
    * `case_count`: Number of confirmed cases.
