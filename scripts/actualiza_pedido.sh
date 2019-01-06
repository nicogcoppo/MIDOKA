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
# SCRIPT PARA EL CONFECCIONADO DE UN PEDIDO

################### MANTENIMIENTO INICIAL #####################

rm log_errores


##########################################################



#shopt -s -o unset

################### DECLARACIONES ########################


declare -r OPERACION=$1

declare CLIENTE


declare -a seleccion

declare POSICION=0

declare NUEVO

declare -a ORDEN=("RUBRO" "CATEGORIA" "MODELO" "MOTIVO")

declare PREVIO

declare COND

declare ORDENADOR

declare BUSQUEDA

declare seleccion

declare ARCHIVO

declare MOTIVO

declare INSERT


################### FUNCIONES ###############################

function menu_seleccion {

    declare VAR

    declare VALORES

    declare NUEVO
    
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
	seleccion[${POSICION}]=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "CONFECCION DEL PEDIDO DEL CLIENTE: ""${CLIENTE}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCION DE ""${ORDEN[${POSICION}]}""" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		let POSICION+=-1
		return
		;;
	    $DIALOG_ESC)
		if test ! -s "./"${temp}"/tmp2.ed"; then
		    dialog --msgbox "NO EXISTE NINGUNA CATEGORIA CON ESA DESCRIPCION" 0 0
		    let POSICION+=-1
		    return
	       	fi
		clear
		limpieza
		exit 204
		;;
	    $DIALOG_ITEM_HELP)
		POSICION=4
		return
		;;
	esac
	
	let POSICION+=1
        break
    done

    

}


function verifico_grabacion {
    
    if test -s ${temp}"log_errores_borrado.ed"; then
	DATA=$(cat ${temp}"log_errores_borrado.ed")
        dialog --msgbox "${DATA}" 0 0
	let POSICION+=-1
        return 2
    else
	dialog --msgbox "OPERACION REALIZADA SATISFACTORIAMENTE" 0 0
	return 0
    fi
}

function busqueda {
    exec 3>&1
    
    
    BUSQUEDA=$(dialog \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "AYUDA" \
			--inputbox " BUSQUEDA ""${ORDEN[${POSICION}]}""" 0 0 2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
	$DIALOG_CANCEL)
	    clear
	    let POSICION+=-1
	    return 192
	    ;;
	$DIALOG_ESC)
	    clear
	    limpieza
	    exit 204
	    ;;
    esac

}


function ubicar { # $selection

    declare REF=$1
    
    declare CANT_MT=$2

    declare INSERTO=$3
    
    CONTADOR=$(grep -nr "${REF}" "./"${temp}"/motivos.ed" | head -1 | tr ':' '\t' | awk '{print $1}')

    
    awk 'NR=='"${CONTADOR}"'{print "'"${INSERTO}"'"}1' ""${temp}""${OPERACION}"/VISTA_"${CANT_MT}"" > ""${temp}"/tmp3.ed"

    
    mv ""${temp}"/tmp3.ed" ""${temp}""${OPERACION}"/VISTA_"${CANT_MT}""


    let CONTADOR+=1
    
    sed -i -e ''"${CONTADOR}"'d' ""${temp}""${OPERACION}"/VISTA_"${CANT_MT}"" 

    
}

function limpieza {
      
    rm -rf ${temp}"${OPERACION}"

    VAR_s=${temp}"*.ed" 

    rm $VAR_s

}

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

CLIENTE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO) WHERE opID="${OPERACION}";" | tail -n +2)"

rm -rf ${temp}"${OPERACION}"

mkdir ${temp}"${OPERACION}"


mysql -u "${user}" --password="${pass}" --execute="SELECT RUBRO,CATEGORIA,MODELO,MOTIVO,CANTIDAD FROM "${DB}".PEDIDO JOIN ("${DB}".ARTICULOS) ON ("${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}";" | tail -n +2 >${temp}"desglose_pedido.ed"


