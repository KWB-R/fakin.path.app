test_that("read_file_info_() works", {

  f <- fakin.path.app:::read_file_info

  expect_warning(expect_error(f()))

  file <- extdata_file("example_file_info_1.csv")

  expect_warning(f(file))
})
