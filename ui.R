# ui.R
shinyUI(pageWithSidebar(
  headerPanel("FantasyQuantLab"),
  
  sidebarPanel(
    radioButtons("dfs_site", "DFS Site",
                          c("DraftKings" = "1",
                            "FanDuel" = "2")) 
    
   , radioButtons("dfs_slate", "NFL Slate",
                 c("All NFL Games - 16 gms" = "1",
                   "Sunday Only - 14 gms" = "2",
                   "Sunday Early Games - 11 gms" = "3",
                   "Sunday Primetime + MNF - 2 gms" = "4")) 
    
    , checkboxGroupInput("dfs_flex", "Flex Position",
                       c("RB" = "1",
                         "WR" = "2",
                         "TE" = "3") ,
                      selected = c("RB", "WR", "TE"))  
   
   , radioButtons("dfs_contest", "Contest",
                  c("50/50 Double-Up - Top 50% Win" = "1",
                    "Cash Tournament - Top 20% Payout w $1 million Top Prize" = "2")) 
    
    , selectInput("dfs_model", 
                    label = "Choose an optimization model ",
                    choices = list("Bayesian Basset" ,"Cash Game Model", "Tournament Model"),
                    selected = "Bayesian Basset")
    
    , sliderInput('mu', 'Guess at the mean placement',value = 70, min = 62, max = 74, step = 0.05,)
   
   , submitButton("Submit")
  ),
  
  mainPanel(
    verbatimTextOutput("summary")
    
    , plotOutput('newHist')
  )
))