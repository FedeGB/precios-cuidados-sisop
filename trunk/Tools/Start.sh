#!/bin/bash
# Función Start para RETAILC
# La función comienza procesos procesos devolviendo el valor del PID del mismo
# Pre: Recibe como mínimo 2 parámetros.
# $1: Tipo de ejecución (-f: foreground, -b: background) ambos en el contexto de quien lo ejecuta
# $2: Nombre del comando (no se si pasandole ruta o no)
# $3: Arreglo con parametros para el comando a ejectar

if [ $# -lt 2 ]
then
	echo "-1" # Faltan parámetros
	exit -1
fi

if ! [ $1 == "-f" -o $1 == "-b" ]
then
	echo -1 # el primer parametro es incorrecto
	exit -1
fi

if [ $1 == "-f" ]
then
	TIPO=""
else
	TIPO="&"
fi

CMD=$2

PID=$(pgrep "$CMD")

if [ -z $ENVINIT ]
then
	echo "-3" # El ambiente no está inicializado
	exit -3
fi

if ! [ -z $PID ]
then
	./logging "$CMD" "El proceso $1 ya está corriendo" "WAR"
	echo "$PID"
	exit 0
fi



if [ $# -eq 2 ]
then
	. "$CMD" "$TIPO"
else
	PAR=$3
	ISARRAY=$(declare -p "$PAR" | grep '^declare \-a' -c)
	if [ ISARRAY -ne 0 ]
	then
		. "$CMD" "${$PAR[@]}" "$TIPO"
	else
		echo "-2" # Se debe pasar un arreglo como tercer parámetro
		exit -2
	fi
fi