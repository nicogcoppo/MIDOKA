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

declare ENTRADA=$(echo $5 | sed 's/[^0-9]*//g')

declare seleccion_comun

declare NOMBRE_DIA

declare -a FLAGS

FLAGS[9]="ENTREGA"

FLAGS[2]="VISITA"

FLAGS[6]="ARMADO"

################### FUNCIONES ###############################

function menu_seleccion_DISTINTIVOS {

    
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    NOMBRE_DIA=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}")
	NOMBRE_DIA+=("$(date --date=""${line}"" +%A)") 
        
    done <"./"${temp}"/tmp3.ed"

   

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" "${NOMBRE_DIA[${CONTADOR}]}")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp3.ed"

    INTERESADO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT tipo_oop FROM "${DB}".ORDEN_OPERACION WHERE oopID="${OPERACION}";" | tail -n +2)
    
    while true; do

	exec 3>&1
	seleccion=$(dialog \
			--backtitle "ORDENES VIGENTES" \
			--title """${INTERESADO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE LA ORDEN A DETALLAR" 0 0 0 "${foraneos[@]}" \
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


function menu_seleccion {

    declare VAR
    
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

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "EDICION DE PEDIDOS CONFECCIONADOS" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE UN PEDIDO PARA EDITARLO" 0 0 0 "${foraneos[@]}" \
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


function mostrado {
    mysql -u "${user}" --password="${pass}" --execute="SELECT scID,DENOMINACION FROM "${DB}".SOLICITUDES JOIN ("${DB}".CLIENTE,"${DB}".OPERACIONES) ON ("${DB}".OPERACIONES.opID="${DB}".SOLICITUDES.REFERENCIA AND "${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID) WHERE CLASE="${OPERACION}" AND COMIENZO='"${seleccion}"' AND REALIZACION IS NULL ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"
    
    menu_seleccion
}
    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

bash "./"${scr}"busqueda_tipo.sh" "CLIENTE"

VAR="$(cat ${temp}"busqueda")"

mysql -u "${user}" --password="${pass}" --execute="SELECT opID,DENOMINACION,FECHA FROM "${DB}".OPERACIONES JOIN ("${DB}".SOLICITUDES,"${DB}".CLIENTE) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID) WHERE ("${DB}".SOLICITUDES.CLASE=4 AND "${DB}".SOLICITUDES.REALIZACION IS NOT NULL OR "${DB}".SOLICITUDES.CLASE=6) AND ("${DB}".SOLICITUDES.CLASE=6 AND "${DB}".SOLICITUDES.REALIZACION IS NULL OR "${DB}".SOLICITUDES.CLASE=4) AND INTERESADO="${VAR}" ;" | tail -n +2 | awk '!a[$0]++' >${temp}"tmp2.ed"

menu_seleccion

bash  ${scr}"actualiza_pedido.sh" "${seleccion_comun}"

exit_status=$?

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




################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
