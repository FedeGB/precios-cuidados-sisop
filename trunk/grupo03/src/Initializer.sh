#!/bin/bash
# Initializer que por ahora solo inicia variables de ambiente, con la estructura de directorios actuales

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

# Variables que leemos del archivo de configuracion (sin incluir las necesarias para logging)
VARARCHCONF=("CONFDIR" "MAEDIR" "NOVEDIR" "DATASIZE" "ACEPDIR" "RECHDIR" "INFODIR")

# Variables para poder loggear
VARLOG=("BINDIR" "LOGDIR" "LOGEXT" "LOGSIZE")

# Ejecutables
VAREX=("logging.sh" "Start.sh" "Stop.sh" "Mover.sh" "listener.sh" "masterlist.sh" "rating.sh")

# Directorios
VARDIR=("BINDIR" "MAEDIR" "NOVEDIR" "ACEPDIR" "RECHDIR" "INFODIR")

# Mesajes generales
REINSTALL="Por favor, vuelva a instalar el programa nuevamente.
Para ello inicie el instalador y siga los pasos correctamente.
Si el problema sigue persistiendo, intente reinciando el sistema."

ERROR=0

### Paths base

ACTUAL="`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`"
PATHGROUP=`echo "$ACTUAL" | sed "s-\(.*\)/grupo03/.*-\1/grupo03-"`
PATHCONF="$PATHGROUP/conf"

function VerificarPathInicial
{
	if ! [ -d $PATHCONF ]
	then
		echo "No se encuentra directorio grupo03/conf.
		No se puede inicializar RETAILC."
		return 2
	fi

	if ! [ -f "$PATHCONF/Installer.conf" ]
	then
		echo "No se encuentra el archivo de configuración.
		No se puede inicializar RETAILC."
		return 2
	else
		chmod 444 "$PATHCONF/Installer.conf"
	fi

	export GRUPO=`echo \`grep '^GRUPO' "$PATHCONF"/Installer.conf\` | cut -f2 -d'='`
	return 0
}

VerificarPathInicial
ERROR=$?

### Permisos de archivos

# 666 rw-rw-rw
# 555 rx-rx-rx
# 444 r-r-r

### Funciones del script

function iniciarLog
{
	# Inicio variables para Log
	for i in "${VARLOG[@]}"
	do
		export eval "$i"=$(echo `grep "^$i" $PATHCONF/Installer.conf` | cut -f2 -d'=')
		if [ -z "${!i}" ]
		then
			return 1
		fi
	done
	if ! [ -f "$GRUPO/$BINDIR/logging.sh" ]
	then
		return 1
	else
		chmod 555 "$GRUPO/$BINDIR/logging.sh"
	fi
	if ! [[ -d $GRUPO/$LOGDIR ]]
	then
		mkdir $GRUPO/$LOGDIR
		$GRUPO/$BINDIR/logging.sh "Initializer" "No existia el directorio $LOGDIR. Creado." "WAR"
	fi
	$GRUPO/$BINDIR/logging.sh "Initializer" "Comando Initializer: Inicio de Ejecución"
	return 0
}

function cargarVariablesConf
{
	for i in "${VARARCHCONF[@]}"
	do
		eval "$i"=$(echo `grep "^$i" $PATHCONF/Installer.conf` | cut -f2 -d'=')
		if [ -z "${!i}" ]
		then
			$GRUPO/$BINDIR/logging.sh "Initializer" "Falta la variable $i en el archivo de configuración" "ERR"
			return 1
		fi
	done
	# Al archivo .conf ya le di permisos de lectura
	return 0
}

function verficarDirectorios
{
	for d in "${VARDIR[@]}"
	do
		if ! [ -d "$GRUPO/${!d}" ]
		then
			if [ $d == "MAEDIR" ]
			then
				echo "Faltan directorios que contienen archivos imporatntes.
				$REINSTALL"
				$GRUPO/$BINDIR/logging.sh "Initializer" "Falta un directorio que contiene archivos importantes"
				return 2
			fi
			mkdir $GRUPO/${!d}
			$GRUPO/$BINDIR/logging.sh "Initializer" "Falta el directorio ${!d}. Se creo para continuar funcionamiento" "WAR"
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
			$GRUPO/$BINDIR/logging.sh "Initializer" "Falta el ejecutable $x en el directorio $BINDIR" "ERR"
			return 1
		else
			chmod 555 "$GRUPO/$BINDIR/$x"
			$GRUPO/$BINDIR/logging.sh "Initializer" "$x fue otorgado con permisos de ejecución y lectura"
		fi
	done

	return 0
}

