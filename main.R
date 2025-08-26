#### Main file to load the Infinite Trading R-SDK-v1 ####

#Dependencies run this the first time without the # to install the packages if you dont have them.
#install.packages("dotenv")
#install.packages("httr")

#Set your proper working directoty (the folder where this repository is)

wd = "C:/Users/17872/OneDrive/Documents/GitHub/Infinite-Trading-R-SDK-v1/"
URL = "https://api.infinitetrading.io/"

#Load your environmental variable.
load_dot_env(paste0(wd,".env"))
API_KEY = Sys.getenv("APIKEY")


require(dotenv); require(httr)
#Load all dependencies.
source(paste0(wd,"src/coinbase.R"))
source(paste0(wd,"src/api.R"))

source(paste0(wd,"src/correlations.R"))


#Example

#Fetch 1H Candles from Coinbase and store it

eth_1h_candles = get_candles_with_retry(pair="ETH-USD", numcandles=300, timeframe="1h", retries = 3, delay = 1) 
btc_1h_candles = get_candles_with_retry(pair="BTC-USD", numcandles=300, timeframe="1h", retries = 3, delay = 1) 
link_1h_candles = get_candles_with_retry(pair="LINK-USD", numcandles=300, timeframe="1h", retries = 3, delay = 1) 
sol_1h_candles = get_candles_with_retry(pair="SOL-USD", numcandles=300, timeframe="1h", retries = 3, delay = 1) 
