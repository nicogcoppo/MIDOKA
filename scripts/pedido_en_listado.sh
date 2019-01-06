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
# SCRIPT PARA LA VISUALIZACION DE LOS PEDIDOS Y FALTANTES 
# EN FORMA DE LISTADO SOLO LECTURA

################### MANTENIMIENTO INICIAL #####################

#shopt -s -o unset

################### DECLARACIONES ########################

declare CONTADOR

declare foraneos

declare ID

# SI NO ES UNA OPERACION QUE NO SEA NADA

test "$1" -eq "$1" && declare LLAMADO_EXTERNO=$1 || declare LLAMADO_EXTERNO=""

################### FUNCIONES ###############################


function menu_seleccion {

    declare VAR
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    cat "./"${temp}"/tmp2.ed"  >"./"${temp}"/tmp4.ed"

    #cat "./"${temp}"/tmp2.ed" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ed"
    
    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "CONTROL DE PEDIDOS : ""${DENOMINACION}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE UN PEDIDO PARA VISUALIZARLO" 0 0 0 "${foraneos[@]}" \
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



function menu_seleccion_PEDIDO {

    declare VAR

    #TEXTO="$(cat "./"${temp}"/tmp2.ed" | head -1)"

    TEXTO="DETALLE PEDIDO CORRESPONDIENTE A LA OPERACION: "${seleccion_comun}", BULTOS --> "${BULTOS}""
    
    cat "./"${temp}"/tmp2.ed" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    #cat "./"${temp}"/tmp2.ed"  >"./"${temp}"/tmp4.ed"

    #cat "./"${temp}"/tmp2.ed" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ed"

    cat "./"${temp}"/tmp2.ed" >"./"${temp}"/tmp4.ed"
    
    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"

    
    while true; do

	exec 3>&1
	seleccion_comun_2=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "CLIENTE ""${DENOMINACION}""" \
			--clear \
			--cancel-label "COTIZAR" \
			--help-button \
			--help-label "DESCARGAR INFORMACION" \
			--menu """${TEXTO}""" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		cotizado
		clear
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;
	    $DIALOG_ITEM_HELP)
	    DATA_COMPOSC=""${RANDOM}"-"${DIA}".csv"
	    cat "./"${temp}"/tmp2.ed" | tr '\t' ';' >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
	    ;;
	esac

	
	break
	
    done

    

}


