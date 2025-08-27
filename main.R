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



#Load all dependencies.
source(paste0(wd,"src/coinbase.R"))
source(paste0(wd,"src/api.R"))

source(paste0(wd,"src/correlations.R"))


#Example of cryptocurrency correlations.

#Fetch 1H Candles from Coinbase and store it

eth_1h_candles = get_candles_with_retry(pair="ETH-USD", numcandles=30, timeframe="d", retries = 3, delay = 1) 
btc_1h_candles = get_candles_with_retry(pair="BTC-USD", numcandles=30, timeframe="1d", retries = 3, delay = 1) 
link_1h_candles = get_candles_with_retry(pair="LINK-USD", numcandles=30, timeframe="1d", retries = 3, delay = 1) 
sol_1h_candles = get_candles_with_retry(pair="SOL-USD", numcandles=30, timeframe="1d", retries = 3, delay = 1)
ltc_1h_candles = get_candles_with_retry(pair="LTC-USD", numcandles=30, timeframe="1d", retries = 3, delay = 1)

returns_matrix = cbind(returns(eth_1h_candles), returns(btc_1h_candles), returns(link_1h_candles), returns(sol_1h_candles), returns(ltc_1h_candles))
colnames(returns_matrix) = c("ETH", "BTC", "LINK", "SOL","LTC")
chart.Correlation(returns_matrix)