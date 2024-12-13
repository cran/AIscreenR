
#' @title Find updated rate limits for API models
#'
#' @description
#' `r lifecycle::badge("stable")`<br>
#' <br>
#' `rate_limits_per_minute` reports the rate limits for a given API model.
#' The function returns the available requests per minute (RPM) as well as tokens per minute (TPM).
#' Find general information at
#' \url{https://platform.openai.com/docs/guides/rate-limits/overview}.
#'
#' @param AI_tool Character string specifying the AI tool from which the API is
#' issued. Default is `"gpt"`.
#' @param model Character string with the name of the completion model.
#' Default is `"gpt-4o-mini"`. Can take multiple values.
#' Find available model at
#' \url{https://platform.openai.com/docs/models/model-endpoint-compatibility}.
#' @template api-key-arg
#'
#' @return A \code{tibble} including variables with information about the model used,
#' the number of requests and tokens per minute.
#' @export
#'
#' @examples
#' \dontrun{
#' set_api_key()
#'
#' rate_limits_per_minute()
#' }

rate_limits_per_minute <- function(
    model = "gpt-4o-mini",
    AI_tool = "gpt",
    api_key = get_api_key()
) {

  furrr::future_map_dfr(model, ~ .rate_limits_per_minute_engine(model = .x, AI_tool = AI_tool, api_key = api_key))

}

# Hidden function
.rate_limits_per_minute_engine <- function(
    model, AI_tool, api_key
    ){


  if ("gpt" %in% AI_tool){

    body <- list(
      model = model,
      messages = list(list(
        role = "user",
        content = "1+1"
      ))
    )

    req <-
      httr2::request("https://api.openai.com/v1/chat/completions") |>
      httr2::req_method("POST") |>
      httr2::req_headers(
        "Content-Type" = "application/json",
        "Authorization" = paste("Bearer", api_key)
      ) |>
      httr2::req_body_json(body) |>
      httr2::req_retry(
        is_transient = gpt_is_transient,
      ) |>
      httr2::req_user_agent("AIscreenR (http://mikkelvembye.github.io/AIscreenR/)")


    if (curl::has_internet()){

    resp <- try(
      suppressMessages(req |> httr2::req_perform()),
      silent = TRUE
    )

    if (status_code() == 200){

    rmp <- resp |>
      httr2::resp_header("x-ratelimit-limit-requests") |>
      as.numeric()

    tmp <- resp |>
      httr2::resp_header("x-ratelimit-limit-tokens") |>
      as.numeric()

    res <- tibble::tibble(
      model = model,
      requests_per_minute = rmp,
      tokens_per_minute = tmp
      )

    } else {

      res <- tibble::tibble(
        model = error_message(),
        requests_per_minute = NA_real_,
        tokens_per_minute = NA_real_
      )

      }

    } else {

      res <- tibble::tibble(
        model = "Error: Could not reach host [check internet connection]",
        requests_per_minute = NA_real_,
        tokens_per_minute = NA_real_
      )

    }

  }

  res

}
