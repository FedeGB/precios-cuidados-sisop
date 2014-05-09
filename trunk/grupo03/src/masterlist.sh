#!/bin/bash

function validarRegistroCabecera
{	
	if [[ "$2" == "-1" ]]; then # Verifico si existe el Supermercado
		logging.sh "Masterlist" "Se rechaza el archivo por Supermercado inexistente" "WAR";
		logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
		Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
		return 2;
	fi

	if [[ $3 -eq -1 ]]; then # Verifico cantidad de campos
		logging.sh "Masterlist" "Se rechaza el archivo por Cantidad de campos invalida" "WAR";
		logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
		Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
		return 2;
	else
		if [[ $4 -eq -1 || $4 -gt $3 || $4 -eq $5 ]]; then # Verifico posicion producto
			logging.sh "Masterlist" "Se rechaza el archivo por Posicion producto invalida" "WAR";
			logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
			Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
			return 2;
		fi 					
		
		if [[ $5 -eq -1 || $5 -gt $3 || $4 -eq $5 ]]; then # Verifico posicion precio
			logging.sh "Masterlist" "Se rechaza el archivo por Posicion precio invalida" "WAR";
			logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
			Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
			return 2;
		fi
	fi

	if [[ "$6" == "-1" ]]; then # Verifico correo electronico
		logging.sh "Masterlist" "Se rechaza el archivo por Correo electronico del colaborador invalido" "WAR";
		logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
		Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
		return 2;
	fi

	return 0
}

function compararFechas
{
#Compara dos fechas
#PRE: las fechas son del estilo aaaammdd y deben ser validas
#POST: devuelve 1 o 0 si $1 es mayor o menor que $2, respectivamente

	anio1=`echo $1 | sed s-'^\([0-9]\{4\}\).*-\1-'`
	anio2=`echo $2 | sed s-'^\([0-9]\{4\}\).*-\1-'`
	mes1=`echo $1 | sed s-'^[0-9]\{4\}\([0-1][0-9]\).*-\1-'`
	mes2=`echo $2 | sed s-'^[0-9]\{4\}\([0-1][0-9]\).*-\1-'`
	dia1=`echo $1 | sed s-'^[0-9]\{4\}[0-1][0-9]\([0-3][0-9]\)-\1-'`
	dia2=`echo $2 | sed s-'^[0-9]\{4\}[0-1][0-9]\([0-3][0-9]\)-\1-'`

	if [ $anio1 -gt $anio2 ]; then
		return 1;
	elif [ $anio1 -lt $anio2 ]; then
		return 0;
	else 
		if [ $mes1 -gt $mes2 ]; then
			return 1;
		elif [ $mes1 -lt $mes2 ]; then
			return 0;
		else
			if [ $dia1 -gt $dia2 ]; then
				return 1;
			else
				return 0;
			fi
		fi
	fi
	return 1
}

function procesarArchivo
{
	IFS=$'\n' # Modifico Internal Field Separator (tal vez este de mas)
	cantidadRegistrosOk=0
	cantidadRegistrosNok=0
	esPrimeroRegistro=1
	for registro in $(<$pathPrecios/$1); do
		# Si es el primer registro (header) lo salteo
		if [ $esPrimeroRegistro -eq 1 ]; then
			esPrimeroRegistro=0;
			continue;
		fi
		# valido precio y nombre
		producto=`echo $registro | cut -d ";" -f $7`
		producto=`echo $producto | sed 's-^$-\-1-'` # Si el nombre es vacio lo cambio a -1
		precio=`echo $registro | cut -d ";" -f $6 | sed 's-^.*\$\\\?\([0-9]\+[. | ,][0-9]\+\).*$-\1-'`
		precio=`echo $precio | sed 's-^$-\-1-'` # Si no hay match lo cambio a -1
		precio=`echo $precio | sed -r 's/[,]/\./g'` # Si el precio es de la forma nn,nn lo paso a nn.nn
		if [[ "$precio" == "-1" || "$producto" == "-1" ]]; then
			cantidadRegistrosNok=`expr $cantidadRegistrosNok + 1`;
			continue;
		else 
			cantidadRegistrosOk=`expr $cantidadRegistrosOk + 1`;
			echo "$3;$4;$5;$producto;$precio" >> $2;
		fi
	done
	logging.sh "Masterlist" "Archivo $1 ha sido procesado" "INF";
	logging.sh "Masterlist" "Registros ok: $cantidadRegistrosOk" "INF";
	logging.sh "Masterlist" "Registros nok: $cantidadRegistrosNok" "INF";
}

