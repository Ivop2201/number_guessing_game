#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME

#check if user is in database
SEARCH=$($PSQL "SELECT user_id FROM users WHERE username='$NAME'")
if [[ -z $SEARCH ]]
then
  #user is not in database
  INSERT=$($PSQL "INSERT INTO users(username,best_game,games_played) VALUES ('$NAME',0,0)" )
  GAMES_PLAYED=0
  BEST_GAME=0
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  #user is in database
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$NAME'")
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Generating Random Number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
#echo $SECRET_NUMBER

echo "Guess the secret number between 1 and 1000:"
TOTAL_GUESSES=0

LOOP(){
  read GUESS
  TOTAL_GUESSES=$(( $TOTAL_GUESSES + 1 ))
  #check if guess is a number
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      LOOP
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      LOOP
    else
      #number was guessed
      GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
      if [[ $GAMES_PLAYED = 1 ]]
      then
        INSERT=$($PSQL "UPDATE users SET best_game=$TOTAL_GUESSES, games_played=$GAMES_PLAYED WHERE username='$NAME'")
      elif [[ $TOTAL_GUESSES -lt $BEST_GAME ]]
      then
        INSERT=$($PSQL "UPDATE users SET best_game=$TOTAL_GUESSES, games_played=$GAMES_PLAYED WHERE username='$NAME'")
      else
        INSERT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$NAME'")
      fi
    fi
  else
    #guess is not a number
    echo "That is not an integer, guess again:"
    LOOP
  fi
}

LOOP
echo "You guessed it in $TOTAL_GUESSES tries. The secret number was $GUESS. Nice job!"
