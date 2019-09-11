test_that("get_recursive_file_info() works", {

  f <- fakin.path.app::get_recursive_file_info

  expect_error(f())

  file_info <- f(root_dir = system.file(package = "fakin.path.app"))

  expect_is(file_info, "data.frame")
  expect_true(all(c("path", "type", "size") %in% names(file_info)))
})

