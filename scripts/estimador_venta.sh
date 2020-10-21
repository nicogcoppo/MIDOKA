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

    TEXTO="ESTADISTICAS DE VENTAS"
    
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
	seleccion_comun=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "ESTIMADOR VENTAS" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "DESCARGAR INFORMACION" \
			--menu """${TEXTO}""" 0 0 0 "${foraneos[@]}" \
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
	    DATA_COMPOSC=""${RANDOM}"-"${DIA}".csv"
	    cat "./"${temp}"/tmp2.ed" | tr '\t' ';' >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
	    ;;
	esac

	
	break
	
    done

    

}




function pedido {

    rm ${temp}"tmp2.ed"
    
    test ! -z "$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'ID',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD FROM PEDIDO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}";" | head -1)" && mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'ID',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD FROM PEDIDO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}";" | column -t -s $'\t'>${temp}"tmp2.ed"


    test ! -z "$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD AS 'PEDIDO',CANTIDAD_AR AS 'ARMADO' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO,PEDIDO) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID  AND PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARMADO.ID_ARTICULO_AR=PEDIDO.ID_ARTICULO) WHERE OPERACIONES.opID="${seleccion_comun}";" | head -1)" &&  mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD AS 'PEDIDO',CANTIDAD_AR AS 'ARMADO' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO,PEDIDO) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID  AND PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARMADO.ID_ARTICULO_AR=PEDIDO.ID_ARTICULO) WHERE OPERACIONES.opID="${seleccion_comun}";" | column -t -s $'\t'>${temp}"tmp2.ed"

    FLAG_FALTANTE=0
    
    test ! -z "$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD AS 'PEDIDO',CANTIDAD_AR AS 'ARMADO',CANTIDAD_FL AS 'FALTANTE' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO,PEDIDO,FALTANTE) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID AND FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARMADO.ID_ARTICULO_AR=FALTANTE.ID_ARTICULO_FL AND ARMADO.ID_ARTICULO_AR=PEDIDO.ID_ARTICULO) WHERE OPERACIONES.opID="${seleccion_comun}";" | head -1)" && ( echo -e "\n################ EN FALTANTE #################" >> ${temp}"tmp2.ed" && mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',CANTIDAD AS 'PEDIDO',CANTIDAD_AR AS 'ARMADO',CANTIDAD_FL AS 'FALTANTE' FROM ARMADO JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO,PEDIDO,FALTANTE) ON (ARMADO.OPERACION_REFERENCIA_AR=OPERACIONES.opID AND ARMADO.ID_ARTICULO_AR=ARTICULOS.artID AND FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND PEDIDO.OPERACION_REFERENCIA=OPERACIONES.opID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARMADO.ID_ARTICULO_AR=FALTANTE.ID_ARTICULO_FL AND ARMADO.ID_ARTICULO_AR=PEDIDO.ID_ARTICULO) WHERE OPERACIONES.opID="${seleccion_comun}";" | column -t -s $'\t'>>${temp}"tmp2.ed" )

    menu_seleccion_PEDIDO
}

function faltante {
    mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT artID,CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt),CANTIDAD_FL FROM FALTANTE JOIN (OPERACIONES,ARTICULOS,CATEGORIA,MODELO,MOTIVO) ON (FALTANTE.OPERACION_REFERENCIA_FL=OPERACIONES.opID AND FALTANTE.ID_ARTICULO_FL=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID) WHERE OPERACIONES.opID="${seleccion_comun}";" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"
    
    menu_seleccion
}


#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT t1.ID,t2.FECHA,DATEDIFF(NOW(),t2.FECHA) AS 'DIAS',t2.DENOMINACION,t2.LOC AS 'LOCALIDAD' FROM (SELECT max(opID) AS 'ID' FROM OPERACIONES GROUP BY INTERESADO) t1 INNER JOIN (SELECT opID AS 'ID',IFNULL(COMPLETADO,FECHA) AS 'FECHA',DENOMINACION,estaf_lc AS 'LOC' FROM OPERACIONES JOIN(CLIENTE,LOCALIDAD) ON (OPERACIONES.INTERESADO=CLIENTE.clID AND CLIENTE.LOCALIDAD=LOCALIDAD.lcID)) t2 ON (t1.ID=t2.ID) ORDER BY DIAS DESC;" | grep -v ELIMINADO |column -t -s $'\t'>${temp}"tmp2.ed"

menu_seleccion_PEDIDO


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
