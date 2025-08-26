# Infinite Trading R SDK

This SDK provides tools to simplify interaction with the **Infinite Trading API** and to streamline the development of trading strategies using **R**.

---

## 🚀 Features

* Easy authentication with your Infinite Trading API key
* Helpers for strategy development in R
* Simple environment setup

---

## 📦 Installation

1. **Install R** (and optionally [RStudio](https://posit.co/download/rstudio/))
2. **Clone this repository** to your local machine:

   ```bash
   git clone https://github.com/InfiniteTradingProtocol/Infinite-Trading-R-SDK-v1.git
   ```

---

## 🔑 Getting Your API Key

1. Go to [infinitetrading.io/managers](https://infinitetrading.io/managers)
2. Connect your wallet and sign the message
3. Generate your **Gas Wallet** → this will provide your **API key**

---

## ⚙️ Setup

1. Open the file `main.R`

   * Add the directory containing this repository
   * Use `/` instead of `\` for file paths

2. Open the `.env` file and add your API key:

   ```ini
   API_KEY="your_api_key_here"
   ```

---

## 🧑‍💻 Usage

Once installed and configured, you can begin writing trading strategies directly in R using the Infinite Trading API.
For example:

```r
# Replace this with your current directory or just source("main.R") if you set on R-Studio the working directory as the repository folder.
source("C:/Users/YourUser/Documents/GitHub/Infinite-Trading-R-SDK-V1/main.R")


```

---

## 📝 Strategies

* There is a pre-made ETH-USD 6H EMA Crossover Strategy that you can modify and use to trade using our API. `Strategies/WETH-USDC.R`).
* API requests require your wallet to be funded for transactions (Requires ETH on Optimism/Base/Arbitrum/Ethereum and POL on Polygon).

---

## 📝 Notes

* Ensure your `.env` file is not shared or committed to version control (add it to `.gitignore`).
* API requests require your wallet to be connected and funded for gas transactions.

---

