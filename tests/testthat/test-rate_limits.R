models <- c("gpt-4o-mini", "gpt-4")

skip <- FALSE

test_that("General working of rate_limits_per_minute().", {

  if(skip) skip()
  skip_on_cran()

  rate_limits_per_minute() |>
    nrow() |>
    expect_equal(1L)

  rlpm <- rate_limits_per_minute()

  expect_true(is.numeric(rlpm$requests_per_minute))
  expect_true(is.numeric(rlpm$tokens_per_minute))

  rate_limits_per_minute(model = models) |>
    nrow() |>
    expect_equal(2L)

  rlpm <- rate_limits_per_minute(model = models)
  expect_length(rlpm$requests_per_minute, 2)
  expect_output(print(rlpm), "tibble")

})

test_that("rate_limits_per_minute() casts errors correctly.", {

  #if(skip) skip()
  #skip_on_cran()

  rlpm <- rate_limits_per_minute(model = "gpt-3")
  expect_identical(unique(rlpm$model), "Error 404: The model `gpt-3` does not exist or you do not have access to it.")

  rlpm <- rate_limits_per_minute(api_key = 1234)$model
  expect_true(stringr:::str_detect(rlpm, "401"))

  expect_error(
    rate_limits_per_minute(AI_tool = "Bard")
  )


})


