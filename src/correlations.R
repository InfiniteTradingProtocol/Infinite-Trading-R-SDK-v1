# ------------------------------------------------------------------------------
# File: correlations.R
# Author: etherpilled
# Project: Infinite Trading Protocol
#
# Description:
# This script defines a function to download historical financial data for a specified
# set of global indices, commodities, and futures from Yahoo Finance, computes monthly 
# returns, and visualizes their pairwise correlation using a correlation matrix.
# The function 'correlation(symbols)' is parameterized for asset flexibility.
#
# Dependencies:
# - PerformanceAnalytics
# - quantmod
# - xts
# ------------------------------------------------------------------------------

# Load necessary packages
require(PerformanceAnalytics)
require(quantmod)
require(xts)

# ------------------------------------------------------------------------------
# Helper Function: Format OHLC xts object to a standardized dataframe
# ------------------------------------------------------------------------------
format_xts_ohlc <- function(OHLC) {
  OHLC <- data.frame(time = index(OHLC), Value = coredata(OHLC))
  time <- OHLC[,1]
  open <- OHLC[,2]
  low <- OHLC[,4]
  close <- OHLC[,5]
  high <- OHLC[,3]
  vol <- OHLC[,6]
  OHLC <- cbind(time, low, high, open, close, vol)
  colnames(OHLC) <- c("time", "low", "high", "open", "close", "volume")
  return(OHLC)
}

# ------------------------------------------------------------------------------
# Helper Function: Compute monthly returns from OHLC data
# ------------------------------------------------------------------------------
returns <- function(OHLC) { 
  return((Cl(OHLC) - Op(OHLC)) / Op(OHLC))
}

# ------------------------------------------------------------------------------
# Main Function: correlation(symbols)
# Downloads, processes, and visualizes correlations for given symbols.
# ------------------------------------------------------------------------------
correlation <- function(symbols, start_date = "2008-01-01", end_date = "2023-11-01") {
  # Downloads and processes symbol data into monthly OHLC and returns
  symbol_data <- list()
  for (symbol in symbols) {
    getSymbols(symbol, from = start_date, to = end_date, src = "yahoo", auto.assign = TRUE)
    # Use correct variable name for futures (they get assigned as `SYMBOL`)
    obj_name <- if (grepl("=F$", symbol)) paste0("`", symbol, "`") else symbol
    asset_xts <- eval(parse(text = obj_name))
    # Convert to monthly
    asset_monthly <- to.monthly(asset_xts, OHLC = TRUE, indexAt = "endof")
    symbol_data[[symbol]] <- asset_monthly
  }
  # Compute returns and merge
  return_matrix <- do.call(cbind, lapply(symbol_data, returns))
  # Clean up column names for readability
  colnames(return_matrix) <- symbols
  # Visualize correlation matrix
  chart.Correlation(return_matrix)
  # Return matrix (optional, for further use)
  invisible(return_matrix)
}

# ------------------------------------------------------------------------------
# Example Use Case (matches original script assets)
# ------------------------------------------------------------------------------
default_symbols <- c(
  "ES=F",        # S&P 500 E-mini Futures
  "NQ=F",        # Nasdaq 100 E-mini Futures
  "^FTSE",       # FTSE 100 Index
  "^FCHI",       # CAC 40 Index
  "^GDAXI",      # DAX Index
  "DX=F",        # U.S. Dollar Index Futures
  "ZN=F",        # 10-Year U.S. Treasury Note Futures
  "CL=F",        # Crude Oil Futures (WTI)
  "GC=F"         # COMEX Gold Futures
)

correlation(default_symbols)
