#!/bin/bash
# Comando logging para RETAILC
# Pre: Recibe 3 parámetros, $1: comando, $2: mensaje, $3: tipo de mensaje*
# *Para el tipo de mensaje se tiene:
# INFO = INFORMATIVO: mensajes explicativos sobre el curso de ejecución del comando.
# WAR = WARNING: mensajes de advertencia pero que no afectan la continuidad de ejecución del comando.
# ERR = ERROR: mensajes de error.

if [ $# -lt 3 ]
then
	echo "Faltan parametros" # Esto deberia ir a un log? Idem para el resto de las verificaciones
	exit -1
fi 
if [ $# -gt 3 ]
then
	echo "Hay parametros demas"
	exit -1
fi
if [ $3 != 'INF' -a $3 != 'WAR' -a $3 != 'ERR' ]
then
	echo "El tercer parametro no es ni INF ni WAR ni ERR"
	exit -1
fi

when=`date +"%F %T"`
who=$USER
where=$1
why=$2
what=$3

LOGNAME="$where" # Si se pasa el comando con .sh habria que sacar el .sh de acá

echo "$when-$who-$where-$what-$why" >> "$LOGDIR/$LOGNAME.$LOGEXT"

size=`wc -c < "$LOGDIR/$LOGNAME.$LOGEXT"`
size=`expr $size / 1024` # lo paso a KB

if [ $size -gt $LOGSIZE ]
then
	reducir "$LOGDIR/$LOGNAME.$LOGEXT"
fi

exit 0


function reducir
{
	lineas=`wc -l < $1`
	par=`expr $lineas - 50` # Para dejar las ultimas 50 lineas del log
	split -l $par $1 $1 # el split divide a archivo con prefijoaa .. ab .. (prefijo = $3)
	rm $1 # Borro el viejo
	rm "$1""aa" 
	mv "$1""ab" "$1" 

	return 0
}