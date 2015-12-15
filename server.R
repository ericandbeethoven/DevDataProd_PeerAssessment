# server.R
shinyServer(
  function(input, output) {
    output$summary <- renderPrint({
      dataset <- dk_opt 
      # dataset <- Data()
      dataset[,2:6]
    })
    
    output$newHist <- renderPlot({
      hist(galton$child, xlab='Decile Placement', col='lightblue',main=' DFS Result Histogram')
      mu <- input$mu
      lines(c(mu, mu), c(0, 200),col="red",lwd=5)
      mse <- mean((galton$child - mu)^2)
      text(63, 150, paste("mu = ", mu))
      text(63, 140, paste("MSE = ", round(mse, 2)))
    })
    
  }
)