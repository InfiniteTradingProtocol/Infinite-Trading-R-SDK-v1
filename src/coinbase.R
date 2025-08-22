# Mapping timeframes to their equivalent durations in seconds
timeframe_to_seconds <- list(
  '1m' = 60,
  '5m' = 300,
  '15m' = 900,
  '1h' = 3600,
  '6h' = 21600,
  '1d' = 86400,
  '1w' = 604800
)

get_candles <- function(pair, numcandles, timeframe) {
  product_id <- gsub("_", "-", pair)
  granularity <- timeframe_to_seconds[[timeframe]]
  if (is.null(granularity)) {
    cat(sprintf("Error: Granularity for timeframe '%s' is not defined.\n", timeframe))
    return(NULL)
  }
  url <- sprintf("https://api.exchange.coinbase.com/products/%s/candles", product_id)
  params <- list(granularity = granularity)
  tryCatch({
    response <- GET(url, query = params)
    if (status_code(response) >= 400) {
      stop(sprintf("HTTP error occurred: %d - %s", status_code(response), content(response, "text")))
    }
    candles <- fromJSON(content(response, "text"), flatten = TRUE)
    colnames(candles) = c("time","open","high","low","close","volume")
    candles = rev(candles)
    # Return only the last `numcandles` if available
    if (length(candles) > numcandles) {
      return(candles[1:numcandles, ])
    } else {
      return(candles)
    }
  }, error = function(e) {
    cat(sprintf("Error fetching candles: %s\n", e$message))
    return(NULL)
  })
}

get_candles_with_retry <- function(pair, numcandles, timeframe, retries = 3, delay = 1) {
  attempt <- 0
  while (attempt < retries) {
    tryCatch({
      candles <- get_candles(pair, numcandles, timeframe)
      if (!is.null(candles)) {
        return(candles)
      }
    }, error = function(e) {
      cat(sprintf("Error fetching candles: %s\n", e$message))
      if (grepl("ban", tolower(e$message)) || grepl("403", e$message) || grepl("rate limit", tolower(e$message))) {
        cat("It looks like your IP might be banned or rate-limited.\n")
        break
      }
    })
    attempt <- attempt + 1
    cat(sprintf("Retrying... (%d/%d)\n", attempt, retries))
    Sys.sleep(delay)
  }
  return(NULL)
}