function verificarArchivos
{
	PRE="$GRUPO/$MAEDIR"
	if ! [ -f "$PRE/um.tab" ]
	then
		$GRUPO/$BINDIR/logging.sh "Initializer" "Falta la tabla del sistema um.tab" "ERR"
		return 1
	else
		chmod 444 "$PRE/um.tab"
		$GRUPO/$BINDIR/logging.sh "Initializer" "um.tab fue otorgado con permisos de lectura"
	fi
	if ! [ -f "$PRE/asociados.mae" ]
	then
		$GRUPO/$BINDIR/logging.sh "Initializer" "Falta el archivo maestro asociados.mae" "ERR"
		return 1
	else
		chmod 444 "$PRE/asociados.mae"
		$GRUPO/$BINDIR/logging.sh "Initializer" "asociados.mae fue otorgado con permisos de lectura"
	fi
	if ! [ -f "$PRE/super.mae" ]
	then
		$GRUPO/$BINDIR/logging.sh "Initializer" "Falta el archivo maestro super.mae" "ERR"
		return 1
	else
		chmod 444 "$PRE/super.mae"
		$GRUPO/$BINDIR/logging.sh "Initializer" "super.mae fue otorgado con permisos de lectura"
	fi

	return 0
}

 function verificarAmbiente
 {
 	if ! [ -z $ENVINIT ]
	then
		echo "El ambiente ya está inicializado, si quiere reiniciar termine su sesión e ingrese nuevamente"
		$GRUPO/$BINDIR/logging.sh "Initializer" "Ambiente ya fue inicializado" "ERR"
		return 1
	fi
	return 0
 }

 function setearAmbiente
 {
 	for i in "${VARARCHCONF[@]}"
	do
		export "$i"
		if [ -z "${!i}" ]
		then
			$GRUPO/$BINDIR/logging.sh "Initializer" "No se pudo setear la variable $i en el ambiente" "ERR"
			return 1
		fi
	done
	export ENVINIT=1
	return 0
 }

 function iniciarDaemon
 {
 	echo "¿Desea efectuar la activación del Listener? Si(s)-No(n)"
 	VALIDO=0
 	while [ $VALIDO -eq 0 ]
 	do
 		read CHOICE
 		if [ $CHOICE == "s" ]
 		then
 			$GRUPO/$BINDIR/logging.sh "Initializer" "Inicializando listener"
 			$GRUPO/$BINDIR/Start.sh "Initializer" "-b" listener # Verifica si el proceso está corriendo o no
 			VALIDO=1
 		elif [ $CHOICE == "n" ]
 		then
 			echo "Usted eligio no inicializr el listener.
 			Para ejecutarlo hagalo a traves del comando Start:
 			Start.sh NULL -b"
 			$GRUPO/$BINDIR/logging.sh "Initializer" "El listener no fue inicializado"
 			VALIDO=1
 		else
 			echo "La respuesta ingresada no es válida.
 			Nuevamente, si quiere inicializar el listener
 			responda s (Si), de lo contrario n (No)"
 		fi

 	done

 	echo "Para detener el listener use el comando Stop:
 	Stop.sh listener"

 	return 0
 }

 function estadoFinal
 {
 	echo "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright Grupo 03"
 	echo "Directorio de configuración: $CONFDIR"
 	ls $GRUPO/$CONFDIR -1
 	echo "Directorio de ejecutables: $BINDIR"
 	ls $GRUPO/$BINDIR -1
 	echo "Directorio de Maestros y Tablas: $MAEDIR"
 	ls $GRUPO/$MAEDIR -1
 	echo "Directorio de Novedades: $NOVEDIR" 
 	echo "Directorio de Novedades aceptadas: $ACEPDIR"
 	echo "Directorio de Informes de Salida: $INFODIR"
 	echo "Directorio de Archivos Rechazados: $RECHDIR"
 	echo "Directorio de los Logs de Comandos: $LOGDIR"
 	ls $GRUPO/$LOGDIR -1
 	echo "Estado del sistema: INICIALIZADO"
 	LISPID=$(pgrep "listener.sh")
 	if ! [ -z $LISPID ]
 	then
 		echo "Listener corriendo bajo el no.: $LISPID"
 	else
 		echo "Listener no está corriendo"
 	fi

 	return 0
 }

### Comienzo script

if [[ $ERROR -eq 0 ]]
then
	if [ $# -eq "1" ]
	then
		if [ $1 == "-f" ]
		then
			unset ENVINIT
		fi
	fi
fi

if [[ $ERROR -eq 0 ]]
then
	iniciarLog
fi

if [ $? -eq 1 ]
then
	echo "Faltan archivos o variables para el correcto funcionamiento del programa.
$REINSTALL"
ERROR=2
fi

if [[ $ERROR -eq 0 ]]
then
	cargarVariablesConf 
fi

if [ $? -eq 1 ]
then
	echo "Faltan variables en el archivo de configuración.
$REINSTALL"
	ERROR=2
fi

if [[ $ERROR -eq 0 ]]
then
	$GRUPO/$BINDIR/logging.sh "Initializer" "Se cargó satisfactoriamente el archivo de configuración"
	verficarDirectorios
	ERROR=$?
fi

if [[ $ERROR -eq 0 ]]
then
	$GRUPO/$BINDIR/logging.sh "Initializer" "Se completó verificación de directorios"
	verificarEx
fi

if [ $? -eq 1 ]
then
	echo "Faltan ejecutales para la correcta ejecución del programa.
$REINSTALL"
	ERROR=2
fi

if [[ $ERROR -eq 0 ]]
then
	$GRUPO/$BINDIR/logging.sh "Initializer" "Se identificaron todos los ejecutables necesarios"
	verificarArchivos
	ERROR=$?
fi

if [ $? -eq 1 ]
then
	echo "Faltan archivos maestros y/o tablas del sistema.
$REINSTALL"
	ERROR=2	
fi

if [[ $ERROR -eq 0 ]]
then
	$GRUPO/$BINDIR/logging.sh "Initializer" "Se encontraron los archivos maestros y tablas del sistema"
	verificarAmbiente
	ERROR=$?
fi

if [[ $ERROR -eq 0 ]]
then
	$GRUPO/$BINDIR/logging.sh "Initializer" "El ambiente no se encontraba inicializado"
	setearAmbiente
	ERROR=$?
fi

if [[ $ERROR -eq 0 ]]
then
	$GRUPO/$BINDIR/logging.sh "Initializer" "Se incializo correctamente el ambiente"
	# Seteo variable PATH para los ejecutables
	export PATH=$PATH:"$GRUPO/$BINDIR"
fi

if [[ $ERROR -eq 0 ]]
then
	iniciarDaemon
	ERROR=$?
fi

if [[ $ERROR -eq 0 ]]
then
	estadoFinal
fi

return $ERROR