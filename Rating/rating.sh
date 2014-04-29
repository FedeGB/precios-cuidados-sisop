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

resultado=$(sameUnit kg k)
echo $resultado