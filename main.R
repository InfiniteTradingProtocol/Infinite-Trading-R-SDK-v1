#### Main file to load the Infinite Trading R-SDK-v1 ####

#Set your proper working directoty (the folder where this repository is)
wd = "C:/GitHub/Infinite-Trading-R-SDK-v1/"

#Dependencies
require(dotenv)
#Load all dependencies.
source(paste0(wd,"/src/coinbase.R"))
source(paste0(wd,"/src/api.R"))

#Load your environmental variable.
load_dot_env(paste0(,wd,".env"))
API_KEY = Sys.getenv("API_KEY")

