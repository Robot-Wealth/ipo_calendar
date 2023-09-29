readRenviron(".Renviron")
KEY <- Sys.getenv("FINNHUB_KEY")

library(shiny)
library(shinyalert)
library(jsonlite)
library(httr)


# Define the UI
ui <- fluidPage(
  titlePanel(
      HTML("IPO Calendar <br> <small>Past/upcoming IPOs around selected date</small>"),
      windowTitle = "IPO Calendar"
    ),
  
  tags$style(
    HTML("
    .date-box {
      width: 180px;
      height: 180px;
      border: 1px solid #ccc;
      display: inline-block;
      margin: 5px;
      text-align: center;
      vertical-align: top;
      font-size: 14px;
      line-height: 1.5em;
      background-color: #FFEEDE; 
    }
    .highlighted {
      background-color: #FFDDC1;
      font-weight: bold;
      border: 3px solid #FFBB99; 
    }
    .sidebar {
      width: 15%;
    }
  ")
  ),
  
  fluidRow(
    column(
      2, 
      class = "sidebar",
      dateInput("date", "Select a date:", format = "yyyy-mm-dd")
    ),
    column(
      10, 
      uiOutput("calendar")
    )
  )
)

server <- function(input, output) {
  
  fetch_ipo_data <- function(from, to) {
    base_url <- "https://finnhub.io/api/v1/calendar/ipo"
    api_key <- KEY
    request_url <- sprintf("%s?from=%s&to=%s&token=%s", base_url, from, to, api_key)
    response <- GET(request_url)
    data <- fromJSON(content(response, "text"))
    return(data$ipoCalendar)
  }
  
  output$calendar <- renderUI({
    selected_date <- input$date
    
    from <- as.Date(selected_date) - 25
    to <- as.Date(selected_date) + 5
    
    ipo_data <- fetch_ipo_data(from, to)
    
    date_range <- seq(from, to, by = "1 day")
    
    ui_elements <- lapply(date_range, function(date_current) {
      date_text <- div(as.character(date_current))
      
      ipos_on_date <- subset(ipo_data, date == as.character(date_current))
      ticker_links <- if (nrow(ipos_on_date) > 0) {
        lapply(1:nrow(ipos_on_date), function(row_num) {
          ipo <- ipos_on_date[row_num,]
          # alert_text <- sprintf(
          #   "Symbol: %s, Name: %s, Price: %s, Date: %s, Exchange: %s, Shares: %s, Total Value: %s",
          #   ipo$symbol, ipo$name, ipo$price, ipo$date,
          #   ipo$exchange, ipo$numberOfShares, ipo$totalSharesValue
          # )
          alert_text <- sprintf(
            "Symbol: %s\\nName: %s\\nPrice: %s\\nDate: %s\\nExchange: %s\\nShares: %s\\nTotal Value: %s",
            ipo$symbol, ipo$name, ipo$price, ipo$date, ipo$exchange, ipo$numberOfShares, ipo$totalSharesValue
          )
          
          
          return(tags$a(
            href = "#",
            onclick = sprintf("Shiny.setInputValue('show_alert', {alert_text: '%s'}, {priority: 'event'}); return false;", alert_text),
            ipo$symbol, 
            br() # The br() ensures that each ticker is on a new line.
          ))
        })
      } else {
        NULL
      }
      
      return(
        div(
          class = ifelse(date_current == as.Date(selected_date), "date-box highlighted", "date-box"),
          date_text,
          ticker_links
        )
      )
    })
    return(ui_elements)
  })
  
  observeEvent(input$show_alert, {
    shinyalert::shinyalert(
      title = "IPO Details", 
      text = input$show_alert$alert_text, 
      type = "info"
    )
  })
}

# Run the app
shinyApp(ui, server)

