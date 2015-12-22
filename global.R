# global.R
library(shiny)
library(ggplot2)
library(Rglpk)



#####################################
# DATA LOAD
#####################################
# Fantasy Football Data is for games played 13-14 Dec 2015
data(galton)
# player data
draftkings = read.csv("./data/dk_players.csv", header = TRUE, sep = ",") 
fanduel = read.csv("./data/fd_players.csv", header = TRUE, sep = ",")
names(fanduel)[1]<-paste("PosID") # Standardize column names
# position analytics
dk_positions = read.csv("./data/dk_position_analytics.csv", header = TRUE, sep = ",") 
fd_positions = read.csv("./data/fd_position_analytics.csv", header = TRUE, sep = ",") 
# contest analytics
dfs_contest_itm = read.csv("./data/dfs_contest_itm.csv", header = TRUE, sep = ",") 

#####################################
# Initialize Model Parameters
#####################################

z_score = 0.674 # 50% confidence interval

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

# extract summary
dk_opt_summary = data.frame(
  site = "DraftKings",
  slate = "14 NFL Games - Dec 13-14, 2015",
  salary = sum(dk_opt$Salary),
  opt_points = sum(dk_opt$FPPG), 
  opt_upside = sum(dk_opt$FPPG) + z_score * (sum(dk_opt$PosID==1)*dk_positions[1,3] + 
                                            sum(dk_opt$PosID==2)*dk_positions[2,3] +
                                            sum(dk_opt$PosID==3)*dk_positions[3,3] +
                                            sum(dk_opt$PosID==4)*dk_positions[4,3] +
                                            sum(dk_opt$PosID==5)*dk_positions[5,3] 
                                          ) , 
  opt_downside = sum(dk_opt$FPPG) - z_score * (sum(dk_opt$PosID==1)*dk_positions[1,3] + 
                                            sum(dk_opt$PosID==2)*dk_positions[2,3] +
                                            sum(dk_opt$PosID==3)*dk_positions[3,3] +
                                            sum(dk_opt$PosID==4)*dk_positions[4,3] +
                                            sum(dk_opt$PosID==5)*dk_positions[5,3] 
  ) , 
  target_5050 = 150 ,
  target_tourney_t20pct = 180 ,
  target_tourney_1st = 200
)


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

# extract summary
fd_opt_summary = data.frame(
  site = "FanDuel",
  slate = "14 NFL Games - Dec 13-14, 2015",
  salary = sum(fd_opt$Salary),
  opt_points = sum(fd_opt$FPPG), 
  opt_upside = sum(fd_opt$FPPG) + z_score * (sum(fd_opt$PosID==1)*fd_positions[1,3] + 
                                            sum(fd_opt$PosID==2)*fd_positions[2,3] +
                                            sum(fd_opt$PosID==3)*fd_positions[3,3] +
                                            sum(fd_opt$PosID==4)*fd_positions[4,3] +
                                            sum(fd_opt$PosID==5)*fd_positions[5,3] +
                                            sum(fd_opt$PosID==6)*fd_positions[6,3]
  ) , 
  opt_downside = sum(fd_opt$FPPG) - z_score * (sum(fd_opt$PosID==1)*fd_positions[1,3] + 
                                              sum(fd_opt$PosID==2)*fd_positions[2,3] +
                                              sum(fd_opt$PosID==3)*fd_positions[3,3] +
                                              sum(fd_opt$PosID==4)*fd_positions[4,3] +
                                              sum(fd_opt$PosID==5)*fd_positions[5,3] +
                                              sum(fd_opt$PosID==6)*fd_positions[6,3]
  ) , 
  target_5050 = 120 ,
  target_tourney_t20pct = 150 ,
  target_tourney_1st = 180
)


#####################################
# PLOTS
#####################################
# FD 180 is Best score, 25 is Worst Score, 100 last winning pos in FD 50/50
dk_hist_mean = (sum(dk_opt$PosID==1)*dk_positions[1,2] + 
                  sum(dk_opt$PosID==2)*dk_positions[2,2] +
                  sum(dk_opt$PosID==3)*dk_positions[3,2] +
                  sum(dk_opt$PosID==4)*dk_positions[4,2] +
                  sum(dk_opt$PosID==5)*dk_positions[5,2] 
)

dk_hist_stdev = (sum(dk_opt$PosID==1)*dk_positions[1,3] + 
                   sum(dk_opt$PosID==2)*dk_positions[2,3] +
                   sum(dk_opt$PosID==3)*dk_positions[3,3] +
                   sum(dk_opt$PosID==4)*dk_positions[4,3] +
                   sum(dk_opt$PosID==5)*dk_positions[5,3] 
)

dk_plot = ggplot(data.frame(x = c(dk_hist_mean - 1.5*dk_hist_stdev, dk_hist_mean + 1.5*dk_hist_stdev)), aes(x)) +
  stat_function(fun = dnorm, args = list(mean = dk_hist_mean, sd = dk_hist_stdev)) + 
   scale_x_continuous(limits=c(0, 225), breaks = seq(0, 225, length = 10)) + 
  scale_y_continuous(limits=c(0, 0.006), breaks = seq(0, 0.006, length = 7)) +
  xlab("DraftKings")


fd_hist_mean = (sum(fd_opt$PosID==1)*fd_positions[1,2] + 
                  sum(fd_opt$PosID==2)*fd_positions[2,2] +
                  sum(fd_opt$PosID==3)*fd_positions[3,2] +
                  sum(fd_opt$PosID==4)*fd_positions[4,2] +
                  sum(fd_opt$PosID==5)*fd_positions[5,2] +
                  sum(fd_opt$PosID==6)*fd_positions[6,2]
)

fd_hist_stdev = (sum(fd_opt$PosID==1)*fd_positions[1,3] + 
                   sum(fd_opt$PosID==2)*fd_positions[2,3] +
                   sum(fd_opt$PosID==3)*fd_positions[3,3] +
                   sum(fd_opt$PosID==4)*fd_positions[4,3] +
                   sum(fd_opt$PosID==5)*fd_positions[5,3] +
                   sum(fd_opt$PosID==6)*fd_positions[6,3]
)

fd_plot = ggplot(data.frame(x = c(fd_hist_mean - 1.5*fd_hist_stdev, fd_hist_mean + 1.5*fd_hist_stdev)), aes(x)) + 
  stat_function(fun = dnorm, args = list(mean = fd_hist_mean, sd = fd_hist_stdev)) +
  scale_x_continuous(limits=c(0, 225), breaks = seq(0, 200, length = 9)) + 
  scale_y_continuous(limits=c(0, 0.008), breaks = seq(0, 0.008, length = 9)) + 
  xlab("FanDuel")



