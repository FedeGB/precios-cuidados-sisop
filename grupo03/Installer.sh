#!/bin/bash


###################Variables de entorno#######################

# Codigos de error:
ERROR0=0	
ERROR_DEPENDENCIAS=1
ERROR_PERL=2	
ERROR_USUARIO=3	
ERROR_ARCHIVO=4	


GRUPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NUMGRUPO=03
VERSION='v1.0'
ARCHIVOLOG="logging.sh"
LOG="./${ARCHIVOLOG}"
CONFDIR="conf"
CONF_INSTALACION="${GRUPO}/${CONFDIR}/Installer.conf"
SRCDIR="src"
PERL_VER_REQ=5
SCRIPTS=('Initializer.sh' 'listener.sh' 'masterlist.sh' 'rating.sh' 'reporting.pl' 'Mover.sh' 'Start.sh' 'Stop.sh' 'logging.sh')

#Ubicaciones de directorios
BINDIR=bin
MAEDIR=mae
NOVEDIR=arribos
DATASIZE=100
ACEPDIR=aceptadas
INFODIR=informes
RECHDIR=rechazados
LOGDIR=log
LOGEXT=log
LOGSIZE=400
DIRECTORIOS=( "$BINDIR" "$MAEDIR" "$NOVEDIR" "$DATASIZE" "$ACEPDIR" "$INFODIR" "$RECHDIR" "$LOGDIR" "$LOGEXT" "$LOGSIZE" )

#Mensajes para que el usuario elija los directorios
MENSAJE1="Defina el directorio de instalación de los ejecutables"
MENSAJE2="Defina directorio para maestros y tablas"
MENSAJE3="Defina el Directorio de arribo de novedades"
MENSAJE4="Defina espacio mínimo para el arribo de novedades en Mbytes"
MENSAJE5="Defina el directorio de grabación de las novedades aceptadas"
MENSAJE6="Defina el directorio de grabación de los informes de salida"
MENSAJE7="Defina el directorio de grabación de Archivos rechazados"
MENSAJE8="Defina el directorio de logs"
MENSAJE9="Ingrese la extensión para los archivos de log"
MENSAJE10="Defina el tamaño máximo para los archivos de log en Kbytes"
MENSAJES=( "$MENSAJE1" "$MENSAJE2" "$MENSAJE3" "$MENSAJE4" "$MENSAJE5" "$MENSAJE6" "$MENSAJE7" 
"$MENSAJE8" "$MENSAJE9" "$MENSAJE10" )

#Mensajes para presentar el estado de la instalacion
HEADER1="Direct. de Configuracion: "
HEADER2="Directorio Ejecutables: "
HEADER3="Direct. Maestros y Tablas: "
HEADER4="Directorio de Novedades: "
HEADER5="Espacio mínimo libre para arribos: "
HEADER6="Dir. Novedades aceptadas: "
HEADER7="Dir. Informes de salida: "
HEADER8="Dir. Archivos Rechazados: "
HEADER9="Dir. de Logs de Comandos: "
HEADER10="Tamaño máximo para los archivos de logs del sistema: "
HEADER11="Estado de la instalación: "

HEADERS=("$HEADER1" "$HEADER2" "$HEADER3" "$HEADER4" "$HEADER5" "$HEADER6" "$HEADER7" "$HEADER8" "$HEADER9" "$HEADER10" "$HEADER11")

#Mensajes generales
COPYRIGHT="TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo $NUMGRUPO"
TERM_Y_COND="$COPYRIGHT\n\n Al instalar TP SO7508 Primer Cuatrimestre 2014 UD.expresa aceptar los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.\n\nAcepta? (Si - No)"
MENSAJE_PERL="$COPYRIGHT\n\nPara instalar el TP es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente.\n\n Proceso de Instalación Cancelado"

#Funciones

