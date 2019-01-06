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

declare -r DB="MIDOKA_PGC_B"

 
declare -r scr=${DIR}"scripts/"

declare -r arc=${DIR}"archivos/"

declare -r temp=${DIR}"temporales/"${RANDOM}"/" || exit 1 ; cd ${temp} && exit 1 ; mkdir ${temp} || exit 1

declare -r imp=${DIR}"impresion/"

declare -r mail=${DIR}"correo/"

declare -r oper=${DIR}"operaciones/"



declare -r DESTINATARIO="1"

declare -a ACTOR=("---" "CLIENTE" "PROOVEDOR")

declare TIPO

declare DIA

declare INTERESADO

declare -a ID

declare CONTADOR

declare SALDO

declare -r user="root"

declare -r pass=""

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
			--help-label "AYUDA" \
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
	esac

	break
	
    done

    

}



#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT (SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES) ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC);" | tail -n +2)" 

mysql -u "${user}" --password="${pass}" --execute="SELECT clID AS 'CODIGO',DENOMINACION AS 'CLIENTE',(SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)) AS 'SALDO' ,IF((SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS))>1,'PGC_SI','') AS 'FLAG' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES,"${DB}".CLIENTE,"${DB}".LOCALIDAD) ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC AND "${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".CLIENTE.LOCALIDAD="${DB}".LOCALIDAD.lcID)  GROUP BY DENOMINACION ORDER BY COMPLETADO,cp_lc;" | column -t -s $'\t' | grep PGC_SI   

#menu_seleccion || break


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
