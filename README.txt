## TP SO7508 Primer Cuatrimestre 2014. Tema C, Grupo 03, RETAILC
## Todos los derechos e izquierdos reservados ©

Requisitos mínimos para el funcionamiento de RETAILC
	* Alguna distribución de linux
	* Interprete de bash versión 4.2.45 o superior
	* Interprete de perl versión 5 o superior
	
Instalar el programa en un ordenador que no cumpla los requisitos mínimos
dados no asegura el correcto funcinamiento del programa RETAILC.

Las siguientes instrucciones suponen que el usuario que desea instalar
el programa dispone de conocimientos mínimos para ejecución de comandos 
por consola.
En las instrucciones los comandos estaran puestos como $<comando>, siendo 
"$" el prompt de la terminal de unix.
El path/dirección absoluto/a a la carpeta descomprimida (grupo03) será referido/a como GRUPO.


Instrucciones para obtener paquete de instalación:
	1) Insertar el dispositivo de almacenamiento con el archivo tp-so-03c.tgz
	2) Cree un nuevo directorio en donde desee
		$mkdir DEST
		Siendo DEST el nombre del directorio a crear
	3) Copie el archivo tp-so-03c.tgz al directorio creado. Esto lo puede hacer mediante el comando $cp <origen> <destino>, siendo el destino el nuevo directorio creado anteriormente y origen el directorio del .tgz (por ejemplo /media/A341-4AB3/tp-so-03c.tgz). Para mas información consulte $man cp
	4) Descomprimir el archivo tp-so-03c.tgz de manera de generar el archivo tp-so-03c.tar. Para ello, puede hacerlo a traves de una terminal. Si no venia trabajando con una terminal, abra una en el directorio donde copio el archivo.
	4.1) Algunos sistemas de linux vienen con la opcion de abrir una terminal en el directorio con el menu que se despliega al hacer click derecho en la ventana de ese directorio. Sino puede abrir una terminal e ir moviendose por los directorios con el comando cd. Ejemplo: $cd DEST (ver $man cd para mas ayuda).
	4.2) Entonces estando en el directorio que contiene el archivo tgz (copiado, no el del dispositivo) escriba el siguiente comando:
	$gunzip tp-so-03c.tgz
	5) Una vez obtenido el archivo .tar, en la misma terminal extraer el contenido de ese archivo con el comando: $tar -xvf tp-so-03c.tar obteniendo finalmente el directorio tp-so-03c.
	El directorio obtenido debe contener lo siguiente:
	tp-so-03c/
		README.txt
		7508SO-1-c2014-Informe-Grupo03.pdf
		datos/
			Lista de Compras/
				<Varios archivos con listas de compras>
			Lista de Precios/
				<Varios archivos con listas de precios>
		grupo03/
			Installer.sh
			src/
				asociados.mae
				Initializer.sh
				listener.sh
				logging.sh
				masterlist.sh
				Mover.sh
				rating.sh
				reporting.pl
				Start.sh
				Start_README
				Stop.sh
				Stop_README
				super.mae
				um.tab

Instrucciones de instalación:
	1) Desde una terminal diríjase al directorio grupo03 (en la misma terminal donde venia trabajando sería $cd tp-so-03c/grupo03) y asigne permisos de ejecución al instalador ejecutando el comando $chmod u+x Installer.sh.

	2) Ahora ejecute el comando $./Installer.sh, el programa de instalación lo guiará durante el proceso de configuración y copiado del sistema hacia su PC. En caso de haber una instalacion previa salte al paso 10 de reinstalacion.

	4) El instalador chequeara que se encuentren los archivos fuentes necesarios, iniciara un logger y mostrara los directorios donde se almacenaran al informacion de log y configuracion final. Se le preguntara si acepta los terminos y condiciones. Responda "Si" en caso de estar de acuerdo o "No" aceptar y el proceso de instalacion finalizara.
	
	5) A continuacion se le pediran los nombres de los directorios y algunos parametros del sistema. Entre parentesis se le indica la opcion por defecto que puedeser seleccion pulsando enter. Los nombres de directorios ingresados deben ser validos y se crearan en la carpeta grupo03. Tambien le sera posible determinar tamaños de archivos, los cuales deben ser numeros enteros y que no superen la cantidad de espacio disponible en el sistema. La extension de los archivos log deben ser de 3 caracteres validos.

	6) Una vez ingresados todos los datos se le mostrara los valores finales de los parametros del sistema y se le preguntara si esta de acuerdo con la configuracion. Ingrese "Si" en caso afirmativo, "No" en caso de volver a ingresar los datos (Paso anterior).

	7) Se le informa que se iniciara la instalacion. Teclee "Si" en caso de completar o "No" si desea salir.
		
	8) Una vez terminada la instalación, el sistema mostrará un mensaje indicando que la misma ha concluido exitosamente y habrá creado la siguiente estructura de directorios dentro de la carpeta grupo03 ademas de la carpeta src/ con los archivos fuentes:

