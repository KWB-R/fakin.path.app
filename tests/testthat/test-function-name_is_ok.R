#
# This test file has been generated by kwb.test::create_test_files()
# launched by user hauke on 2019-07-14 11:27:35.
# Your are strongly encouraged to modify the dummy functions
# so that real cases are tested. You should then delete this comment.
#

test_that("name_is_ok() works", {

  expect_error(
    fakin.path.app:::name_is_ok()
    # argument "x" is missing, with no default
  )

})

