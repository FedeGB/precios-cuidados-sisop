#!/usr/bin/env perl 

#use warnings;

$cantidadPerl=`pgrep "perl" | wc -l`;
if ($cantidadPerl > 1){
	print "Se esta ejecutando un proceso en perl, se cerrara el prorama.";
	exit -1;
}

use Env qw(GRUPO MAEDIR INFODIR BINDIR ENVINIT);
# Variables generales del modulo
#$path_maestro_super= "E:\\Desktop&Documents\\My Documents\\RICCI\\75.08\\Practica\\TP\\Maestros y tablas\\super.mae";	#"MAEDIR/";

if ($ENVINIT == 0){
	print "Ambiente no inicializado.";
	exit -1;
}

$path_maestro_super="$GRUPO/$MAEDIR/super.mae";
$path_dir_listasDeCompraPresupuestadas="$GRUPO/$INFODIR/pres/";						#"INFODIR/pres/";
$path_dir_informes="$GRUPO/$INFODIR/";													#"INFODIR/";
$regex_campo_faltante='[0-9]';


&menu;






sub menu {

	my @opciones_de_menu = ("\n============================================================================\n","Bienvenido a la sección de reportes\n\n", "-a (ayuda)\n",
				"-w (grabar)\n", "-r (precio de referencia)\n",
				"-m (menor precio)\n", "-d (donde comprar)\n", "-f (precio faltante)\n", "-x (filtra por provincia y supermercado)\n"
				, "-u (filtra por usuario comprador)\n", "-s (salir)\n", "Por favor, elija las opciones para su reporte y/o -s para salir.\n");


	$parametros_menu=0;
	
	while ($parametros_menu !~ /-s/) {
		print @opciones_de_menu;
		$parametros_menu = (<STDIN>); #chop $parametros_menu;

		#Verifico si no va a salir antes de cargar el hash del super.mae
		if ($parametros_menu =~ "-f|-r|-d|-m|-x") {&abrir_maestro_super;}
		if ($parametros_menu =~ /-w/) { $filtro_w=1; &grabar} else {$filtro_w=0;}
		if ($parametros_menu =~ /-a/) {&ayuda;}
		if ($parametros_menu =~ /-x/) { $filtro_x=1; &filtro_provin_super} else {$filtro_x=0;}
		if ($parametros_menu =~ /-u/) { $filtro_u=1; &filtro_usuario} else {$filtro_u=0;}
		if ($parametros_menu =~ /-r/) {&rep_precios_referencia;}
		if ($parametros_menu =~ /-m[^r]/) {&rep_menor_precio;}
		if ($parametros_menu =~ /-d[^r]/) {&rep_donde_comprar;}
		if ($parametros_menu =~ /-f/) {&rep_precio_faltante;}
		if ($parametros_menu =~ /-mr/ ) {&rep_menor_precio_mas_referencia;}
		if ($parametros_menu =~ /-dr/ ) {&donde_comprar_mas_referencia;}

		close (SUPERMERCADOS);
		close (INFODIR);
		close (INFORME);
		close (OCP_DIR);
		close (OCP);
		
	}

}




sub abrir_maestro_super {

	# Guardo el archivo 'super.mae' en un hash structure
	open (SUPERMERCADOS,$path_maestro_super)
	 or die"No se pudo abrir el archivo maestro de supermercados. $!";
	#Creo la variable global tipo hash para utilizar los datos dentro del super.mae
	%hash_super;
	for $registro (<SUPERMERCADOS>) {

	# el registro del archivo se compone de: SUPER_ID;PROVINCIA;NOMBRE_SUPER;NRO_DOC;TIPO_DOC;DIRECCION
	@campos_super= split (/;/, $registro);
	$hash_super{$campos_super[0]}= join ('-', "$campos_super[2]", "$campos_super[1]");
	}
	
}



