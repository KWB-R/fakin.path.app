#
# This test file has been generated by kwb.test::create_test_files()
# launched by user hauke on 2019-09-11 11:51:32.
# Your are strongly encouraged to modify the dummy functions
# so that real cases are tested. You should then delete this comment.
#

test_that("get_global() works", {

  expect_error(
    fakin.path.app:::get_global()
    # argument "name" is missing, with no default
  )

})

