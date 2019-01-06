#!/bin/bash
#
# Script para el desplegado del menu de tipo RADIO
#

############## DECLARACIONES ###########################

declare CONTADOR

declare -a foraneos

declare -a ESTADO

declare -a REFERENCIADOR

declare -r FONDO="$1"

declare -r TITULO="$2"

declare -r SUBTITULO="$3"

declare -r ENTRADA="$4"

declare -r SALIDA="$5"

declare -r OPERACION="$6"

declare VAR

################# FUNCIONES ############################

function control_estados { 

    CONTADOR=0
    while read line ; do

	REFERENCIADOR[${CONTADOR}]=""${line}""
	let CONTADOR+=1
	
    done < "./"${temp}"/"${OPERACION}"/REFERENCIA_"${SALIDA}""
  
    
    CONTADOR=0
    while read line ; do

	ESTADO[${CONTADOR}]=""${line}""
	let CONTADOR+=1
	
    done < "./"${temp}"/"${OPERACION}"/VISTA_"${SALIDA}""

    
    CONTADOR=0
    foraneos=()
    while read line ; do
	let VAR=${CONTADOR}+1 
	foraneos+=("""${line}""" ""${VAR}"" "3" """${ESTADO[${CONTADOR}]}""" ""${VAR}"" "30" "30" "100")
	let CONTADOR+=1
	echo "${foraneos[@]}"
    done < "./"${temp}"/"${ENTRADA}""
}



###############  SCRIPT ###########################

# TRES ARCHIVOS >> REFERENCIA_1-1-1 : ID DE LOS MOTIVOS
#               >> 1-1-1 : EL ARCHIVO CONTIENE IDMOTIVO,CANTIDAD LISTO PARA GRABAR EN MARIADB
#               >> VISTA_1-1-1 : CONTIENE LAS CANTIDADES PARA SU VISUALIZACION


control_estados

dialog --backtitle "${FONDO}" --title "${TITULO}" \
       --form "\n${SUBTITULO}" 0 0 0 "${foraneos[@]}" \
       2>"./"${temp}"/"${OPERACION}"/VISTA_"${SALIDA}""


# ESCRITURA DEL ARCHIVO PARA GRABAR

CONTADOR=0
rm "./"${temp}"/"${OPERACION}"/"${SALIDA}""
    while read line ; do

	if test ! -z ""${line}"";then
	    echo ""${REFERENCIADOR[${CONTADOR}]}","${line}"" >>"./"${temp}"/"${OPERACION}"/"${SALIDA}""
	fi
	
	let CONTADOR+=1
	
    done < "./"${temp}"/"${OPERACION}"/VISTA_"${SALIDA}""
  
    

################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.r " 

rm $VAR_s

exit 0