while read line ; do

    
    ARCHIVO="$(echo """${line}""" | cut -f1-3 | tr '\t' '-')"

    seleccion="$(echo """${line}""" | cut -f3 )"
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT mtID FROM "${DB}".MOTIVO WHERE modelo_mt="${seleccion}";"| tail -n +2 >""${temp}"motivos.ed"

    MOTIVO="$(echo """${line}""" | cut -f4 )"

    INSERT="$(echo """${line}""" | cut -f5 )"
    
    if test ! -f ""${temp}""${OPERACION}"/VISTA_"${ARCHIVO}"" ;then
	while read linez;do
	    echo " " >> ""${temp}""${OPERACION}"/VISTA_"${ARCHIVO}""
	done <""${temp}"motivos.ed"
    fi

    ubicar "${MOTIVO}" "${ARCHIVO}" "${INSERT}"
    
    echo """${line}""" | cut -f4-5 | tr '\t' ',' >>""${temp}""${OPERACION}"/"${ARCHIVO}""
    
done <${temp}"desglose_pedido.ed"



while [ "${POSICION}" -lt "${#ORDEN[@]}" ];do

    POSICION=0
    VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2 | sed '$d' | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"
    ORDENADOR="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +3 | head -1 | awk '{print $1}')"
    mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" ORDER BY "${ORDENADOR}" ASC;" | tail -n +2 >"./"${temp}"/tmp2.ed"
    menu_seleccion

    if test ${POSICION} -lt 0;then
	limpieza
	exit 192
    fi


    
    while [ "${POSICION}" -lt "${#ORDEN[@]}" -a "${POSICION}" -ne 0 ];do

	let PREVIO=${POSICION}-1
	VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2 | sed '$d' | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"
	COND="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n -1 | awk '{print $1}')" 
	ORDENADOR="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +3 | head -1 | awk '{print $1}')"

	case "${POSICION}" in
	    1)
		busqueda
		case $? in
		    192) break;;
		esac
		
		mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}" AND "${ORDENADOR}" LIKE '%""${BUSQUEDA}""%' ORDER BY "${ORDENADOR}" ASC;" | tail -n +2 >"./"${temp}"/tmp2.ed"
	        menu_seleccion;;
	    
	    3)
		VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +3 | sed '$d' | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"
		mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}";"| tail -n +2 >"./"${temp}"/tmp2.ed"

		NUEVO=$(echo ${seleccion[@]} | tr ' ' '\n'|tr '\n' '-' | sed 's/.$//')

		mysql -u "${user}" --password="${pass}" --execute="SELECT mtID FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}";"| tail -n +2 >""${temp}""${OPERACION}"/REFERENCIA_"${NUEVO}""
     
		PRODUCTO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (mod_md) FROM "${DB}".ARTICULOS JOIN ("${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO) ON ("${DB}".RUBRO.ruID="${DB}".ARTICULOS.RUBRO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO) WHERE RUBRO="${seleccion[0]}" AND CATEGORIA="${seleccion[1]}" AND MODELO="${seleccion[2]}";" | tail -n +2)" 


		
		bash ${scr}"radio_std_pedido.sh" "ADMINISTRACION" "CONFECCION DEL PEDIDO DEL CLIENTE : '${CLIENTE}'" "UNIDADES DE '${PRODUCTO}'" "tmp2.ed" ""${NUEVO}"" ""${OPERACION}""

	        let POSICION+=-1
		;;
      
	    
	    *)
		mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}" ORDER BY "${ORDENADOR}" ASC;" | tail -n +2 >"./"${temp}"/tmp2.ed"
		menu_seleccion;;
	esac
	
	

    done
    
done

case $? in
    0)

	mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".PEDIDO WHERE OPERACION_REFERENCIA="${OPERACION}";"

	ls ""${temp}""${OPERACION}"" | tr '\t' ',' | grep -e '^[0-9]' >""${temp}"pedido_listo.ed"


	while read line ; do

	    echo ""${line}"" | tr '-' '\n' >""${temp}"articulo_listo.ed" 

	    cat ""${temp}""${OPERACION}"/"${line}"" | tr ',' '\t' >""${temp}"articulo_listo_cantidad.ed"

	    CONTADOR=0
	    while read linea ; do
		while read lineb ; do
		
		    seleccion[${CONTADOR}]=""${lineb}""
		    let CONTADOR+=1
		
		done <""${temp}"articulo_listo.ed"

		 seleccion[${CONTADOR}]="$(echo ""${linea}"" | awk '{print $1}')" 

		 let CONTADOR+=1

		 seleccion[${CONTADOR}]="$(echo ""${linea}"" | awk '{print $2}')" 

		 ID="$(mysql -u "${user}" --password="${pass}" --execute="SELECT artID FROM "${DB}".ARTICULOS WHERE RUBRO="${seleccion[0]}"  AND CATEGORIA="${seleccion[1]}" AND MODELO="${seleccion[2]}" AND MOTIVO="${seleccion[3]}" ;" | tail -n +2)"

		 mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".PEDIDO (OPERACION_REFERENCIA,ID_ARTICULO,CANTIDAD) VALUES ('${OPERACION}','${ID}','${seleccion[4]}');" 

		 CONTADOR=0
		 
	    done <""${temp}"articulo_listo_cantidad.ed"
	    
	    
	    
	done <""${temp}"pedido_listo.ed"

	;;
    *)  limpieza
	exit 255;;
esac

  
rm -rf ${temp}"${OPERACION}"
 


################## MANTENIMIENTO FINAL ###################



VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192

