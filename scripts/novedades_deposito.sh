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
# # SCRIPT para la organizacion y registro de las novedades de trabajo en el deposito

################### MANTENIMIENTO INICIAL #####################


#shopt -s -o unset

################### DECLARACIONES ########################

declare CONTADOR

declare SOLICITUD

declare OPERACION

declare CLASE

declare SIGUIENTE_SOL

declare RECURSO

declare DIA_ASIGNA

declare TIPO_RECURSO

declare ETAPA_UBI

declare ETAPA_ARMADO

declare ETAPA_BULTOS

declare AGMYSQL

################### FUNCIONES ###############################

function busqueda_novedad {

    
    mysql -u "${user}" --password="${pass}" --execute="SELECT opID,DENOMINACION,tipo_oop,DATE_FORMAT(COMIENZO,'%d %b %Y') FROM "${DB}".SOLICITUDES JOIN ("${DB}".CLIENTE,"${DB}".ORDEN_OPERACION,"${DB}".OPERACIONES) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".OPERACIONES.opID="${DB}".SOLICITUDES.REFERENCIA AND "${DB}".ORDEN_OPERACION.oopID="${DB}".SOLICITUDES.CLASE) WHERE ASIGNADA='4' AND REALIZACION IS NULL AND COMIENZO <= CAST('${DIA}' AS DATE) ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.depo"

    
    cat "./"${temp}"/tmp2.depo" | awk '{print $1}' >"./"${temp}"/tmp3.depo"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.depo"

    cat "./"${temp}"/tmp2.depo" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.depo"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.depo"


    while true; do

	exec 3>&1
	OPERACION=$(dialog \
			--backtitle "TAREAS A REALIZAR" \
			--title """${INTERESADO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE LA OPERACION A GESTIONAR" 0 0 0 "${foraneos[@]}" \
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



function escape {


    VAR_s=${temp}"*.depo" 

    rm $VAR_s

 
}


function control_final {


echo "SELECT 'ERROR' FROM BULTOS WHERE NOT EXISTS (SELECT * FROM BULTOS WHERE OPERACION_REF="${OPERACION}") LIMIT 1;" >>${AGMYSQL}

echo "SELECT 'ERROR' FROM LOCALIZACION_PEDIDO WHERE NOT EXISTS (SELECT * FROM LOCALIZACION_PEDIDO WHERE OPERACION_REF="${OPERACION}") LIMIT 1;" >>${AGMYSQL}

echo "SELECT 'ERROR' FROM ARMADO WHERE NOT EXISTS (SELECT * FROM ARMADO WHERE OPERACION_REFERENCIA_AR="${OPERACION}") LIMIT 1;" >>${AGMYSQL}

echo "SELECT COUNT(CANTIDAD_AR) FROM ARMADO WHERE OPERACION_REFERENCIA_AR="${OPERACION}" INTO A;" >>${AGMYSQL}

echo "SELECT COUNT(BULTOS) FROM BULTOS WHERE OPERACION_REF="${OPERACION}" INTO B;" >>${AGMYSQL}

echo "SELECT COUNT(LOCALIZACION) FROM LOCALIZACION_PEDIDO WHERE OPERACION_REF="${OPERACION}" INTO C;" >>${AGMYSQL}

echo  "SELECT A + B + C INTO D;" >>${AGMYSQL}

echo  "IF(D < 3) THEN" >>${AGMYSQL}

echo  "SIGNAL SQLSTATE '45000';" >>${AGMYSQL}


echo  "END IF;" >>${AGMYSQL}


}

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


busqueda_novedad

rm ${temp}"log_errores_nov.depo"

AGMYSQL=""${temp}"/"${OPERACION}".grabado"

bash  ${scr}"arma_pedido.sh" "${OPERACION}" "${AGMYSQL}"



case $? in
    0)

	if test -z ${temp}"log_errores_nov.depo";then
	    dialog --msgbox "OCURRIO UN ERROR LLAMAR A NICO POR FAVOR" 0 0
	    exit 192
	else
	    
	    
	    echo "UPDATE SOLICITUDES SET REALIZACION='${DIA}' WHERE ASIGNADA=4 AND REFERENCIA="${OPERACION}";" >>${AGMYSQL}
	    let SOLICITUD="$(mysql -u "${user}" --password="${pass}" --execute="SELECT scID FROM "${DB}".SOLICITUDES WHERE ASIGNADA=4 AND REFERENCIA="${OPERACION}";" | tail -n +2)"+2
	    echo "UPDATE SOLICITUDES SET COMIENZO='${DIA}' WHERE scID="${SOLICITUD}" AND REFERENCIA="${OPERACION}";">>${AGMYSQL}
	    control_final && bash ${scr}"transaccion.sh" "${AGMYSQL}" && dialog --msgbox "PEDIDO FINALIZADO CORRECTAMENTE" 0 0 || (dialog --infobox "FALTA BRINDAR ALGUNA INFORMACION SOBRE EL PEDIDO, REINICIAR EL ORDENADOR POR FAVOR" 0 0 && sleep 2 && mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";UPDATE PEDIDO SET FLAG=NULL WHERE OPERACION_REFERENCIA="${OPERACION}";")
	    
	fi

	;;

    192)escape
	exit 192;;
esac




################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.depo" 

rm $VAR_s

exit 192
