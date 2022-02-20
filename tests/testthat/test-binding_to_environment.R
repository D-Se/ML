test_that("multiplication works", {
  e <- new.env()
  set_in_env(e, {a <- 3})
  expect_equal(e$a, 3)
})
