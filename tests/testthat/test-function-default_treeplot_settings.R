test_that("default_treeplot_settings() works", {

  result <- default_treeplot_settings()
  expect_is(result, "list")
  expect_identical(names(result), c("size", "files"))
})