function showVersion() {
        echo -e "Universidad de Buenos Aires - Facultad de Ingeniería\n7508 Sistemas Operativos\nTrabajo Práctico: Sarasa-$VERSION\nGrupo $NUMGRUPO\n2º cuat. 2013\nHome Page: http://code.google.com/p/ssoo22013/\n"
        echo -e "$COPYRIGHT\n"
}

function showHelp() {
        echo "Ayuda Instalador de Sistema de Reserva de Entradas de Obras Teatrales-$VERSION"
        echo -e "Uso: Instalar_TP [OPCIONES]\n"
        echo "Sin opciones                      Instala o repara el sistema normalmente"
        echo "-v                                Muestra la version del sistema"
        echo "-h                                Muestra esta ayuda"
}


#Sale del script con el codigo pasado en el primer parametro y un mensaje en el segundo
#Se encarga de borrar el archivo de log
function salir() {
	echo -e "$2"
	$LOG "installer" "$2"
	$LOG "installer" "Proceso de instalación finalizado"
	[ -e ${BASE}/${ARCHIVOLOG} ] && rm ${BASE}/${ARCHIVOLOG}
	exit $1
}


#Procesa la respuesta del usuario en caso de si y sus variantes sigue, sino termina
function respuestaSINO() {
        local ELECCION
        read ELECCION
        ELECCION=$(echo "$ELECCION" | tr [:upper:] [:lower:])
        if [ "$ELECCION" != 'si' -a "$ELECCION" != 's' -a "$ELECCION" != '' ]; then
                $LOG "installer" "$ELECCION"
                SALIR $ERROR_USUARIO
        else
		$LOG "installer" "$ELECCION"
        fi
}


#Hace una copia del archivo de log al path actual para utilizarlo
function iniciarLog() {
	echo -n "Inicializar log. . . ."
        cp "${GRUPO}/${SRCDIR}/${ARCHIVOLOG}" "$GRUPO"
        chmod u+x "${GRUPO}/${ARCHIVOLOG}"
	export GRUPO
	export CONFDIR
	export LOGSIZE
	echo "HECHO"
}