function cotizado {

     declare COTIZACION=0 && echo "0" >${temp}"tmp6.fact"

     
     mysql -u "${user}" --password="${pass}" --execute="SELECT IF(CONDICION = CONDICION_REFERENCIA AND DESCUENTO_ESPECIAL <> '-',ROUND(ROUND(1 - DESCUENTO_ESPECIAL/100,2) * IF(UMBRAL>0 AND SUM(CANTIDAD)>=UMBRAL,SUM(CANTIDAD) * CANTIDAD_MINIMA - REGALO * CANTIDAD_MINIMA,SUM(CANTIDAD) * CANTIDAD_MINIMA) * IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (PRECIO_B IS NULL),IF(VALOR_AGREGADO >'0',(1 + VALOR_AGREGADO/100) * PRECIO_A,PRECIO_A),IF(VALOR_AGREGADO >'0',(1 + VALOR_AGREGADO/100) * PRECIO_B,PRECIO_B)),2),IF(DESCUENTO_ESPECIFICO > '0',ROUND(ROUND(1 - DESCUENTO_ESPECIFICO/100,2) * IF(UMBRAL>0 AND SUM(CANTIDAD)>=UMBRAL,SUM(CANTIDAD) * CANTIDAD_MINIMA - REGALO * CANTIDAD_MINIMA,SUM(CANTIDAD) * CANTIDAD_MINIMA) * IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (PRECIO_B IS NULL),IF(VALOR_AGREGADO >'0',(1 + VALOR_AGREGADO/100) * PRECIO_A,PRECIO_A),IF(VALOR_AGREGADO >'0',(1 + VALOR_AGREGADO/100) * PRECIO_B,PRECIO_B)),2),ROUND(cond_num_cd * IF(UMBRAL>0 AND SUM(CANTIDAD)>=UMBRAL,SUM(CANTIDAD) * CANTIDAD_MINIMA - REGALO * CANTIDAD_MINIMA,SUM(CANTIDAD) * CANTIDAD_MINIMA) * IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (PRECIO_B IS NULL),IF(VALOR_AGREGADO >'0',(1 + VALOR_AGREGADO/100) * PRECIO_A,PRECIO_A),IF(VALOR_AGREGADO >'0',(1 + VALOR_AGREGADO/100) * PRECIO_B,PRECIO_B)),2))) AS 'SUB-TOTAL#' FROM "${DB}".PEDIDO JOIN("${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".CONDICION,"${DB}".ARTICULOS,"${DB}".CLIENTE,"${DB}".OPERACIONES,"${DB}".PROOVEDOR) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".CONDICION.cdID="${DB}".CLIENTE.CONDICION AND "${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO AND "${DB}".OPERACIONES.opID="${DB}".PEDIDO.OPERACION_REFERENCIA AND "${DB}".PROOVEDOR.pooID="${DB}".PRECIOS.PROOVEDOR) WHERE opID="${seleccion_comun}" GROUP BY CATEGORIA, MODELO ;" | tail -n +2 >${temp}"tmp6.fact"    
  
   while read line_b; do
       COTIZACION="$(maxima --very-quiet --batch-string "fpprintprec:7$"${COTIZACION}"+"${line_b}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"
       
   done<${temp}"tmp6.fact"


   dialog --msgbox "MONTO ESTIMADO :    $ "$(echo ${COTIZACION} | head -1 | awk '{print $1}')"" 0 0

}

function pedido {

    BULTOS=$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT BULTOS FROM BULTOS WHERE OPERACION_REF="${seleccion_comun}";" | tail -n +2)
    
    rm ${temp}"tmp2.ed"
    
    test ! -z "$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'ID',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD FROM PEDIDO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}";" | head -1)" && mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'ID',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD FROM PEDIDO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}" ORDER BY CATEGORIA,MODELO,MOTIVO;" | column -t -s $'\t'>${temp}"tmp2.ed"


    test ! -z "$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD AS 'PEDIDO',CANTIDAD_AR AS 'ARMADO' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO,PEDIDO) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID  AND PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARMADO.ID_ARTICULO_AR=PEDIDO.ID_ARTICULO) WHERE OPERACIONES.opID="${seleccion_comun}";" | head -1)" &&  mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD AS 'PEDIDO',CANTIDAD_AR AS 'ARMADO' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO,PEDIDO) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID  AND PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARMADO.ID_ARTICULO_AR=PEDIDO.ID_ARTICULO) WHERE OPERACIONES.opID="${seleccion_comun}" ORDER BY CATEGORIA,MODELO,MOTIVO;" | column -t -s $'\t'>${temp}"tmp2.ed"

    FLAG_FALTANTE=0
    
    test ! -z "$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD_FL AS 'FALTANTE' FROM FALTANTE JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND FALTANTE.ID_ARTICULO_FL=ARTICULOS.artID AND FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}" ORDER BY CATEGORIA,MODELO,MOTIVO;" | head -1)" && ( echo -e "\n################ EN FALTANTE #################" >> ${temp}"tmp2.ed" && mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD_FL AS 'FALTANTE' FROM FALTANTE JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND FALTANTE.ID_ARTICULO_FL=ARTICULOS.artID AND FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}" ORDER BY CATEGORIA,MODELO,MOTIVO;" | column -t -s $'\t'>>${temp}"tmp2.ed" )

    menu_seleccion_PEDIDO
}

function faltante {
    mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID,CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt),CANTIDAD_FL FROM FALTANTE JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND FALTANTE.ID_ARTICULO_FL=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}";" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"
    
    menu_seleccion
}


#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

test -z "${LLAMADO_EXTERNO}" && bash "./"${scr}"busqueda_tipo.sh" "CLIENTE"

VAR="$(cat ${temp}"busqueda")"


DENOMINACION="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".CLIENTE WHERE clID="${VAR}";" | tail -n +2 | head -1)"
 
while true; do

    mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT(opID) AS 'REMITO',DENOMINACION AS 'CLIENTE',FECHA FROM "${DB}".OPERACIONES JOIN ("${DB}".SOLICITUDES,"${DB}".CLIENTE) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".SOLICITUDES.REFERENCIA="${DB}".OPERACIONES.opID) WHERE ("${DB}".SOLICITUDES.CLASE=4 AND REALIZACION IS NOT NULL AND INTERESADO="${VAR}") OR (SOLICITUD='46' AND INTERESADO="${VAR}") ORDER BY FECHA DESC;" | column -t -s $'\t' >${temp}"tmp2.ed"

    # SI SE LO LLAMA EXTERIORMENTE NO SE SELECCIONA CLIENTE
    
    test -z "${LLAMADO_EXTERNO}" && menu_seleccion

    test ! -z "${LLAMADO_EXTERNO}" && seleccion_comun=${LLAMADO_EXTERNO} 
    
    pedido
    
    dialog --yesno "DESEA SALIR ? " 0 0 && break

done



################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
