test_that("read_file_info_search_index() works", {

  f <- read_file_info_search_index

  expect_error(f())

  file <- extdata_file("example_file_info_1.csv")

  f(file)
})