function chequearFuentes() {
	local FALTANTES
	
	echo -n "Chequeando Fuentes . . . . "

	if [ -d "${GRUPO}/$SRCDIR" ]; then
       	        for i in "${SCRIPTS[@]}"; do
	       	        [ -e "${GRUPO}/${SRCDIR}/${i}" ] || FALTANTES=("${FALTANTES[@]}" "$i")
       		done
	else
        	[ -d "${GRUPO}/$SRCDIR" ] || FALTANTES=("${FALTANTES[@]}" "${GRUPO}/$SRCDIR")
	fi

	if [ ${#FALTANTES[@]} -gt 0 ]; then
		echo -e "\nPaquete de instalación incompleto.\nFuentes faltantes: ${FALTANTES[@]}	\nInstalación Cancelada."
		$LOG "installer" "\nPaquete de instalación incompleto.\nFuentes faltantes: ${FALTANTES[@]}	\nInstalación Cancelada."
		exit $ERROR_DEPENDENCIAS
	fi

	[ -d "${GRUPO}/conf" ] || mkdir "${GRUPO}/conf"
	echo "HECHO"
}

function terminosYcondiciones() {
	echo -e "$TERM_Y_COND"
	$LOG "installer" "$TERM_Y_COND"
	respuestaSINO
}

function chequearPerl() {
        local PERL_VER_ACT=$(perl -v | grep 'v[0-9][0-9]*' | cut -d. -f1 | sed 's/\(.*\)\(v\)\([0-9]*\)$/\3/')
        if [ $PERL_VER_ACT -lt $PERL_VER_REQ ];then
		salir $ERROR_PERL  "$MENSAJE_PERL"
        fi
        echo -e "$COPYRIGHT\n\nPerl Version: $PERL_VER_ACT"
        $LOG "installer" "$COPYRIGHT\n\nPerl Version: $PERL_VER_ACT"
}


function reasignarDirectorios() {
BINDIR="${DIRECTORIOS[0]}"
MAEDIR="${DIRECTORIOS[1]}"
NOVEDIR="${DIRECTORIOS[2]}"
DATASIZE="${DIRECTORIOS[3]}"
ACEPDIR="${DIRECTORIOS[4]}"
INFODIR="${DIRECTORIOS[5]}"
RECHDIR="${DIRECTORIOS[6]}"
LOGDIR="${DIRECTORIOS[7]}"
LOGEXT="${DIRECTORIOS[8]}"
LOGSIZE="${DIRECTORIOS[9]}"
}


function definirDirectorios() {
local directorio retorno instalado=0
while [ $instalado -eq 0 ]; do
        for (( i = 0; i < ${#MENSAJES[@]}; ++i )); do
                while : ; do
                        # Le pido al usuario que ingrese un valor
			if [ $i = 3 -o $i =  8 -o $i =  9 ]; then
	                        echo -n "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "  
				$LOG "installer" "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "
			else
	                        echo -n "${MENSAJES[$i]} (${GRUPO}/${DIRECTORIOS[$i]}): "  
				$LOG "installer" "${MENSAJES[$i]} (${GRUPO}/${DIRECTORIOS[$i]}): "
			fi
                        read directorio
			if [ "$directorio" = '' ]; then
                                $LOG "installer" "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): ${DIRECTORIOS[$i]}"
	                        break
			else
	                        DIRECTORIOS[$i]="$directorio"
                                $LOG "installer" "$directorio"
                                break
                        fi
                done
        done
        # Muestro el estado de la instalación y lo loggeo
        clear
	reasignarDirectorios
        ESTADO_INST="$COPYRIGHT
${HEADERS[0]}"$CONFDIR"
${HEADERS[1]}"$BINDIR"
${HEADERS[2]}"$MAEDIR"
${HEADERS[3]}"$NOVEDIR"
${HEADERS[4]}"$DATASIZE" Mb
${HEADERS[5]}"$ACEPDIR"
${HEADERS[6]}"$INFODIR"
${HEADERS[7]}"$RECHDIR"
${HEADERS[8]}"$LOGDIR"/<comando>."$LOGEXT"
${HEADERS[9]}"$LOGSIZE" Kb        
${HEADERS[10]}"LISTA""

        echo "$ESTADO_INST"
        $LOG "installer" "$ESTADO_INST"
        echo -e "\nEstá de acuerdo con la configuración de instalación? (Si - No): "
        $LOG "installer" "Está de acuerdo con la configuración de instalación? (Si - No): "
        read OPCION
        OPCION=$(echo "$OPCION" | tr [:upper:] [:lower:])
        [ "$OPCION" = 'si' -o "$OPCION" = 's' -o "$OPCION" = '' ] && instalado=1
	if [ "$OPCION" == '' ]; then
	      	$LOG "installer" "Si"
	else
	      	$LOG "installer" "$OPCION"
	fi
done

}

function CrearJerarquia() {
        local CURR_DIR
        #local A=${1#*/}
        TMP=$IFS
        IFS='/'
        for word in $1; do
                CURR_DIR+="$word/"
                if [ ! -d "$CURR_DIR" ]; then
                        mkdir "$CURR_DIR"
			echo "$1"
                fi
        done
        IFS=$TMP
}

function GuardarDatos() {
        local REG="$1"="$2"=$(whoami)=$(date +"%d/%m/%y %r")
        echo "$REG" >> $CONF_INSTALACION
}


function instalarDirectorios() {
echo -n "Iniciando Instalación. Está Ud. seguro (Si - No): "
$LOG "installer" "Iniciando Instalación. Está Ud. seguro (Si - No): "
respuestaSINO

# Creo la estructura de directorios
echo "Creando Estructuras de Directorios"
MAEDIR2="$MAEDIR/precios/proc"
ACEPDIR2="$ACEPDIR/proc"
INFODIR2="$INFODIR/pres"

DIRECTORIOS=( "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$INFODIR" "$RECHDIR" "$LOGDIR" "$MAEDIR2" "$ACEPDIR2" "$INFODIR2")

for ((i=0; i <= ${#DIRECTORIOS[@]}; ++i)); do
        CrearJerarquia "${DIRECTORIOS[$i]}"
done

# Copio los archivos necesarios para la ejecución del sistema
echo "Instalando Archivos Maestros y Tablas"
local mae_files
for file in $(ls ${SRCDIR}/*.mae); do
        cp "$file" "$MAEDIR"
        file=${file##*/}
        mae_files+="${file#$BASE}"'$'
done

local tab_files
for file in $(ls ${SRCDIR}/*.tab); do
        cp "$file" "$MAEDIR"
        file=${file##*/}
        tab_files+="${file#$BASE}"'$'
done


echo "Instalando Programas y Funciones"
local script_files
for script in "${SCRIPTS[@]}"; do
        cp "${SRCDIR}/${script}" "$BINDIR"
        chmod u+x "${BINDIR}/${script}"
        script_files+="${script}"'$'
done


BASE1="${GRUPO}/"

echo "Actualizando la configuración del sistema"
local COMPONENTES=(GRUPO CONFDIR BINDIR MAEDIR NOVEDIR DATASIZE ACEPDIR INFODIR RECHDIR LOGDIR LOGEXT LOGSIZE )
local VALORES=("$GRUPO" "${CONFDIR#$BASE1}" "${BINDIR#$BASE1}" "${MAEDIR#$BASE1}" "${NOVEDIR#$BASE1}" "${DATASIZE#$BASE1}" "${ACEPDIR#$BASE1}" "${INFODIR#$BASE1}" "${RECHDIR#$BASE1}"  "${LOGDIR#$BASE1}" "${LOGEXT#$BASE1}" "${LOGSIZE#$BASE1}")

#creo archivo d configuracion
#[ -d "$CONF_INSTALACION" ] || mkdir $CONF_INSTALACION

# Guardo las decisiones del usuario
for (( i=0; i < "${#COMPONENTES[@]}"; ++i)); do
        GuardarDatos "${COMPONENTES[$i]}" "${VALORES[$i]}"
done

# Guardo la ubicación de los archivos
GuardarDatos "MAEFILES" "$mae_files"
GuardarDatos "DISFILES" "$dis_files"
GuardarDatos "SCRIPTFILES" "$script_files"


echo "Instalación CONCLUIDA"

#error_exit $ERRNO0 ''

}

function instalacionNormal() {
	echo "Inicio de Ejecución del Installer"
	$LOG "installer" "Inicio de Ejecución del Installer"

	echo "Log de la instalación: ${GRUPO}/${CONFDIR}/Installer.log"
	$LOG "installer" "Log de la instalación: ${GRUPO}/${CONFDIR}/Installer.log"

	echo "Directorio predefinido de Configuración: ${GRUPO}/${CONFDIR}"
	$LOG "installer" "Directorio predefinido de Configuración: ${GRUPO}/${CONFDIR}"

	terminosYcondiciones
	chequearPerl
	definirDirectorios
	instalarDirectorios
}

function reinstalacion() {
DIRECTORIOS=( "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$INFODIR" "$RECHDIR" "$LOGDIR" "$LOGEXT" "$LOGSIZE" )

	$LOG 'installer' 'Comprobando Instalación existente'
        local RESUMEN="$COPYRIGHT\n\n"
	local EXPR DIR DIRFALTANES ARCHFALTANTES
	local reg_name=(GRUPO CONFDIR BINDIR MAEDIR NOVEDIR ACEPDIR INFODIR RECHDIR LOGDIR LOGEXT LOGSIZE)
	local reg_value=("$GRUPO" 'conf' '.' '.' '.' '.' '.' '.' '.' '.' '.' '.' '.')
	local reg_validacion=(ValidarGrupo ValidarConf ValidarDirectorio ValidarDirectorio ValidarDirectorio ValidarDirectorio ValidarDirectorio ValidarDirectorio ValidarDirectorio ValidarDirectorio ValidarExtension)
	local HEADERS2=('' "$HEADER1" "$HEADER2" "$HEADER3" "$HEADER4" "$HEADER6" "$HEADER7" "$HEADER8" "$HEADER9" )

	local BASE2=${GRUPO}/
	for (( i=0; i < ${#reg_name[@]}; ++i)); do
		local reg=$(grep '^'"${reg_name[$i]}"'=[^=]\{1,\}='"$(whoami)=" "$CONF_INSTALACION")
		[ -z "$reg" ] && exit $ERROR5 
		#"Archivo de configuración corrupto. Error en el registro ${reg_name[$i]}."
		reg=$(echo "$reg" | cut -d'=' -f2)
		#${reg_validacion[$i]} "$reg"
		#[ $? -eq 2 ] && exit $ERROR5 
		#"Archivo de configuración corrupto. Error en el registro ${reg_name[$i]}."
		[ "${reg_name[$i]}" = 'GRUPO' ] && continue
		[ "${reg_name[$i]}" = 'LOGSIZE' ] && continue
		if [ "${reg_name[$i]}" = 'LOGEXT' ]; then
			RESUMEN+="$reg\n"	
			continue		
		fi
		if [ "${reg_name[$i]}" = 'LOGDIR' ]; then
			RESUMEN+="${HEADERS2[$i]}$BASE2$reg/<comando>."
			continue
		fi
		if [ "${reg_name[$i]}" = 'CONFDIR' -o "${reg_name[$i]}" = 'BINDIR' -o "${reg_name[$i]}" = 'MAEDIR' ]; then
			RESUMEN+="${HEADERS2[$i]}""$BASE2$reg\n"
			if [ -e "$BASE2$reg" ]; then
        			RESUMEN+='Archivos existentes:\n'$(ls "$BASE2$reg")"\n"
		        else
                	        DIRFALTANTES=("${DIRFALTANTES[@]}" "$BASE2$reg")
		                #RESUMEN+="\n\n"
                	fi	
		elif [ "${reg_name[$i]}" = 'LOGEXT' -o "${reg_name[$i]}" = 'LOGDIR' ]; then
			continue
		else
        		[ -e "$BASE2$reg" ] || DIRFALTANTES=("${DIRFALTANTES[@]}" "$BASE2$reg")
			RESUMEN+="${HEADERS2[$i]}""$reg\n"
			#RESUMEN+='\n\n'
		fi
	done

	[ -z "$(grep "^MAEFILES="'.*'"=$(whoami)=" "$CONF_INSTALACION")" ] && exit $ERROR5
# "Archivo de configuración corrupto. Error en la variable MAEFILES."

        local TMP=$IFS
        IFS='$'

        # Reviso los archivos
        local MAEFILES=$(grep "^MAEFILES" "$CONF_INSTALACION" | cut -d'=' -f2)
	MAEDIR=$(grep '^MAEDIR' "$CONF_INSTALACION" | cut -d'=' -f2)
        for i in $(echo "$MAEFILES" | cat); do
		[ -e "$BASE2$MAEDIR/$i" ] || ARCHFALTANTES=("${ARCHFALTANTES[@]}" "$BASE2$MAEDIR/$i")
	done
		
	IFS=$TMP
	[ -z "$(grep "^DISFILES="'.*'"=$(whoami)=" "$CONF_INSTALACION")" ] && error_exit $ERRNO5 "Archivo de configuración corrupto. Error en la variable DISFILES."
	IFS='$'
	local DISFILES=$(grep "^DISFILES" "$CONF_INSTALACION" | cut -d'=' -f2)
	PROCDIR=$(grep '^PROCDIR' "$CONF_INSTALACION" | cut -d'=' -f2)
	for i in $(echo "$DISFILES" | cat); do
		[ -e "$BASE2$PROCDIR/$i" ] || ARCHFALTANTES=("${ARCHFALTANTES[@]}" "$BASE2$PROCDIR/$i")
	done

	IFS=$TMP
	[ -z "$(grep "^SCRIPTFILES="'.*'"=$(whoami)=" "$CONF_INSTALACION")" ] && error_exit $ERRNO5 "Archivo de configuración corrupto. Error en la variable SCRIPTFILES."
	IFS='$'
	local SCRIPTFILES=$(grep "^SCRIPTFILES" "$CONF_INSTALACION" | cut -d'=' -f2)
	BINDIR=$(grep '^BINDIR' "$CONF_INSTALACION" | cut -d'=' -f2)
	for i in $(echo "$SCRIPTFILES" | cat); do
		[ -e "$BASE2$BINDIR/$i" ] || ARCHFALTANTES=("${ARCHFALTANTES[@]}" "$BASE2$BINDIR/$i")
	done
     
	IFS=$TMP
        # Me fijo si tengo que restaurar algo
	if [ ${#DIRFALTANTES[@]} -eq 0 -a ${#ARCHFALTANTES[@]} -eq 0 ]; then
		# INSTALACIÓN COMPLETA
		RESUMEN+="\nEstado de la Instalación: COMPLETA\n\nProceso de Instalación Cancelado"
		echo -e "$RESUMEN"
		$LOG "installer" "$RESUMEN"
        else
		# REPARAR
                RESUMEN+="\n\nComponentes faltantes:\n\nDirectorios:\n"
                for (( i=0; i <= ${#DIRFALTANTES[@]}; ++i)); do
			RESUMEN+="${DIRFALTANTES[$i]##*/}\n"
                done
                RESUMEN+="Archivos:\n"
                for (( i=0; i <= ${#ARCHFALTANTES[@]}; ++i)); do
			RESUMEN+="${ARCHFALTANTES[$i]##*/}\n"
                done
                RESUMEN+="Estado de la Instalación: INCOMPLETA\n\nDesea completar la Instalación (Si-No)"
                echo -e "$RESUMEN"
                $LOG "installer" "$RESUMEN"
		respuestaSINO
                # Instalar lo que falta
                echo -n "Restaurando Estructuras de Directorio. . . . "
		for DIRECTORIO in "${DIRFALTANTES[@]}"; do
			CrearJerarquia "$DIRECTORIO"
                done
                echo HECHO
                local NOMBRE DIRECCION
                echo -n "Restaurando Archivos faltantes. . . . "
		for ARCHIVO in "${ARCHFALTANTES[@]}"; do
			NOMBRE=${ARCHIVO##*/}
                        DIRECCION=${ARCHIVO%/*}
                        cp "$SRCDIR/$NOMBRE" "$DIRECCION"
                        for s in "${SCRIPTS[@]}"; do
				[ "$s" = "$NOMBRE" ] && chmod u+x "$ARCHIVO"
                        done
		done
                echo HECHO
                echo "Instalación CONCLUIDA"
	fi
        exit $ERROR0

}

#main

# Configuro el script de log para poder usarlo en la instalación
if [ $# -eq 0 ]; then
	iniciarLog
	chequearFuentes	
        if [ ! -e $CONF_INSTALACION ]; then
        	instalacionNormal
	else
		reinstalacion
	fi
elif [ $# -eq 1 ]; then
        if [ "$1" = '-v' ]; then
                showVersion
        elif [ "$1" = '-h' ]; then
                showHelp
        else
                echo -e 'Parámetros inválidos\nIngrese -h para visualizar la ayuda.'            
        fi
else
        echo -e 'Parámetros inválidos\nIngrese -h para visualizar la ayuda.'            
fi
