#!/bin/bash
#
# Script para el administrado de tareas de escuha reiterada
#

############## DECLARACIONES ###########################


declare -rx SSHPASS="/usr/bin/sshpass"

declare -rx PUTTY="/usr/bin/scp"

declare -rx WALL="/usr/bin/wall"

declare -a COMANDOS=($SSHPASS $PUTTY $WALL)

declare -a DETALLES=("$SSHPASS" "scp" "wall")

declare -r OPER_ID="${RANDOM}"

declare CONTADOR=0

declare ESTADO

################## SANIDADES ###########################



for i in ${COMANDOS[@]};do
   
    if test ! -x "$i" ;then
	printf "\n$SCRIPT:$LINENO: El comando necesario ${DETALLES[$CONTADOR]} no se encuentra disponible--> ABORTANDO\n\n" >&2
	exit 192
    fi
    let CONTADOR=CONTADOR+1

done



################## SCRIPT #################################

ESTADO=$(ps aux | grep cola_impresion_impresora.sh | grep -v grep | head -1 | awk '{print $1}')

if test -z "${ESTADO}"; then
    bash -o xtrace /home/ariel/MIDOKA_PGC/scripts/cola_impresion_impresora.sh
    #bash -o xtrace ${HOME}/_ORG/PLAY-COLOR/MIDOKA_PGC/scripts/cola_impresion_impresora.sh

else
    sleep 2
fi


#################### LIMPIEZA ##########################

exit 0
