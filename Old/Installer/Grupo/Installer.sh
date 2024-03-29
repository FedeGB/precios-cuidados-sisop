BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

GRUPO="."

VERSION='v1.0'

ARCHIVOLOG="logging.sh"

LOG=". ${BASE}/${ARCHIVOLOG}"

#CONFDIR="${BASE}/conf"
CONFDIR="/conf"

SRCDIR="${BASE}/src/"

LOG_INSTALACION="${CONFDIR}/Installer"

CONF_INSTALACION="${CONFDIR}/Installer.conf"

PERL_VER_REQ=5

SCRIPTS=('Initializer.sh' 'listener.sh' 'masterlist.sh' 'rating.sh' 'reporting.sh' 'Mover.sh' 'Start.sh' 'Stop.sh' 'logging.sh')


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
DEF_REPODIR=listados
DEF_PROCDIR=procesados

DIRECTORIOS=( "$BINDIR" "$MAEDIR" "$NOVEDIR" "$DATASIZE" "$ACEPDIR" "$INFODIR" "$RECHDIR" "$LOGDIR" "$LOGEXT" "$LOGSIZE" )

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



# Muestra la version del sistema =S
function showVersion() {
        echo -e "Universidad de Buenos Aires - Facultad de Ingeniería\n7508 Sistemas Operativos\nTrabajo Práctico: Sarasa-$VERSION\nGrupo $NUMGRUPO\n2º cuat. 2013\nHome Page: http://code.google.com/p/ssoo22013/\n"
        echo -e "$COPYRIGHT\n"
}

# Muestra la ayuda del instalador =S 
function showHelp() {
        echo "Ayuda Instalador de Sistema de Reserva de Entradas de Obras Teatrales-$VERSION"
        echo -e "Uso: Instalar_TP [OPCIONES]\n"
        echo "Sin opciones                      Instala o repara el sistema normalmente"
        echo "-u                                Desinstala el sistema"
        echo "-v                                Muestra la version del sistema"
        echo "-h                                Muestra esta ayuda"
}

function iniciarLog() {
	echo -n "Inicializar log. . . ."
	#copio script logging
        cp "${SRCDIR}${ARCHIVOLOG}" "$BASE"
        chmod u+x "${SRCDIR}${ARCHIVOLOG}"
	[ -d $lOG_INSTALACION ] || mkdir $lOG_INSTALACION
	#$LOG "installer" "Log instalado"
	echo "sarasa"
}


