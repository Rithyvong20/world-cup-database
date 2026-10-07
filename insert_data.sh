#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

export PSQLRC=/dev/null

# Clear the project data so repeated imports produce the same rows.
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"
declare -A TEAM_IDS
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
 do
  [[ "$YEAR" == "year" ]] && continue
  for TEAM in "$WINNER" "$OPPONENT"
  do
    if [[ -z "${TEAM_IDS[$TEAM]+exists}" ]]; then
      TEAM_IDS["$TEAM"]=$($PSQL "INSERT INTO teams(name) VALUES ('$TEAM') RETURNING team_id;" | head -n 1)
    fi
  done
  WINNER_ID=${TEAM_IDS[$WINNER]}
  OPPONENT_ID=${TEAM_IDS[$OPPONENT]}
  $PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS);"
done < games.csv
