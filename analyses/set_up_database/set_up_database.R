
library(readr)
library(RPostgreSQL)
# General-purpose data wrangling
library(tidyverse)  
# Parsing of HTML/XML files  
library(rvest)    
# String manipulation
library(stringr)   
# Verbose regular expressions
library(rebus)     
# Eases DateTime manipulation
library(lubridate)

# # From within psql
# CREATE DATABASE twitter;
# # Now from command line:
# psql twitter

set_up_database <- function(people = NULL){
  
  # # If null, do everyone
  # if(is.null(people)){
  #   library(gsheet)
  #   if(!'goog.RData' %in% dir()){
  #     goog_people <- gsheet::gsheet2tbl(url = 'https://docs.google.com/spreadsheets/d/1k6_AlqojK47MMqzuFYAzBnDfYXysmUgSseaKvHTb3W4/edit#gid=1425313388')
  #     save(goog_people,
  #          file = 'goog.RData')
  #   } else {
  #     load('goog.RData')
  #   }
  #   people <- tolower(goog_people$username)
  # }
  
  # Parlament de catalunya
  if(is.null(people)){
    library(gsheet)
    if(!'goog_parlament.RData' %in% dir()){
      goog_parlament <- gsheet::gsheet2tbl(url = 'https://docs.google.com/spreadsheets/d/1DBKQi5eN9zT_Pj4J3MRiE3qLXB2VPxvd8BVdSc012Ug/edit#gid=0')
      save(goog_parlament,
           file = 'goog_parlament.RData')
    } else {
      load('goog_parlament.RData')
    }
    people <- tolower(goog_parlament$username)
  }
  people <- people[!is.na(people)]
  people <- sort(unique(people))
  people <-people[113:length(people)]
  # Make sure everything in data is lowercase
  if(!dir.exists('data')){
    dir.create('data')
  }
  
  # Get twitter data
  pg = dbDriver("PostgreSQL")
  con = dbConnect(pg, dbname="twitter")
  for(p in 1:length(people)){
    this_person <- people[p]
    file_name <- (paste0('data/', this_person, '_tweets.csv'))
    if(!file.exists(file_name)){
      message(toupper(this_person), '----------------')
      bash_text <- paste0(
        'twint -u ',
        this_person,
        ' -o data/',
        this_person,
        '_tweets.csv --csv'
      )
      system(bash_text)
      }
    # Read in the data
    tl <- read_csv(file_name)
    dbWriteTable(con,'twitter',tl, row.names=FALSE,append = TRUE)
    
  }
  # Write the database
  # Read back
  # dtab = dbGetQuery(con, "select * from twitter")
  # disconnect from the database
  dbDisconnect(con)
  
}
set_up_database()
source('../../R/delete_duplicates_database.R')
