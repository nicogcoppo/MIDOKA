#!/bin/sh
#
# Script para el espejado del servidor
# Tener en cuenta que sera necesario habilitar la conexion por password para
# La direccion IP del servidor esclavo en el que corre este script

############## DECLARACIONES ###########################


declare -rx SSHPASS="/usr/bin/sshpass"

declare -a COMANDOS=($SSHPASS "/usr/bin/rsync")

declare -a DETALLES=("$SSHPASS" "rsync")

declare CONTADOR=0

declare -r GRABADO=""$(date +%F:%Hh)"_"$(hostname)".sql"

######### CONFIGURACION ################################

declare -r SERVER=$(cat ${HOME}'/serverIP' | base64 -d) # Reemplazar solo con LA IP del server

declare -r passServer=$(cat ${HOME}'/serverPass' | base64 -d) # Reemplazar con el password root del server

declare -r USUARIO="sshcolor" # Reemplazar con el nombre de usuario en el server

declare DBASE="MIDOKA_PGC_B" #Reemplazar con el nombre de la base de datos

declare -r SERVERdata="resguardosMidokaPgc/" #Reemplazar con la carpeta de resguardo en el server

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

    rsync -avz --delete -e "sshpass -p ${passServer} ssh" --progress root@${SERVER}:/home/${USUARIO}/MIDOKA/ /home/${USER}/MIDOKA/ 
    
    ## Copio Base de datos

    sshpass -p ${passServer} ssh -o StrictHostKeyChecking=no root@${SERVER} "mysqldump -u root "${DBASE}" > ${SERVERdata}/"${GRABADO}""
    
    
    # me bajo las ultimas base de datos
    
    rsync -avz --delete -e "sshpass -p ${passServer} ssh" --progress root@${SERVER}:/root/${SERVERdata}/ /home/${USER}/${SERVERdata}/ 
    
    
}

################## SCRIPT #################################



# VERIFICO DIRECTORIOS , CREO EN CASO DE NUEVA DB

if [ ! -d "${HOME}/${SERVERdata}" ]; then
    mkdir "${HOME}/${SERVERdata}"
fi

transmision

#mysql -u root --execute="DROP DATABASE IF EXISTS "${DBASE}";CREATE DATABASE "${DBASE}";"

#mysql -u root -D"${DBASE}" </home/${USER}/${SERVERdata}/${GRABADO} 


#################### LIMPIEZA ##########################

exit 0
