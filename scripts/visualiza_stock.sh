#!/bin/bash
#
# Script para generear menu de busqueda en funcion del objetivo
#

############## DECLARACIONES ###########################

declare INDICE

declare -r OBJETIVO="PRECIOS"

declare COLUMNA_REFERENCIA

declare VALOR

declare -a BUSQUEDAS

declare CONTADOR

declare VAR

declare VAR_a

declare ACTOR=""${OBJETIVO}""

declare BUSQUEDA

declare -a CAMPOS_BUSQUEDA=("PROOVEDOR" "RUBRO" "CATEGORIA" "MODELO" "CODIGO_PROOVEDOR" "CODIGO_BARRAS")

declare -a REFERENCIAS_BUSQ=("NOMBRE_COMERCIAL" "rubro_rb" "clasificacion_cla" "modelo_md" "CODIGO_PROOVEDOR" "CODIGO_BARRAS")

################# FUNCIONES ############################

function menu {


    declare VAR_PRUEBA
    
    cat "./"${temp}"/tmp.ba" | awk '{print $1}' >"./"${temp}"/tmp3.ba"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ba"

     	
    
    cat "./"${temp}"/tmp.ba"  >"./"${temp}"/tmp4.ba"
    
     
        

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ba"


    while true; do

	exec 3>&1
	BUSQUEDA=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title """CONSULTA STOCK""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "DESCARGAR INFORMACION" \
			--menu "SELECCIONE EL CAMPO DE BUSQUEDA" 0 0 0 "${foraneos[@]}" \
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
		
		mysql -u "${user}" --password="${pass}" --execute="${VAR_A}" | tr '\t' ';' >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
		exit 255;;
	    
	esac

	break
	
    done

    
    
}    


function menu2 {


    declare VAR_PRUEBA
    
    cat "./"${temp}"/tmp.ba" | awk '{print $1}' >"./"${temp}"/tmp3.ba"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ba"

    VAR_PRUEBA=$(cat "./"${temp}"/tmp.ba" | awk '{print $2}')

    if test -z $VAR_PRUEBA; then

	rm "./"${temp}"/tmp4.ba"

	while read line; do
	    
	    echo "<<<<<" >>"./"${temp}"/tmp4.ba"
	    
	done<"./"${temp}"/tmp3.ba"
	
	
    else
	cat "./"${temp}"/tmp.ba" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.ba"
    fi
     
        

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.ba"


    while true; do

	exec 3>&1
	BUSQUEDA=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title """CONSULTA STOCK""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "DESCARGAR INFORMACION" \
			--menu "SELECCIONE EL CAMPO DE BUSQUEDA" 0 0 0 "${foraneos[@]}" \
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
		mysql -u "${user}" --password="${pass}" --execute="${VAR_A}" | tr '\t' ';' >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
		exit 255;;
	    
	esac

	break
	
    done

    
    
}    







###############  SCRIPT ###########################


rm ${temp}"busqueda"


while true;do
    

    CONTADOR=0

    rm > "./"${temp}"/tmp.ba"

    for i in ${CAMPOS_BUSQUEDA[@]};do
	echo "${CONTADOR}    ${i}" >> "./"${temp}"/tmp.ba"
	let CONTADOR+=1
    done
    
    menu

    while true; do
	
	exec 3>&1
	VALOR="$(dialog --inputbox "Ingrese el dato de: "${CAMPOS_BUSQUEDA[${BUSQUEDA}]}"" 0 0 2>&1 1>&3)"
	exec 3>&-
	
	case $? in
	    $DIALOG_CANCEL)
		clear
		
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;

	esac


	VAR_select="precioID,rubro_rb,clasificacion_cla,mod_md,NOMBRE_COMERCIAL,CODIGO_PROOVEDOR,CODIGO_BARRAS"

	VAR_join=""${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO,"${DB}".PROOVEDOR,"${DB}".PRECIOS,"${DB}".ARTICULOS"

	VAR_on=""${DB}".RUBRO.ruID="${DB}".PRECIOS.RUBRO_pr AND "${DB}".CATEGORIA.claID="${DB}".PRECIOS.CATEGORIA_pr AND "${DB}".MODELO.mdID="${DB}".PRECIOS.MODELO_pr AND "${DB}".PROOVEDOR.pooID="${DB}".PRECIOS.PROOVEDOR AND "${DB}".ARTICULOS.RUBRO="${DB}".PRECIOS.RUBRO_pr AND "${DB}".ARTICULOS.CATEGORIA="${DB}".PRECIOS.CATEGORIA_pr AND "${DB}".ARTICULOS.MODELO="${DB}".PRECIOS.MODELO_pr AND "${DB}".ARTICULOS.artID="${DB}".ARMADO.ID_ARTICULO_AR AND "${DB}".ARTICULOS.MOTIVO="${DB}".MOTIVO.mtID"

	VAR_A="USE "${DB}";SELECT artID AS 'CODIGO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',(SUM(IFNULL(CANTIDAD_CST,0)) + SUM(IFNULL(CANTIDAD_ING,0)) + SUM(IFNULL(CANTIDAD_DEVOL,0)) - SUM(IFNULL(CANTIDAD_EGR,0)) - SUM(CANTIDAD_AR)) AS 'CANTIDAD',(SUM(IFNULL(CANTIDAD_CST,0) * CANTIDAD_MINIMA / CANTIDAD_BULTO)+SUM(IFNULL(CANTIDAD_ING,0) * CANTIDAD_MINIMA / CANTIDAD_BULTO) + SUM(IFNULL(CANTIDAD_DEVOL,0) * CANTIDAD_MINIMA / CANTIDAD_BULTO) - SUM(IFNULL(CANTIDAD_EGR,0) * CANTIDAD_MINIMA / CANTIDAD_BULTO) - SUM(CANTIDAD_AR * CANTIDAD_MINIMA / CANTIDAD_BULTO)) AS 'BULTOS' FROM ARMADO JOIN (""${VAR_join}"") ON (""${VAR_on}"") WHERE "${REFERENCIAS_BUSQ[${BUSQUEDA}]}" LIKE '%""${VALOR}""%' GROUP BY artID;"
    
	mysql -u "${user}" --password="${pass}" --execute="${VAR_A}" | column -t -s $'\t'> "./"${temp}"/tmp.ba"
        
	
	
	if test -s "./"${temp}"/tmp.ba"; then
	    break 2
	else
	    dialog --msgbox "No existe articulo que responda al criterio de busqueda" 0 0
	fi
    done

done

    
menu





################### MANTENIMIENTO ########################################

VAR_s=${temp}"*.ba" 

rm $VAR_s

exit 0
