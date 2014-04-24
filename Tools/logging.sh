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

numfields=`echo \`pwd\` | grep -o '/' | wc -l`
numfields=`expr $numfields + 1` # le sumo 1 pues cut toma como field antes del / incial tambien
pathconf=`echo \`pwd\` | cut -f"$numfields" -d'/' --complement` # llego hasta ../grupo03
pathconf="$pathconf/conf"

if [ $1 == 'installer' ]  # CAMBIAR SI EL INSTALLER TIENE OTRO NOMBRE O SI PASAMOS CON .sh!
then
	LOGDIR="$pathconf"
	LOGEXT='log'
else
	LOGDIR=`echo \`grep '^LOGDIR' "$pathconf"/installer.conf\` | cut -f2 -d'='` # Suponiendo que LOGDIR tenga el path completo, sino se lo tengo que agregar
	LOGEXT=`echo \`grep '^LOGEXT' "$pathconf"/installer.conf\` | cut -f2 -d'='` # Fijarse tambien que usamos como separador en las lineas!!
fi

LOGNAME="$where" # Si se pasa el comando con .sh habria que sacar el .sh de acá
LOGSIZE=`echo \`grep '^LOGSIZE' "$pathconf"/installer.conf\` | cut -f2 -d'='` # En KB

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

	return 0
}