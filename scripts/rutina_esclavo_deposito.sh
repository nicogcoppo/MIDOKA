#!/bin/bash
#
# Script para el resguardo de la base de datos
#

############## DECLARACIONES ###########################


declare -rx SSHPASS="/usr/bin/sshpass"

declare -rx PUTTY="/usr/bin/scp"

declare -rx WALL="/usr/bin/wall"

declare -a COMANDOS=($SSHPASS $PUTTY $WALL)

declare -a DETALLES=("$SSHPASS" "scp" "wall")

declare -r OPER_ID="${RANDOM}"

declare -r RAIZ=""${HOME}"/_ORG/PLAY-COLOR/MIDOKA_PGC/"

declare -r GRABADO=""$(date +%F)"_"$(hostname)".sql"

declare CONTADOR=0

declare ACTIVIDAD


################## SANIDADES ###########################



for i in ${COMANDOS[@]};do
   
    if test ! -x "$i" ;then
	printf "\n$SCRIPT:$LINENO: El comando necesario ${DETALLES[$CONTADOR]} no se encuentra disponible--> ABORTANDO\n\n" >&2
	exit 192
    fi
    let CONTADOR=CONTADOR+1

done


################# FUNCIONES #############################


################## SCRIPT #################################

# ACTUALIZO SCRIPTS

while true; do

    sshpass -p "cat0classmacaco1236729038" env CVS_RSH=ssh cvs -d:ext:root@mail.midoka.com.ar:/home/playcolor/REPOSITORIO update . 

    case $? in
	0) break;;
	1) sleep 15;;
    esac
    
done


# BUSCO NOMBRE DE LA ULTIMA BASE DE DATOS

declare -rx DBASE="$(cat "${RAIZ}/MIDOKA3.sh" | grep DB= | grep -o '".*"' | sed s/^.// | sed s/.$//)" 


# VERIFICO DIRECTORIOS , CREO EN CASO DE NUEVA DB

if [ ! -d ""${HOME}"/RESGUARDO" ]; then
    mkdir ""${HOME}"/RESGUARDO"
fi


if [ ! -d ""${HOME}"/RESGUARDO/"${DBASE}"" ]; then
    mkdir ""${HOME}"/RESGUARDO/"${DBASE}""
fi



# CREO COPIA LOGICA DE LA BASE DE DATOS ACTUAL

while true; do

   
    sshpass -p "cat0classmacaco1236729038" ssh -o StrictHostKeyChecking=no root@mail.midoka.com.ar "mysqldump -u root "${DBASE}" >""MIDOKA_PGC_DATA/"${GRABADO}""
    
    
    sshpass -p "cat0classmacaco1236729038" scp "root@mail.midoka.com.ar:/root/MIDOKA_PGC_DATA/"${GRABADO}"" ""${HOME}"/RESGUARDO/"${DBASE}""  


    case $? in
	0) break;;
	1) sleep 15;;
    esac
done

    
#################### LIMPIEZA ##########################


exit 0
