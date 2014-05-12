#!/bin/bash


###################Definicion de variables#######################

# Codigos de error:
ERROR0=0	
ERROR_DEPENDENCIAS=1	#Faltan archivos fuentes
ERROR_PERL=2		#Perl no esta instalado o es una version antigua
ERROR_USUARIO=3		#El usuario decidio terminar la instalacion
ERROR_ARCHIVO=4		#Error al leer el archivo de configuracion "Installer.conf"


GRUPO=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
NUMGRUPO=03
VERSION="v1.0"
ARCHIVOLOG="logging.sh"
LOG="./${ARCHIVOLOG}"
CONFDIR="conf"
CONF_INSTALACION="${GRUPO}/${CONFDIR}/Installer.conf"
SRCDIR="src"
VERSION_PERL=5
SCRIPTS=('Initializer.sh' 'listener.sh' 'masterlist.sh' 'rating.sh' 'reporting.pl' 'Mover.sh' 'Start.sh' 'Stop.sh' 'logging.sh')

#Ubicaciones y parametros de directorios y archivos
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

#Mensajes generales
COPYRIGHT="TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo $NUMGRUPO"
TERM_Y_COND="$COPYRIGHT\n\nAl instalar TP SO7508 Primer Cuatrimestre 2014 UD.expresa aceptar los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.\n\nAcepta? (Si - No)"
MENSAJE_PERL="$COPYRIGHT\n\nPara instalar el TP es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente.\n\n Proceso de Instalación Cancelado"

###################Funciones#######################

function showVersion() {
        echo -e "Universidad de Buenos Aires - Facultad de Ingeniería\n7508 Sistemas Operativos\nTrabajo Práctico: RETAILC-$VERSION\nGrupo $NUMGRUPO\n1º cuat. 2014\n"
}

function showHelp() {
        echo "Ayuda Instalador RETAILC-$VERSION"
        echo -e "Uso: Instalar_TP [OPCIONES]\n"
        echo "Sin opciones                      Instala o repara el sistema normalmente"
        echo "-v                                Muestra la version del sistema"
        echo "-h                                Muestra esta ayuda"
}


#Sale del script con el codigo pasado en el primer parametro y un mensaje en el segundo que se muestran por consola y se guardan en el log
#Se encarga de borrar el archivo de log
function salir() {
	echo -e "$2"
	$LOG "installer" "$2"
	$LOG "installer" "Proceso de instalación finalizado"
	[ -e ${GRUPO}/${ARCHIVOLOG} ] && rm ${GRUPO}/${ARCHIVOLOG}
	exit $1
}


#Procesa la respuesta del usuario. En caso de si o alguna variante devuelve 0, no o alguna variante devuelve 1 sino se pide que responda de nuevo
function respuestaSINO() {
        local ELECCION ELECCION_AUX
	while : ; do
	        read ELECCION
	        ELECCION_AUX=$(echo "$ELECCION" | tr [:upper:] [:lower:])
	        if [ "$ELECCION_AUX" = 'si' -o "$ELECCION_AUX" = 's' -o "$ELECCION_AUX" = '' ]; then
        	        $LOG "installer" "$ELECCION"
			return 0
	        elif [ "$ELECCION_AUX" = 'no' -o "$ELECCION_AUX" = 'n' ]; then
			$LOG "installer" "$ELECCION"
			return 1
		else
			echo "$ELECCION es una respuesta invalida, responda si-no"
			$LOG "installer" "$ELECCION es una respuesta invalida, responda Si-No"
	        fi
	done
}


#Valida que sea un numero entero y que haya espacio suficiente en disco. Devuelve 0 en caso afirmativo sino 1 
function validarEspacio() {
	local espacio=$(df -B"M" ./ | tail -n1 | sed 's/\s//g' | cut -d"M" -f3)
        echo "$1" | grep -e '^[1-9][0-9]\{1,\}$' > /dev/null
        if [ $? -eq 0 ]; then
		if [ $espacio -gt $1 -a $1 -gt 0 ]; then
			return 0
		else
	               	echo -e "Insuficiente espacio en disco.\nEspacio disponible: $espacio Mb.\nEspacio requerido $1 Mb\n Inténtelo nuevamente."
			$LOG "installer" "Insuficiente espacio en disco.\nEspacio disponible: $espacio Mb.\nEspacio requerido $1 Mb\n Inténtelo nuevamente."
			return 1
		fi
	else
		echo "Respuesta invalida. Ingrese un entero"
		$LOG "installer" "Respuesta invalida. Ingrese un entero"
	return 1
        fi
}



