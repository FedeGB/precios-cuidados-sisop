#!/bin/bash
# Función Start para RETAILC
# La función comienza procesos procesos o en foreground o en background
# Pre: Recibe como mínimo 3 parámetros. Deben estar inicializadas las variables de ambiente (ENVINIT=1)
# $1: Proceso caller (nombre del comando que esta utilizando el Start, sin el .sh). Si se le pasa NULL,
# no graba un archivo de log, en caso de ser un comando que no usa archivos de log.
# $2: Tipo de ejecución (-f: foreground, -b: background) ambos en el contexto de quien lo ejecuta
# $3: Nombre del comando (sin .sh)
# $N: Parametros para pasar al comando a ejecutar

if [ $# -lt 3 ]
then
	echo "Faltan parámetros"
	exit -1
fi

if ! [ $2 == "-f" -o $2 == "-b" ]
then
	echo "El primer parametro es incorrecto"
	exit -1
fi

CALL="$1"
TIPO="$2"
PRO="$3"
CMD="$3.sh"

PID=$(pgrep "$CMD")

if [ -z $ENVINIT ]
then
	echo "El ambiente no está inicializado"
	exit -3
fi

if ! [ -z $PID ]
then
	if ! [ $CALL == "NULL" ]
	then
	./logging "$CALL" "El proceso $PRO ya está corriendo" "WAR"
	fi
	echo "El proceso $PRO ya está corriendo"
	exit 0
fi

if [ $# -eq 3 ]
then
	if [ "$TIPO" == "-f" ]
	then
		./$CMD
	else
		./$CMD &
	fi
else
	last=$(expr $# + 1)
	declare -a PAR=("$@")
	if [ "$TIPO" == "-b" ]
	then
		./"$CMD" "${PAR[@]:3:$last}" &
	else
		./"$CMD" "${PAR[@]:3:$last}"
	fi
	
fi

if ! [ $CALL == "NULL" ]
then
	./logging "$CALL" "Comenzo la ejecución de $PRO"
fi

exit 0