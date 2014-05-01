#!/bin/bash

function validarRegistroCabecera
{	
	if [ $2 -eq -1 ]; then
		bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por Supermercado inexistente" "ERR";
		bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
		bash ../Tools/Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
		return -2;
	fi

	if [ $3 -eq -1 ]; then # Verifico cantidad de campos
		bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por Cantidad de campos invalida" "ERR";
		bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
		bash ../Tools/Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
		return -2;
	else
		if [[ $4 -eq -1 ]] || [[ $4 -gt $3 ]] || [[ $4 -eq $5 ]]; then # Verifico posicion producto
			bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por Posicion producto invalida" "ERR";
			bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
			bash ../Tools/Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
			return -2;
		fi 					
		
		if [[ $5 -eq -1 ]] || [[ $5 -gt $3 ]] || [[ $4 -eq $5 ]]; then # Verifico posicion precio
			bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por Posicion precio invalida" "ERR";
			bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
			bash ../Tools/Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
			return -2;
		fi
	fi

	if [ $6 -eq -1 ]; then # Verifico correo electronico
		bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por Correo electronico del colaborador invalido" "ERR";
		bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$1 a $GRUPO/$RECHDIR/$1";
		bash ../Tools/Mover.sh "$pathPrecios/$1" "$GRUPO/$RECHDIR/$1" "Masterlist";
		return -2;
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
}

function procesarArchivo
{
	cantidadRegistrosOk=0
	cantidadRegistrosNok=0
	while read -r registro; do
		# valido precio y nombre
		precio=`echo $registro | cut -d ";" -f $6`
		producto=`echo $registro | cut -d ";" -f $7`
		producto=`echo $producto | sed 's-^$-\-1-'` # Si no hay match lo cambio a -1
		precio=`echo $precio | grep '^[0-9]\+\.[0-9]\+$'`
		precio=`echo $precio | sed 's-^$-\-1-'` # Si no hay match lo cambio a -1
		if [ [ $precio -eq -1 ] -o [ $producto -eq -1 ] ]; then
			cantidadRegistrosNok=`expr $cantidadRegistrosNok + 1`;
			continue;
		else 
			cantidadRegistrosOk=`expr $cantidadRegistrosOk + 1`;
			echo "$3;$4;$5;$producto;$precio" >> $2;
		fi
	done < $pathPrecios/$1
	bash ../Tools/logging.sh "Masterlist" "Archivo $1 ha sido procesado" "INF";
	bash ../Tools/logging.sh "Masterlist" "Registros ok: $cantidadRegistrosOk" "INF";
	bash ../Tools/logging.sh "Masterlist" "Registros nok: $cantidadRegistrosNok" "INF";
}

pathPreios="$GRUPO/$MAEDIR/precios"
pathProcesados="$pathPrecios/proc"
superMae="$GRUPO/$MAEDIR/super.mae"
asociadosMae="$GRUPO/$MAEDIR/asociados.mae"
preciosMae="$GRUPO/$MAEDIR/precios.mae"

#Inicio del archivo de Log
bash ../Tools/logging.sh "Masterlist" "Inicio de Masterlist"
cantidadArchivos=`ls $pathPreios | wc -l`
bash ../Tools/logging.sh "Masterlist" "Cantidad de Listas de precios a procesar: $cantidadArchivos"
#Fin cabecera de log

IFS=$'\n' # Modifico Internal Field Separator