sub filtro_provin_super {

	print "\nOpciones de reporte: $parametros_menu\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu\n\n";} 
	#$paginador=0;
	for $super_actual (values(%hash_super)) {
		#ordenar la lista alfabéticamente
		if ($super_actual !~ /Precios Cuidados/) {
			print $super_actual ."\n"; if ($filtro_w) {print INFORME $super_actual ."\n";} 
		}
		#if ($paginador < 6) {$paginador++;}
		#else {print "\n"; $paginador=0;}
	}
	print "\n\nPor favor, liste los supermercados y provincias que desea incluir en su consulta, ingresandolos por teclado, tal y como aparecen en la lista y separados por un circunflejo. (Para elegir todos ingrese -t)"; if ($filtro_w) {print INFORME "\n\nPor favor, liste los supermercados y provincias que desea incluir en su consulta, ingresandolos por teclado, tal y como aparecen en la lista y separados por un circunflejo. (Para elegir todos ingrese -t)";} 
	$lista_elegida= <STDIN>; chop $lista_elegida; 
	if ($lista_elegida =~ /-t/) {$filtro_x=0;}
	print "\nLista elegida: $lista_elegida\n\n"; if ($filtro_w) {print INFORME "\nLista elegida: $lista_elegida\n\n";} 

}


sub filtro_usuario {

	print "\nOpciones de reporte: $parametros_menu\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu\n\n";} 
	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		print "\n". substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); if ($filtro_w) {print INFORME "\n". substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.'));} 
	}
	print "\n\nPor favor, liste los usuarios que desea incluir en su consulta, ingresandolos por teclado, tal y como aparecen en la lista y separados por un circunflejo. (Para elegir todos ingrese -t)"; if ($filtro_w) {print INFORME "\n\nPor favor, liste los usuarios que desea incluir en su consulta, ingresandolos por teclado, tal y como aparecen en la lista y separados por un circunflejo. (Para elegir todos ingrese -t)";} 
	$lista_usuario_elegida= <STDIN>; chop $lista_usuario_elegida;
	if ($lista_usuario_elegida =~ /-t/) {$filtro_u=0;}

}



sub grabar {

	#reviso el directorio de informes $INFORMES/ para conocer que identificadores de archivos ya existen ahi
	opendir (INFO_DIR, $path_dir_informes) or die "No se pudo abrir el directorio de informes. $!";
	$descriptor_mayor=1;
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(INFO_DIR)) {

			my $descriptor=0;
			next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
			$descriptor= substr ($nom_archivo_actual, index ($nom_archivo_actual, '.') + 1); 
			if ($descriptor_mayor <= $descriptor) {$descriptor_mayor++}
	}
	#Me abro/creo un archivo en modo escritura (>) para ir guardando cada salida a pantalla
	open (INFORME, ">".$path_dir_informes."INFO_".$descriptor_mayor) or die "No se pudo crear el archivo de informes. $!"; 
}



