#--------------------------------------------------------------------------------
# READ THIS IF YOU ARE USING THIS FOR THE FIRST TIME
#
#If this is the first time and you don't have those R packages already installed
#Use install.packages(c("httr","jsonlite","lubridate","TTR","quantmod")) 
#
# 1. Create your dHEDGE vault on dHEDGE.org
#
# 2. Create your gas wallet and api key on our API Site: http://api.infinitetrading.io
#
# 3. Send gas $1 of ETH (Optimism/Arbitrum/Base) or POL (Polygon)) to your gas wallet
#
# 4. Set on your dHEDGE vault the gas wallet address as a 'trader'
#    Go to your vaults on dHEDGE.org click the vault and 'manage' then 'set trader'.
#
# 5. Link your gas wallet to your pool using your apiKeys on the API Site.
#    using the linkGasWallet endpoint.
#
# 6. Use the 'approve' endpoint on the API site and approve both the token to trade and USDC on 'uniswapV3'.
#    For example if your pair is WETH-USDC you have to approve WETH and USDC on two separate calls.
#
# You are set, now you only need to run this code from your server/computer.
# This code will run forever on an infinite loop.
#--------------------------------------------------------------------------------

#This strategy is live here: https://dhedge.org/vault/0xb3daeb9b47bab1e56f29a77eb7a9c7f0ff63221d
#Loading dependencies  

require(httr)
require(jsonlite)
require(lubridate)
require(TTR)
require(quantmod)

#Setup and credentials

network = "optimism"     #Network of your pool (optimism/base/polygon/arbitrum).
protocol = "dhedge"     #Protocol of your pool (dhedge).
pool = "0xb3daeb9b47bab1e56f29a77eb7a9c7f0ff63221d"    #Address of your pool (smart contract address of your pool).
apiKey ="YourAPIKeyHere"    #Your Infinite Trading API Key.
pair = "WETH-USDC"       #The pair to trade.
slippage = 1            #The max allowed slippage for each trade.
share = 100             #The percentage of the whole available balance to buy/sell on each trade.
platform = "uniswapV3"  #The platform to use to execute the swaps.
max_usd = 10000         #This will overrides the 'share' when the share is bigger than this amount. This is the highest amount of USD per trade allowed to buy/sell.
threshold = 1           #This is the max amount allowed on the other side of the trade. Example if the trade side is BUY and there is more than 1% of the vault in USDC (from new deposits) it will rebalance the pool.

#Crossover Strategy Parameters

n_fast=11   #Fast moving average (EMA)
n_slow =33 #Slow moving average (EMA)


#API Adapter

library(httr)

itp_api <- function(endpoint, params) {
  url <- paste0("https://api.infinitetrading.io/", endpoint)
  
  # For setBot: send query params, no body
  if (endpoint == "setBot") {
    response <- POST(url, query = params, body = "", encode = "raw")
  } else {
    response <- GET(url, query = params)
  }
  
  content_text <- content(response, "text", encoding = "UTF-8")
  cat("Response from API:", content_text, "\n")
}


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


# STRATEGY IMPLEMENTATION

last_side = "hold"
while (1) {
  tryCatch({
  candles <- get_candles_with_retry(pair = "POL-USD", numcandles = 300, timeframe = "6h")
  print(candles)
  EMA_FAST = EMA(Cl(candles),n=n_fast); EMA_SLOW = EMA(Cl(candles),n=n_slow)

  CROSSOVERS = sign(EMA_FAST - EMA_SLOW)
  side = ifelse(last(CROSSOVERS),"long","neutral")
  if (side != last_side) { 
      last_side = side
      itp_api(endpoint="setBot",params=list(apiKey=apiKey,protocol=protocol,network=network,pool=pool,pair=pair,side=side,max_usd=max_usd,slippage=slippage,threshold=threshold,share=share,platform=platform))  }
  }
  ,error = function(e) { 
    print(paste0("Error: ", e$message, " sleeping for 5 minutes to try again"))
  })
  #sleep for 5 minutes
  Sys.sleep(300)
}
