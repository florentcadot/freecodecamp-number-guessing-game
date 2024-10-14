#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_TO_GUESS=$(($RANDOM%1000+1))
echo "Enter your username:"
read USERNAME
USER=$($PSQL "SELECT games_played,best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER ]]; then
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")  
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    IFS='|' read GAMES_PLAYED BEST_GAME <<< $USER
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"

guess() {

 if [[ $1 ]]; then
    echo $1
 fi
 
 read NUMBER_ANSWER

 if [[ ! $NUMBER_ANSWER =~ ^[0-9]+$ ]]; then
  guess "That is not an integer, guess again:"
  else 
   
   (( NUMBER_OF_GUESSES++ ))

   if (( $NUMBER_TO_GUESS == $NUMBER_ANSWER )); then
     echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
     BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
     UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'")
     if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
     fi
     
   elif (( $NUMBER_TO_GUESS < $NUMBER_ANSWER )); then
      guess "It's lower than that, guess again:"

   elif (( $NUMBER_TO_GUESS > $NUMBER_ANSWER )); then
      guess "It's higher than that, guess again:"
   fi
 fi
}

guess