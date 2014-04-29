#comentario
#
ERROR=0
ACEPDIR=/home/ubuntu/precios-cuidados-sisop/Rating/aceptados
PROCDIR=/home/ubuntu/precios-cuidados-sisop/Rating/procesados
RECHDIR=/home/ubuntu/precios-cuidados-sisop/Rating/rechazados
BASE="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
MOVER='../Tools/Mover.sh'
TABLA="../Datos/Maestros y tablas/um.tab"

<<CheckFile 
	Checks that a file is not empty nor already processed. Returns zero if OK.
CheckFile

function checkFile() {
	if [[ -f $PROCDIR/$1 ]]; then
		echo "Archivo duplicado -> Mover a RECHAZADOS"
		return
	fi
	if [[ ! -s $ACEPDIR/$1 ]]; then
		echo "Archivo vacío -> Mover a RECHAZADOS"
		return
	fi
		echo "0"
}

<<sameUnit
	Checks if 2 units are actually the same, by using the unit table.	
sameUnit

function sameUnit() {
	declare local line1
	declare local line2
	line1=$(cat "$TABLA" | grep $1 -n | sed 's/\([^;]*\):.*/\1/')
	line2=$(cat "$TABLA" | grep $2 -n | sed 's/\([^;]*\):.*/\1/')	
	if [[ "$line1" = "$line2" ]]; then
		echo "0"
		return
	fi
	echo "1"
	return
}

function getDescription() {
	declare local descriptionRE="^[^;]*;(.*) .*$"
	declare local description
	if [[ $1 =~ $descriptionRE ]]; then
		description=${BASH_REMATCH[1]}
		echo $description
	fi
	return
}

function getUnit() {
	declare local unitRE="^[^;]*;.* (.*)$"
	declare local unit
	if [[ $1 =~ $unitRE ]]; then
		unit=${BASH_REMATCH[1]}
		echo $unit
	fi
	return
}

#resultado=$(sameUnit kg k)
oldIFS=$IFS
IFS=$'\n'
let cant=0
for file in $(ls $ACEPDIR); do
	let cant=cant+1
	fileOK=$(checkFile $file)
	if [[ $fileOK = "0" ]]; then
		echo $file is ready to be processed \(moved to PROCDIR\)
		for record in $(cat $ACEPDIR/$file); do
			descriptionCompra=$(getDescription $record)
			unitCompra=$(getUnit $record)
			
		done 
	else 
		echo $file cannot be processed \(moved to RECHDIR\)
	fi
done
#sed 's/^[^;]*;\(.*\) .*$/\1/' $ACEPDIR/$file