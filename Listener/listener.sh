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

function esListaDeCompras
{
	declare local usuario=`echo $1 | grep "^\([^\.]\)*\.[^-\s]\{3\}" | sed 's~^\([^\.]*\)\.[^-\s]\{3\}~\1~'`
	if [[ "$usuario" == "" ]]; then
		#return False
	else
		declare local asociado=`cat "$MAEDIR"asociados.mae | grep "^[^;]*;[^;]*;$usuario;[0 | 1];[^@]*@[^@]*\.[^@]*$" |  
		sed "s~^[^;]*;[^;]*;\($usuario\);[0 | 1];[^@]*@[^@]*\.[^@]*\$~\1~"`
		if [[ "$asociado" == "$usuario" ]]; then
			#return True
		else
			#return False
		fi
	fi
}

for arch in `ls $NOVEDIR`;
do
	#Por qué declare local? ver!
	declare local str=`file $arch | sed 's-^.*\(text\)$-\1-'`
	if [ "$str" != "text" ]
	then
		echo Rechazado #rechazar $arch
	else
		if [[ esListaDeCompras $arch ]]; then
			#statements
		fi
	fi
done