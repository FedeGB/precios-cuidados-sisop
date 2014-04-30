#!/bin/bash
#
#Variables:
#Paths para testear
PATHLOG='../Tools/'
NOVEDIR='./novedades/'
MAEDIR='../Datos/Maestros y Tablas/'
ACEPDIR='./aceptados/'
RECHDIR='./rechazados/'
LOGEXT='lis.log'
CANTCICLOS=0
#Funciones
function rechazar
{

}

function aceptar
{

}

#Valida que un usuario sea asociado
#Parámetros:
#$1 -> Nombre de usuario
#$2 -> "Y" si se quiere chequear que sea colaborador, cualquier otra cosa no chequea
function usuario_es_asociado
{
	declare local validationData=`cat "$MAEDIR"asociados.mae | grep "^[^;]*;[^;]*;$1;[0 | 1];[^@]*@[^@]*\.[^@]*$" |  
		sed "s~^[^;]*;[^;]*;\($1\);\([0 | 1]\);[^@]*@[^@]*\.[^@]*\$~\1-\2~"`
	if [[ "$2" == "Y" ]]; then
		declare local colaborador=`echo $validationData | sed "s~^$1-\([0 | 1]\)$~\1~"`
		if [[ "$colaborador" == "" ] || [ "$colaborador" == 0 ]]; then
			return 0
		fi
	fi
	declare local asociado=`echo $validationData | sed "s~^\($1\)-[0 | 1]$~\1~"`
	if [[ "$asociado" == "$1" ]]; then
		return 1
	else
		return 0
	fi
}

function es_lista_compras
{
	declare local usuario=`echo $1 | grep "^\([^\.]\)*\.[^- ]\{3\}$" | sed 's~^\([^\.]*\)\.[^- ]\{3\}$~\1~'`
	if [[ "$usuario" == "" ]]; then
		return 0
	else
		usuario_es_asociado $usuario
		return $? 
	fi
}

function es_lista_precios
{
	declare local validationData=`echo $1 | grep "^[^ ]*-[0-9]\{8\}\..*$" | sed 's~^[^ ]*-\([0-9]\{8\}\)\.\(.*\)$~\1-\2'`
	declare local fecha=`echo $validationData | sed "s~^\([0-9]\{8\}\)-.*$~\1~"`
	validar_fecha $fecha
	if [[ $? == 0 ]]; then
		return 0
	fi
	declare local colaborador=`echo $validationData | sed 's~^[0-9]\{8\}-\(.*\)$~\1~'`
	usuario_es_asociado $colaborador "Y"
	if [[ $? == 0 ]]; then
		return 0
	fi
	return 1
}


for arch in `ls $NOVEDIR`;
do
	#Por qué declare local? ver!
	declare local str=`file $arch | sed 's-^.*\(text\)$-\1-'`
	if [ "$str" != "text" ]
	then
		echo Rechazado #rechazar $arch
	else
		if [[ es_lista_compras $arch ]]; then
			#Aceptar
		else #ver de cambiar a elif
			if [[ es_lista_precios ]]; then
				#statements
			fi
		fi
	fi
done