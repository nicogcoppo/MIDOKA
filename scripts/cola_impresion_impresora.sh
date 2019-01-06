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

declare -r IMPRESORA="HP1102"  ## CRONTAB  cupsenable HP1102


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



function transmision {

    CONTADOR=0
    
    ## Mando imprimir, guardo numero de operacion

    TRABAJO="$(lp -d "$IMPRESORA" ""${directorioImpresion}/*"" | awk '{print $5}' | tr '-' '\n' | tail -n -1)" 

    test -z ${TRABAJO} && return 1

       
    while true; do

	ESTADO="$(lpstat -W completed | grep ${IMPRESORA} | head -1 | awk '{print $1}' | tr '-' '\n' | tail -n -1)"

	if [[ "$TRABAJO" -eq "$ESTADO" ]]; then

	    rm -rf "${directorioImpresion}"
	    
	    break

	else

	    sleep 10
	    
	    let CONTADOR+=1

	    if [[ "$CONTADOR" -gt "10" ]]; then

		STOPPED=$(lpstat -l | grep -A 4 ${TRABAJO} | grep completed | head -1)

		test -z """${STOPPED}""" || rm -rf "${directorioImpresion}" 

		cancel ${IMPRESORA}-${TRABAJO}
			    
		break

		
		

		
	    fi
	    
	fi
	
    done
    
}

    
    
    
################## SCRIPT #################################

VAR=$(ls ${HOME}/MIDOKA_IMPRESION | head -1)

directorioImpresion=""${HOME}"/MIDOKA_IMPRESION/"${VAR}""

test -z $(ls $directorioImpresion | head -1) || transmision

directorioImpresion=""${HOME}"/MIDOKA_IMPRESION/"${RANDOM}"" && mkdir ${directorioImpresion}

## Copio Archivos

rsync -avz --remove-source-files  -e "sshpass -p '36729038macaco12cat0class' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress playcolor@mail.midoka.com.ar:${DIR}/colaImpresion/ ${directorioImpresion}/

test -z $(ls  $directorioImpresion | head -1) && rm -rf ${directorioImpresion} || transmision




#################### LIMPIEZA ##########################

exit 0
