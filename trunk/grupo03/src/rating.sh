#!/bin/bash
TABLA="$GRUPO/$MAEDIR/um.tab"
PROCDIR="$ACEPDIR/proc"
if [[ ! -f "$GRUPO/$MAEDIR/precios.mae" ]]; then
	bash logging.sh "Rating" "No se encuentra el archivo precios.mae" "ERR"
	exit -1
fi
MAESTRO="$GRUPO/$MAEDIR/precios.mae"

<<CheckFile 
	Checks that a file is not empty nor already processed. Returns zero if OK.
CheckFile

function checkFile() {
	if [[ -f $GRUPO/$PROCDIR/$1 ]]; then
		echo "DUPLICADO"
		return
	fi
	if [[ ! -s $GRUPO/$ACEPDIR/$1 ]]; then
		echo "VACÍO"
		return
	fi
		echo "0"
}

<<sameUnit
	Checks if 2 units are actually the same, by using the unit table.
	$1: 1st Unit
	$2: 2nd Unit
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

<<getDescription
	Returns the product description of a "lista de compras" record.
	$1: "lista de compras" record.
getDescription

function getDescription() {
	echo $1 | grep "^[^;]*;[^;]* [^;]*$" | sed 's/^[^;]*;\([^;]*\) [^;]*$/\1/'
	return
}

<<getUnit
	Returns the unit of a "lista de compras" product.
	$1: "lista de compras" record.
getUnit

function getUnit() {
	echo $1 | grep "^[^;]*;[^;]* [^;]*$" | sed 's/^[^;]*;[^;]* \([^;]*\)$/\1/'
	return
}

<<getProductNumber
	Returns the first field of a "lista de compras" record.
	$1: "lista de compras" record.
getProductNumber

function getProductNumber() {
	echo $1 | grep "^[^;]*;[^;]* [^;]*$" | sed 's/^\([^;]*\);[^;]* [^;]*$/\1/'
	return
}

<<getMasterlistDescription
	Returns the description of a Masterlist product.
	$1: Masterlist record.
getMasterlistDescription

function getMasterlistDescription() {
	echo $1 | grep "^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;[^;]*$" | sed 's/^[^;]*;[^;]*;[^;]*;\([^;]*\) [^;]*;[^;]*$/\1/'
	return
}

<<getMasterlistUnit
	Returns the unit of a Masterlist product.	
	$1: Masterlist record.
getMasterlistUnit

function getMasterlistUnit() {
	echo $1 | grep "^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;[^;]*$" | sed 's/^[^;]*;[^;]*;[^;]*;[^;]* \([^;]*\);[^;]*$/\1/'
	return
}

<<getMasterlistSuperID
	Returns the SuperID of a Masterlist product.
	$1: Masterlist record.
getMasterlistSuperID

function getMasterlistSuperID() {
	echo $1 | grep "^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;[^;]*$" | sed 's/^\([^;]*\);[^;]*;[^;]*;[^;]* [^;]*;[^;]*$/\1/'
	return
}

<<getMasterlistPrice
	Returns the price of a Masterlist product.
	$1: Masterlist record.
getMasterlistPrice

function getMasterlistPrice() {
	echo $1 | grep "^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;[^;]*$" | sed 's/^[^;]*;[^;]*;[^;]*;[^;]* [^;]*;\([^;]*\)$/\1/'
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

<<filterSameDescriptions
	Given a string and the Masterlist, this function returns a filtered Masterlist that contains the same description as the string.
	$1: String.
	$2: Masterlist.	
filterSameDescriptions

function filterSameDescriptions() {
	declare local maestroFiltrado=$(cat $2)
	for word in $(splitIntoWords "$1"); do
		maestroFiltrado=$(echo "$maestroFiltrado" | grep -i "^[^;]*;[^;]*;[^;]*;[^;]*${word}[^;]* [^;]*;[^;]*$")
	done
	echo "$maestroFiltrado"
	return
}

<<splitIntoWords
	Returns each word of a string.	
	$1: String.
splitIntoWords

function splitIntoWords() {
	declare local oldIFS=$IFS	
	IFS=$" "
	for word in $1; do
		echo $word
	done
	IFS=$oldIFS	
	return
}

<<findMatches
	Returns a list with the matches of a "lista de compras" product in the Masterlist.	
	$1: "lista de compras" record.
	$2: Masterlist.
findMatches

function findMatches() {
	declare local descriptionCompra=$(getDescription $1)
	declare local unitCompra=$(getUnit $1)
	declare local productNumberCompra=$(getProductNumber $1)
	declare local superID
	declare local price
	declare local descriptionMaster
	declare local unitMaster
	declare local counter
	let counter=0
	for masterRecord in $(filterSameDescriptions $descriptionCompra $MAESTRO); do
		descriptionMaster=$(getMasterlistDescription $masterRecord)
		unitMaster=$(getMasterlistUnit $masterRecord)
		superID=$(getMasterlistSuperID $masterRecord)
		price=$(getMasterlistPrice $masterRecord)		
		if [[ $(sameUnit $unitMaster $unitCompra) = "0" ]]; then
			#echo "$unitMaster y $unitCompra son la misma unidad"
				echo "$productNumberCompra;$descriptionCompra $unitCompra;$superID;$descriptionMaster $unitMaster;$price"
				let counter=$counter+1
		fi
	done
	if [[ "$counter" = "0" ]]; then
		echo "$productNumberCompra;$descriptionCompra $unitCompra;;;"
	fi
	return	
}

<<validRecord
	Valids a "lista de compras" record.
	$1: "lista de compras" record.
validRecord

function validRecord() {
	echo $1 | grep "^[^;]*;[^;]*$"
	return
}

if [[ $ENVINIT -eq 0 ]]; then
	bash logging.sh "Rating" "Se finaliza el script por no estar seteado el ambiente." "ERR"
	exit -1
fi

bash logging.sh "Rating" "Inicio de Rating"
oldIFS=$IFS
IFS=$'\n'
let cant=0
cantListas=$(ls -F $GRUPO/$ACEPDIR/ | grep -v \/ | wc -l)
bash logging.sh "Rating" "Cantidad de listas de compras a procesar: $cantListas "
for file in $(ls -F $GRUPO/$ACEPDIR/ | grep -v \/); do
	let cant=cant+1
	bash logging.sh "Rating" "Archivo a procesar: $file"
	fileOK=$(checkFile $file)
	if [[ $fileOK = "0" ]]; then
		for record in $(cat $GRUPO/$ACEPDIR/$file); do
			if [[ ! $(validRecord "$record") = "" ]]; then
				findMatches $record >> "$GRUPO/$INFODIR/pres/$file"
			else
				bash logging.sh "Rating" "Ignorado registro de lista de compras del archivo $file por formato inválido." "WAR"
			fi
		done
		bash logging.sh "Rating" "Generada lista de compra: $file" 
		bash Mover.sh "$GRUPO/$ACEPDIR/$file" "$GRUPO/$PROCDIR/"
	else 
		bash logging.sh "Rating" "El archivo $file se rechaza por estar $fileOK" "WAR"
		bash Mover.sh "$GRUPO/$ACEPDIR/$file" "$GRUPO/$RECHDIR/"
	fi
done
IFS=$oldIFS
bash logging.sh "Rating" "Fin de Rating."
exit 0