sub ayuda {


	print "\n\n\nBienvenido al manual de reportes\n\n"."Para ejecutar una o varias opcion/es de reporte ingrese\n, desde el teclado, el caracter guion"
		." (-) seguido de la letra correspondiente a la o las opciones elegidas, seguida de la tecla ENTER.\n Por ejemplo -w + ENTER"
		." para grabar o -s + ENTER para salir del aplicativo.\n"
		."\nDescripcion de las opciones:\n"
		."-w graba en un archivo diferente cada pedido de reporte. Queda disponible en: \$INFODIR/ .\n"
		."-r informa el precio cuidado de cada item de la orden de compra presupuestada, si lo hubiere.\n"
		."-m informa el menor precio para cada item de la orden de compra presupuestada. Excluye los items de supermercados con precios cuidados.\n"
		."-d informa donde comprar cada item de la orden de compra presupuestada, agrupado por supermercado.\n"
		."-dr informa donde comprar cada item de la orden de compra presupuestada, y le adosa el precio de referencia si lo hubiere.\n"
		."-mr informa el menor precio para cada item de la orden de compra presupuestada. Excluye los items de supermercados con precios cuidados, sin embargo adosa el precio de referencia, si lo hubiere.\n"
		."-f informa cuales items de la orden de compra presupuestada no tiene precio establecido.\n"
		."-x establece un filtro, para los reportes, segun la provincia y el nombre del supermercado. Excluye los \n"
		."supermercados con precios cuidados.\n"
		."-u establece un filtro, para los reportes, segun los usuarios de las ordenes de compra presupuestadas.\n"
		."\nPara ejecutar varias opciones, cuando se pudiere, ingreselas en el mismo pedido de reporte.\n\n"; 

	if ($filtro_w) {print INFORME "\n\n\nBienvenido al manual de reportes\n\n"."Para ejecutar una o varias opcion/es de reporte ingrese\n, desde el teclado, el caracter guion"
		." (-) seguido de la letra correspondiente a la o las opciones elegidas, seguida de la tecla ENTER.\n Por ejemplo -w + ENTER"
		." para grabar o -s + ENTER para salir del aplicativo.\n"
		."\nDescripcion de las opciones:\n"
		."-w graba en un archivo diferente cada pedido de reporte. Queda disponible en: \$INFODIR/ .\n"
		."-r informa el precio cuidado de cada item de la orden de compra presupuestada, si lo hubiere.\n"
		."-m informa el menor precio para cada item de la orden de compra presupuestada. Excluye los items de supermercados con precios cuidados.\n"
		."-d informa donde comprar cada item de la orden de compra presupuestada, agrupado por supermercado.\n"
		."-dr informa donde comprar cada item de la orden de compra presupuestada, y le adosa el precio de referencia si lo hubiere.\n"
		."-mr informa el menor precio para cada item de la orden de compra presupuestada. Excluye los items de supermercados con precios cuidados, sin embargo adosa el precio de referencia, si lo hubiere.\n"
		."-f informa cuales items de la orden de compra presupuestada no tiene precio establecido.\n"
		."-x establece un filtro, para los reportes, segun la provincia y el nombre del supermercado. Excluye los \n"
		."supermercados con precios cuidados.\n"
		."-u establece un filtro, para los reportes, segun los usuarios de las ordenes de compra presupuestadas.\n"
		."\nPara ejecutar varias opciones, cuando se pudiere, ingreselas en el mismo pedido de reporte.\n\n"}
		
}



sub rep_precios_referencia {

	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	print "\nOpciones de reporte: $parametros_menu --> Precios de referencia\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu --> Precios de referencia\n\n";}
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		#Aplico el filtro de usuario (-u) en las dos siguientes lineas 		
		$varaux=substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); 
		next if ($filtro_u and $lista_usuario_elegida !~ /$varaux/);
		print "\n". $nom_archivo_actual. "\n";  if ($filtro_w) {print INFORME "\n". $nom_archivo_actual. "\n";}      
		#Creo el handle para el archivo de orden de compra presupuestada (OCP)
		open (OCP,"$path_dir_listasDeCompraPresupuestadas" . "$nom_archivo_actual")	or die"No se pudo abrir el archivo de orden de compra presupuestada. $!";
		print "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n"; if ($filtro_w) {print INFORME "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n";} 
		for $linea_actual (<OCP>) {

			chop $linea_actual;
			# el registro del archivo se compone de: NRO de ITEM;PRODUCTO PEDIDO;SUPER_ID;PRODUCTO ENCONTRADO;PRECIO
			my @campos_OCP= split (/;/, $linea_actual);	
			# Filtro para la opcion -r ..precios de referencia 
			if ($campos_OCP[2] < 100) {
				if ($filtro_x) {
					if($lista_elegida =~ /$hash_super{$campos_OCP[2]}/){
					print "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n"; if ($filtro_w) {print INFORME "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n";} 
					}
				}
				else
					{print "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n"; if ($filtro_w) {print INFORME "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n";} 
				}
			}
		}
		
	}
}



