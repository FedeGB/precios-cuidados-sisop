## TP SO7508 Primer Cuatrimestre 2014. Tema C, Grupo 03, RETAILC
## Todos los derechso e izquierdos reservados ©

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
El path/dirección absoluto/a a la carpeta descomprimida será referido/a como GRUPO.


Instrucciones para obtener paquete de instalación:
	1) Insertar el dispositivo de almacenamiento con el archivo tp-so-03c.tgz
	2) Crear e el directorio corriente un directorio de trabajo
	3) Copiar el archivo tp-so-03c.tgz a ese directorio
	4) Descomprimir el archivo tp-so-03c.tgz de manera de generar el archivo tp-so-03c.tar
		a través del comando $gunzip tp-so-03c.tar.gz
	5) Extraer los archivos del .tar generado en el paso anterior usando el comando
		$tar -xvf tp-so-03c.tar obteniendo finalmente el directorio tp-so-03c.
	El directorio obtenido debe contener lo siguiente:
	tp-so-03c/
		README.txt
		7508SO-1-c2014-Informe-Grupo03.pdf
		pruebas/
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
SARASA


Instrucciones de ejecución:
	1) En el directorio donde se instaló el porgrama (../grupo03/)
		ir al directorio de ejecutables (bin, con el nombre que se le haya asignado).
	2) Abra una consola de comandos con path en ese directorio (si no lo estaba haciendo
		ya desde un principio).
	3) Ejecute el comando Initializer.sh de la siguiente forma:
		$. Initializer.sh o bien $source Initializer.sh
	4) En caso de haber algun problema será informado por el programa.