# Variables
pathPrecios="$GRUPO/$MAEDIR/precios"
pathProcesados="$pathPrecios/proc"
superMae="$GRUPO/$MAEDIR/super.mae"
asociadosMae="$GRUPO/$MAEDIR/asociados.mae"
preciosMae="$GRUPO/$MAEDIR/precios.mae"

if [[ $ENVINIT -eq 0 ]]; then
	logging.sh "Masterlist" "Se finaliza el script por no estar seteado el ambiente" "ERR";
	exit -1;
fi

#Inicio del archivo de Log
logging.sh "Masterlist" "Inicio de Masterlist"
cantidadArchivos=`ls $pathPrecios | wc -l`
cantidadArchivos=`expr $cantidadArchivos - 1` #Resto uno por la carpeta proc
logging.sh "Masterlist" "Cantidad de Listas de precios a procesar: $cantidadArchivos"
#Fin cabecera de log

IFS=$'\n' # Modifico Internal Field Separator

if [[ $cantidadArchivos -eq 0 ]]; then
	logging.sh "Masterlist" "No hay archivos para procesar." "WAR";
else
	for archivoPrecios in $(ls $pathPrecios); do 
		#Evito procesar el directorio proc
		if [ -d $pathPrecios/$archivoPrecios ]; then
			continue;
		fi
		logging.sh "Masterlist" "Archivo a procesar: $archivoPrecios"
		if [ -e $pathProcesados/$archivoPrecios ]; then #Archivo ya procesado
			logging.sh "Masterlist" "Se rechaza el archivo por estar DUPLICADO" "WAR";
			logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
			Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
			continue;
		fi
		cabecera=`sed -n '1p' "$pathPrecios/$archivoPrecios"` # Obtengo el registro de cabecera
		nombreSuper=`echo "$cabecera" | sed 's-^\([^;]*\);.*-\1-'`
		nombreProv=`echo "$cabecera" | sed 's-^[^;]*;\([^;]*\);.*-\1-'`
		busquedaSuper=`grep "^[^;]*;$nombreProv;$nombreSuper;[^;]*;[^;]*;[^;]*$" $superMae`
		busquedaSuper=`echo $busquedaSuper | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
		usuario=`echo "$archivoPrecios" | sed 's-^[^.]*.\(.*\)$-\1-'`
		cantidadCampos=`echo "$cabecera" | sed 's-^[^;]*;[^;]*;\([1-9]*\).*-\1-'`
		cantidadCampos=`echo $cantidadCampos | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
		posProducto=`echo "$cabecera" | sed 's-^[^;]*;[^;]*;[^;]*;\([1-9]*\).*-\1-'`
		posProducto=`echo $posProducto | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
		posPrecio=`echo "$cabecera" | sed 's-^[^;]*;[^;]*;[^;]*;[^;]*;\([1-9]*\).*-\1-'`
		posPrecio=`echo $posPrecio | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
		mailColaborador=`echo "$cabecera" | sed 's-^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([^;]*\)$-\1-'`
		
		busquedaUsuario=`grep "^[^;]*;[^;]*;$usuario;[^;]*;$mailColaborador$" $asociadosMae` # Busco si existe registro con ese usuario y mail
		busquedaUsuario=`echo $busquedaUsuario | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1

		validarRegistroCabecera "$archivoPrecios" "$busquedaSuper" "$cantidadCampos" "$posProducto" "$posPrecio" "$busquedaUsuario"
		if [[ $? -eq 2 ]]; then
			continue;
		fi
		superID=`echo $busquedaSuper | sed 's-^\([0-9]*\);.*-\1-'`

		fechaArchivo=`echo "$archivoPrecios" | sed 's/^[^-]*-\([^.]*\).*$/\1/'`
		fechaArchivo=`echo $fechaArchivo | grep "^[0-9]\{4\}\(\(\(01\|03\|05\|07\|08\|10\|12\)\(0[1-9]\|[12][0-9]\|3[01]\)\)\|\(\(04\|06\|09\|11\)\(0[1-9]\|[12][0-9]\|30\)\)\|02\(0[1-9]\|1[0-9]\|2[0-8]\)\)"`
		fechaArchivo=`echo $fechaArchivo | sed 's-^$-\-1-'` # si no matchea (fecha invalida), reemplazo por -1

		if [[ "$fechaArchivo" == "-1" ]]; then # Archivo de lista de precios con fecha invalida, se rechaza.
			logging.sh "Masterlist" "Se rechaza el archivo por FECHA INVALIDA" "WAR";
			logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
			Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
			continue;
		fi	

		if [[ -e $preciosMae ]]; then	
			busquedaRegistro=`grep -m 1 "^$superID;$usuario;[^;]*;[^;]*;[^;]*$" $preciosMae` # Busco algun match para el superID y usuario dado
			busquedaRegistro=`echo $busquedaRegistro | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
			if ! [[ "$busquedaRegistro" == "-1" ]]; then
				fechaRegistro=`echo $busquedaRegistro | sed 's-^[^;]*;[^;]*;\([0-9]\{4\}[0-1][0-9][0-3][0-9]\);.*-\1-'`
				compararFechas "$fechaArchivo" "$fechaRegistro"
				if [[ "$?" == "1" ]]; then
					cantidadRegistrosEliminados=`grep "^$superID;$usuario;$fechaRegistro;.*$" $preciosMae | wc -l`
					sed -i "s/^$superID;$usuario;$fechaRegistro;.*$//g" $preciosMae #Elimino los registros viejos 
					sed -i '/^$/d' $preciosMae #Elimino las lineas en blanco producto de eliminar registros
					procesarArchivo "$archivoPrecios" "$preciosMae" "$superID" "$usuario" "$fechaArchivo" "$posPrecio" "$posProducto";
					logging.sh "Masterlist" "Registros eliminados: $cantidadRegistrosEliminados" "INF";
					logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $pathProcesados/$archivoPrecios";
					Mover.sh "$pathPrecios/$archivoPrecios" "$pathProcesados/$archivoPrecios" "Masterlist";			
				else 
					# La fecha del registro encontrado en precios.mae es mayor a la fecha del archido a procesar
					logging.sh "Masterlist" "Se rechaza el archivo por fecha anterior a la existente" "WAR";
					logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
					Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
				fi
			else
				procesarArchivo "$archivoPrecios" "$preciosMae" "$superID" "$usuario" "$fechaArchivo" "$posPrecio" "$posProducto";
				logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $pathProcesados/$archivoPrecios";
				Mover.sh "$pathPrecios/$archivoPrecios" "$pathProcesados/$archivoPrecios" "Masterlist";
			fi
		else 
			procesarArchivo "$archivoPrecios" "$preciosMae" "$superID" "$usuario" "$fechaArchivo" "$posPrecio" "$posProducto";
			logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $pathProcesados/$archivoPrecios";
			Mover.sh "$pathPrecios/$archivoPrecios" "$pathProcesados/$archivoPrecios" "Masterlist";
		fi
	done	
fi

#Fin del archivo de Log
logging.sh "Masterlist" "Fin de Masterlist"

exit 0