sub rep_precio_faltante {

	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	print "\nOpciones de reporte: $parametros_menu --> Precios faltantes\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu --> Precios faltantes\n\n";} 
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		#Aplico el filtro de usuario (-u) en las dos siguientes lineas
		$varaux=substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); 
		next if ($filtro_u and $lista_usuario_elegida !~ /$varaux/);
		print "\n". $nom_archivo_actual. "\n";   if ($filtro_w) {print INFORME "\n". $nom_archivo_actual. "\n";}       
		#Creo el handle para el archivo de orden de compra presupuestada (OCP)
		open (OCP,"$path_dir_listasDeCompraPresupuestadas" . "$nom_archivo_actual")	or die"No se pudo abrir el archivo de orden de compra presupuestada. $!";
		print "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n"; if ($filtro_w) {print INFORME "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n";} 
		for $linea_actual (<OCP>) {

			chop $linea_actual;
			# el registro del archivo se compone de: NRO de ITEM;PRODUCTO PEDIDO;SUPER_ID;PRODUCTO ENCONTRADO;PRECIO
			my @campos_OCP= split (/;/, $linea_actual);	
			# Filtro para la opcion -f ..precios faltantes
			if ($campos_OCP[4] !~ /$regex_campo_faltante/) {
				if ($filtro_x) {
					if($lista_elegida =~ /$hash_super{$campos_OCP[2]}/){
					print "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n"; if ($filtro_w) {print INFORME "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n";} 
					}
				}
				else
					{print "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n"; if ($filtro_w) {print INFORME "$campos_OCP[0] $campos_OCP[1] $campos_OCP[3] $campos_OCP[4] $hash_super{$campos_OCP[2]}\n";} 
				}				
			}				
		}
	}
}




sub rep_menor_precio {

	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	print "\nOpciones de reporte: $parametros_menu --> Menor precio\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu --> Menor precio\n\n";} 
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		#Aplico el filtro de usuario (-u) en las dos siguientes lineas 		
		$varaux=substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); 
		next if ($filtro_u and $lista_usuario_elegida !~ /$varaux/);
		print "\n". $nom_archivo_actual. "\n";  if ($filtro_w) {print INFORME "\n". $nom_archivo_actual. "\n";}        
		#Creo el handle para el archivo de orden de compra presupuestada (OCP)
		open (OCP,"$path_dir_listasDeCompraPresupuestadas" . "$nom_archivo_actual")	or die"No se pudo abrir el archivo de orden de compra presupuestada. $!";
		print "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n"; if ($filtro_w) {print INFORME "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n";} 
		# Filtro para la opcion -m ..menor precio. Creo un hash para guardar los registros con menores precios de cada item
		local %hash_items_menores_precios;
		for $linea_actual (<OCP>) {

			chop $linea_actual;
			# el registro del archivo se compone de: NRO de ITEM;PRODUCTO PEDIDO;SUPER_ID;PRODUCTO ENCONTRADO;PRECIO
			my @campos_OCP= split (/;/, $linea_actual);	
			#Descarto los super con precios cuidados
			if ($campos_OCP[2] >= 100) {
				if (exists($hash_items_menores_precios{$campos_OCP[0]})) { 
					#si existe un item con el mismo codigo cargado en el hash comparo el precio con el item del registro actual
					@campos_hash_items_menores_precios= split (/;/, $hash_items_menores_precios{$campos_OCP[0]});
					if ($campos_OCP[4] < $campos_hash_items_menores_precios[4]) {
						$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual;
					}
				}
				else { 
					$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual; 			
				}		
			}
			
							
		}
		#Ahora imprimo el hash cargado con los items (registros) de menores precios.
		#rehago la lista devuelta por los values del hash ordenada por item 			
		for $linea_actual (  values(%hash_items_menores_precios) ){      #&ordenar_array_registros_OCP      					

			@campos_hash_items_menores_precios= split (/;/, $linea_actual); 
			if ($filtro_x) { 
				if($lista_elegida =~ /$hash_super{$campos_hash_items_menores_precios[2]}/){	
				print " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";  if ($filtro_w) {print INFORME " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";} 
				}
			}
			else
				{print " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";  if ($filtro_w) {print INFORME " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";} 
			}
			
		}
	}	
	return (  values(%hash_items_menores_precios));
}




