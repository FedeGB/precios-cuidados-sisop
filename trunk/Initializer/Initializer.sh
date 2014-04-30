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
VARARCHCONF=("GRUPO" "CONFDIR" "BINDIR" "MAEDIR" "NOVEDIR" "DATASIZE" "ACEPDIR" "RECHDIR" "INFODIR" "LOGDIR" "LOGEXT" "LOGSIZE")

# Variables que tienen información de path a directorios
VARPATH=("GRUPO" "CONFDIR" "BINDIR" "MAEDIR" "NOVEDIR" "ACEPDIR" "RECHDIR" "INFODIR" "LOGDIR")

# Variales que tienen información de data (no path)
VARLOG=("LOGEXT" "LOGSIZE")

# Variable Datasize esta aparte

### Paths base

ACTUAL="`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd`"
PATHGROUP=`echo "$ACTUAL" | sed "s-\(.*\)/grupo03/.*-\1/grupo03-"`
PATHCONF="$PATHGROUP/conf"

function cargarVariablesConf
{
	for i in "${VARARCHCONF[@]}"
	do
		eval "$i"=`echo \`grep '^"$i"' "$PATHCONF"/installer.conf\` | cut -f2 -d'='`
	done

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


