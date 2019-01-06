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

declare -r ARCHIVO="$1"

declare TOTAL

declare CONTADOR

declare ENTRADA="9"

declare MONTO

declare -a COMISIONES=("VENTA.fact" "DEPOSITO.fact" "ADMINISTRACION.fact")

declare RECURSO_HUMANO

declare COMISIONA_MARCE=""

declare CARPETA_TRABAJO="${DIA}-${SESION_ID}"


#@@@@@@@@@@@@@@@@@ FUNCIONES @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function facturar_render {

    #enscript -B ""${temp}"tmp3.fact" -p ""${temp}"/"${line}".eps"

    paps --font=Monospace\ 8 ""${temp}"tmp3.fact" >""${temp}"/LISTA-PRECIOS-"${DIA}".eps"
    
       

}


function menu_seleccion_PEDIDO {

    declare VAR

    #TEXTO="$(cat "./"${temp}"/tmp3.fact" | head -1)"

    TEXTO="En los precios emitidos se priorizan los que van a entrar en vigencia por sobre los vigentes"
    
    cat "./"${temp}"/tmp3.fact" | awk '{print $1}' >"./"${temp}"/tmp3.ed"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ed"

    #cat "./"${temp}"/tmp3.fact"  >"./"${temp}"/tmp4.ed"

    #cat "./"${temp}"/tmp3.fact" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ed"

    cat "./"${temp}"/tmp3.fact" >"./"${temp}"/tmp4.ed"
    
    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ed"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title "LISTA DE PRECIOS ""${DIA}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "EMITIR LISTA" \
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
	    paps --font=Monospace\ 11 ""${temp}"tmpr.fact" >""${temp}"/LISTA-PRECIOS-"${DIA}".eps" && gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -sOutputFile=""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/LISTA-PRECIOS-"${DIA}".pdf" ""${temp}"/LISTA-PRECIOS-"${DIA}".eps" && dialog --msgbox "LISTA DE PRECIOS EMITIDA CORRECTAMENTE" 0 0
	    ;;
	esac

	
	break
	
    done
}

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	



echo -e "_____________________________________________________________________________" >${temp}"tmpr.fact"

echo -e "                   LISTA DE PRECIOS   价位表                                 " >>${temp}"tmpr.fact"

echo -e "_____________________________________________________________________________\n\n" >>${temp}"tmpr.fact"

#mysql -u "${user}" --password="${pass}" --execute="SELECT UNO,DOS,CONCAT('  ',TRES),CONCAT('   ',CUATRO),CONCAT('   ',CINCO),CONCAT('    ',SEIS),CONCAT('     ',SIETE) FROM "${DB}".CHINO WHERE chinoID=2;" | tail -n +2 | tr '\t' ',' >${temp}"tmp31.fact"

mysql -u "${user}" --password="${pass}" --execute="SELECT CODIGO_BARRAS AS CODIGO,CONCAT(clasificacion_cla,' ',mod_md,'  ',DESCRIPCION_CHINO) AS DESCRIPCION,ROUND(IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_A,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_B,0)),2) AS 'PRECIO',CANTIDAD_BULTO AS 'PCS/BOX',ROUND(IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_A,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_B,0)) * CANTIDAD_BULTO,2) AS '$/BOX#' FROM "${DB}".ARTICULOS JOIN("${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".CONDICION,"${DB}".PROOVEDOR) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".PROOVEDOR.pooID="${DB}".PRECIOS.PROOVEDOR)  GROUP BY CATEGORIA, MODELO ORDER BY artID ;" | column -t -s $'\t' | sed 's/NULL/CONSULTAR/' >>${temp}"tmpr.fact"



echo -e "\n\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" >>${temp}"tmpr.fact"

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT CONCAT(UNO,'--> ',DOS,' | ',TRES,' | ',CUATRO,'      | ',CINCO,' | ',SEIS) FROM CHINO WHERE chinoID=4;" | tail -n +2 >>${temp}"tmpr.fact"

echo -e "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  \n" >>${temp}"tmpr.fact"


sed -i 's/#$/\n/g' ${temp}"tmpr.fact"

mysql -u "${user}" --password="${pass}" --execute="SELECT CODIGO_BARRAS AS CODIGO,CONCAT(clasificacion_cla,' ',mod_md,'  ',DESCRIPCION_CHINO) AS DESCRIPCION,ROUND(IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_A,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_B,0)),2) AS 'PRECIO',CANTIDAD_BULTO AS 'PCS/BOX',ROUND(IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_A,0),(1 + VALOR_AGREGADO/100) * IFNULL(PRECIO_B,0)) * CANTIDAD_BULTO,2) AS '$/BOX' FROM "${DB}".ARTICULOS JOIN("${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".CONDICION,"${DB}".PROOVEDOR) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".PROOVEDOR.pooID="${DB}".PRECIOS.PROOVEDOR)  GROUP BY CATEGORIA, MODELO ORDER BY artID ;" | column -t -s $'\t' | sed 's/NULL/CONSULTAR/' >${temp}"tmp3.fact"


menu_seleccion_PEDIDO

################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.fact" 

rm $VAR_s

exit 192
