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
# # SCRIPT para el seleccionado de la orden de carga a realizar

################### MANTENIMIENTO INICIAL #####################


#shopt -s -o unset

################### DECLARACIONES ########################

declare CONTADOR

declare VAR

declare seleccion

declare ENTRADA="9"

declare seleccion_comun

declare NOMBRE_DIA

declare -a FLAGS

declare FECHA

declare GESTOR

declare LATID

declare LONG

declare FECHA_CARGA

FLAGS[9]="ENTREGA"

FLAGS[2]="VISITA"

FLAGS[6]="ARMADO"

################### FUNCIONES ###############################

function menu_seleccion_DISTINTIVOS {

    
    
    cat "./"${temp}"/tmp2.dist" | awk '{print $1}' >"./"${temp}"/tmp3.dist"

    ID=()
    NOMBRE_DIA=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}")
	NOMBRE_DIA+=("$(date --date=""${line}"" +%A)") 
        
    done <"./"${temp}"/tmp3.dist"

   

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" "${NOMBRE_DIA[${CONTADOR}]}")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp3.dist"

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
			--menu "SELECCIONE LA ORDEN A GESTIONAR" 0 0 0 "${foraneos[@]}" \
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


function liquidar {

    
mysql -u "${user}" --password="${pass}" --execute="SELECT scID + 1 as ID FROM "${DB}".SOLICITUDES WHERE CLASE="${OPERACION}" AND COMIENZO='${FECHA_CARGA}' AND REALIZACION IS NULL ;" | tail -n +2 >${temp}"actualizado.dist"

mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".SOLICITUDES SET REALIZACION='${DIA}' WHERE CLASE="${OPERACION}" AND COMIENZO='${FECHA_CARGA}' AND REALIZACION IS NULL ;" 

while read line; do

    mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".SOLICITUDES SET COMIENZO='${DIA}' WHERE scID="${line}" ;"

done<${temp}"actualizado.dist"

}
    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

declare -rx REPARTO=${temp}${RANDOM}

mkdir ${REPARTO}


OPERACION=""${ENTRADA}""

# testeoOrden="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (COMIENZO) FROM "${DB}".SOLICITUDES WHERE CLASE="${OPERACION}" AND COMIENZO IS NOT NULL AND REALIZACION IS NULL ORDER BY COMIENZO DESC;" | tail -n +2 | head -1)"



# if test -z "${testeoOrden}"; then
    
   
#     FECHA=$(mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (REALIZACION) FROM "${DB}".SOLICITUDES WHERE CLASE='6' AND REALIZACION IS NOT NULL ORDER BY COMIENZO DESC;" | tail -n +2 | head -1 | column -t -s $'\t')

#     test -z ${FECHA} && exit 1
    
#     FECHA_CARGA=${FECHA}

#     seleccion=${FECHA}

#     echo "$(mysql -u "${user}" --password="${pass}" --execute="SELECT scID + 3 FROM "${DB}".SOLICITUDES WHERE CLASE='6' AND REALIZACION IS NOT NULL ORDER BY COMIENZO DESC;" | tail -n +2)" >${temp}grabarSinOrden

#     sed -i 's/^/UPDATE SOLICITUDES SET COMIENZO=${FECHA_CARGA} WHERE scID=/' ${temp}grabarSinOrden

#     sed -i 's/&/UPDATE SOLICITUDES SET COMIENZO=${FECHA_CARGA} WHERE scID=/' ${temp}grabarSinOrden  
    
#     mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".SOLICITUDES SET COMIENZO='${FECHA_CARGA}' WHERE CLASE="${OPERACION}" AND REALIZACION IS NULL;" || exit 1

# else
    
#     mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (COMIENZO) FROM "${DB}".SOLICITUDES WHERE CLASE="${OPERACION}" AND COMIENZO IS NOT NULL AND REALIZACION IS NULL ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.dist"

#     menu_seleccion_DISTINTIVOS


#     FECHA="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (COMIENZO) FROM "${DB}".SOLICITUDES WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t')"

#     FECHA_CARGA="${seleccion}"
# g
# fi

    
mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (COMIENZO) FROM "${DB}".SOLICITUDES WHERE CLASE="${OPERACION}" AND COMIENZO IS NOT NULL AND REALIZACION IS NULL ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.dist"

menu_seleccion_DISTINTIVOS


FECHA="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (COMIENZO) FROM "${DB}".SOLICITUDES WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t')"

FECHA_CARGA="${seleccion}"


