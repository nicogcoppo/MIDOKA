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


declare -r DESTINATARIO=$(echo $5 | sed 's/[^0-9]*//g')

declare -a ACTOR=("---" "CLIENTE" "PROOVEDOR")

declare TIPO

declare DIA

declare INTERESADO

declare -a ID

declare CONTADOR

declare SALDO

################### FUNCIONES ###############################

function menu_seleccion {

    declare VAR
    
    cat "./"${temp}"/temp2.cont" | awk '{print $1}' >"./"${temp}"/temp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/temp3.cont"

    cat "./"${temp}"/temp2.cont" >"./"${temp}"/temp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/temp4.cont"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title """${ACTOR[${DESTINATARIO}]}"" : ""${NOMBRE}"" " \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "DESCARGAR INFORMACION" \
			--menu "COMPOSICION : $ ${SALDO} " 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		
		return
		;;
	    $DIALOG_ESC)
		clear
		limpiado
		exit 204
		;;
	    $DIALOG_ITEM_HELP)

		DATA_COMPOSC=""${RANDOM}"-"${DIA}".csv"
		cat "./"${temp}"/temp2RE.cont" | tr '\t' ';' >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
				
		;;
	esac

	break
	
    done

    

}



#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

while true; do

    SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND((SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)),2) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES) ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC);" | tail -n +2)" 

    mysql -u "${user}" --password="${pass}" --execute="SELECT clID AS 'CODIGO',DENOMINACION AS 'CLIENTE',ROUND(SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS),2) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES,"${DB}".CLIENTE) ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC AND "${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO) GROUP BY DENOMINACION HAVING (SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)) >'1' ;" | column -t -s $'\t' >${temp}"temp2.cont"

    mysql -u "${user}" --password="${pass}" --execute="SELECT clID AS 'CODIGO',DENOMINACION AS 'CLIENTE',ROUND(SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS),2) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES,"${DB}".CLIENTE) ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC AND "${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO) GROUP BY DENOMINACION HAVING (SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)) >'1' ;" | tr '.' ',' >${temp}"temp2RE.cont"

    menu_seleccion || break

    INTERESADO="${seleccion_comun}"

    NOMBRE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".CLIENTE WHERE clID="${INTERESADO}" ;" | tail -n +2)"

    mysql -u "${user}" --password="${pass}" --execute="SELECT opID AS OPERACION,FECHA,DEBE,HABER,DEVOLUCION,PERDIDAS AS 'MAL-ESTADO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES)ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${INTERESADO}" ORDER BY FECHA ASC ;" | column -t -s $'\t' >${temp}"temp2.cont"

    echo "COMPOSICION CLIENTE: "${NOMBRE}"" >${temp}"temp2RE.cont"
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT opID AS OPERACION,FECHA,DEBE,HABER,DEVOLUCION,PERDIDAS AS 'MAL-ESTADO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES)ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${INTERESADO}" ORDER BY FECHA ASC ;" | tr '.' ',' >>${temp}"temp2RE.cont"

    SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND((SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)),2) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES)ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${INTERESADO}" GROUP BY INTERESADO ;" | tail -n +2)" 

    menu_seleccion || break

    NOMBRE="COMPOSICION DE SALDOS AL "${DIA}""
    
done


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
