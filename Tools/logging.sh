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
if [ $3 <> 'INF' -o $3 <> 'WAR' -o $3 <> 'ERR' ]
then
	echo "El tercer parametro no es ni INF ni WAR ni ERR"
	exit -1
fi

when=`date +"$F %T"`
who=$USER
where=$1
why=$2
what=$3

if [ $1 == 'Installer' ]  # CAMBIAR SI EL INSTALLER TIENE OTRO NOMBRE O SI PASAMOS CON .sh!
then
	LOGDIR='./grupo03/conf'
	LOGEXT='log'
else
	LOGDIR=`echo \`grep '^LOGDIR' ./grupo03/conf/Installer.conf\` | cut -f2 -d'='` # Suponiendo que LOGDIR tenga el path completo, sino se lo tengo que agregar
	LOGEXT=`echo \`grep '^LOGEXT' ./grupo03/conf/Installer.conf\` | cut -f2 -d'='` # Fijarse tambien que usamos como separador en las lineas!!
fi

LOGNAME="$where" # Si se pasa el comando con .sh habria que sacar el .sh de acá
LOGSIZE=`echo \`grep '^LOGSIZE' ./grupo03/conf/Installer.conf\` | cut -f2 -d'='` # En KB

exit 0