#  # CREACION DE LA ORDEN DE CARGA

    
# echo -e "ORDEN DE CARGA CON FECHA: "${FECHA}" A CARGO DE RODRIGO LATORRE\n\n" >${temp}"tmp2.dist"

# mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION AS CLIENTE,BULTOS,LOCACIONES AS UBICACION FROM "${DB}".SOLICITUDES JOIN("${DB}".CLIENTE,"${DB}".OPERACIONES,"${DB}".BULTOS,"${DB}".LOCALIZACION_PEDIDO,"${DB}".LOCALIDAD,"${DB}".LOCACIONES_DEPOSITO) ON("${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID AND "${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".BULTOS.OPERACION_REF AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".LOCALIZACION_PEDIDO.OPERACION_REF AND "${DB}".LOCALIDAD.lcID="${DB}".CLIENTE.LOCALIDAD AND "${DB}".LOCACIONES_DEPOSITO.locdepID="${DB}".LOCALIZACION_PEDIDO.LOCALIZACION) WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY cp_lc DESC;" | column -t -s $'\t'>>${temp}"tmp2.dist"


# cp ${temp}"tmp2.dist" ${temp}"tmp2b.dist"

# cat ${temp}"tmp2b.dist" | column -t -s $'\t' >${temp}"tmp2.dist"

# sed -i G s/// ${temp}"tmp2.dist" 


# CREACION DE LA HOJA DE RUTA


echo "__________________________________________________________________________________________" >${temp}"tmp3.dist"

echo -e "HOJA DE RUTA CON FECHA: "${FECHA}" A CARGO DE RODRIGO LATORRE\n\n" >${temp}"tmp4.dist"

mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION AS CLIENTE,BULTOS,opID AS REMITO,DIRECCION,estaf_lc AS LOCALIDAD,HORARIO FROM "${DB}".SOLICITUDES JOIN("${DB}".CLIENTE,"${DB}".OPERACIONES,"${DB}".BULTOS,"${DB}".LOCALIZACION_PEDIDO,"${DB}".LOCALIDAD,"${DB}".LOCACIONES_DEPOSITO) ON("${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID AND "${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".BULTOS.OPERACION_REF AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".LOCALIZACION_PEDIDO.OPERACION_REF AND "${DB}".LOCALIDAD.lcID="${DB}".CLIENTE.LOCALIDAD AND "${DB}".LOCACIONES_DEPOSITO.locdepID="${DB}".LOCALIZACION_PEDIDO.LOCALIZACION) WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY cp_lc DESC;" | sed 's/tx2//' | column -t -s $'\t'>>${temp}"tmp4.dist"



#cat ${temp}"tmp3.dist" | column -t -s $'\t' >${temp}"CARGA.dist"



sed -i G s/// ${temp}"tmp4.dist" 



# FECHA="$(cat ${temp}"tmp4.dist")"

# #CONTADOR="$(cat ${temp}"tmp2.dist")"

# echo "${CONTADOR}" >${temp}"CARGA.dist" 


# echo "${FECHA}" >>${temp}"CARGA.dist" 



enscript -B ${temp}"tmp4.dist" -M A4 -p ${REPARTO}"/carga.eps"



# CREACION DEL MAPA DE RUTA

mysql -u "${user}" --password="${pass}" --execute="SELECT LATITUD,LONGITUD FROM "${DB}".SOLICITUDES JOIN("${DB}".CLIENTE,"${DB}".OPERACIONES,"${DB}".BULTOS,"${DB}".LOCALIZACION_PEDIDO,"${DB}".LOCALIDAD,"${DB}".LOCACIONES_DEPOSITO) ON("${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID AND "${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".BULTOS.OPERACION_REF AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".LOCALIZACION_PEDIDO.OPERACION_REF AND "${DB}".LOCALIDAD.lcID="${DB}".CLIENTE.LOCALIDAD AND "${DB}".LOCACIONES_DEPOSITO.locdepID="${DB}".LOCALIZACION_PEDIDO.LOCALIZACION) WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY cp_lc DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.dist"

rm ${temp}"tmp3.dist"

while read line; do

    declare lat

    declare lon

    lat="$(echo "${line}" | awk '{print $1}')"

    lon="$(echo "${line}" | awk '{print $2}')"

    python ${scr}"conversor_UTM.py" "${lat}" "${lon}" | tr ' ' ',' >>${temp}"tmp3.dist"

    
done<${temp}"tmp2.dist"



mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION,DIRECCION,HORARIO FROM "${DB}".SOLICITUDES JOIN("${DB}".CLIENTE,"${DB}".OPERACIONES,"${DB}".BULTOS,"${DB}".LOCALIZACION_PEDIDO,"${DB}".LOCALIDAD,"${DB}".LOCACIONES_DEPOSITO) ON("${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID AND "${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".BULTOS.OPERACION_REF AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".LOCALIZACION_PEDIDO.OPERACION_REF AND "${DB}".LOCALIDAD.lcID="${DB}".CLIENTE.LOCALIDAD AND "${DB}".LOCACIONES_DEPOSITO.locdepID="${DB}".LOCALIZACION_PEDIDO.LOCALIZACION) WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY cp_lc DESC;" | tail -n +2 | tr '\t' '#' | sed 's/^\|$/"/g' >${temp}"tmp4.dist"

paste -d ',' ${temp}"tmp4.dist" ${temp}"tmp3.dist" | sed 's/^/[/g' | sed 's/$/]/g' | tr '\n' ',' | sed 's/.$//' >${temp}"tmp5.dist"

LATID="$(cat ${temp}"tmp3.dist" | tr ',' '\t' | cut -f1 | tr '\n' ',' | sed 's/.$//' | sed 's/^/[/g' | sed 's/$/]/g')"

LONG="$(cat ${temp}"tmp3.dist" | tr ',' '\t' | cut -f2 | tr '\n' ',' | sed 's/.$//' | sed 's/^/[/g' | sed 's/$/]/g')"


rm '$MAPA_MAXIMA.eps'

echo "load(draw);g1:points("${LATID}","${LONG}");etiquetas:label("$(cat ${temp}"tmp5.dist")");draw2d(terminal='eps,file_name="mapa_maxima",dimensions = [2900,2100],color = black,font= "Arial",font_size = 20,etiquetas,xaxis=false,point_size = 4,point_type = 6,g1,border=false,xtics=false,ytics=false,axis_bottom=false,axis_right=false,axis_left=false,axis_top=false,proportional_axes = xy);" >${MAXIMA_DIR}"/ubicacion_mapeo.wxm"

maxima -b ubicacion_mapeo.wxm


cp '$MAPA_MAXIMA.eps' ${REPARTO}"/mapa.eps"

# Verifico la impresion

# while true;do
    
#     dialog --infobox "IMPRIMIENDO ORDEN ." 0 0

#     sleep 1

#     dialog --infobox "IMPRIMIENDO ORDEN . ." 0 0

#     sleep 1

#     dialog --infobox "IMPRIMIENDO ORDEN . . ." 0 0

#     sleep 1
    
#     VAR_BULTOS="$(ls ${imp}${user})"

    
#     if test -z ${VAR_BULTOS}; then
# 	break
#     fi
# done


# Facturacion

mysql -u "${user}" --password="${pass}" --execute="SELECT opID FROM "${DB}".SOLICITUDES JOIN("${DB}".CLIENTE,"${DB}".OPERACIONES,"${DB}".BULTOS,"${DB}".LOCALIZACION_PEDIDO,"${DB}".LOCALIDAD,"${DB}".LOCACIONES_DEPOSITO) ON("${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID AND "${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".BULTOS.OPERACION_REF AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".LOCALIZACION_PEDIDO.OPERACION_REF AND "${DB}".LOCALIDAD.lcID="${DB}".CLIENTE.LOCALIDAD AND "${DB}".LOCACIONES_DEPOSITO.locdepID="${DB}".LOCALIZACION_PEDIDO.LOCALIZACION) WHERE CLASE="${OPERACION}" AND COMIENZO='${seleccion}' AND REALIZACION IS NULL ORDER BY cp_lc DESC;" | tail -n +2 >${temp}"facturar.dist"


bash ${scr}"facturador.sh" ""${temp}"facturar.dist"

case $? in
    255) exit 255;;

esac
	  

while true;do
    
    dialog --infobox "IMPRIMIENDO REMITOS ." 0 0

    sleep 1

    dialog --infobox "IMPRIMIENDO REMITOS . ." 0 0

    sleep 1

    dialog --infobox "IMPRIMIENDO REMITOS . . ." 0 0

    sleep 1
    
    # VAR_BULTOS="$(ls ${imp}${user})"

    
    # if test -z ${VAR_BULTOS}; then
    # 	break
    # fi

    break
    
done


liquidar



################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.dist" 

rm $VAR_s

rm '$MAPA_MAXIMA.eps'

exit 192
