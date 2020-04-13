#!/bin/bash
#
# Script para el resguardo LOCAL de la base de datos
#
# Si $1 es nulo se creara una copia de la base de datos al momento
# de la ejecucion de este script

############## DECLARACIONES ###########################


declare -rx SSHPASS="/usr/bin/sshpass"

declare -rx PUTTY="/usr/bin/scp"

declare -rx WALL="/usr/bin/wall"

declare -a COMANDOS=($SSHPASS $PUTTY $WALL)

declare -a DETALLES=("$SSHPASS" "scp" "wall")

declare -r OPER_ID="${RANDOM}"

declare -r RAIZ=""${HOME}"/_org/MIDOKA/" #Reemplazar por el directorio de instalacion

declare -r ACUMULADOR=""${HOME}"/_org/playcolor/resguardosBaseDatos/" #Reemplazar por el directorio de copias de seguridad

declare -r SERVER="root@66.97.37.139" #Reemplazar con el nombre del server

declare -r SERVERdata="resguardosMidokaPgc/" #Reemplazar con la carpeta de resguardo en el server

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


# BUSCO NOMBRE DE LA ULTIMA BASE DE DATOS

declare -rx DBASE="$(cat "${RAIZ}/MIDOKA3.sh" | grep DB= | grep -o '".*"' | sed s/^.// | sed s/.$//)" 


# VERIFICO DIRECTORIOS , CREO EN CASO DE NUEVA DB

if [ ! -d "${ACUMULADOR}" ]; then
    mkdir "${ACUMULADOR}"
fi


# CREO COPIA LOGICA DE LA BASE DE DATOS ACTUAL

while true; do

   
    test -z $1 && ssh -o StrictHostKeyChecking=no "${SERVER}" "mysqldump -u root "${DBASE}" > "${SERVERdata}""${GRABADO}";find "${SERVERdata}"* -type f -ctime +45  -exec rm -rf {} \;"
        
    rsync -az "${SERVER}":"${SERVERdata}" ${ACUMULADOR}


    case $? in
	0) break;;
	1) sleep 15;;
    esac
done

    
#################### LIMPIEZA ##########################


exit 0
