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
    
    , sliderInput('mu', 'Guess contest money target',value = 140, min = 90, max = 200, step = 2.5)
   
   , submitButton("Submit")
   
  ),
  
  mainPanel(
    tabsetPanel(
    tabPanel("Lineup"
    , h3("Optimal Lineup")
    , verbatimTextOutput("optimal_lineup")),
    
    tabPanel("Summary"
             , h4("Site and Slate")
             , verbatimTextOutput("summary1")
             , h4("Summary Metrics")
             , verbatimTextOutput("summary2")
             , h4("Contest Targets")
             , verbatimTextOutput("summary3")
             , h4("")
             , h4("")
             , ("Note 1: Summary Metrics show Lineup Salary, Lineup Points and Upside / Downside based on historical lineup risk. A better model would capture individual player risk thus reducing downside.")
             , h4("")
             , ("Note 2: Contest Targets show historical point targets required to win cash payout for Double-up, Top 20% Tournament and First Place Tournament.")
             ),
    
    
    tabPanel("Plot"
             , plotOutput('ffpgdistplot')),
    
    tabPanel("User Documentation"
             ,  h3("Supporting Documentation")
             , ("Instructions the user will need to get started using this application.")
             , h4("")
             , h4("1. Select desired DFS Site.")
             , h4("2. Optionally select a guess for contest money target. (See Note 1)")
             , h4("3. Note Contest, NFL Slate and Optimization Model are for UI Demonstration only. No functionality in this Proof of Concept version.")
             , h4("4. Click Submit. Reactive Output will display on respective tabs.")
             , h4("5. Optimized Lineup appears on Lineup tab.")
             , h4("6. Summary Lineup Metrics appear on Summary tab.")
             , h4("5. Optimized Lineup Point Distribution appears on Plot tab.")
             , h4("")
             , ("Note 1: Contest Money Target is the Score required to win a Cash payout. This changes throughout the season due to a number of factors such as less experienced players leaving contests.")
             ))
    
    
    )
))
