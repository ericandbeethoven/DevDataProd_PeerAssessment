# server.R
shinyServer(
  function(input, output) {
  
    
      output$optimal_lineup <- renderPrint({
        # check for the input variable
        if (input$dfs_site == 1) {
          # DraftKings
          dataset <- dk_opt 
        }
        else {
          # FanDuel
          dataset <- fd_opt 
        }
        dataset[,2:6]
      })
      
      output$summary1 <- renderPrint({
        # check for the input variable
        if (input$dfs_site == 1) {
          # DraftKings
          dataset <- dk_opt_summary 
        }
        else {
          # FanDuel
          dataset <- fd_opt_summary 
        }
        dataset[,1:2]
      })
        
      output$summary2 <- renderPrint({
        # check for the input variable
        if (input$dfs_site == 1) {
          # DraftKings
          dataset <- dk_opt_summary 
        }
        else {
          # FanDuel
          dataset <- fd_opt_summary 
        }
        dataset[,3:6]
      })
    
      output$summary3 <- renderPrint({
        # check for the input variable
        if (input$dfs_site == 1) {
          # DraftKings
          dataset <- dk_opt_summary 
        }
        else {
          # FanDuel
          dataset <- fd_opt_summary 
        }
        dataset[,7:9]
      })
        
      output$ffpgdistplot <- renderPlot(function() {
        mu = input$mu
        # check for the input variable
        if (input$dfs_site == 1) {
          # DraftKings
          pts = dk_opt_summary[1,4]
          sd = dk_hist_stdev
          tcash = dfs_contest_itm[1,3]
          ttourney = dfs_contest_itm[2,3]
          p = dk_plot + 
            geom_text(x=40, y=c(.0030, 0.0025), hjust = 0, 
                                  label=c(paste("Optimized Pts = ", round(pts, 0)), paste("StDev = ", round(sd, 2)))) +
            geom_text(x=40, y=c(.002, 0.0015), hjust = 0, 
                      colour="green", label=c(paste("Cash Gm Target Pts = ", round(tcash, 0)), paste("Tourney Target Pts = ", round(ttourney, 2)))) +
            geom_text(x=40, y=.001, hjust = 0, 
                      colour = "red", label=c(paste("My Target = ", round(mu, 0)))) 
          
          }
        
        else {
          # FanDuel
          pts = fd_opt_summary[1,4]
          sd  = fd_hist_stdev
          tcash = dfs_contest_itm[3,3]
          ttourney = dfs_contest_itm[4,3]
          p = fd_plot + 
            geom_text(x=25, y=c(.0040, 0.0035), hjust = 0, 
                      label=c(paste("Optimized Pts = ", round(pts, 0)), paste("StDev = ", round(sd, 2)))) +
            geom_text(x=25, y=c(.003, 0.0025), hjust = 0, 
                      colour="green", label=c(paste("Cash Gm Target Pts = ", round(tcash, 0)), paste("Tourney Target Pts = ", round(ttourney, 2)))) +
            geom_text(x=25, y=.0020, hjust = 0, 
                      colour = "red", label=c(paste("My Target = ", round(mu, 0)))) 
          
                      
        }
       
        p = p + ylab("") + ggtitle("Optimized Lineup Point Distribution") +
          theme_bw() +  theme(plot.title = element_text(lineheight=1.2, face="bold")) +
          geom_vline(xintercept = c(pts, tcash, ttourney, mu) ,
                        colour=c("black",  "green", "green", "red") , lwd = 1.25,
                        linetype = c("solid", "longdash", "longdash", "dotdash"))
         
        print(p)
         
         
      })
      
  }
)