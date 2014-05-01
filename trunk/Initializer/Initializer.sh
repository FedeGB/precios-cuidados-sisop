#!/bin/bash
# Initializer que por ahora solo inicia variables de ambiente, con la estructura de directorios actuales
# Para que las inicie, hay que correr este script con ". initializer.sh" para que este en el contexto de la consola, sino no las setea (y no se puede hacer desde script, ya probe y busque...)

### Variables a setear

GRUPO=""
CONFDIR=""
BINDIR=""
MAEDIR=""
NOVEDIR=""
DATASIZE=""
ACEPDIR=""
RECHDIR=""
INFODIR=""
LOGDIR=""
LOGEXT=""
LOGSIZE=""

# Variables que leemos del archivo de configuracion
VARARCHCONF=("CONFDIR" "MAEDIR" "NOVEDIR" "DATASIZE" "ACEPDIR" "RECHDIR" "INFODIR")

# Variables para el log
VARLOG=("BINDIR" "LOGDIR" "LOGEXT" "LOGSIZE")

# Ejecutables
VAREX=("logging.sh" "Start.sh" "Stop.sh" "Mover.sh")

# Mesajes generales
REINSTALL="Por favor, vuelva a instalar el programa nuevamente.
Para ello inicie el instalador y siga los pasos correctamente.
Si el problema sigue persistiendo, intente reinciando el sistema."

### Paths base

ACTUAL="`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`"
PATHGROUP=`echo "$ACTUAL" | sed "s-\(.*\)/grupo03/.*-\1/grupo03-"`
PATHCONF="$PATHGROUP/conf"
if ! [ -d $PATHCONF ]
then
	echo "No se encuentra directorio grupo03/conf.
	No se puede inicializar RETAILC."
	exit -2
fi

if ! [ -f "$PATHCONF/installer.conf" ]
then
	echo "No se encuentra el archivo de configuración.
	No se puede inicializar RETAILC."
	exit -2
fi

export GRUPO=`echo \`grep '^GRUPO' "$PATHCONF"/installer.conf\` | cut -f2 -d'='`
### Permisos de archivos

# 755 rwx-rx-rx
# 666 rw-rw-rw
# 555 rx-rx-rx

### Funciones del script

function iniciarLog
{
	# Inicio variables para Log
	for i in "${VARLOG[@]}"
	do
		export eval "$i"=$(echo `grep "^$i" $PATHCONF/installer.conf` | cut -f2 -d'=')
		if [ -z "${!i}" ]
		then
			return 1
		fi
	done
	if ! [ -f "$GRUPO/$BINDIR/logging.sh" ]
	then
		return 1
	fi
	$GRUPO/$BINDIR/logging.sh "Initializer" "Comando Initializer: Inicio de Ejecución"
	return 0
}

function cargarVariablesConf
{
	for i in "${VARARCHCONF[@]}"
	do
		export eval "$i"=$(echo `grep "^$i" $PATHCONF/installer.conf` | cut -f2 -d'=')
		if [ -z "${!i}" ]
		then
			return 1
		fi
	done

	return 0
}

function verificarEx
{
	for x in "${VAREX[@]}"
	do
		if ! [ -f "$GRUPO/$BINDIR/$x" ]
		then
			return 1
		fi
	done

	return 0
}

function verificarArchivos
{
	PRE="$GRUPO/$MAEDIR"
	if ! [ -f $PRE/um.tab ]
	then
		return 1
	elif ! [ -f $PRE/asociados.mae ]
	then
		return -1
	elif ! [ -f $PRE/super.mae ]
	then
		return 1
	fi

	return 0
}

### Comienzo script

if [ $# -eq "1" ]
then
	if [ $1 == "-f" ]
	then
		unset ENVINIT
		exit 0
	fi
fi

iniciarLog
if [ $? -eq 1 ]
then
	echo "Faltan archivos o variables para el correcto funcionamiento del programa.
$REINSTALL"
exit -2
fi

cargarVariablesConf 
if [ $? -eq 1 ]
then
	echo "Faltan variables en el archivo de configuración.
$REINSTALL"
$GRUPO/$BINDIR/logging.sh "Initializer" "Faltan variables en el archivo de configuración" "ERR"
exit -2
fi
$GRUPO/$BINDIR/logging.sh "Initializer" "Se cargó satisfactoriamente el archivo de configuración" 

verificarEx
if [ $? -eq 1 ]
then
	echo "Faltan ejecutales para la correcta ejecución del programa.
$REINSTALL"
$GRUPO/$BINDIR/logging.sh "Initializer" "Faltan ejecutables en el directorio $BINDIR" "ERR"
exit -2
fi
$GRUPO/$BINDIR/logging.sh "Initializer" "Se identificaron todos los ejecutables necesarios"

verificarArchivos
if [ $? -eq 1 ]
then
	echo "Faltan archivos maestros y/o tablas del sistema.
$REINSTALL"
$GRUPO/$BINDIR/logging.sh "Initializer" "Faltan archivos maestros y/o tablas del sistema" "ERR"
exit -2
fi
$GRUPO/$BINDIR/logging.sh "Initializer" "Se encontraron los archivos maestros y tablas del sistema"

if ! [ -z ENVINIT ]
then
	echo "El ambiente ya está inicializado, si quiere reiniciar termine su sesión e ingrese nuevamente"
	$GRUPO/$BINDIR/logging.sh "Initializer" "Ambiente ya fue inicializado" "ERR"
	exit -1
fi
