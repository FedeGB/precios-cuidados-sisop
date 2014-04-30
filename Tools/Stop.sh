#!/bin/bash
# Función Stop para RETAILC
# Esta función detiene procesos que se le pasan por parámetro
# Recibe como mínimo 1 parámetro que es el proceso a detener
# El 2do parámetro que se le puede pasar es el nombre de la función que invoca a Stop
# Esto solo es necesario si la función invocadora utiliza archivos de log
# $1: Comando a detener (sin el .sh)
# $2: Comando invocador (opcional)

if [ $# -lt "1" ]
then
	echo "Faltan parámetros"
	exit -1
fi

if [ $# -gt "2" ]
then
	echo "Hay parámetros demás"
	exit -1
fi

PRO=$1
CMD="$1.sh"
CALL=$2
PID=$(pgrep "$CMD")

if [ -z $PID ]
then
	if [ $# -eq 2 ]
	then
		./logging.sh "$CALL" "No hay ningún proceso $PRO en ejecución" "WAR"
	fi
	echo "No hay ningún proceso $PRO en ejecución"
else
	kill -15 $PID
	if [ $# -eq 2 ]
	then
		./logging.sh "$CALL" "Se detuvo el proceso $PRO" "WAR"
	fi
fi

exit 0