% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_game_ids.R
\name{get_game_ids}
\alias{get_game_ids}
\title{Get Team gameIds By Season}
\usage{
get_game_ids(team, season)
}
\arguments{
\item{team}{(str) Team to get Play-by-Play data for}

\item{season}{(str) or (int) Season for which to get schedule. In form "2019-20" or "2020". Single number is season of tournament.}
}
\value{
A data frame of the team's gameIds data for the specified season.
}
\description{
Scrapes the season schedule for desired team. Team
is assumed to be the ESPN team name, which can be looked up in the ids
dataframe.
}
\details{
Requires use of ESPN oriented team names, found in locally saved file (ids.csv)
}
