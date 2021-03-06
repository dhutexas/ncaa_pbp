######################## Complete Bracket with Predictions ####################
#' Fill out the 64 team tournament bracket with predictions
#' from zachmayer/kaggleNCAA on github, updated by Derek J. Hanson
#'
#' @title Generate a printable NCAA bracket of predicted winners
#'
#' @description Given an NCAA tournament bracket (a list of slots and who won
#' the game) this function will plot the bracket in a way that can be printed
#' off.
#'
#' @param bracket A bracket to print off
#'
#' @import data.table graphics dplyr
#' @importFrom magrittr %>% %<>%
#'
#' @return NULL
#' @export
#' @references
#' \url{http://www.kaggle.com/c/march-machine-learning-mania-2015/forums/t/12775/printable-bracket-for-r}
#' \url{http://www.kaggle.com/c/march-machine-learning-mania-2015/forums/t/12627/simulating-the-tournament}
#' \url{http://www.kaggle.com/c/march-machine-learning-mania/forums/t/7309/printable-bracket-in-r}
#' \url{https://github.com/chmullig/marchmania/blob/master/bracket.R}


print_bracket <- function(bracket, font_size = .7){
  utils::data('seed_print_positions', package='collegehoops', envir=environment())
  utils::data('slot_print_positions', package='collegehoops', envir=environment())
  utils::data('tourney_seeds', package='collegehoops', envir=environment())
  utils::data('teams', package='collegehoops', envir=environment())

  #Deep copy to avoid updating data
  bracket <- data.table::copy(bracket)

  #Checks
  year <- sort(unique(bracket$season))
  stopifnot(length(year)==1)

  #Subset seeds current year
  #tourney_seeds <- tourney_seeds[season == year,]
  tourney_seeds %<>%
    dplyr::filter(season == year) %>%
    data.table::as.data.table()

  KEYS <- 'teamid'

  #Add team names
  data.table::setnames(bracket, 'winner', 'teamid')
  bracket_seeds <- merge(tourney_seeds, teams, by=KEYS, all.x=TRUE)
  bracket <- merge(bracket, teams, by=KEYS, all.x=TRUE)

  #Parse seeds
  bracket_seeds[,seed_int := as.integer(substr(seed, 2, 3))]
  bracket <- merge(bracket, bracket_seeds[,list(teamid, women, seed_int)], by=KEYS)

  bracket_seeds[,teamname := paste0(teamname, '-(', seed_int, ')')]
  bracket[,teamname := paste0(teamname, '-(', seed_int, ')')]

  #Add preds
  bracket[,teamname := paste0(teamname, '-(', round(pred, 2), ')')]

  #Add printing positions
  bracket_seeds <- merge(bracket_seeds, seed_print_positions, by=c('seed'), all.x=TRUE)
  bracket <- merge(bracket, slot_print_positions, by=c('slot'), all.x=TRUE)

  #Check missing print positions
  missing <- bracket_seeds[,is.na(x) | is.na(y)]
  if(any(missing)){
    missing_seeds <- bracket_seeds[missing,sort(unique(seed))]
    missing_seeds <- paste(missing_seeds, collapse=', ')
    stop(paste("The following seeds need print positions:", missing_seeds))
  }

  #Check dupe print positions
  dupes1 <- bracket_seeds[, duplicated(paste(x,y,women))]
  dupes2 <- bracket_seeds[, duplicated(paste(x,y,women),fromLast=T)]
  dupes <- dupes1 | dupes2
  if(any(dupes)){
    dupe_seeds <- bracket_seeds[dupes,sort(unique(seed))]
    dupe_seeds <- paste(dupe_seeds, collapse=', ')
    stop(paste("The following seeds have duplicate print position:", dupe_seeds))
  }

  #Setup plot
  x <- seq(0,220,(221/67))
  y <- 0:66
  graphics::plot(x,y,type="l", col.axis="white", col.lab="white", bty="n",axes=F, col="white")
  graphics::segments(0,c(seq(0,30,2),seq(34,64,2)),20,c(seq(0,30,2),seq(34,64,2)))
  graphics::segments(20,c(seq(0,28,4),seq(34,62,4)),20,c(seq(2,30,4),seq(36,64,4)))
  graphics::segments(20,c(seq(1,29,4),seq(35,63,4)),40,c(seq(1,29,4),seq(35,63,4)))
  graphics::segments(40,c(seq(1,25,8),seq(35,59,8)),40,c(seq(5,29,8),seq(39,63,8)))
  graphics::segments(40,c(3,11,19,27,37,45,53,61),60,c(3,11,19,27,37,45,53,61))
  graphics::segments(60,c(3,19,37,53),60,c(11,27,45,61))
  graphics::segments(60,c(7,23,41,57),80,c(7,23,41,57))
  graphics::segments(80,c(7,41),80,c(23,57))
  graphics::segments(80,c(15,49),100,c(15,49))
  graphics::segments(100,c(27,37),120,c(27,37))
  graphics::segments(200,c(seq(0,30,2),seq(34,64,2)),220,c(seq(0,30,2),seq(34,64,2)))
  graphics::segments(200,c(seq(0,28,4),seq(34,62,4)),200,c(seq(2,30,4),seq(36,64,4)))
  graphics::segments(180,c(seq(1,29,4),seq(35,63,4)),200,c(seq(1,29,4),seq(35,63,4)))
  graphics::segments(180,c(seq(1,25,8),seq(35,59,8)),180,c(seq(5,29,8),seq(39,63,8)))
  graphics::segments(160,c(3,11,19,27,37,45,53,61),180,c(3,11,19,27,37,45,53,61))
  graphics::segments(160,c(3,19,37,53),160,c(11,27,45,61))
  graphics::segments(140,c(7,23,41,57),160,c(7,23,41,57))
  graphics::segments(140,c(7,41),140,c(23,57))
  graphics::segments(120,c(15,49),140,c(15,49))

  #Print Winner
  winner <- bracket[slot == 'R6CH',]
  graphics::text(winner$x,winner$y,winner$teamname, cex=font_size*2)

  #Print Bracket
  bracket <- bracket[slot != 'R6CH',]
  graphics::text(bracket$x, bracket$y, bracket$teamname,cex=font_size)

  #Print seeds
  graphics::text(bracket_seeds$x, bracket_seeds$y, bracket_seeds$teamname,cex=font_size)

  #Return nothing
  return(invisible())
}
