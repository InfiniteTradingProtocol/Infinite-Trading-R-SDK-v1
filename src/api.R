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

# build path to endpoints folder
endpoints_dir <- file.path(wd, "src", "endpoints")

# list all .R files in the folder
r_files <- list.files(endpoints_dir, pattern = "\\.R$", full.names = TRUE)

# source each file
sapply(r_files, source)