for [ archivoPrecios in $(ls $pathPrecios) ]; do 
	bash ../Tools/logging.sh "Masterlist" "Archivo a procesar: $archivoPrecios"
	if [ -e $pathProcesados/$archivoPrecios ]; then #Archivo ya procesado
		bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por estar DUPLICADO" "ERR";
		bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
		bash ../Tools/Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
		continue;
	fi
	cabecera=`sed -n '1p' "$pathPrecios/$archivoPrecios"` # Obtengo el registro de cabecera
	nombreSuper=`echo $cabecera | sed 's-^\([^;]*\);.*-\1-'`
	nombreProv=`echo $cabecera | sed 's-^[^;]*;\([^;]*\);.*-\1-'`
	busquedaSuper=`grep "^[^;]*;$nombreProv;$nombreSuper;[^;]*;[^;]*;[^;]*$" $superMae`
	busquedaSuper=`echo $busquedaSuper | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
	usuario=`echo $pathPrecios/$archivoPrecios | sed 's-^[^.]*.\(.*\)$-\1-'`
	cantidadCampos=`echo $cabecera | sed 's-^[^;]*;[^;]*;\([1-9]*\).*-\1-'`
	cantidadCampos=`echo $cantidadCampos | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
	posProducto=`echo $cabecera | sed 's-^[^;]*;[^;]*;[^;]*;\([1-9]*\).*-\1-'`
	posProducto=`echo $posProducto | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
	posPrecio=`echo $cabecera | sed 's-^[^;]*;[^;]*;[^;]*;[^;]*;\([1-9]*\).*-\1-'`
	posPrecio=`echo $posPrecio | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
	mailColaborador=`echo $cabecera | sed 's-^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([^;]*\)$-\1-'`
	
	busquedaUsuario=`grep "^[^;]*;[^;]*;$usuario;[^;]*;$mailColaborador$" $asociadosMae` # Busco si existe registro con ese usuario y mail
	busquedaUsuario=`echo $busquedaUsuario | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1

	validarRegistroCabecera "$archivoPrecios" "$busquedaSuper" "$cantidadCampos" "$posProducto" "$posPrecio" "$busquedaUsuario" #ver parametros que tal vez esten de mas
	if [ $? -eq -2 ]; then
		continue;
	fi
	superID=`echo $busquedaSuper | sed 's-^\([0-9]*\);.*-\1-'`

	fechaArchivo=`echo $archivoPrecios | sed 's/^[^-]*-\([^.]*\).*$/\1/'`
	if [ -e $preciosMae ]; then	
		busquedaRegistro=`grep -m 1 "^$superID;$usuario;[^;]*;[^;]*;[^;]*$" $preciosMae` # Busco algun match para el superID y usuario dado
		busquedaRegistro=`echo $busquedaRegistro | sed 's-^$-\-1-'` # si no matchea, reemplazo por -1
		if [ $busquedaRegistro -ne -1 ]; then
			fechaRegistro=`echo $busquedaRegistro | sed 's-^[^;]*;[^;]*;\([0-9]\{4\}[0-1][0-9][0-3][0-9]\);.*-\1-'`
			compararFechas "$fechaArchivo" "$fechaRegistro"
			if [ $? -eq 1 ]; then
				cantidadRegistrosEliminados=`echo sed 's/^\($superID;$usuario;$fechaRegistro;.*\)$/\1/' $preciosMae | wc -l`
				sed -i 's/^$superID;$usuario;$fechaRegistro;.*$//g' $preciosMae #Elimino los registros viejos 
				sed -i '/^$/d' $preciosMae #Elimino las lineas en blanco producto de eliminar registros
				procesarArchivo "$archivoPrecios" "$preciosMae" "$superID" "$usuario" "$fechaRegistro" "$fechaArchivo" "$posPrecio" "posProducto";
				bash ../Tools/logging.sh "Masterlist" "Registros eliminados: $cantidadRegistrosEliminados" "INF";
				bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $pathProcesados/$archivoPrecios";
				bash ../Tools/Mover.sh "$pathPrecios/$archivoPrecios" "$pathProcesados/$archivoPrecios" "Masterlist";			
			else 
				# La fecha del registro encontrado en precios.mae es mayor a la fecha del archido a procesar
				bash ../Tools/logging.sh "Masterlist" "Se rechaza el archivo por fecha anterior a la existente" "ERR";
				bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
				bash ../Tools/Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
			fi
		else
			procesarArchivo "$archivoPrecios" "$preciosMae" "$superID" "$usuario" "$fechaArchivo" "$posPrecio" "posProducto";
			bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
			bash ../Tools/Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
		fi
	else 
		procesarArchivo "$archivoPrecios" "$preciosMae" "$superID" "$usuario" "$fechaArchivo" "$posPrecio" "posProducto";
		bash ../Tools/logging.sh "Masterlist" "Moviendo $pathPrecios/$archivoPrecios a $GRUPO/$RECHDIR/$archivoPrecios";
		bash ../Tools/Mover.sh "$pathPrecios/$archivoPrecios" "$GRUPO/$RECHDIR/$archivoPrecios" "Masterlist";
	fi
done

#Fin del archivo de Log
bash ../Tools/logging.sh "Masterlist" "Fin de Masterlist"

exit 0