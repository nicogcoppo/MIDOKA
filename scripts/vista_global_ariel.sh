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
# # SCRIPT para deposito visualiza de forma global

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
			--backtitle "VISTA GLOBAL DE PEDIDOS" \
			--title """${INTERESADO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE PEDIDO PARA VISUALIZAR" 0 0 0 "${foraneos[@]}" \
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

while true; do
    

    busqueda_novedad

    bash  ${scr}"pedido_en_listado.sh" "${OPERACION}"

    dialog --yesno "DESEAR SEGUIR CHUSMEANDO PEDIDOS ?" 0 0 || break

done






################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.depo" 

rm $VAR_s

exit 192
