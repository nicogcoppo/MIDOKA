#!/bin/bash
#
# Script para el automatizado del proceso de impresion en el deposito
#

############## DECLARACIONES ###########################


declare -rx SSHPASS="/usr/bin/sshpass"

declare -rx PUTTY="/usr/bin/scp"

declare -rx WALL="/usr/bin/wall"

declare -a COMANDOS=($SSHPASS $PUTTY $WALL "/usr/bin/rsync")

declare -a DETALLES=("$SSHPASS" "scp" "wall" "rsync")

declare -r OPER_ID="${RANDOM}"

declare  DIR="/home/playcolor/MIDOKA_PGC/impresion/repartos/" ## Directorio de trabajo

declare -r IMPRESORA="HP-LaserJet-Professional-P1102w"

declare CONTADOR=0

declare -r GRABADO=""$(date +%F)"_"$(hostname)".sql"

######### CONFIGURACION ################################

declare -r USUARIO="playcolor"

declare DBASE="MIDOKA_PGC_B"

declare DIRECTORIO_ORIGEN="MIDOKA_PGC_DATA"

################## SANIDADES ###########################



for i in ${COMANDOS[@]};do
   
    if test ! -x "$i" ;then
	printf "\n$SCRIPT:$LINENO: El comando necesario ${DETALLES[$CONTADOR]} no se encuentra disponible--> ABORTANDO\n\n" >&2
	exit 192
    fi
    let CONTADOR=CONTADOR+1

done


################# FUNCIONES #############################


function transmision {

    
    ## Copio Archivos

    rsync -avz --delete -e "sshpass -p '36729038macaco12cat0class' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress ${USUARIO}@mail.midoka.com.ar:/home/${USUARIO}/MIDOKA_PGC/ /home/${USUARIO}/MIDOKA_PGC/ 

    rsync -avz --delete -e "sshpass -p '36729038macaco12cat0class' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress ${USUARIO}@mail.midoka.com.ar:/home/${USUARIO}/REPOSITORIO/ /home/${USUARIO}/REPOSITORIO/ 
    
    ## Copio Base de datos

      
    sshpass -p "cat0classmacaco1236729038" ssh -o StrictHostKeyChecking=no root@mail.midoka.com.ar "find ${DIRECTORIO_ORIGEN}/* -type d -ctime +45  -exec rm -rf {} \;"


    sshpass -p "cat0classmacaco1236729038" ssh -o StrictHostKeyChecking=no root@mail.midoka.com.ar "mysqldump -u root "${DBASE}" > ${DIRECTORIO_ORIGEN}/"${GRABADO}""
    
    
    # me bajo las ultimas base de datos
    
    rsync -avz --delete -e "sshpass -p 'cat0classmacaco1236729038' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress root@mail.midoka.com.ar:/root/${DIRECTORIO_ORIGEN}/ /home/${USUARIO}/${DIRECTORIO_ORIGEN}/ 
    

}

################## SCRIPT #################################

transmision

mysql -u root --execute="DROP DATABASE IF EXISTS "${DBASE}";CREATE DATABASE "${DBASE}";"

mysql -u root -D"${DBASE}" </home/${USUARIO}/${DIRECTORIO_ORIGEN}/${GRABADO} 


#################### LIMPIEZA ##########################

exit 0
