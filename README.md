# IPO Calendar Shiny App
This Shiny application provides an interactive calendar that highlights past and upcoming IPOs within a given date range. The data for the IPOs is sourced from the FinnHub API.

## Setup
FinnHub API Key: Before deploying or running the app, ensure you have a FinnHub API key. You can obtain it by signing up at finnhub.io. The IPO calendar uses a free endpoint.

.Renviron File: Create a .Renviron file in the project root directory with the following content:

```
FINNHUB_KEY=your_finnhub_key_here
```

Replace your_finnhub_key_here with your actual FinnHub API key.

## Local Execution
To run the app locally, navigate to the project directory and execute:

```R
shiny::runApp()
```
Ensure you have all the required R packages installed:

```
shiny
shinyalert
jsonlite
httr
```
## Deployment
To deploy the app to shinyapps.io:

Install and load the `rsconnect` package.

Authenticate with your shinyapps.io account using `rsconnect::setAccountInfo()`.

Deploy the app using:

```R
rsconnect::deployApp(
  appDir = ".", 
  appFiles = c("app.R", ".Renviron),
  account = "your_account_name_here"
)
```
Replace `your_account_name_here` with your shinyapps.io account name.

License
This project is open-sourced under the MIT License.
