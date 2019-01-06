#!/bin/bash
#
# Script para el automatizado del proceso de impresion en el deposito
#

############## DECLARACIONES ###########################


declare -rx SSHPASS="/usr/bin/sshpass"

declare -rx PUTTY="/usr/bin/scp"

declare -rx WALL="/usr/bin/wall"

declare -a COMANDOS=($SSHPASS $PUTTY $WALL)

declare -a DETALLES=("$SSHPASS" "scp" "wall")

declare -r OPER_ID="${RANDOM}"

declare  DIR="impresion/"${OPER_ID}""

declare -r IMPRESORA="QL-720NW"

declare CONTADOR=0

declare ACTIVIDAD

declare PRUEBA_IMPRESION

################## SANIDADES ###########################



for i in ${COMANDOS[@]};do
   
    if test ! -x "$i" ;then
	printf "\n$SCRIPT:$LINENO: El comando necesario ${DETALLES[$CONTADOR]} no se encuentra disponible--> ABORTANDO\n\n" >&2
	exit 192
    fi
    let CONTADOR=CONTADOR+1

done


################# FUNCIONES #############################

function control_eliminado {
    
    CONTADOR=0
    while true; do
	
	
	sshpass -p "cat0classmacaco1236729038" ssh -o StrictHostKeyChecking=no root@mail.midoka.com.ar "rm -f /home/playcolor/MIDOKA_PGC/impresion/ariel/${i}" 2>log_error_depo_impr

	
	if test ! -s "log_error_depo_impr"; then

	    return 

	else

	    rm "log_error_depo_impr"
	    
	    ACTIVIDAD="$(sshpass -p "cat0classmacaco1236729038" ssh -o StrictHostKeyChecking=no root@mail.midoka.com.ar "stat /home/playcolor/MIDOKA_PGC/impresion/ariel/${i}")"
	    
	    if test -z ${ACTIVIDAD}; then
		return
	    else
		test "$CONTADOR" -gt 60 && return
	    fi
	    
	fi
	
	let CONTADOR+=1
	
    done
}

################## SCRIPT #################################

cd "/"${HOME}"/MIDOKA_PGC"

mkdir ${DIR}


# Me bajo los archivos mandados a imprimir

	
ACTIVIDAD="$(sshpass -p "cat0classmacaco1236729038" ssh -o StrictHostKeyChecking=no root@mail.midoka.com.ar "ls /home/playcolor/MIDOKA_PGC/impresion/ariel/")"

if test -z ${ACTIVIDAD}; then

    echo "No hay actividad reciente"

else
    
	
    sshpass -p '36729038macaco12cat0class' scp 'playcolor@mail.midoka.com.ar:/home/playcolor/MIDOKA_PGC/impresion/ariel/*' "./"${DIR}""  
        
    ls ${DIR} >""${DIR}"/data."${OPER_ID}""

    echo -e "\n">>""${DIR}"/data."${OPER_ID}""


    
    cat ""${DIR}"/data."${OPER_ID}"" | sed '/^data/d' | awk 'NF' >""${DIR}"/data2."${OPER_ID}""
    
    ar=()
    while read line; do
	ar+=("${line}")
    done<""${DIR}"/data2."${OPER_ID}""

    rm -f ""${DIR}"/data."${OPER_ID}"" ""${DIR}"/data2."${OPER_ID}""


    

    
    for i in "${ar[@]}"; do
	while true; do
	    
	    # Chekeo estado de la impresora

	    ACTIVIDAD=$(lpstat -p | grep activada | head -1)
	    
	    
	    if test -z ${ACTIVIDAD}; then
		#dialog --msgbox "LA ETIQUETADORA BROTHER NO ESTA ENCENDIDA, ENCIENDALA POR FAVOR " 0 0
		sleep 1
		wall "ENCENDER LA ETIQUETADORA ""${IMPRESORA}"" POR FAVOR" 
	    else
		break
	    fi
	    
	done

	lp -o landscape -d "$IMPRESORA" -c ""${DIR}"/"${i}""

	while true; do
	    
	    PRUEBA_IMPRESION=$(lpq -a | tail -n +2)

	    if test -z "${PRUEBA_IMPRESION}"; then
		break
	    else
		sleep 5
		wall "LA IMPRESORA ESTA INTENTANDO IMPRIMIR"
	    fi
	    
		
	done	
	
	rm ""${DIR}"/"${i}""
	
	rm "log_error_depo_impr"

	control_eliminado

    done

    rm "log_error_depo_impr"
	
    rm -rf "${DIR}/"
    
    rm ""${DIR}"/data."${OPER_ID}""
    

fi


#################### LIMPIEZA ##########################

rm "log_error_depo_impr" ""${DIR}"/data."${OPER_ID}""

rm -rf "${DIR}"

exit 0
