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
# SCRIPT PARA EL VISUALIZADO Y EL CIERRE DE COMISIONES EFECTIVAS

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

function VISTA_COMISION {

    

    
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    cat "./"${temp}"/tmp2.ed" >"./"${temp}"/tmp4.ed"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"


    while true; do

	exec 3>&1
	SOLICITUD=$(dialog \
			--backtitle "" \
			--title """${NOMBRE}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "PAGAR COMISIONES" \
			--menu "TOTAL $"${TOTAL}" -> INICIO : "${INICIO}" FIN: "${FIN}"" 0 0 0 "${foraneos[@]}" \
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
	    $DIALOG_ITEM_HELP)

		dialog --msgbox "RECURDE QUE PARA QUE LOS CAMBIOS TENGAN EFECTO DEFINITIVO DEBERA RECONFIRMAR AL FINAL" 0 0
		muestra_asignaciones
		;;

	esac

	break
	
    done


  
}


function buscar_asignantes {


    declare -r TITULO=$1

    
    
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT rhdID,nombre_rhd FROM "${DB}".RECURSOS_HUMANOS_DISPONIBLES JOIN ("${DB}".RECURSOS_HUMANOS) ON ("${DB}".RECURSOS_HUMANOS_DISPONIBLES.tipo_rhd="${DB}".RECURSOS_HUMANOS.rhID) WHERE tipo_rhd='1' OR tipo_rhd='2' OR tipo_rhd='4';" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"
    
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
			--backtitle "CONTABILIDAD" \
			--title """${TITULO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE UNA OPCION" 0 0 0 "${foraneos[@]}" \
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

	NOMBRE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT nombre_rhd FROM "${DB}".RECURSOS_HUMANOS_DISPONIBLES JOIN ("${DB}".RECURSOS_HUMANOS) ON ("${DB}".RECURSOS_HUMANOS_DISPONIBLES.tipo_rhd="${DB}".RECURSOS_HUMANOS.rhID) WHERE rhdID="${RECURSO}";"  | tail -n +2 | head -1 )"
    
	break
	
    done
}

function buscar_dia {
    declare TITULO=$1
    exec 3>&1
	DIA_ASIGNA=$(dialog \
			--backtitle "CONTABILIDAD" \
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


function muestra_asignaciones {

    declare nom="$(echo ${NOMBRE} | awk '{print $1}')"
    
    mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT VIGENCIA AS 'FECHA',opID AS 'REMITO',DENOMINACION AS 'CLIENTE',ROUND(MONTO,2) AS 'COMISION' FROM COMISIONES JOIN(CLIENTE,OPERACIONES) ON(OPERACIONES.opID=COMISIONES.OPERACION_REF_C AND OPERACIONES.INTERESADO=CLIENTE.clID) WHERE TRABAJADOR="${RECURSO}" AND (VIGENCIA BETWEEN CAST('${INICIO}' AS DATE) AND CAST('${FIN}' AS DATE)) AND MONTO>0 ORDER BY VIGENCIA ASC;" | tr '\t' ';' >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${CARPETA_TRABAJO}"/"${nom}".csv" && dialog --msgbox """SE ENCUENTRA EN LA CARPETA DE DROPBOX EL ARCHIVO "${nom}".csv""" 0 0 
  
    
    echo "UPDATE COMISIONES SET  CANCELACION='${DIA}' WHERE TRABAJADOR="${RECURSO}" AND (VIGENCIA BETWEEN CAST('${INICIO}' AS DATE) AND CAST('${FIN}' AS DATE)) AND CANCELACION IS NULL;" >>${AGMYSQL}
}


#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


AGMYSQL=""${temp}"/"${RANDOM}".grabado"

rm ${AGMYSQL}

test -f "${AGMYSQL}" || touch "${AGMYSQL}"


while true; do

    buscar_dia "SELECCIONE FECHA DE INICIO DE PERIODO"

    INICIO=${DIA_ASIGNA}

    buscar_dia "SELECCIONE FECHA DE FIN DE PERIODO"

    FIN=${DIA_ASIGNA}
    
    dialog --yesno "INICIO : "${INICIO}" FIN: "${FIN}" ES CORRECTA ESTA INFORMACION?" 0 0 && break

done

declare -r CARPETA_TRABAJO="COMISIONES-${INICIO}-${FIN}"

mkdir ""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${CARPETA_TRABAJO}"" || dialog --msgbox "EXISTEN COMISIONES VISUALIZADAS CON EL MISMO PERIODO, SI CONTINUA SE SOBREESCRIBIRAN" 0 0


while true; do

    buscar_asignantes "SELECCIONE A LA PERSONA POR FAVOR"
    mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT VIGENCIA AS 'FECHA',opID AS 'REMITO',DENOMINACION AS 'CLIENTE',ROUND(MONTO,2) AS 'COMISION',IF(CANCELACION IS NULL,'POR PAGAR','CANCELADA') AS 'ESTADO' FROM COMISIONES JOIN(CLIENTE,OPERACIONES) ON(OPERACIONES.opID=COMISIONES.OPERACION_REF_C AND OPERACIONES.INTERESADO=CLIENTE.clID) WHERE TRABAJADOR="${RECURSO}" AND (VIGENCIA BETWEEN CAST('${INICIO}' AS DATE) AND CAST('${FIN}' AS DATE)) AND MONTO>0 ORDER BY VIGENCIA ASC;" | column -t -s $'\t'>"./"${temp}"/tmp2.ed"
    TOTAL="$(mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT ROUND(SUM(MONTO),2) FROM COMISIONES JOIN(CLIENTE,OPERACIONES) ON(OPERACIONES.opID=COMISIONES.OPERACION_REF_C AND OPERACIONES.INTERESADO=CLIENTE.clID) WHERE TRABAJADOR="${RECURSO}" AND (VIGENCIA BETWEEN CAST('${INICIO}' AS DATE) AND CAST('${FIN}' AS DATE)) AND MONTO>0 ORDER BY VIGENCIA ASC;" | tail -n +2 | head -1)"

    VISTA_COMISION
    
    dialog --yesno "SEGUIR VISUALIZANDO COMISIONES ? " 0 0 || break

done




dialog --yesno "APLICAR DEFINITIVAMENTE LOS CAMBIOS PRODUCIDOS ? " 0 0  && (bash ${scr}"transaccion.sh" "${AGMYSQL}" && dialog --msgbox "COMISIONES ASIGNADAS CORRECTAMENTE" 0 0 || dialog --msgbox "OCURRIO UN ERROR" 0 0) || dialog --msgbox "SE CANCELO EL GRABADO DE LAS COMISIONES" 0 0 
    


############### MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