grupo03/

	Installer.sh

	BINDIR/
		Initializer.sh
		listener.sh
		logging.sh
		masterlist.sh
		Mover.sh
		rating.sh
		reporting.pl
		Start.sh
		Stop.sh

	MAEDIR/
		precios/
			proc/
		asociados.mae
		super.mae
		um.tab

	CONFDIR/
		Installer.conf
		installer.log

	ARRIDIR/

	ACEPDIR/
		proc/

	NOVEDIR/
		pres/
	INFODIR/
	
	LOGDIR/

	Los nombres de las carpetas son variables genericas que el usuario puede seleccionar durante la instalación.
	
	9) Para verificar si falta algun componente y reinstalarlo ejecutar nuevamente ./Installer.sh y el instalador lo guiara en la recuperacion de la instalación (Paso 10).

	10) Se le informaran las carpetas y archivos presentes y faltantes. En caso de que no hayan faltantes el proceso de reinstalacion finaliza. De lo contrario se le preguntara si desea completar la instalacion. Responda "Si" en caso de continuar o "No" si desea finalizar.

	11) Se le mostraran la lista de directorios y archivos restaurados, finalizando la reinstalacion.

Instrucciones de ejecución:
	1) Para ejecutar el sistema, en una terminal, estando en el directorio en donde efectuó la instalación, ingrese al directorio que configuró para los binarios (bin por defecto). Por ejemplo $cd bin/ .
	2) Entonces, para ejecutar el comando Initializer.sh lo puede hacer de las siguientes formas:
	$. Initializer.sh o bien $source Initializer.sh
	3) En caso de ejecutarse con éxito debería aparecerle una opción que le permite iniciar el "listener". Esto quiere decir que el sistema se inicializo con éxito y puede continuar con lo siguiente. Si se le presenta algún problema, será informado por el mismo Initializer.
	3.1) Si elige no inicializar el listener, puede hacerlo cuando desee a traves del comando Start.sh (ver apartado mas adelante).
	3.2) Una vez ejecutado el listener éste queda corriendo hasta que se lo pare. Para ello debe utilizar el comando Stop.sh (ver apartado mas adelante).
	4) Para empezar a procesar archivos debe dejarlos en la carpeta que configuro para los "arribos" (arribos por defecto).
	5) Para ver reportes sobre los archivos procesados con filtros y opciones puede hacerlo mediante el comando $reporting.pl (requiere haber procesado listas de compras y de precios antes)

Instrucción Start.sh:
	Si no ejecuto el listener automáticamente y lo desea ejecutar puede hacerlo, desde la terminal en donde inicializó el programa (su sesión), de la siguiente manera:
	$Start.sh NULL -b listener
	Recuerde que si no esta inicializado el sistema no se puede avanzar. Para incializarlo siga las instrucciones de ejecución.

Instruccion Stop.sh:
	Si desea terminar la ejecucion del listener correctamente, puede hacerlo, desde la terminal en donde inicilizo el programa (su sesión), de la siguiente manera:
	$Stop.sh listener
	Esto sólo se puede efectuar desde su sesión (terminal en donde inicializo el sistema).
