#!/bin/bash
# Comando logging para RETAILC
# Pre: Recibe 3 parámetros, $1: comando, $2: mensaje, $3: tipo de mensaje*
# *Para el tipo de mensaje se tiene:
# INFO = INFORMATIVO: mensajes explicativos sobre el curso de ejecución del comando.
# WAR = WARNING: mensajes de advertencia pero que no afectan la continuidad de ejecución del comando.
# ERR = ERROR: mensajes de error.
# Por default, si no se le pase 3er parametro, el tipo de mensaje es informativo

function reducir
{
	tail -50 "$1" > "$1.tmp" # Me quedo con las ultimas 50 lineas
	mv "$1.tmp" "$1" # Piso el viejo con el nuevo
	echo "Se excedio el limite de $LOGSIZE, se corto el archivo" >> "$1"
	return 0
}

if [ $# -lt 2 ] # El 3ro se puede no pasar nada y queda el default
then
	echo "Faltan parametros" 
	exit -1
fi 
if [ $# -gt 3 ]
then
	echo "Hay parametros demas"
	exit -1
fi
 
if [ $1 == "installer" ]
then
	if [ -z ${CONFDIR} ]
	then
		echo "No esta seteada la variable CONFDIR"
		exit -3
	elif [ -z ${GRUPO} ]
	then
		echo "No esta seteada la variable GRUPO"
		exit -3
	fi
	dir="$GRUPO/$CONFDIR" # El instalador debe setear variables GRUPO y CONFDIR para poder usar el logging
	LOGEXT="log"
else
	dir="$GRUPO/$LOGDIR"
fi

when=`date +"%F %T"`
who=$USER
where=$1
why=$2
if [ $# == 2 ]
then
	what='INF'
else
	what=$3
fi

LOGNAME="$where"


echo "$when-$who-$where-$what-$why" >> "$dir/$LOGNAME.$LOGEXT"

size=`wc -c < "$dir/$LOGNAME.$LOGEXT"`
size=`expr $size / 1024` # lo paso a KB

if [ $size -gt $LOGSIZE ]
then
	reducir "$dir/$LOGNAME.$LOGEXT"
fi

exit 0