sub rep_donde_comprar {

	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	print "\nOpciones de reporte: $parametros_menu --> Donde comprar\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu --> Donde comprar\n\n";} 
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		#Aplico el filtro de usuario (-u) en las dos siguientes lineas 		
		$varaux=substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); 
		next if ($filtro_u and $lista_usuario_elegida !~ /$varaux/);
		print "\n". $nom_archivo_actual. "\n";   if ($filtro_w) {print INFORME "\n". $nom_archivo_actual. "\n";}       
		#Creo el handle para el archivo de orden de compra presupuestada (OCP)
		open (OCP,"$path_dir_listasDeCompraPresupuestadas" . "$nom_archivo_actual")	or die"No se pudo abrir el archivo de orden de compra presupuestada. $!";
		print "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n"; if ($filtro_w) {print INFORME "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\n\n";} 
		# Filtro para la opcion -m ..menor precio. Creo un hash para guardar los registros con menores precios de cada item
		local %hash_items_menores_precios;
		#Creo una variable para guardar los campos SUPER_ID presentes en cada archivo de OCP, sin repetición.
		$SUPER_ID_presentes='';
		for $linea_actual (<OCP>) {

			chop $linea_actual;
			# el registro del archivo se compone de: NRO de ITEM;PRODUCTO PEDIDO;SUPER_ID;PRODUCTO ENCONTRADO;PRECIO
			my @campos_OCP= split (/;/, $linea_actual);	
			if($SUPER_ID_presentes !~ /$campos_OCP[2]/) {$SUPER_ID_presentes .= "$campos_OCP[2];";}
			#Descarto los super con precios cuidados
			if ($campos_OCP[2] >= 100) {
				if (exists($hash_items_menores_precios{$campos_OCP[0]})) { 
					#si existe un item con el mismo codigo cargado en el hash comparo el precio con el item del registro actual
					@campos_hash_items_menores_precios= split (/;/, $hash_items_menores_precios{$campos_OCP[0]});
					if ($campos_OCP[4] < $campos_hash_items_menores_precios[4]) {
						$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual;
					}
				}
				else { 
					$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual; 			
				}		
			}
			
							
		}
		#Ahora imprimo el hash cargado con los items (registros) de menores precios ordenandolos por SUPER_ID segun el string $SUPER_ID_presentes .
		for $SUPER_ID_actual (split (/;/, $SUPER_ID_presentes)) {

			for $linea_actual (  values(%hash_items_menores_precios)){ 

				@campos_hash_items_menores_precios= split (/;/, $linea_actual);
				if ($SUPER_ID_actual eq $campos_hash_items_menores_precios[2]) {
					if ($filtro_x) { 
						if($lista_elegida =~ /$hash_super{$campos_hash_items_menores_precios[2]}/){	
						print " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";  if ($filtro_w) {print INFORME " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";} 
						}
					}
					else
						{print " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";  if ($filtro_w) {print INFORME " $campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]}\n";} 
					}
					
				}
			}
		print "\n"; if ($filtro_w) {print INFORME "\n";} 
		}
	}	
	return (  values(%hash_items_menores_precios));


#debo copiar lo de rep_menor_precio y en el loop que arma el hash para la salida debo armar un string en variable escalar
# que concatene al fila del mismo cada nuevo SUPER_ID de no encontrarlo ($mi_string =~ /SUPER_ID/) en la cadena.
# luego, con la cadena y cada SUPER_ID separado por delimitador (;), hago una lista y la recorro para cada SUPER_ID imprimiendo
# la salida correspondiente
	

}




