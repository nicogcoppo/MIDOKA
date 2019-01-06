#!/bin/bash
#
#
#
# 
# 
#
# 
#
# 
# 
# Script para visualizado de ordenes ya asignadas historicamente

################### MANTENIMIENTO INICIAL #####################

#shopt -s -o unset

################### DECLARACIONES ########################

declare CONTADOR

declare foraneos

declare ID

declare -r CLASE_EXT=$5


################### FUNCIONES ###############################


function menu_seleccion {

    declare VAR
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    cat "./"${temp}"/tmp2.ed"  >"./"${temp}"/tmp4.ed"

    #cat "./"${temp}"/tmp2.ed" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ed"
    
    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "ORDENES HISTORICAS" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu """${NOMBRE}""" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;
	esac

	
	break
	
    done

    

}



#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT REFERENCIA AS OPERACION,DENOMINACION,CONCAT(COMIENZO,' ',DAYNAME(COMIENZO)) AS ASIGNADA,IFNULL(REALIZACION,'SIN TERMINAR') AS CONCRETADA  FROM SOLICITUDES JOIN(OPERACIONES,CLIENTE) ON(OPERACIONES.opID=SOLICITUDES.REFERENCIA AND OPERACIONES.INTERESADO=CLIENTE.clID) WHERE CLASE="${CLASE_EXT}" AND COMIENZO IS NOT NULL ORDER BY COMIENZO DESC;" | column -t -s $'\t' >${temp}"tmp2.ed"

NOMBRE="$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT tipo_oop FROM ORDEN_OPERACION WHERE oopID="${CLASE_EXT}";" | tail -n +2 | head -1)"

menu_seleccion


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
