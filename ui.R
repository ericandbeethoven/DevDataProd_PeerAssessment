# ui.R
shinyUI(pageWithSidebar(
  headerPanel("FantasyQuantLab"),
  
  sidebarPanel(
    radioButtons("dfs_site", "DFS Site",
                          c("DraftKings" = "1",
                            "FanDuel" = "2")) 
    
    , radioButtons("dfs_contest", "Contest",
                   c("50/50 Double-Up - Top 50% Win" = "1",
                     "Cash Tournament - Top 20% Payout w $1 million Top Prize" = "2")) 
    
     , radioButtons("dfs_slate", "NFL Slate",
                 c("All NFL Games - 16 gms" = "1",
                   "Sunday Only - 14 gms" = "2",
                   "Sunday Early Games - 11 gms" = "3",
                   "Sunday Primetime + MNF - 2 gms" = "4")) 
    
   
  
    , selectInput("dfs_model", 
                    label = "Choose an optimization model ",
                    choices = list("Bayesian Basset" ,"Cash Game Model", "Tournament Model"),
                    selected = "Bayesian Basset")
    
    , sliderInput('mu', 'Guess at the money target',value = 140, min = 90, max = 200, step = 2.5)
   
   , submitButton("Submit")
  ),
  
  mainPanel(
    h3("Optimal Lineup")
    , verbatimTextOutput("optimal_lineup")
    , h4("Site and Slate")
    , verbatimTextOutput("summary1")
    , h4("Summary Statistics")
    , verbatimTextOutput("summary2")
    , h4("Contest Targets")
    , verbatimTextOutput("summary3")
    , plotOutput('ffpgdistplot')
  )
))