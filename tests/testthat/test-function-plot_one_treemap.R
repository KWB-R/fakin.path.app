test_that("plot_treemap() works", {

  dtf <- data.frame(a = 1)

  fakin.path.app:::plot_treemap(dtf, index = "a", vSize = "a")

})
