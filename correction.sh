PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#Create types table
$($PSQL "CREATE TABLE types(type_id SERIAL PRIMARY KEY, type VARCHAR(50) NOT NULL)")./



#New elements
$($PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(9, 'F', 'Fluorine')")
$($PSQL "INSERT INTO properties(atomic_number, type, weight, melting_point, boiling_point) VALUES(9, 'nonmetal', 18.998, -220, -188.1)")

$($PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(10, 'Ne', 'Neon')")
$($PSQL "INSERT INTO properties(atomic_number, type, weight, melting_point, boiling_point) VALUES(10, 'nonmetal', 20.18, -248.6, -246.1)")

#Deletions
$($PSQL "DELETE FROM properties WHERE atomic_number = 1000")
$($PSQL "DELETE FROM elements WHERE atomic_number = 1000")



#Replace type by type_id in properties
#1) Add type_id column to properties
$($PSQL "ALTER TABLE properties ADD COLUMN type_id INT")

#2) Fill in types table and set type_id in properties accordingly
TYPES=$($PSQL "SELECT DISTINCT type FROM properties")
for TYPE in $TYPES
do
  $($PSQL "INSERT INTO types(type) VALUES('$TYPE')")
  TYPE_ID=$($PSQL "SELECT type_id FROM types WHERE type = '$TYPE'")
  $($PSQL "UPDATE properties SET type_id = $TYPE_ID WHERE type = '$TYPE'")
done

$($PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL")
$($PSQL "ALTER TABLE properties ADD FOREIGN KEY (type_id) REFERENCES types(type_id)")

#3) Drop type column from properties table
$($PSQL "ALTER TABLE properties DROP COLUMN type")


#Corrections on properties table
$($PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass")
$($PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius")
$($PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius")
$($PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL")
$($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL")
$($PSQL "ALTER TABLE properties ADD FOREIGN KEY(atomic_number) REFERENCES elements(atomic_number)")

$($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL")
ATOMIC=$($PSQL "SELECT atomic_number, atomic_mass, CAST(CAST(atomic_mass AS decimal(9,6)) AS float) FROM properties")
ATOMIC=$(echo $ATOMIC | sed 's/|/-/g')
for VALUE in $ATOMIC
do
  echo $VALUE | while IFS='-' read ATOMIC_NUMBER ATOMIC_MASS NEW_ATOMIC_MASS
  do
    $($PSQL "UPDATE properties SET atomic_mass=$NEW_ATOMIC_MASS WHERE atomic_number=$ATOMIC_NUMBER")
  done
done

#Corrections on elements table
$($PSQL "ALTER TABLE elements ADD UNIQUE(symbol)")
$($PSQL "ALTER TABLE elements ADD UNIQUE(name)")
$($PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL")
$($PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL")

SYMBOLS=$($PSQL "SELECT symbol FROM elements")
for SYMBOL in $SYMBOLS
do
  $($PSQL "UPDATE elements SET symbol='${SYMBOL^}' WHERE symbol='$SYMBOL'")
done
