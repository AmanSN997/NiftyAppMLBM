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
      print(e) # Add this line
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
