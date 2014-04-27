#!/bin/bash
# Función mover para RETAILC
# Pre: Recibe $1: origen, $2: destino, $3: comando invocador
# $1 y $2 son parametros obligatorios. $3 es opcional, si el comando invocador utiliza
# archivos de log se le debe pasar $3. Mover escribirá el resultado de su acción en el mismo

if [ $# -lt 2 ]
then
	echo "Faltan parametros"
	exit -1
fi
if [ $# -gt 3 ]
then
	echo "Hay parametros demas"
	exit -1
fi

ORG=$1
DEST=$2

if ! [ -f $ORG ]
then
	./logging.sh "Mover" "No existe el archivo de origen" "ERR" 
	echo "No existe el archivo de origen"
	exit -2
fi
DESTDIR=$( echo "$DEST" | sed "s-\(.*\)/.*\$-\1-")
if ! [ -d $DESTDIR ]
then
	./logging.sh "Mover" "No existe el directorio de destino" "ERR" 
	echo "No existe el directorio de destino"
	exit -2
fi