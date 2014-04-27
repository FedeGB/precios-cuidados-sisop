#!/bin/bash
# Función mover para RETAILC
# Pre: Recibe $1: origen, $2: destino, $3: comando invocador
# $1 y $2 son parametros obligatorios. $3 es opcional, si el comando invocador utiliza
# archivos de log se le debe pasar $3. Mover escribirá el resultado de su acción en el mismo log.
# Post: termina con 0 en caso de éxito, otro numero en otro casos.

if [ $# -lt 2 ]
then
	echo "Faltan parametros"
	exit -1
fi
if [ $# -gt 3 ]
then
	echo "Hay parametros demas"
	exit -1
fi

ORG=$1
DEST=$2

if [ $# -eq 3 ]
then
	CMD=$3
fi

if ! [ -f $ORG ]
then
	if ! [ -z $CMD ]
	then
		./logging.sh "$CMD" "No existe el archivo de origen: $ORG" "ERR" 
	fi
	echo "No existe el archivo de origen: $ORG"
	exit -2
fi

DESTDIR=$( echo "$DEST" | sed "s-\(.*\)/.*\$-\1-")
DESTNAME=$( echo "$DEST" | sed "s-\(.*\)/\(.*\)\$-\2-")
if ! [ -d $DESTDIR ]
then
	if ! [ -z $CMD ]
	then
		./logging.sh "$CMD" "No existe el directorio de destino: $DESTDIR" "ERR" 
	fi
	echo "No existe el directorio de destino"
	exit -2
fi

if [ -f $DEST ]
then
	if ! [ -d "$DESTDIR/dup" ]
	then
		mkdir "$DESTDIR/dup"
		mv "$ORG" "$DESTDIR/dup/$DESTNAME.1"
		if ! [ -z $CMD ]
		then
			./logging.sh "$CMD" "Se movio $ORG a $DESTDIR/dup/$DESTNAME.1 pues $DESTNAME ya existia"
		fi
		exit 0
	else
		ACTN=$(ls "$DESTDIR/dup" -1 | grep "$DESTNAME\.[0-9]\{1,3\}" -c)
		N=$(expr $ACTN + 1)
		mv "$ORG" "$DESTDIR/dup/$DESTNAME.$N"
		if ! [ -z $CMD ]
		then
			./logging.sh "$CMD" "Se movio $ORG a $DESTDIR/dup/$DESTNAME.$N pues $DESTNAME ya existia"
		fi
		exit 0
	fi
else
	mv "$ORG" "$DEST"
	if ! [ -z $CMD ]
		then
			./logging.sh "$CMD" "Se movio $ORG a $DEST"
	fi
fi

exit 0