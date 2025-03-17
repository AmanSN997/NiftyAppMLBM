# ui.R

library(shiny)

# Predefined Nifty 50 company symbols
nifty_symbols <- c(
  "RELIANCE.NS", "TCS.NS", "HDFCBANK.NS", "INFY.NS", "ICICIBANK.NS",
  "HINDUNILVR.NS", "KOTAKBANK.NS", "BAJFINANCE.NS", "LT.NS", "AXISBANK.NS",
  "BHARTIARTL.NS", "ASIANPAINT.NS", "MARUTI.NS", "TITAN.NS", "ULTRACEMCO.NS",
  "NESTLEIND.NS", "WIPRO.NS", "POWERGRID.NS", "NTPC.NS", "SBIN.NS",
  "ADANIPORTS.NS", "HCLTECH.NS", "JSWSTEEL.NS", "GRASIM.NS", "BAJAJFINSV.NS",
  "M&M.NS", "HDFC.NS", "ONGC.NS", "TATACONSUM.NS", "TECHM.NS",
  "DIVISLAB.NS", "CIPLA.NS", "ADANIENT.NS", "EICHERMOT.NS", "LTIM.NS",
  "SHREECEM.NS", "COALINDIA.NS", "HEROMOTOCO.NS", "BPCL.NS", "SUNPHARMA.NS",
  "TATAMOTORS.NS", "INDUSINDBK.NS", "DRREDDY.NS", "IOC.NS", "UPL.NS",
  "APOLLOHOSP.NS", "SBILIFE.NS", "HINDALCO.NS", "TATSTEEL.NS", "ADANIPOWER.NS"
)

ui <- fluidPage(
  titlePanel("Nifty 50 Stock Data"),

  sidebarLayout(
    sidebarPanel(
      selectInput("stock", "Select Stock:", choices = nifty_symbols),
      dateInput("start_date", "Start Date:", value = Sys.Date() - 365),
      dateInput("end_date", "End Date:", value = Sys.Date()),
      actionButton("fetch_data", "Fetch Data")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Stock Chart", plotOutput("stock_plot"), dataTableOutput("stock_table")),
        tabPanel("Relative Performance", plotOutput("relative_plot")),
        tabPanel("Stock vs Nifty", plotlyOutput("stock_nifty_plot")),
        tabPanel("Daily Changes", dataTableOutput("daily_changes_table")) # New tab
      )
    )
  )
)
