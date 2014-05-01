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

#Determina si el archivo es una lista de compras o no
#Retorna 1 en caso verdadero 0 en caso contrario
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
	if [[ `echo $1 | wc -m` -ne 8 ]]; then return 0; fi;
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
