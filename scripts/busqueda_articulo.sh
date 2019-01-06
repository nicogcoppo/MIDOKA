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

declare -a REFERENCIAS_BUSQ=("NOMBRE_COMERCIAL" "rubro_rb" "clasificacion_cla" "mod_md" "CODIGO_PROOVEDOR" "CODIGO_BARRAS")

declare FLAG_CONTROL_ULTIMA_BUSQUEDA="$2"

################# FUNCIONES ############################

function menu {


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
			--title """ACTUALIZADO DE PRECIOS""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
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

		
		exit 255;;
	    
	esac

	break
	
    done

    
    
}    


function dato {

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

    # SI DECIDO ULTIMA BUSQUEDA NI VOY AL MENU
    
    test -z ${FLAG_CONTROL_ULTIMA_BUSQUEDA} && menu

    while true; do

	# SI DECIDO ULTIMA BUSQUEDA NI VOY AL MENU
	
	test -z ${FLAG_CONTROL_ULTIMA_BUSQUEDA} && dato


	VAR_select="precioID,rubro_rb,clasificacion_cla,mod_md,NOMBRE_COMERCIAL,CODIGO_PROOVEDOR,CODIGO_BARRAS"

	VAR_join=""${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".PROOVEDOR"

	VAR_on=""${DB}".RUBRO.ruID="${DB}".PRECIOS.RUBRO_pr AND "${DB}".CATEGORIA.claID="${DB}".PRECIOS.CATEGORIA_pr AND "${DB}".MODELO.mdID="${DB}".PRECIOS.MODELO_pr AND "${DB}".PROOVEDOR.pooID="${DB}".PRECIOS.PROOVEDOR"

	VAR_A="SELECT "${VAR_select}" FROM "${DB}"."${ACTOR}" JOIN (""${VAR_join}"") ON (""${VAR_on}"") WHERE "${REFERENCIAS_BUSQ[${BUSQUEDA}]}" LIKE '%""${VALOR}""%';"

	# GRABO ULTIMA BUSQUEDA SINO ESTA ACTIVADO EL FLAG PARA LLAMARLA
	
	test -z ${FLAG_CONTROL_ULTIMA_BUSQUEDA} && mysql -u "${user}" --password="${pass}" --execute="${VAR_A}" | tail -n +2 > "./"${temp}"/tmp.ba" && echo "${VAR_A}" >${temp}"/ultima_busqueda.cont" || mysql -u "${user}" --password="${pass}" --execute="$(cat "./"${temp}"/ultima_busqueda.cont")" | tail -n +2 > "./"${temp}"/tmp.ba"
        

	if test -s "./"${temp}"/tmp.ba"; then
	    break 2
	else
	    dialog --msgbox "No existe articulo que responda al criterio de busqueda" 0 0
	fi
    done

done

    
menu



echo "${BUSQUEDA}" > "./"${temp}"/busqueda"

rm "./"${temp}"/busqueda_nom"

mysql -u "${user}" --password="${pass}" --execute="SELECT mod_md FROM "${DB}".PRECIOS JOIN ("${DB}".MODELO) ON ("${DB}".MODELO.mdID="${DB}".PRECIOS.MODELO_pr) WHERE precioID='${BUSQUEDA}';" | tail -n +2 > "./"${temp}"/busqueda_nom"

rm "./"${temp}"/busqueda_mod"


VAR_select="ruID,claID,mdID"

VAR_join=""${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".PROOVEDOR"

VAR_on=""${DB}".RUBRO.ruID="${DB}".PRECIOS.RUBRO_pr AND "${DB}".CATEGORIA.claID="${DB}".PRECIOS.CATEGORIA_pr AND "${DB}".MODELO.mdID="${DB}".PRECIOS.MODELO_pr AND "${DB}".PROOVEDOR.pooID="${DB}".PRECIOS.PROOVEDOR"

VAR_A="SELECT "${VAR_select}" FROM "${DB}"."${ACTOR}" JOIN (""${VAR_join}"") ON (""${VAR_on}"") WHERE precioID='${BUSQUEDA}';"

mysql -u "${user}" --password="${pass}" --execute="${VAR_A}" | tail -n +2 > "./"${temp}"/busqueda_mod"


################### MANTENIMIENTO ########################################

VAR_s=${temp}"*.ba" 

rm $VAR_s

exit 0
