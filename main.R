#### Main file to load the Infinite Trading R-SDK-v1 ####

#Dependencies run this the first time without the # to install the packages if you dont have them.
#install.packages("dotenv")
#install.packages("httr")
#install.packages("corrplot")
#Set your proper working directoty (the folder where this repository is)
library(corrplot); library(dotenv); library(httr); library(jsonlite)
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

###################
## Data fetching
###################

#Fetch 1d Candles from Coinbase and store it (30 days)

eth_1d_candles = get_candles_with_retry(pair="ETH-USD", numcandles=300, timeframe="1d", retries = 3, delay = 1) 
btc_1d_candles = get_candles_with_retry(pair="BTC-USD", numcandles=300, timeframe="1d", retries = 3, delay = 1) 
link_1d_candles = get_candles_with_retry(pair="LINK-USD", numcandles=300, timeframe="1d", retries = 3, delay = 1) 
sol_1d_candles = get_candles_with_retry(pair="SOL-USD", numcandles=300, timeframe="1d", retries = 3, delay = 1)
ltc_1d_candles = get_candles_with_retry(pair="LTC-USD", numcandles=300, timeframe="1d", retries = 3, delay = 1)


###################
## Crossovers
###################
library(xts)
btc_xts <- xts(btc_1d_candles[, c("open", "high", "low", "close", "volume")], order.by = as.POSIXct(btc_1d_candles[,1], origin = "1970-01-01", tz = "UTC"))
colnames(btc_xts) <- c("Open", "High", "Low", "Close", "Volume")
chartSeries(btc_xts)
EMA_FAST = EMA(Cl(btc_xts),n=20)
EMA_SLOW = EMA(Cl(btc_xts),n=50)

addTA(ts(EMA_FAST),on=1,col="blue")
addTA(ts(EMA_SLOW),on=1,col="red")

###################
## Correlation analysis
###################

returns_matrix = cbind(returns(eth_1d_candles), returns(btc_1d_candles), returns(link_1d_candles), returns(sol_1d_candles), returns(ltc_1d_candles))
colnames(returns_matrix) = c("ETH", "BTC", "LINK", "SOL","LTC")
#Original correltions plot
#chart.Correlation(returns_matrix)

#New correlations plot
cor_mat <- cor(returns_matrix, use = "pairwise.complete.obs")
corrplot(cor_mat, method = "color", 
         col = colorRampPalette(c("#ff0000ff", "#264a2dff", "#00ff48ff"))(200),
         title = "Infinite Trading Crypto Correlations",
         mar = c(0,0,2,0), # top margin for title
         addCoef.col = "black", # show correlation coefficients
         tl.col = "black", tl.srt = 45, # label color and rotation
         cl.cex = 1.2, tl.cex = 1.2, number.cex = 1.2)

