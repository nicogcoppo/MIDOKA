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
			--help-label "AYUDA" \
			--menu "SALDO ACTUAL: $ ${SALDO} " 0 0 0 "${foraneos[@]}" \
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
		#limpiado
		exit 204
		;;
	esac

	break
	
    done

    

}



#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

bash  "./"${scr}"busqueda_tipo.sh" ""${ACTOR[${DESTINATARIO}]}"" || exit 192



#rm ${temp}"log_errores.cont"


INTERESADO=$(cat ${temp}"busqueda" | head -1)



# VEO SI ES PROOVEDOR O CLIENTE

case ${DESTINATARIO} in
    1)

	NOMBRE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".CLIENTE WHERE clID="${INTERESADO}" ;" | tail -n +2)"
	
	mysql -u "${user}" --password="${pass}" --execute="SELECT opID AS OPERACION,FECHA,DEBE,HABER,DEVOLUCION,PERDIDAS AS 'MAL-ESTADO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES)ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${INTERESADO}" ORDER BY FECHA ASC ;" | column -t -s $'\t' >${temp}"temp2.cont" 

	SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND(SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS),2) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES) ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${INTERESADO}" GROUP BY INTERESADO ;" | tail -n +2)" 
	
	menu_seleccion

	;;
    2)

	while true; do
	    
	    NOMBRE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT NOMBRE_COMERCIAL FROM "${DB}".PROOVEDOR WHERE pooID="${INTERESADO}" ;" | tail -n +2)"
	    
	    mysql -u "${user}" --password="${pass}" --execute="SELECT OPERACION_ASOCIADA AS ID,REFERENCIA AS OPERACION,FECHA,DEBE,HABER FROM "${DB}".SALDO_PROOVEDOR WHERE PROOVEDOR="${INTERESADO}" ORDER BY FECHA DESC ;" | column -t -s $'\t' >${temp}"temp2.cont" 
	    
	    SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND((SUM(DEBE) - SUM(HABER)),2) AS 'SALDO' FROM "${DB}".SALDO_PROOVEDOR  WHERE PROOVEDOR="${INTERESADO}" GROUP BY PROOVEDOR ;" | tail -n +2)" 
	    
	    menu_seleccion

	    mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD_ING AS 'CANTIDAD FACTURADA' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID)  WHERE OPERACIONES.opID="${seleccion_comun}";" | column -t -s $'\t' >${temp}"temp2.cont"

	    SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND(DEBE,2) AS 'SALDO' FROM "${DB}".SALDO_PROOVEDOR  WHERE PROOVEDOR="${INTERESADO}" AND OPERACION_ASOCIADA="${seleccion_comun}";" | tail -n +2)" 
	    
	    menu_seleccion

	    dialog --yesno "SEGUIR CON EL MISMO PROVEEDOR ?" 0 0 || break
	done
									  
	;;
esac





################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
