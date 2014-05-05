#!/bin/bash

#Variables:
CANTCICLOS=0
#Valida que un usuario sea asociado
#Parámetros:
#$1 -> Nombre de usuario
#$2 -> "Y" si se quiere chequear que sea colaborador, cualquier otra cosa no chequea
#Retorna:
#0 Si el usuario es válido
#1 Si el usuario no existe
#2 Si el usuario no es colaborador
function usuario_es_asociado
{
	declare local validationData=`cat "$GRUPO/$MAEDIR"/asociados.mae | grep "^[^;]*;[^;]*;$1;[0 | 1];[^@]*@[^@]*\.[^@]*$" | sed "s~^[^;]*;[^;]*;\($1\);\([0 | 1]\);[^@]*@[^@]*\.[^@]*\$~\1-\2~"`
	declare local asociado=`echo $validationData | sed "s~^\($1\)-[0 | 1]\$~\1~"`
	if [[ "$asociado" == "$1" ]]; then
		if [[ "$2" == "Y" ]]; then
			declare local colaborador=`echo $validationData | sed "s~^$1-\([0 | 1]\)\$~\1~"`
			if [[ "$colaborador" == "" || "$colaborador" == 0 ]]; then
				return 2
			fi
		fi
		return 0
	else
		return 1
	fi
}

#Determina si el archivo es una lista de compras o no
#Retorna 1 en caso verdadero 0 en caso contrario.
#Guarda en $prob por qué se rechazó (si corresponde "" sino)
function es_lista_compras
{
	prob=""
	declare local usuario=`echo "$1" | grep "^[^\.]*\.[^- ]\{3\}$" | sed 's~^\([^\.]*\)\.[^- ]\{3\}$~\1~'`
	if [[ "$usuario" == "" ]]; then
		prob="Formato invalido"
		return 0
	else
		usuario_es_asociado "$usuario"
		res=$?
		if [[ $res -ne 0 ]]; then
			prob="Asociado inexistente"
			return 0
		fi	
	fi
	return 1
}


#Función que devuelve 1 si el parámetro 1 es mayor o igual al parámetro 2 y menor o igual al parámetro 3
#0 en caso contrario. Si ($2 <= $1 <= $3) => 1, sino 0
#$1 -> Parámetro a chequear
#$2 -> Cota menor
#$3 -> Cota mayor
function in_range
{
	if [ $1 -lt $2 ];
	then
		return 0
	elif [ $1 -gt $3 ];
	then
		return 0
	else
		return 1
	fi
}

#Valida que la fecha pasada por parámetro esté entre 2014 01 01 (>) y el año, mes y día actual (<=)
#Formato de la fecha aaaammdd
#Devuelve 1 si la fecha es válida, 0 en caso contrario
function validar_fecha
{
	if [[ `echo "$1" | wc -m` -ne 9 ]]; then return 0; fi;
	declare local compValue=`echo $1 | grep "^[0-9]\{4\}\(\(\(01\|03\|05\|07\|08\|10\|12\)\(0[1-9]\|[12][0-9]\|3[01]\)\)\|\(\(04\|06\|09\|11\)\(0[1-9]\|[12][0-9]\|30\)\)\|02\(0[1-9]\|1[0-9]\|2[0-8]\)\)"`
	if [[ "$compValue" == "" ]]; then return 0; fi;
	if [ $1 -le 20140101 ]; then return 0; fi;
	compValue=`echo $1 | grep "^[0-9]\{4\}[0-9]\{2\}[0-9]\{2\}$" | sed 's~^\([0-9]\{4\}\).*$~\1~'`
	in_range $compValue 2014 `date +%Y`
	if [ "$?" == 0 ]; then return 0; fi;
	if [[ $compValue -lt `date +%Y` ]]; then return 1; fi;
	compValue=`echo $1 | grep "^[0-9]\{4\}[0-9]\{2\}[0-9]\{2\}$" | sed 's~^[0-9]\{4\}\([0-9]\{2\}\).*$~\1~'`
	in_range $compValue 01  `date +%m`
	if [ "$?" == 0 ]; then return 0; fi;
	if [[ $compValue -lt `date +%m` ]]; then return 1; fi;
	compValue=`echo $1 | grep "^[0-9]\{4\}[0-9]\{2\}[0-9]\{2\}$" | sed 's~^[0-9]\{4\}[0-9]\{2\}\([0-9]\{2\}\)$~\1~'`
	in_range $compValue 01  `date +%d`
	if [ "$?" == 0 ]; then return 0; fi;
	if [[ $compValue -lt `date +%d` ]]; then return 1; fi;
	return 0
}

