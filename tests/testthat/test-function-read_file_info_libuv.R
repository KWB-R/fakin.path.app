test_that("read_file_info_libuv() works", {

  f <- read_file_info_libuv

  expect_error(f())

  file <- extdata_file("example_file_info_1.csv")

  f(file)
})