#Valida si el nombre del directorio ingresado por el usuario tiene un formato correcto. Retorna 0 en caso positivo sino 1.
function validarDirectorio() {
        local tmp=$IFS count=0

  	local tmp2=$1
        echo "$tmp2" | grep '^/' > /dev/null
       	[ $? -eq 0 ] && tmp2=${tmp2#*/}
        echo "$tmp2" | grep '/$' > /dev/null
        IFS='/'
        for campo in $tmp2; do
		echo "$campo" | grep -e '[[<>:^"\|*?=%$+,;~]' -e ']' -e '^$' -e '//' -e '^\s' -e '\s$' -e '\.$' 		-e '^\.' -e '^-' -e '\.\.' > /dev/null
                [ $? -eq 0 ] && let ++count
        done
        IFS=$tmp
        if [ $count -eq 0 ]; then
		return 0
        else
        	return 1
        fi

}

#Valida que la extension pasada como parametro sea a los sumo de 3 caracteres alfanumericos. Devuelve 0 en caso posivo sino 1
function validarExtension() {
        echo "$1" | grep -e '^[[:alnum:]]\{1,3\}$' > /dev/null
        if [ $? -eq 0 ]; then
        	return 0
        else
        	return 1
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


#Chequea la lista de archivos fuentes en el directorio src/ y el directorio conf/ en caso de no existir
function chequearFuentes() {
	declare -a local FALTANTES 
	
	echo -n "Chequeando Fuentes . . . . "

	if [ -d "${GRUPO}/$SRCDIR" ]; then
       	        for i in "${SCRIPTS[@]}"; do
	       	        [ -e "${GRUPO}/${SRCDIR}/${i}" ] || FALTANTES=("${FALTANTES[@]}" "$i")
       		done
	else
        	[ -d "${GRUPO}/$SRCDIR" ] || FALTANTES=("${FALTANTES[@]}" "${GRUPO}/$SRCDIR")
	fi
	
	if [ ${#FALTANTES[@]} -gt 0 ]; then
		salir $ERROR_DEPENDENCIAS "\nPaquete de instalación incompleto.\nFuentes faltantes: ${FALTANTES[@]}	\nInstalación Cvancelada."
	fi

	[ -d "${GRUPO}/conf" ] || mkdir "${GRUPO}/conf"
	echo "HECHO"
}

function terminosYcondiciones() {
	echo -e "\n\n$TERM_Y_COND"
	$LOG "installer" "$TERM_Y_COND"
	respuestaSINO
	if [ $? = 1 ]; then
		salir "$ERROR_USUARIO" "El usuario no acepto terminos y condiciones"
	fi
}

function chequearPerl() {
        local aux=$(perl -v | grep 'v[0-9][0-9]*' | cut -d. -f1 | sed 's/\(.*\)\(v\)\([0-9]*\)$/\3/')
        if [ $aux -lt $VERSION_PERL ];then
		salir $ERROR_PERL  "$MENSAJE_PERL"
        fi
        echo -e "$COPYRIGHT\n\nPerl Version: $aux"
        $LOG "installer" "$COPYRIGHT\n\nPerl Version: $aux"
}


#Reasigna los parametros del sistema de los valores por default a los ingresados po el usuario
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



#Loop en donde el usuario ingresa parametros del sistema
function definirDirectorios() {
local respuesta retorno instalado=0
while [ $instalado -eq 0 ]; do
        for (( i = 0; i < ${#MENSAJES[@]}; ++i )); do
                while : ; do
                        # Le pido al usuario que ingrese un valor
			if [ $i = 3 -o $i =  8 -o $i =  9 ]; then
	                        echo -n "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "  
				$LOG "installer" "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "
			else
	                        echo -n "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "  
				$LOG "installer" "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "
			fi
                        read respuesta
			#Si la respuesta es por defecto sigo a la siguiente pregunta
			if [ "$respuesta" = '' ]; then
                                $LOG "installer" "${DIRECTORIOS[$i]}"
	                        break
			#Si la respuesta es el tamanio de un archivo lo valido
			elif [ $i = 3 -o $i = 9 ]; then
				validarEspacio "$respuesta"
				if [ $? = 0 ]; then
	                        	DIRECTORIOS[$i]="$respuesta"
	                                $LOG "installer" "$respuesta"
                                	break
				else
					continue
				fi

			#Si la respuesta es la extension del archivo log la valido
			elif [ "$i" = 8 ]; then
				validarExtension "$respuesta"
				if [ $? = 0 ]; then
	                        	DIRECTORIOS[$i]="$respuesta"
	                                $LOG "installer" "$respuesta"
                                	break
				else
					echo "$respuesta es una extension invalida, vuelva a intentar"
	                                $LOG "installer" "$respuesta es una extension invalida, vuelva a intentar"
					continue
				fi
			#Si la respuesta es un nombre de directorio lo valido
			else 	
				validarDirectorio "$respuesta"
				if [ $? = 0 ]; then
	                        	DIRECTORIOS[$i]="$respuesta"
	                                $LOG "installer" "$respuesta"
                                	break
				else
					echo "$respuesta es una extension invalida, vuelva a intentar"
	                                $LOG "installer" "$respuesta es una extension invalida, vuelva a intentar"
					continue
				fi
		
                        fi
                done
        done
        #Muestro el estado de la instalación y lo loggeo
        clear
	local HEADERS=("$HEADER1" "$HEADER2" "$HEADER3" "$HEADER4" "$HEADER5" "$HEADER6" "$HEADER7" "$HEADER8" "$HEADER9" "$HEADER10" "$HEADER11")

        ESTADO_INST="$COPYRIGHT
${HEADERS[0]}"$GRUPO/$CONFDIR"
Installer.conf
${HEADERS[1]}"$GRUPO/${DIRECTORIOS[0]}"
Initializer.sh listener.sh masterlist.sh rating.sh reporting.pl Mover.sh Start.sh Stop.sh logging.sh
${HEADERS[2]}"$GRUPO/${DIRECTORIOS[1]}"
asociados.mae super.mae um.tab
${HEADERS[3]}"$GRUPO/${DIRECTORIOS[2]}"
${HEADERS[4]}"${DIRECTORIOS[3]}" Mb
${HEADERS[5]}"$GRUPO/${DIRECTORIOS[4]}"
${HEADERS[6]}"$GRUPO/${DIRECTORIOS[5]}"
${HEADERS[7]}"$GRUPO/${DIRECTORIOS[6]}"
${HEADERS[8]}"$GRUPO/${DIRECTORIOS[7]}"/<comando>."${DIRECTORIOS[8]}"
${HEADERS[9]}"${DIRECTORIOS[9]}" Kb        
${HEADERS[10]} LISTA"

        echo "$ESTADO_INST"
        $LOG "installer" "$ESTADO_INST"
        echo -e "\nEstá de acuerdo con la configuración de instalación? (Si - No): "
        $LOG "installer" "Está de acuerdo con la configuración de instalación? (Si - No): "
	respuestaSINO
	if [ $? = 0 ]; then
		reasignarDirectorios
		instalado=1
	fi
done

}

function crearJerarquia() {
	if [ ! -d "$1" ]; then
		mkdir "$1"
		echo "$1"
        fi
}

#Guarda variables de configuracion en el archivo Installer.conf
function guardarDatos() {
        local REG="$1"="$2"=$(whoami)=$(date +"%d/%m/%y %r")
        echo "$REG" >> $CONF_INSTALACION
}


#Crea la jerarquia de directorios, copia los archivos fuentes y guarda los parametros del sistema en el archivo Installer.conf
function instalarDirectorios() {
	echo -n "Iniciando Instalación. Está Ud. seguro (Si - No): "
	$LOG "installer" "Iniciando Instalación. Está Ud. seguro (Si - No): "
	respuestaSINO
	if [ $? = 1 ]; then
		salir "$ERROR_USUARIO" "El usuario no estaba seguro de continuar la instalacion"
	fi

	# Creo la estructura de directorios
	echo "Creando Estructuras de Directorios"
	MAEDIR2="$MAEDIR/precios"
	MAEDIR3="$MAEDIR/precios/proc"
	ACEPDIR2="$ACEPDIR/proc"
	INFODIR2="$INFODIR/pres"

	DIRECTORIOS2=( "$BINDIR" "$MAEDIR" "$MAEDIR2" "$MAEDIR3" "$NOVEDIR" "$ACEPDIR" "$ACEPDIR2" "$INFODIR" "$INFODIR2" "$RECHDIR" "$LOGDIR" )

	for ((i=0; i <= ${#DIRECTORIOS[@]}; ++i)); do
        	crearJerarquia "${DIRECTORIOS2[$i]}"
	done


	echo "Instalando Archivos Maestros y Tablas"
	local MAE_ARCHIVOS
	for file in $(ls ${SRCDIR}/*.mae); do
        	cp "$file" "$MAEDIR"
	        file=${file##*/}
        	MAE_ARCHIVOS+="${file#$BASE}"'$'
	done

	local TAB_ARCHIVOS
	for file in $(ls ${SRCDIR}/*.tab); do
        	cp "$file" "$MAEDIR"
        	file=${file##*/}
        	TAB_ARCHIVOS+="${file#$BASE}"'$'
	done


	echo "Instalando Programas y Funciones"
	local SCRIPT_ARCHIVOS
	for script in "${SCRIPTS[@]}"; do
        	cp "${SRCDIR}/${script}" "$BINDIR"
        	chmod u+x "${BINDIR}/${script}"
        	SCRIPT_ARCHIVOS+="${script}"'$'
	done

	echo "Actualizando la configuración del sistema"
	local COMPONENTES=(GRUPO CONFDIR BINDIR MAEDIR NOVEDIR DATASIZE ACEPDIR INFODIR RECHDIR LOGDIR LOGEXT LOGSIZE )
	local VALORES=("$GRUPO" "${CONFDIR}" "${BINDIR}" "${MAEDIR}" "${NOVEDIR}" "${DATASIZE}" "${ACEPDIR}" "${INFODIR}" "${RECHDIR}"  "${LOGDIR}" "${LOGEXT}" "${LOGSIZE}")

	#Guardo las decisiones del usuario
	for (( i=0; i < "${#COMPONENTES[@]}"; ++i)); do
        	guardarDatos "${COMPONENTES[$i]}" "${VALORES[$i]}"
	done

	#Guardo la ubicación de los archivos
	guardarDatos "MAEFILES" "$MAE_ARCHIVOS"
	guardarDatos "TABFILES" "$TAB_ARCHIVOS"
	guardarDatos "SCRIPTFILES" "$SCRIPT_ARCHIVOS"
}

#Secuencia de pasos de una instalacion inicial
function instalacionNormal() {
	echo "Inicio de Ejecución del Installer"
	$LOG "installer" "Inicio de Ejecución del Installer"

	[ -d $CONFDIR ] || mkdir $CONFDIR
	echo "Log de la instalación: ${GRUPO}/${CONFDIR}/Installer.log"
	$LOG "installer" "Log de la instalación: ${GRUPO}/${CONFDIR}/Installer.log"

	
	echo "Directorio predefinido de Configuración: ${GRUPO}/${CONFDIR}"
	$LOG "installer" "Directorio predefinido de Configuración: ${GRUPO}/${CONFDIR}"

	terminosYcondiciones
	chequearPerl
	definirDirectorios
	instalarDirectorios
	
	salir $ERROR0 "Instalación CONCLUIDA"
}

#Secuencia de pasos de una reinstalacion
function reinstalacion() {
	DIRECTORIOS=( "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$INFODIR" "$RECHDIR" "$LOGDIR" "$LOGEXT" "$LOGSIZE" )

	$LOG 'installer' 'Comprobando Instalación existente'
	
	#Se construye en la variable resumen un informe con los directorios y archivos presentes y faltantes
        local RESUMEN="$COPYRIGHT\n\n"
	local EXPR DIR DIRFALTANES ARCHFALTANTES
	local REG_NOMBRE=(GRUPO CONFDIR BINDIR MAEDIR NOVEDIR ACEPDIR INFODIR RECHDIR LOGDIR LOGEXT LOGSIZE)
	local reg_value=("$GRUPO" 'conf' '.' '.' '.' '.' '.' '.' '.' '.' '.' '.' '.')
	local HEADERS2=('' "$HEADER1" "$HEADER2" "$HEADER3" "$HEADER4" "$HEADER6" "$HEADER7" "$HEADER8" "$HEADER9" )

	for (( i=0; i < ${#REG_NOMBRE[@]}; ++i)); do
		local reg=$(grep '^'"${REG_NOMBRE[$i]}"'=[^=]\{1,\}='"$(whoami)=" "$CONF_INSTALACION")
		[ -z "$reg" ] && exit salir ERROR_ARCHIVO "Archivo de configuración corrupto"
		reg=$(echo "$reg" | cut -d'=' -f2)
		[ "${REG_NOMBRE[$i]}" = 'GRUPO' ] && continue
		[ "${REG_NOMBRE[$i]}" = 'LOGSIZE' ] && continue
		if [ "${REG_NOMBRE[$i]}" = 'LOGEXT' ]; then
			RESUMEN+="$reg\n"	
			continue		
		fi
		if [ "${REG_NOMBRE[$i]}" = 'LOGDIR' ]; then
			RESUMEN+="${HEADERS2[$i]}$GRUPO/$reg/<comando>."
			continue
		fi
		if [ "${REG_NOMBRE[$i]}" = 'CONFDIR' -o "${REG_NOMBRE[$i]}" = 'BINDIR' -o "${REG_NOMBRE[$i]}" = 'MAEDIR' ]; then
			RESUMEN+="${HEADERS2[$i]}$GRUPO/$reg\n"
			if [ -e "$GRUPO/$reg" ]; then
        			RESUMEN+='Archivos existentes:\n'$(ls "$GRUPO/$reg")"\n"
		        else
                	        DIRFALTANTES=("${DIRFALTANTES[@]}" "$GRUPO/$reg")
                	fi	
		elif [ "${REG_NOMBRE[$i]}" = 'LOGEXT' -o "${REG_NOMBRE[$i]}" = 'LOGDIR' ]; then
			continue
		else
        		[ -e "$GRUPO/$reg" ] || DIRFALTANTES=("${DIRFALTANTES[@]}" "$GRUPO/$reg")
			RESUMEN+="${HEADERS2[$i]}""$GRUPO/$reg\n"
		fi
	done

	#chequeo archivos .mae
	[ -z "$(grep "^MAEFILES="'.*'"=$(whoami)=" "$CONF_INSTALACION")" ] && salir $ERROR_ARCHIVO "Archivo de configuración corrupto"
        local TMP=$IFS
        IFS='$'
        local MAEFILES=$(grep "^MAEFILES" "$CONF_INSTALACION" | cut -d'=' -f2)
	MAEDIR=$(grep '^MAEDIR' "$CONF_INSTALACION" | cut -d'=' -f2)
        for i in $(echo "$MAEFILES" | cat); do
		[ -e "${GRUPO}/$MAEDIR/$i" ] || ARCHFALTANTES=("${ARCHFALTANTES[@]}" "${GRUPO}/$MAEDIR/$i")
	done

	#chequeo archivos .tab
	IFS=$TMP
	[ -z "$(grep "^TABFILES="'.*'"=$(whoami)=" "$CONF_INSTALACION")" ] && salir $ERROR_ARCHIVO "Archivo de configuración corrupto"
	IFS='$'
	local TABFILES=$(grep "^TABFILES" "$CONF_INSTALACION" | cut -d'=' -f2)
	MAEDIR=$(grep '^MAEDIR' "$CONF_INSTALACION" | cut -d'=' -f2)
	for i in $(echo "$TABFILES" | cat); do
		[ -e "${GRUPO}/$MAEDIR/$i" ] || ARCHFALTANTES=("${ARCHFALTANTES[@]}" "${GRUPO}/$MAEDIR/$i")
	done
	
	#chequeo scripts
	IFS=$TMP
	[ -z "$(grep "^SCRIPTFILES="'.*'"=$(whoami)=" "$CONF_INSTALACION")" ] && salir $ERROR_ARCHIVO "Archivo de configuración corrupto"
	IFS='$'
	local SCRIPTFILES=$(grep "^SCRIPTFILES" "$CONF_INSTALACION" | cut -d'=' -f2)
	BINDIR=$(grep '^BINDIR' "$CONF_INSTALACION" | cut -d'=' -f2)
	for i in $(echo "$SCRIPTFILES" | cat); do
		[ -e "${GRUPO}/$BINDIR/$i" ] || ARCHFALTANTES=("${ARCHFALTANTES[@]}" "${GRUPO}/$BINDIR/$i")
	done
     
	IFS=$TMP

        #Chequeo si tengo que reinstalar componentes
	if [ ${#DIRFALTANTES[@]} -eq 0 -a ${#ARCHFALTANTES[@]} -eq 0 ]; then
		RESUMEN+="\nEstado de la Instalación: COMPLETA\n\nProceso de Instalación Cancelado"
		salir $ERROR0 "$RESUMEN"
        else
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
		if [ $? = 1 ]; then
			salir "$ERROR_USUARIO" "El usuario no deseo completa la instalacion"
		fi


                # Reinstalo lo q falta
                echo -e "Restaurando Estructuras de Directorio\n"
		for DIRECTORIO in "${DIRFALTANTES[@]}"; do
			CrearJerarquia "$DIRECTORIO"
                done

                local NOMBRE DIRECCION
                echo -e "Restaurando Archivos faltantes\n"
		for ARCHIVO in "${ARCHFALTANTES[@]}"; do
			NOMBRE=${ARCHIVO##*/}
                        DIRECCION=${ARCHIVO%/*}
                        cp "$SRCDIR/$NOMBRE" "$DIRECCION"
                        for s in "${SCRIPTS[@]}"; do
				[ "$s" = "$NOMBRE" ] && chmod u+x "$ARCHIVO"
                        done
		done
	        salir $ERROR0 "Instalación CONCLUIDA"
	fi


}

#main

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