sub rep_menor_precio_mas_referencia {

	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	print "\nOpciones de reporte: $parametros_menu --> Menor precio mas precio de referencia\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu --> Menor precio mas precio de referencia\n\n";} 
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		#Aplico el filtro de usuario (-u) en las dos siguientes lineas 		
		$varaux=substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); 
		next if ($filtro_u and $lista_usuario_elegida !~ /$varaux/);
		print "\n". $nom_archivo_actual. "\n";   if ($filtro_w) {print INFORME "\n". $nom_archivo_actual. "\n";}       
		#Creo el handle para el archivo de orden de compra presupuestada (OCP)
		open (OCP,"$path_dir_listasDeCompraPresupuestadas" . "$nom_archivo_actual")	or die "No se pudo abrir el archivo de orden de compra presupuestada. $!";
		print "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\t|PRECIO de REFERENCIA\t|Observaciones\n\n"; if ($filtro_w) {print INFORME "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\t|PRECIO de REFERENCIA\t|Observaciones\n\n";} 
		# Filtro para la opcion -m ..menor precio. Creo un hash para guardar los registros con menores precios de cada item
		local %hash_items_menores_precios;
		#Tb creo un hash para guardar los items de precios cuidados. KEY:NRO_ITEM ==> VALUE:PRECIO
		local %hash_items_precios_cuidados;
		for $linea_actual (<OCP>) {

			chop $linea_actual;
			# el registro del archivo se compone de: NRO de ITEM;PRODUCTO PEDIDO;SUPER_ID;PRODUCTO ENCONTRADO;PRECIO
			my @campos_OCP= split (/;/, $linea_actual);	
			#Descarto los super con precios cuidados
			if ($campos_OCP[2] >= 100) {
				if (exists($hash_items_menores_precios{$campos_OCP[0]})) { 
					#si existe un item con el mismo codigo cargado en el hash comparo el precio con el item del registro actual
					@campos_hash_items_menores_precios= split (/;/, $hash_items_menores_precios{$campos_OCP[0]});
					if ($campos_OCP[4] < $campos_hash_items_menores_precios[4]) {
						$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual;
					}
				}
				else { 
					$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual; 			
				}		
			}
			else {

				$hash_items_precios_cuidados{$campos_OCP[0]} = $campos_OCP[4];
			}			
							
		}
		#Ahora imprimo el hash cargado con los items (registros) de menores precios.
		for $linea_actual (  values(%hash_items_menores_precios)){ 

			@campos_hash_items_menores_precios= split (/;/, $linea_actual);
			#Aplico el filtro_x para supermercados-provincias elegidos por el usuario																
			if ($filtro_x && $lista_elegida =~ /$hash_super{$campos_hash_items_menores_precios[2]}/ || $filtro_x == 0){

				if (exists ($hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]})) {
					if ($campos_hash_items_menores_precios[4] <= $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]}) { $asteriscos= '*'}
					elsif ($campos_hash_items_menores_precios[4] > $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]}) { $asteriscos= '**'}
							
						print "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]} $asteriscos\n"; if ($filtro_w) {print INFORME "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]} $asteriscos\n";} 
					
				}
				else{
					print "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} no encontrado ***\n"; if ($filtro_w) {print INFORME "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} no encontrado ***\n";} 
					}
			}
		}
	}	
	return (  values(%hash_items_menores_precios));
}