function chequearFuentes() {
	local FALTANTES
	
	echo -n "Chequeando Fuentes . . . . "
	#$LOG 'Instalar_TP' 'Comprobando Fuentes de Instalación'
	# Busco directorios faltantes
	# Me fijo si existen los directorios conf y src y el script para loggear

	if [ -d "$SRCDIR" ]; then
        	# Busco scripts faltantes
       	        for i in "${SCRIPTS[@]}"; do
	       	        [ -e "${SRCDIR}${i}" ] || FALTANTES=("${FALTANTES[@]}" "$i")
       		done
	else
        	[ -d "$SRCDIR" ] || FALTANTES=("${FALTANTES[@]}" "$SRCDIR")
	fi
	# Informo los resultados
	local MSG="\n\nPaquete de instalación incompleto.\nFuentes faltantes: ${FALTANTES[@]}\nInstalación 		Cancelada."
	#[ ${#FALTANTES[@]} -gt 0 ] && error_exit $ERRNO4 "$MSG"
	[ ${#FALTANTES[@]} -gt 0 ] && echo -e "$MSG"
	#$LOG 'Instalar_TP' 'Paquete de instalación completo'
	# Si no está el confdir, lo creo
	[ -d "${BASE}/conf" ] || mkdir "${BASE}/conf"
	echo "HECHO"
}



function mostrarUbicacionLog() {
	echo "Log de la instalación: CONFDIR/Installer.log"
	#$LOG "installer" "Log de la instalación: CONFDIR/Installer.log"
}

function mostrarUbicacionConf() {
	#$LOG "installer" "Directorio predefinido de Configuración: CONFDIR"
	echo "Directorio predefinido de Configuración: CONFDIR"
}

function chequearInstalacion() {
        if [ ! -e $CONF_INSTALACION ]; then
		echo "Instalacion normal"
	else
		echo "Reinstalacion"
	fi
}

function terminosYcondiciones() {
	#echo -e "$MSG_TERM_Y_COND"
	#$LOG "Instalar_TP" "$MSG_TERM_Y_COND"
	echo -e "terminos y condiciones"
        local OPCION
        read OPCION
        OPCION=$(echo "$OPCION" | tr [:upper:] [:lower:])
        if [ "$OPCION" != 'si' -a "$OPCION" != 's' -a "$OPCION" != '' ]; then
                $LOG "Instalar_TP" "$OPCION"
                error_exit $ERRNO2 "Abortado por el usuario"
        else

                if [ "$OPCION" = '' ]; then
                	#$LOG "Instalar_TP" 'Si'
			echo -e "sigue instalacion"
                else
			echo -e "sigue instalacion"
                        #$LOG "Instalar_TP" "$OPCION"
                fi
        fi
}

function comprobarPerl() {
        local PERL_VER_ACT=$(perl -v | grep 'v[0-9][0-9]*' | cut -d. -f1 | sed 's/\(.*\)\(v\)\([0-9]*\)$/\3/')
        if [ $PERL_VER_ACT -lt $PERL_VER_REQ ];then
		echo "error perl"
                #error_exit $ERRNO1 "$MSG_ERROR_PERL"
        fi
        echo -e "$COPYRIGHT\n\nPerl Version: $PERL_VER_ACT"
        #$LOG "Instalar_TP" "$COPYRIGHT\n\nPerl Version: $PERL_VER_ACT"
}

function definirDirectorios() {
local directorio retorno instalado=0
while [ $instalado -eq 0 ]; do
        for (( i = 0; i < ${#MENSAJES[@]}; ++i )); do
                while : ; do
                        # Le pido al usuario que ingrese un valor
                        echo -n "${MENSAJES[$i]} (${DIRECTORIOS[$i]}): "
                        read directorio
                        # Falta validar
                        #${ARREGLO_FUNCIONES[$i]} "$val_ingresado" "${ARREGLO_ARGS[$i]}"
                        retorno=$?
                        #if [ "$ret_val" -eq 1 ]; then
                        #        echo "$val_ingresado" | grep '^/' > /dev/null
                        #        [ $? -eq 0 ] && val_ingresado=${val_ingresado#*/}
                        #        echo "$val_ingresado" | grep '/$' > /dev/null
                        #        [ $? -eq 0 ] && val_ingresado=${val_ingresado%/*}
                        #        $LOG "Instalar_TP" "${ARREGLO_MSG[$i]} (${ARREGLO_VALORES[$i]}): 				#$val_ingresado"
			if [ "$retorno" -eq 1 ]; then
	                        DIRECTORIOS[$i]="$directorio"
	                        break
                        # Si el valor igresado es inválido
                        #elif [ $ret_val -eq 2 ]; then
                        #        echo -e "${ARREGLO_MSG_ERROR[$i]}"
                        #        $LOG "Instalar_TP" "${ARREGLO_MSG[$i]} (${ARREGLO_VALORES[$i]}): $val_ingresado"

                        #        $LOG "Instalar_TP" "${ARREGLO_MSG_ERROR[$i]}"
                        # Si no ingresó nada
                        #else
			else
				echo "Directorio de ${DIRECTORIOS[$i]}: ${DIRECTORIOS[$i]}"
                        #        $LOG "Instalar_TP" "${ARREGLO_MSG[$i]} (${ARREGLO_VALORES[$i]}): ${ARREGLO_VALORES[$i]}"
                                break
                        fi
                done
        done
        # Muestro el estado de la instalación y lo loggeo
        #clear
        #echo "$ESTADO_INST"
        #$LOG "Instalar_TP" "$ESTADO_INST"
        echo -e "\nEstá de acuerdo con la configuración de instalación? (Si - No): "
        #$LOG "Instalar_TP" "Está de acuerdo con la configuración de instalación? (Si - No): "
        read OPCION
        OPCION=$(echo "$OPCION" | tr [:upper:] [:lower:])
        [ "$OPCION" = 'si' -o "$OPCION" = 's' -o "$OPCION" = '' ] && instalado=1
	if [ "$OPCION" == '' ]; then
		echo "log"
	      #$LOG "Instalar_TP" "Si"
	else
		echo "log"
	      #$LOG "Instalar_TP" "$OPCION"
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
        echo "$REG" >> ${BASE}/$CONF_INSTALACION
}


function instalarDirectorios() {
echo -n "Iniciando Instalación. Está Ud. seguro (Si - No): "
#$LOG "Instalar_TP" "Iniciando Instalación. Está Ud. seguro (Si - No): "
#ValidarDecisionUsuario

# Creo la estructura de directorios
echo "Creando Estructuras de Directorios. . . . "
DIRECTORIOS=( "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$INFODIR" "$RECHDIR" "$LOGDIR" )

for ((i=0; i <= ${#DIRECTORIOS[@]}; ++i)); do
        CrearJerarquia "${DIRECTORIOS[$i]}"
done
echo HECHO

# Copio los archivos necesarios para la ejecución del sistema
echo -n "Instalando Archivos Maestros y Tablas. . . . "
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
echo "HECHO"

echo -n "Instalando Programas y Funciones. . . ."
local script_files
for script in "${SCRIPTS[@]}"; do
        cp "${SRCDIR}/${script}" "$BINDIR"
        chmod u+x "${BINDIR}/${script}"
        script_files+="${script}"'$'
done


BASE1="${BASE}/"

echo -n "Actualizando la configuración del sistema . . . . "
local COMPONENTES=(GRUPO CONFDIR BINDIR MAEDIR NOVEDIR DATASIZE ACEPDIR INFODIR RECHDIR LOGDIR LOGEXT LOGSIZE )
local VALORES=("$BASE" "${CONFDIR#$BASE1}" "${BINDIR#$BASE1}" "${MAEDIR#$BASE1}" "${NOVEDIR#$BASE1}" "${DATASIZE#$BASE1}" "${ACEPDIR#$BASE1}" "${INFODIR#$BASE1}" "${RECHDIR#$BASE1}"  "${LOGDIR#$BASE1}" "${LOGEXT#$BASE1}" "${LOGSIZE#$BASE1}")

	[ -d $lOG_INSTALACION ] || mkdir $lOG_INSTALACION

#creo archivo d configuracion
[ -d $CONF_INSTALACION ] || mkdir $CONF_INSTALACION

# Guardo las decisiones del usuario
for (( i=0; i < "${#COMPONENTES[@]}"; ++i)); do
        GuardarDatos "${COMPONENTES[$i]}" "${VALORES[$i]}"
done

# Guardo la ubicación de los archivos
GuardarDatos "MAEFILES" "$mae_files"
GuardarDatos "DISFILES" "$dis_files"
GuardarDatos "SCRIPTFILES" "$script_files"

echo HECHO

echo "Instalación CONCLUIDA"

#error_exit $ERRNO0 ''

}

function etapas() {
	local etapa
	echo -n "etapa concluida"
	read etapa
}

function startInstall() {
	echo "Inicio de Ejecución del Installer"

	mostrarUbicacionLog


	mostrarUbicacionConf


	chequearInstalacion


	terminosYcondiciones


	comprobarPerl


	definirDirectorios


	instalarDirectorios

}

#main

# Configuro el script de log para poder usarlo en la instalación
if [ $# -eq 0 ]; then
	chequearFuentes	
	iniciarLog
	startInstall
	echo 'instalacion completa'

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
