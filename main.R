#### Main file to load the Infinite Trading R-SDK-v1 ####

#Set your proper working directoty (the folder where this repository is)

wd = "C:/Users/17872/OneDrive/Documents/GitHub/Infinite-Trading-R-SDK-v1/"
URL = "https://api.infinitetrading.io/"

#Load your environmental variable.
load_dot_env(paste0(wd,".env"))
API_KEY = Sys.getenv("APIKEY")

#Dependencies
#install.packages("dotenv")
#install.packages("httr")

require(dotenv); require(httr)
#Load all dependencies.
source(paste0(wd,"src/coinbase.R"))
source(paste0(wd,"src/api.R"))


