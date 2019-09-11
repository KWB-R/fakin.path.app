test_that("write_csv() works", {

  f <- write_csv

  expect_error(f())

  f(data.frame(a = 1), tempfile(), version = 1)
  f(data.frame(a = 1), tempfile(), version = 2)
  expect_error(f(data.frame(a = 1), tempfile(), version = 3))
})
