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
# SCRIPT PARA EL CREADO CUALITATIVO DE UN PRODUCTO

################### MANTENIMIENTO INICIAL #####################

rm log_errores


##########################################################



#shopt -s -o unset

################### DECLARACIONES ########################

declare -a seleccion

declare POSICION=0

declare NUEVO

declare -a ORDEN=("RUBRO" "CATEGORIA" "MODELO" "MOTIVO")

declare PREVIO

declare COND

declare ORDENADOR

declare BUSQUEDA

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
			--title "SELECCION DE ""${ORDEN[${POSICION}]}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "NUEVO" \
			--menu "SELECCIONE LA OPCION NUEVO PARA INSERTAR UN NUEVO ""${ORDEN[${POSICION}]}""" 0 0 0 "${foraneos[@]}" \
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
		    nueva_categoria
		    return
	       	fi
		clear
		exit 204
		;;
	    $DIALOG_ITEM_HELP)
		clear
		nueva_categoria

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

	case $POSICION in

	    4)dialog --msgbox "OPERACION REALIZADA SATISFACTORIAMENTE" 0 0 ;;
	esac
	
	

	return 0
    fi
}

function nueva_categoria {

    rm ${temp}"log_errores.ed"
    exec 3>&1
    

    NUEVO=$(dialog \
			--backtitle "ADMINISTRACION" \
			--title "SELECCION DE ""${ORDEN[${POSICION}]}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "AYUDA" \
			--inputbox "INGRESE NUEVO/A ""${ORDEN[${POSICION}]}""" 0 0 2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
	$DIALOG_CANCEL)
	    clear
	    let POSICION+=-1
	    return
	    ;;
	$DIALOG_ESC)
	    clear
	    exit 204
	    ;;
    esac

    rm ${temp}"prueba_estado.ed"

    echo """${NUEVO}""" | sed '/^$/d' >${temp}"prueba_estado.ed"

    if test ! -s ${temp}"prueba_estado.ed"; then
	let POSICION+=-1
	return
    fi

   
    
    VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +3 | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')" 

    mysql -u "${user}" --password="${pass}" --execute="INSERT IGNORE INTO "${DB}"."${ORDEN[${POSICION}]}" ("${VALORES}") VALUES ('""${NUEVO}""','""${seleccion[${PREVIO}]}""');" 2>${temp}"log_errores_borrado.ed"

    verifico_grabacion

    NUEVO="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | head -n +2 | tail -n +2 | awk '{print $1}')"

    seleccion[${POSICION}]="$(mysql -u "${user}" --password="${pass}" --execute="SELECT MAX("${NUEVO}") FROM "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2)"

    
    case ${POSICION} in
	2)
	    novedad_contable;;
	3)
	    POSICION=4;;
    esac

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
	    return
	    ;;
	$DIALOG_ESC)
	    clear
	    exit 204
	    ;;
    esac

}

function limpieza {
    
    VAR_s=${temp}"*.ed" 

    rm $VAR_s

}


function novedad_contable { # Se crea una novedad de producto nuevo en caso de un NUEVO MODELO
    
    declare N_NOVEDAD

    declare N_VALORES
    
    N_NOVEDAD='"'${seleccion[0]}'","'${seleccion[1]}'","'${seleccion[2]}'"'
    
    N_VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}".NUEVO_ARTICULO ;" | tail -n +3 | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"

    rm ${temp}"log_errores.ed"

    mysql -u "${user}" --password="${pass}" --execute="INSERT IGNORE INTO "${DB}".NUEVO_ARTICULO ("${N_VALORES}") VALUES ("${N_NOVEDAD}",'${DIA}',NULL);" 2>${temp}"log_errores_borrado.ed"

    verifico_grabacion

}


    

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


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

	if test "${POSICION}" -eq 1;then

	    busqueda

	    mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}" AND "${ORDENADOR}" LIKE '%""${BUSQUEDA}""%' ORDER BY "${ORDENADOR}" ASC;" | tail -n +2 >"./"${temp}"/tmp2.ed"
	else

	    case ${POSICION} in
		3)mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}" ORDER BY mtID ASC ;" | tail -n +2 >"./"${temp}"/tmp2.ed";;
		*)mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}"."${ORDEN[${POSICION}]}" WHERE "${COND}"="${seleccion[${PREVIO}]}" ORDER BY "${ORDENADOR}" DESC;" | tail -n +2 >"./"${temp}"/tmp2.ed";;
	    esac
	    

	fi
	
	menu_seleccion

    done
    
done


NUEVO=$(echo ${seleccion[@]} | tr ' ' '\n'| sed 's/^\|$/"/g' | tr '\n' ',' | sed 's/.$//')

VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}".ARTICULOS ;" | tail -n +3 | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"

rm ${temp}"log_errores.ed"

mysql -u "${user}" --password="${pass}" --execute="INSERT IGNORE INTO "${DB}".ARTICULOS ("${VALORES}") VALUES ("${NUEVO}");" 2>${temp}"log_errores_borrado.ed"

verifico_grabacion

  

 


################## MANTENIMIENTO FINAL ###################



VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 0


