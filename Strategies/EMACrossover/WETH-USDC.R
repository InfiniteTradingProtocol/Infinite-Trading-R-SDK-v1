#--------------------------------------------------------------------------------
#
# INFINITE TRADING PROTOCOL - Trading Strategy Example with Trading Bot
#
#--------------------------------------------------------------------------------
# READ THIS IF YOU ARE USING THIS FOR THE FIRST TIME
#--------------------------------------------------------------------------------
#
# If this is the first time and you don't have those R packages already installed
# Use install.packages(c("httr","jsonlite","lubridate","TTR","quantmod")) 
#
# 1. Create your dHEDGE vault on dHEDGE.org
#
# 2. Connect your manager wallet and create your gas wallet our managers site: https://www.infinitetrading.io/managers
#
# 3. Send gas $1 of ETH (Optimism/Arbitrum/Base) or POL (Polygon)) to your gas wallet
#
# 4. Wait until the vault appears on https://www.infinitetrading.io/managers?section=vaults (refresh after ~ 1min) 
#
# 5. Link the vault to the API using the generated gas wallet on the 'Managed Vaults' section (Is Linked? Column)
#
# 6. Click on 'Create New Bot' on the 'Trading Bots' Section: https://www.infinitetrading.io/managers?section=vaults
#
# 7. Select your gas wallet, the newly linked vault, and WETH-USDC (recommended: Odos platform)
# 
# You are set, now you only need to run this code from the cloud server or your personal computer.
#
# This code will run forever on an infinite loop. You can remove the while(1) {} loop and use a cron scheduler if desired.
#
#--------------------------------------------------------------------------------

#This strategy is live here: https://dhedge.org/vault/0xb3daeb9b47bab1e56f29a77eb7a9c7f0ff63221d

#Load the required packages (use install.packages() to install each of those if its the first time)
require(jsonlite); require(lubridate); require(TTR); require(quantmod)

#Setup and credentials

network = "optimism"     #Network of your pool (optimism/base/polygon/arbitrum).
protocol = "dhedge"     #Protocol of your pool (dhedge).
pool = "0xb3daeb9b47bab1e56f29a77eb7a9c7f0ff63221d"    #Address of your pool (smart contract address of your pool).
apiKey ="YourAPIKeyHere"    #Your Infinite Trading API Key.
pair = "WETH-USDC"       #The pair to trade.
slippage = 1            #The max allowed slippage for each trade.
share = 100             #The percentage of the whole available balance to buy/sell on each trade.
platform = "odos"  #The platform to use to execute the swaps.
max_usd = 10000         #This will overrides the 'share' when the share is bigger than this amount. This is the highest amount of USD per trade allowed to buy/sell.
threshold = 1           #This is the max amount allowed on the other side of the trade. Example if the trade side is BUY and there is more than 1% of the vault in USDC (from new deposits) it will rebalance the pool.

#Crossover Strategy Parameters

n_fast=11   #Fast moving average (EMA)
n_slow =33 #Slow moving average (EMA)

# STRATEGY IMPLEMENTATION

last_side = "hold"
while (1) {
  tryCatch({
  candles <- get_candles_with_retry(pair = "ETH-USD", numcandles = 300, timeframe = "6h")
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