#Determina si el archivo es una lista de precios o no
#Retorna 1 en caso verdadero 0 en caso contrario
#Guarda en $prob por qué se rechazó (si corresponde "" sino)
function es_lista_precios
{
	prob=""
	declare local validationData=`echo "$1" | grep "^[^ ]*-[0-9]\{8\}\..*$" | sed 's~^[^ ]*-\([0-9]\{8\}\)\.\(.*\)$~\1-\2~'`
	declare local fecha=`echo "$validationData" | sed "s~^\([0-9]\{8\}\)-.*$~\1~"`
	validar_fecha $fecha
	if [[ $? == 0 ]]; then
		#eval "$2"="Fecha invalida"
		prob="Fecha invalida"		
		return 0
	fi
	declare local colaborador=`echo "$validationData" | sed 's~^[0-9]\{8\}-\(.*\)$~\1~'`
	usuario_es_asociado "$colaborador" "Y"
	if [[ $? == 1 ]]; then
		prob="Asociado inexistente"
		return 0
	elif [[ $? == 2 ]]; then
		prob="Colaborador inexistente"
		return 0
	fi
	return 1
}

#Chequea si hay archivos en $1 y en caso de haber dispara el proceso $2 si no se están ejecutando
#ni el proceso $2 ni el proceso $3
function disparar_proceso
{
	declare local procName=`echo "$2" | tr [:lower:] [:upper:]`
	if [[ `find "$1" -maxdepth 1 -type f | wc -l` -ne 0  ]]; then
		#Si se está ejecutando $2 o $3 entonces pospongo la ejecución.
		if [[ ! -z `pgrep "$2"` || ! -z `pgrep "$3"` ]]; then
			bash logging.sh listener "Invocacion de $procName pospuesta para el proximo ciclo"
		else
			"$2.sh" &
			res=$?
			declare local pid=$(pgrep "$2")
			if [[ $res -ne 0 ]]; then
				bash logging.sh listener "Invocacion de $procName pospuesta para el proximo ciclo"
			else
				bash logging.sh listener "$procName corriendo bajo el no.: $pid"
				echo "$procName ejecutado, PID: $pid"
			fi
		fi
	fi
}

#Si el ambiente no está inicializado salgo con error.
if [[ -z $ENVINIT ]]; then
	bash logging.sh listener "Ambiente no inicializado" ERR
	exit 1
fi
#Ciclo infinito
while [[ 1 ]]; do
	#Grabar en el log el nro de ciclo
	CANTCICLOS=`expr $CANTCICLOS + 1`
	bash logging.sh listener "Nro de Ciclo: $CANTCICLOS"
	#Para cada archivo en $NOVEDIR ver que sea lista de compras o precios, sino rechazar
	#Archivos con pinta de lista de compras
	for arch in `ls -1 "$GRUPO/$NOVEDIR/" | grep "^[^\.]*\....$"`;
	do
		declare local str=`file "$GRUPO/$NOVEDIR/$arch" | sed 's-.*\(text\)$-\1-'`
		if [[ "$str" != "text" ]]; then
			bash Mover.sh "$GRUPO/$NOVEDIR/$arch" "$GRUPO/$RECHDIR/" listener
			bash logging.sh listener "Archivo rechazado: Tipo de archivo invalido"
			continue
		fi
		es_lista_compras "$arch"
		declare local res=$?
		if [[ $res -eq 1 ]]; then
			bash Mover.sh "$GRUPO/$NOVEDIR/$arch" "$GRUPO/$ACEPDIR/" listener
		else
			bash Mover.sh "$GRUPO/$NOVEDIR/$arch" "$GRUPO/$RECHDIR/" listener
			echo $prob
			logging.sh listener "Archivo rechazado: $prob"
		fi
	done
	#Archivos con pinta de lista de precios
	for arch in `ls -1 "$GRUPO/$NOVEDIR/" | grep "^[^\.]*-[^\.]*\..*$"`;
	do
		declare local str=`file "$GRUPO/$NOVEDIR/$arch" | sed 's-.*\(text\)$-\1-'`
		if [[ "$str" != "text" ]]; then
			bash Mover.sh "$GRUPO/$NOVEDIR/$arch" "$GRUPO/$RECHDIR/" listener
			bash logging.sh listener "Archivo rechazado: Tipo de archivo invalido"
			continue
		fi
		es_lista_precios "$arch"
		declare local res=$?
		if [[ $res -eq 1 ]]; then
			bash Mover.sh "$GRUPO/$NOVEDIR/$arch" ""$GRUPO"/"$MAEDIR"/precios/" listener
		else
			bash Mover.sh "$GRUPO/$NOVEDIR/$arch" "$GRUPO/$RECHDIR/" listener
			logging.sh listener "Archivo rechazado: $prob"
		fi
	done
	#Rechazar archivos que no tengan pinta de nada
	for arch in `ls -1 "$GRUPO/$NOVEDIR/" | grep -v "^[^\.]*-[^\.]*\..*$" | grep -v "^[^\.]*\....$"`;
	do
		bash Mover.sh "$GRUPO/$NOVEDIR/$arch" "$GRUPO/$RECHDIR/" listener
		bash logging.sh listener "Archivo rechazado: Estructura de nombre de archivo no identificada"
	done
	#Ver si hay que llamar a masterlist
	disparar_proceso ""$GRUPO"/"$MAEDIR"/precios/" masterlist rating
	#Ver si hay que llamar a rating	
	disparar_proceso ""$GRUPO"/"$ACEPDIR"/" rating masterlist
	#Dormir
	sleep 30
done
exit 0
