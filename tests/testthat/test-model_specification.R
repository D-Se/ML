# test_that("Inserting tune::tune() in model specs works", {
#   expect_equal(
#     ML::mod(linear_reg, glmnet, penalty=,mixture=),
#     parsnip::linear_reg(engine = "glmnet", penalty = tune::tune(), mixture = tune::tune())
#   )
# })
# 
# 
