#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOALS OPPGOALS
do
  if [[ $WINNER != "winner" ]]
  then
    #get team_id of winnners
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    #if not found
    if [[ -z $TEAM_ID ]]
    then
      #insert team
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted winning team name, $WINNER
      fi
    fi
    # get new team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

  #get team_id of opponents
    if [[ $OPPONENT != "opponent" ]]
    then
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      if [[ -z $TEAM_ID ]]
      then
        INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        if [[ $INSERT_TEAM == "INSERT 0 1" ]]
        then
          echo Inserted opponent team name, $OPPONENT
        fi
      fi
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOALS OPPGOALS
do
  if [[ $YEAR != year ]]
  then
    #get winner_id & opponent_id from team_id (foreign key)
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #insert game details
    INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINGOALS,$OPPGOALS)")
    if [[ $INSERT_GAME_RESULTS == "INSERT 0 1" ]]
    then
      echo "Inserted into games, $YEAR:'$ROUND':$WINGOALS:$OPPGOALS"
    fi
  fi
done
