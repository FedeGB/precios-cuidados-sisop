#comentario
#
ERROR=0
ACEPDIR=/home/ubuntu/precios-cuidados-sisop/Rating/aceptados
PROCDIR=/home/ubuntu/precios-cuidados-sisop/Rating/procesados

<<CheckFile 
	Checks that a file is not empty nor already processed. Returns zero if OK.
CheckFile

function checkFile() {
	if [[ -f $PROCDIR/$1 ]]; then
		echo "Archivo duplicado -> Mover a RECHAZADOS"
		return
	fi
	if [[ ! -s $ACEPDIR/$1 ]]; then
		echo "Archivo vacío -> Mover a RECHAZADOS"
		return
	fi
		echo "0"
}

checkFile lista2