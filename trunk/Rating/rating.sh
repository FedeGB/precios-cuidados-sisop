#comentario
#
ERROR=0
ACEPDIR=/home/ubuntu/precios-cuidados-sisop/Rating/aceptados
PROCDIR=/home/ubuntu/precios-cuidados-sisop/Rating/procesados
RECHDIR=/home/ubuntu/precios-cuidados-sisop/Rating/rechazados
BASE="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
MOVER='../Tools/Mover.sh'
TABLA="../Datos/Maestros y tablas/um.tab"
MAESTRO="../Datos/Maestros y tablas/preciosExample.mae"

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
	line1=$(cat "$TABLA" | grep $1 -n -i | sed 's/\([^;]*\):.*/\1/')
	line2=$(cat "$TABLA" | grep $2 -n -i| sed 's/\([^;]*\):.*/\1/')	
	if [[ "$line1" = "$line2" ]]; then
		echo "0"
		return
	fi
	echo "1"
	return
}

function getDescription() {
	echo $1 | grep "^[^;]*;[^;]* [^;]*$" | sed 's/^[^;]*;\([^;]*\) [^;]*$/\1/'
	return
}

function getUnit() {
	echo $1 | grep "^[^;]*;[^;]* [^;]*$" | sed 's/^[^;]*;[^;]* \([^;]*\)$/\1/'
	return
}

function getMasterlistDescription() {
	echo $1 | grep "^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;[^;]*$" | sed 's/^[^;]*;[^;]*;[^;]*;\([^;]*\) [^;]*;[^;]*$/\1/'
	return
}

function getMasterlistUnit() {
	echo $1 | grep "^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;[^;]*$" | sed 's/^[^;]*;[^;]*;[^;]*;[^;]* \([^;]*\);[^;]*$/\1/'
	return
}

function sameDescription() {
	declare local oldIFS=$IFS
	declare local counter
	declare local listDescriptionTotalWords
	let counter=0
	IFS=$" "
	let listDescriptionTotalWords=$(echo $1 | wc -w)
	for word in $1; do
			if [[ $(echo $2 | grep -i -c "$word") -ne "0" ]]; then
				let counter=counter+1
			fi
	done
	if [[ $counter -eq $listDescriptionTotalWords ]]; then
		echo "0"
	else
		echo "1"
	fi
	IFS=$oldIFS
	return
}

function writeMatch() {
	declare local descriptionCompra=$(getDescription $1)
	declare local unitCompra=$(getUnit $1)
	declare local descriptionMaster
	declare local unitMaster
	for masterRecord in $(cat $MAESTRO); do
		descriptionMaster=$(getMasterlistDescription $masterRecord)
		unitMaster=$(getMasterlistUnit $masterRecord)	
		if [[ $(sameUnit $unitMaster $unitCompra) = "0" ]]; then
			#echo "$unitMaster y $unitCompra son la misma unidad"
			if [[ $(sameDescription $descriptionCompra $descriptionMaster) = "0" ]]; then
				echo "Producto pedido: $descriptionCompra Producto encontrado: $descriptionMaster -> GRABAR"
			fi
		fi
	done
}


oldIFS=$IFS
IFS=$'\n'
let cant=0
for file in $(ls $ACEPDIR); do
	let cant=cant+1
	fileOK=$(checkFile $file)
	if [[ $fileOK = "0" ]]; then
		echo $file is ready to be processed \(moved to PROCDIR\)
		for record in $(cat $ACEPDIR/$file); do
			writeMatch $record		
		done 
	else 
		echo $file cannot be processed \(moved to RECHDIR\)
	fi
done