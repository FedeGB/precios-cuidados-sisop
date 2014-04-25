#!/bin/bash
# Initializer que por ahora solo inicia variables de ambiente, con la estructura de directorios actuales
# Para que las inicie, hay que correr este script con ". initializer.sh" para que este en el contexto de la consola, sino no las setea (y no se puede hacer desde script, ya probe y busque...)

numfields=`echo \`pwd\` | grep -o '/' | wc -l`
numfields=`expr $numfields + 1` # le sumo 1 pues cut toma como field antes del / incial tambien
pathconf=`echo \`pwd\` | cut -f"$numfields" -d'/' --complement` # llego hasta ../grupo03
pathconf="$pathconf/conf"

export LOGDIR=`echo \`grep '^LOGDIR' "$pathconf"/installer.conf\` | cut -f2 -d'='` # Suponiendo que LOGDIR tenga el path completo, sino se lo tengo que agregar
export LOGEXT=`echo \`grep '^LOGEXT' "$pathconf"/installer.conf\` | cut -f2 -d'='` # Fijarse tambien que usamos como separador en las lineas!!
export LOGSIZE=`echo \`grep '^LOGSIZE' "$pathconf"/installer.conf\` | cut -f2 -d'='` # En B