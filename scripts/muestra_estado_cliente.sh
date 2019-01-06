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
# # SCRIPT para el grabado en tabla de las operaciones de PEDIDO DIRECTO Y SOLICITUD DE VISITA principalmente
# que originan las ordenes de trabajo

################### MANTENIMIENTO INICIAL #####################


#shopt -s -o unset

################### DECLARACIONES ########################

declare CONTADOR

declare VAR

declare seleccion

################### FUNCIONES ###############################

function menu_seleccion {

    
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    cat "./"${temp}"/tmp2.ed" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ed"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"

    INTERESADO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".CLIENTE WHERE clID="${VAR}";" | tail -n +2)
    
    while true; do

	exec 3>&1
	seleccion=$(dialog \
			--backtitle "ESTADO DE SITUACION DE CLIENTE" \
			--title """${INTERESADO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE LA OPERACION A DETALLAR" 0 0 0 "${foraneos[@]}" \
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


bash ${scr}"busqueda_tipo.sh" "CLIENTE"

VAR=$(cat ${temp}"busqueda")

mysql -u "${user}" --password="${pass}" --execute="SELECT opID,DENOMINACION,nombre_nm,FECHA,IF(COMPLETADO IS NOT NULL,'COMPLETADA','INCOMPLETA') FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE,"${DB}".NOMBRE_MENU) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".NOMBRE_MENU.nmID="${DB}".OPERACIONES.SOLICITUD) WHERE INTERESADO="${VAR}" AND FECHA IS NOT NULL ORDER BY FECHA DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"
	    
menu_seleccion

mysql -u "${user}" --password="${pass}" --execute="SELECT scID AS ID,tipo_oop AS TAREA,nombre_rhd AS NOMBRE,COMIENZO,REALIZACION FROM "${DB}".SOLICITUDES JOIN ("${DB}".ORDEN_OPERACION,"${DB}".RECURSOS_HUMANOS_DISPONIBLES) ON ("${DB}".ORDEN_OPERACION.oopID="${DB}".SOLICITUDES.CLASE AND "${DB}".SOLICITUDES.ASIGNADA="${DB}".RECURSOS_HUMANOS_DISPONIBLES.rhdID) WHERE REFERENCIA="${seleccion}" ORDER BY scID ASC;" | column -t -s $'\t'>${temp}"tmp2.ed"

menu_seleccion


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
