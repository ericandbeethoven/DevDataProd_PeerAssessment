# global.R
library(shiny)
library(ggplot2)
library(Rglpk)
library(UsingR)


#####################################
# DATA LOAD
#####################################
# Fantasy Football Data is for games played 13-14 Dec 2015
data(galton)
# player data
draftkings = read.csv("./data/dk_players.csv", header = TRUE, sep = ",") 
fanduel = read.csv("./data/fd_players.csv", header = TRUE, sep = ",")
# position analytics
dk_positions = read.csv("./data/dk_position_analytics.csv", header = TRUE, sep = ",") 
fd_positions = read.csv("./data/fd_position_analytics.csv", header = TRUE, sep = ",") 
# contest analytics
dfs_contest_itm = read.csv("./data/dfs_contest_itm.csv", header = TRUE, sep = ",") 


#####################################
# DRAFTKINGS optimization
#####################################
# number of variables
num.players = length(draftkings$Name)
# objective:
obj = draftkings$FPPG
# the vars are represented as booleans
var.types = rep("B", num.players)
# the constraints
matrix = rbind(as.numeric(draftkings$Position == "QB"), # num QB
                as.numeric(draftkings$Position == "RB"), # num RB
                as.numeric(draftkings$Position == "RB"), # num RB
                as.numeric(draftkings$Position == "WR"), # num WR
                as.numeric(draftkings$Position == "WR"), # num WR
                as.numeric(draftkings$Position == "TE"), # num TE
                as.numeric(draftkings$Position == "TE"), # num TE
                as.numeric(draftkings$Position %in% c("RB", "WR", "TE")),  # FLEX Num RB/WR/TE
                as.numeric(draftkings$Position == "DST"),# num DEF
                draftkings$Salary)                       # total cost
direction = c("==",
               ">=",
               "<=",
               ">=",
               "<=",
               ">=",
               "<=",
               "==",
               "==",
               "<=")
rhs = c(1, # QB
         2, # RB Min
         3, # RB Max
         3, # WR Min
         4, # WR Max
         1, # TE Min
         2, # TE Max
         7, # RB/WR/TE
         1, # DST
         50000) 
# solve model
dk_sol = Rglpk_solve_LP(obj = obj, mat = matrix, dir = direction, rhs = rhs,
                               types = var.types, max = TRUE)

# extract solution
dk_opt = draftkings[dk_sol$solution==1,]
dk_opt_TotSalary = sum(dk_opt$Salary)
dk_opt_TotFPPG = sum(dk_opt$FPPG)

#####################################
# FANDUEL optimization
#####################################

# number of variables
num.players = length(fanduel$Name)
# objective:
obj = fanduel$FPPG
# the vars are represented as booleans
var.types = rep("B", num.players)
# the constraints
matrix = rbind(as.numeric(fanduel$Position == "QB"), # num QB
               as.numeric(fanduel$Position == "RB"), # num RB
               as.numeric(fanduel$Position == "WR"), # num WR
               as.numeric(fanduel$Position == "TE"), # num TE
               as.numeric(fanduel$Position == "K"), # num TE
               as.numeric(fanduel$Position == "DST"),# num DEF
               fanduel$Salary)                       # total cost
direction = c("==",
              "==",
              "==",
              "==",
              "==",
              "==",
              "<=")
rhs = c(1, # QB
        2, # RB
        3, # WR
        1, # TE
        1, # K
        1, # DST
        60000) 
# solve model
fd_sol = Rglpk_solve_LP(obj = obj, mat = matrix, dir = direction, rhs = rhs,
                        types = var.types, max = TRUE)

# extract solution
fd_opt = fanduel[fd_sol$solution==1,]
fd_opt_TotSalary = sum(fd_opt$Salary)
fd_opt_TotFPPG = sum(fd_opt$FPPG)


#####################################
# PLOTS
#####################################
# FD 180 is Best score, 25 is Worst Score, 100 last winning pos in FD 50/50

dk_plot = ggplot(data.frame(x = c(25, 180)), aes(x)) + stat_function(fun = dnorm, args = list(mean = 100, sd = .5))