sub donde_comprar_mas_referencia {

	#Creo el handle para el directorio de los archivos de orden de compra presupuestada (OCP_DIR)
	opendir (OCP_DIR, $path_dir_listasDeCompraPresupuestadas) or die "No se pudo abrir el directorio. $!";
	print "\nOpciones de reporte: $parametros_menu --> Donde comprar mas precio de referencia\n\n"; if ($filtro_w) {print INFORME "\nOpciones de reporte: $parametros_menu --> Donde comprar mas precio de referencia\n\n";} 
	for $nom_archivo_actual (@lista_archivos_OCP= readdir(OCP_DIR)) {

		next if ($nom_archivo_actual eq "." || $nom_archivo_actual eq "..");
		#Aplico el filtro de usuario (-u) en las dos siguientes lineas 		
		$varaux=substr ($nom_archivo_actual, 0, index ($nom_archivo_actual, '.')); 
		next if ($filtro_u and $lista_usuario_elegida !~ /$varaux/);
		print "\n". $nom_archivo_actual. "\n";  if ($filtro_w) {print INFORME "\n". $nom_archivo_actual. "\n";}        
		#Creo el handle para el archivo de orden de compra presupuestada (OCP)
		open (OCP,"$path_dir_listasDeCompraPresupuestadas" . "$nom_archivo_actual")	or die"No se pudo abrir el archivo de orden de compra presupuestada. $!";
		print "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\t|PRECIO de REFERENCIA\t|Observaciones\n\n"; if ($filtro_w) {print INFORME "NRO de ITEM\t|PRODUCTO PEDIDO\t|PRODUCTO ENCONTRADO\t|PRECIO\t|NOMBRE_SUPER_PROVINCIA\t|PRECIO de REFERENCIA\t|Observaciones\n\n";} 
		# Filtro para la opcion -m ..menor precio. Creo un hash para guardar los registros con menores precios de cada item
		local %hash_items_menores_precios;
		#Creo una variable para guardar los campos SUPER_ID presentes en cada archivo de OCP, sin repetición.
		#Tb creo un hash para guardar los items de precios cuidados. KEY:NRO_ITEM ==> VALUE:PRECIO
		local %hash_items_precios_cuidados;
		$SUPER_ID_presentes='';
		for $linea_actual (<OCP>) {

			chop $linea_actual;
			# el registro del archivo se compone de: NRO de ITEM;PRODUCTO PEDIDO;SUPER_ID;PRODUCTO ENCONTRADO;PRECIO
			my @campos_OCP= split (/;/, $linea_actual);	
			if($SUPER_ID_presentes !~ /$campos_OCP[2]/) {$SUPER_ID_presentes .= "$campos_OCP[2];";}
			#Descarto los super con precios cuidados
			if ($campos_OCP[2] >= 100) {
				if (exists($hash_items_menores_precios{$campos_OCP[0]})) { 
					#si existe un item con el mismo codigo cargado en el hash comparo el precio con el item del registro actual
					@campos_hash_items_menores_precios= split (/;/, $hash_items_menores_precios{$campos_OCP[0]});
					if ($campos_OCP[4] < $campos_hash_items_menores_precios[4]) {
						$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual;
					}
				}
				else { 
					$hash_items_menores_precios{$campos_OCP[0]} = $linea_actual; 			
				}		
			}
			else {

				$hash_items_precios_cuidados{$campos_OCP[0]} = $campos_OCP[4];
			}		
		}
		#Ahora imprimo el hash cargado con los items (registros) de menores precios ordenandolos por SUPER_ID segun el string $SUPER_ID_presentes .
		for $SUPER_ID_actual (split (/;/, $SUPER_ID_presentes)) {

			#Aplico el filtro_x para supermercados-provincias elegidos por el usuario																
			if ($filtro_x && $lista_elegida =~ /$hash_super{$SUPER_ID_actual}/ || $filtro_x == 0){

				for $linea_actual (  values(%hash_items_menores_precios)){ 

					@campos_hash_items_menores_precios= split (/;/, $linea_actual);
					if ($SUPER_ID_actual eq $campos_hash_items_menores_precios[2]) {
					
							if (exists ($hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]})) {
							if ($campos_hash_items_menores_precios[4] <= $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]}) { $asteriscos= '*'}
							elsif ($campos_hash_items_menores_precios[4] > $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]}) { $asteriscos= '**'}
							print "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]} $asteriscos\n"; if ($filtro_w) {print INFORME "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} $hash_items_precios_cuidados{$campos_hash_items_menores_precios[0]} $asteriscos\n";} 
							}

						else{
							print "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} no encontrado ***\n"; if ($filtro_w) {print INFORME "$campos_hash_items_menores_precios[0] $campos_hash_items_menores_precios[1] $campos_hash_items_menores_precios[3] $campos_hash_items_menores_precios[4] $hash_super{$campos_hash_items_menores_precios[2]} no encontrado ***\n";} 
						}
					}
				}
				print "\n"; if ($filtro_w) {print INFORME ;} 
			}
		}
	}	
	return (  values(%hash_items_menores_precios));
}






sub ordenar_array_registros_OCP  {

	
	#local @lista_entrada= @_; print "La lista de keys de entrada es:" .@_."\n";
	local @lista_salida;
	#my @lista_ordenada = sort {$a <=> $b} @lista_entrada; print "La lista de keys ordenada es:" .@lista_ordenada."\n";
	#Copio cada elemento value del hash desde la lista ordenada de los keys hacia la lista salida
	for ( sort {$a <=> $b} keys %hash_items_menores_precios) {

		push (@lista_salida, $hash_items_menores_precios{$_}); #print "La lista de salida es:" .@lista_salida."\n";
	}

return (@lista_salida);
}


