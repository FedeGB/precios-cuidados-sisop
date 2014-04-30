#!/bin/bash
# Función Start para RETAILC
# La función comienza procesos procesos o en foreground o en background
# Pre: Recibe como mínimo 2 parámetros. Deben estar inicializadas las variables de ambiente (ENVINIT=1)
# $1: Tipo de ejecución (-f: foreground, -b: background) ambos en el contexto de quien lo ejecuta
# $2: Nombre del comando (sin .sh)
# $N: Parametros para pasar al comando a ejecutar

if [ $# -lt 2 ]
then
	echo "Faltan parámetros"
	exit -1
fi

if ! [ $1 == "-f" -o $1 == "-b" ]
then
	echo "El primer parametro es incorrecto"
	exit -1
fi

CMD="$2.sh"

PID=$(pgrep "$CMD")

if [ -z $ENVINIT ]
then
	echo "El ambiente no está inicializado"
	exit -3
fi

if ! [ -z $PID ]
then
	./logging "$2" "El proceso $1 ya está corriendo" "WAR"
	exit 0
fi



if [ $# -eq 2 ]
then
	if [ "$TIPO" == "-f" ]
	then
		./"$CMD"
	else
		./$CMD &
	fi
else
	last=$(expr $# + 1)
	declare -a PAR=("$@")
	if [ "$TIPO" == "-b" ]
	then
		./$CMD "${PAR[@]:2:$last}" &
	else
		./"$CMD" "${PAR[@]:2:$last}"
	fi
	
fi

./logging "$2" "Comenzo la ejecución de $CMD con PID: $PID"
exit 0