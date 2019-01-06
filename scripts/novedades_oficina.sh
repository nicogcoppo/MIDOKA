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

declare SOLICITUD

declare OPERACION

declare CLASE

declare SIGUIENTE_SOL

declare RECURSO

declare DIA_ASIGNA

declare TIPO_RECURSO
################### FUNCIONES ###############################

function busqueda_novedad {

    
    mysql -u "${user}" --password="${pass}" --execute="SELECT scID,DENOMINACION,tipo_oop,DATE_FORMAT(COMIENZO,'%d %b %Y') FROM "${DB}".SOLICITUDES JOIN ("${DB}".CLIENTE,"${DB}".ORDEN_OPERACION,"${DB}".OPERACIONES) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".OPERACIONES.opID="${DB}".SOLICITUDES.REFERENCIA AND "${DB}".ORDEN_OPERACION.oopID="${DB}".SOLICITUDES.CLASE) WHERE ASIGNADA='5' AND REALIZACION IS NULL AND COMIENZO IS NOT NULL ORDER BY tipo_oop,COMIENZO ASC ;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"

    
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
	SOLICITUD=$(dialog \
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


    mysql -u "${user}" --password="${pass}" --execute="SELECT REFERENCIA,CLASE FROM "${DB}".SOLICITUDES WHERE scID="${SOLICITUD}";" | tail -n +2 >${temp}"tmp5.ed"

    OPERACION=$(cat ${temp}"tmp5.ed" | awk '{print $1}')

    CLASE=$(cat ${temp}"tmp5.ed" | awk '{print $2}')

    let SIGUIENTE_SOL=${SOLICITUD}+1

    TIPO_RECURSO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT tipo_recurso_oop FROM "${DB}".ORDEN_OPERACION WHERE oopID="${CLASE}";" | tail -n +2) 
}


function buscar_asignantes {


    declare -r TITULO=$1

    
    
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT rhdID,nombre_rhd FROM "${DB}".RECURSOS_HUMANOS_DISPONIBLES JOIN ("${DB}".RECURSOS_HUMANOS) ON ("${DB}".RECURSOS_HUMANOS_DISPONIBLES.tipo_rhd="${DB}".RECURSOS_HUMANOS.rhID) WHERE tipo_rhd="${TIPO_RECURSO}" ;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"
    
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
	RECURSO=$(dialog \
			--backtitle "RECURSOS HUMANOS" \
			--title """${TITULO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE EL RECURSO A ASIGNAR LA TAREA" 0 0 0 "${foraneos[@]}" \
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

function buscar_dia {
    declare TITULO=$1
    exec 3>&1
	DIA_ASIGNA=$(dialog \
			--backtitle "RECURSOS HUMANOS" \
			--title """${TITULO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--calendar "SELECCION UTILIZANDO ENTER" 0 0\
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
	reconstruir_fecha "${DIA_ASIGNA}"
}


function reconstruir_fecha {
    declare fecha=$1
    declare -a data_fecha
    CONTADOR=0
    echo ${fecha} | tr '/' '\n' >${temp}"fecha.ed"
    while read line;do
	data_fecha[${CONTADOR}]="${line}"
	let CONTADOR+=1
    done<${temp}"fecha.ed"
    DIA_ASIGNA=""${data_fecha[2]}"-"${data_fecha[1]}"-"${data_fecha[0]}""
}

function completado {

    echo "UPDATE "${DB}".SOLICITUDES SET REALIZACION='${DIA}' WHERE scID="${SOLICITUD}";" >>${AGMYSQL} || exit 1

}

    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


while true; do

    busqueda_novedad

    AGMYSQL=""${temp}"/"${OPERACION}".grabado"

    rm ${AGMYSQL}

    test -f "${AGMYSQL}" || touch "${AGMYSQL}"

    rm ${temp}"log_errores_nov.ed"

    case ${CLASE} in
	1)buscar_asignantes "ORDEN DE VISITA"
	  let MAS_SIGUIENTE_SOL=${SIGUIENTE_SOL}+1
	  buscar_dia "FECHA DE EFECTUACION DE ORDEN DE VISITA"
	  (echo "UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA_ASIGNA}',ASIGNADA="${RECURSO}" WHERE scID="${SIGUIENTE_SOL}";" >>${AGMYSQL} && echo "UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA_ASIGNA}',ASIGNADA='5' WHERE scID="${MAS_SIGUIENTE_SOL}";" >>${AGMYSQL} && completado) || exit 192
	  
	  ;;
	
	3)let ANTERIOR_SOL=${SOLICITUD}-1
	  (echo "UPDATE "${DB}".SOLICITUDES SET REALIZACION='${DIA}' WHERE scID="${ANTERIOR_SOL}";" >>${AGMYSQL} && echo "UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA}' WHERE scID="${SIGUIENTE_SOL}";" >>${AGMYSQL} && completado) || exit 192
	  
	  ;;
	
	4)bash ${scr}"confeccion_pedido.sh" "${OPERACION}" 
	  (echo "UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA}' WHERE scID="${SIGUIENTE_SOL}";" >>${AGMYSQL} && completado) || exit 192
	  
	    
	  ;;

	5)buscar_asignantes "ORDEN DE ARMADO"
	  
	  buscar_dia "FECHA DE EFECTUACION DE ORDEN DE ARMADO"
	  (echo "UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA_ASIGNA}',ASIGNADA="${RECURSO}" WHERE scID="${SIGUIENTE_SOL}";" >>${AGMYSQL} && completado) || exit 192
	  
	  ;;

	8)buscar_asignantes "ORDEN DE ENTREGA"
	  
	  buscar_dia "FECHA DE EFECTUACION DE ORDEN DE ENTREGA"
	  (echo "UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA_ASIGNA}',ASIGNADA="${RECURSO}" WHERE scID="${SIGUIENTE_SOL}";" >>${AGMYSQL} && completado) || exit 192
	  
	  ;;
	10)
	  (echo "UPDATE "${DB}".OPERACIONES SET COMPLETADO='${DIA}' WHERE opID="${OPERACION}";" >>${AGMYSQL} && completado) || exit 192
	    
	    ;;
	14);;
	16);;
    esac

  

   (bash ${scr}"transaccion.sh" "${AGMYSQL}" && dialog --msgbox "NOVEDAD ACTUALIZADA CORRECTAMENTE" 0 0 || dialog --msgbox "OCURRIO UN ERROR EN EL ACTUALIZADO DE LA NOVEDAD" 0 0) || dialog --msgbox "OCURRIO UN ERROR EN EL ACTUALIZADO DE LA NOVEDAD" 0 0 
    

    dialog --yesno "SEGUIR CON OTRA NOVEDAD ?" 0 0 || break

done

################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
