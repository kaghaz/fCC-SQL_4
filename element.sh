PSQL="psql --username=postgres --dbname=periodic_table -t --no-align -c"

PRINT_INFO(){
  echo $INFO | while IFS='|' read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

if [[ $1 ]]
then
  #search by atomic number
  if [[ $1 =~ (^[0-9]+$) ]]
  then
    INFO=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1")
    if [[ -z $INFO ]]
    then
      echo "I could not find that element in the database."
    else
      PRINT_INFO $INFO
    fi
  else
    INFO=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1' OR name='$1'")
    if [[ -z $INFO ]]
    then
      echo "I could not find that element in the database."
    else
      PRINT_INFO $INFO
    fi
  fi
else
  echo "Please provide an element as an argument."
fi
