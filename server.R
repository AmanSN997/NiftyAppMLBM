# server.R
source("dependencies.R")
library(shiny)
library(quantmod)
library(tidyverse)
library(lubridate)
library(plotly)
library(DT) # For data tables with conditional formatting
server <- function(input, output) {

  stock_data <- eventReactive(input$fetch_data, {
    req(input$stock, input$start_date, input$end_date)
    tryCatch({
      getSymbols(input$stock, from = input$start_date, to = input$end_date, auto.assign = FALSE)
    }, error = function(e) {
      showNotification(paste("Error fetching data:", e$message), type = "error")
      return(NULL)
    })
  })

  nifty_data <- eventReactive(input$fetch_data, {
    req(input$start_date, input$end_date)
    tryCatch({
      getSymbols("^NSEI", from = input$start_date, to = input$end_date, auto.assign = FALSE)
    }, error = function(e) {
      showNotification(paste("Error fetching Nifty data:", e$message), type = "error")
      return(NULL)
    })
  })

  output$stock_plot <- renderPlot({
    data <- stock_data()
    if (!is.null(data)) {
      chartSeries(data, name = input$stock)
    }
  })

  output$stock_table <- renderDataTable({
    data <- stock_data()
    if (!is.null(data)) {
      as.data.frame(data)
    }
  })

  output$relative_plot <- renderPlot({
    stock <- stock_data()
    nifty <- nifty_data()

    if (!is.null(stock) && !is.null(nifty)) {
      stock_returns <- dailyReturn(stock)
      nifty_returns <- dailyReturn(nifty)

      returns_df <- merge.xts(stock_returns, nifty_returns)
      colnames(returns_df) <- c("Stock", "Nifty")

      returns_df <- as.data.frame(returns_df)

      if (nrow(returns_df) > 0) {
        plot(returns_df$Stock, type = "l", col = "blue", ylab = "Daily Returns", xlab = "Date", main = "Stock vs. Nifty Returns")
        lines(returns_df$Nifty, col = "red")
        legend("topright", legend = c(input$stock, "Nifty 50"), col = c("blue", "red"), lty = 1)
      }
    }
  })

  output$stock_nifty_plot <- renderPlotly({
    stock <- stock_data()
    nifty <- nifty_data()

    if (!is.null(stock) && !is.null(nifty)) {
      stock_close <- Cl(stock)
      nifty_close <- Cl(nifty)

      stock_df <- data.frame(Date = index(stock_close), Stock = as.numeric(stock_close))
      nifty_df <- data.frame(Date = index(nifty_close), Nifty = as.numeric(nifty_close))

      p <- plot_ly(stock_df, x = ~Date, y = ~Stock, type = 'scatter', mode = 'lines', name = input$stock, yaxis = "y2", line = list(color = "blue")) %>%
        add_trace(data = nifty_df, x = ~Date, y = ~Nifty, type = 'scatter', mode = 'lines', name = "Nifty 50", yaxis = "y1", line = list(color = "red")) %>%
        layout(
          yaxis = list(title = "Nifty 50 Price"),
          yaxis2 = list(title = paste(input$stock, "Price"), overlaying = "y", side = "right"),
          title = paste(input$stock, " vs. Nifty 50 Price")
        )
      p
    }
  })

  output$daily_changes_table <- renderDataTable({
    all_changes <- lapply(nifty_symbols, function(symbol) {
      tryCatch({
        data <- getSymbols(symbol, from = Sys.Date() - 1, to = Sys.Date(), auto.assign = FALSE)
        if (nrow(data) > 1) {
          prev_close <- Cl(data)[1] # Previous day's closing price
          curr_close <- Cl(data)[2] # Current day's closing price
          change <- curr_close - prev_close
          change_percent <- (change / prev_close) * 100
          data.frame(Symbol = symbol, Change = change, ChangePercent = change_percent)
        } else {
          data.frame(Symbol = symbol, Change = NA, ChangePercent = NA)
        }
      }, error = function(e) {
        data.frame(Symbol = symbol, Change = NA, ChangePercent = NA)
      })
    })

    changes_df <- do.call(rbind, all_changes)

    datatable(changes_df, options = list(pageLength = 50)) %>%
      formatStyle(
        'Change',
        backgroundColor = styleInterval(0, c('red', 'lightgreen'))
      )
  })
}
