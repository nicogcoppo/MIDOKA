#!/bin/bash
#
# Script para la adecuacion on-line del stock
#

############## DECLARACIONES ###########################

declare -a foraneos

declare -a flag_f

declare CONTADOR

declare VAR

declare -a INDISPENSABLE=("1" "2")

declare -r ACTOR="PRECIOS"

declare CONTADOR

declare SOLICITUD

declare ARTICULO

declare NOMBRE_ARTICULO

declare DIA_ASIGNA

declare PROOVEDOR

declare FECHATIEMPO

declare REMITO

declare ENTRADA_DATOS

declare IDS_DATOS
################# FUNCIONES ############################




function control_estados {
    
    CONTADOR=0
    while read line ; do

	if [ "$line" = ".." ] ; then
	    line="INCOMPLETO"
	fi
    	
	flag_f[${CONTADOR}]="${line}"
	let CONTADOR+=1
	
    done < "./"${temp}"/tmp_num_v.cont"


    CONTADOR=0
    foraneos=()
    while read line ; do


	foraneos+=("${line}" "${flag_f[${CONTADOR}]}")
	let CONTADOR+=1
	
    done < "./"${temp}"/tmp.cont"
}


# La funcion ubicar , escribe en la linea de texto correlativa a la ubicacion en el archivo tmp.cont

function ubicar { # $selection
    
    CONTADOR=$(grep -nr "${1}" "./"${temp}"/tmp.cont" | tr ':' '\t' | awk '{print $1}')

    
    cat ""${temp}"/selection.cont" | tail -n +2 | awk '{print $1}' >""${temp}"/a.cont"

    
    cat ""${temp}"/selection.cont" | tail -n +2 | awk 'BEGIN{FS=OFS="\t"}{$1="";}1' >""${temp}"/b.cont"    

    
    VAR="$(cat ""${temp}"/a.cont")"
    
    awk 'NR=='"${CONTADOR}"'{print "'"${VAR}"'"}1' ""${temp}"/tmp_num.cont" > ""${temp}"/tmp3.cont"
   
    
    mv ""${temp}"/tmp3.cont" ""${temp}"/tmp_num.cont" 

    awk 'NR=='"${CONTADOR}"'{print "'"$(cat ""${temp}"/b.cont")"'"}1' ""${temp}"/tmp_num_v.cont" > ""${temp}"/tmp3.cont"


    mv ""${temp}"/tmp3.cont" ""${temp}"/tmp_num_v.cont"

    let CONTADOR+=1
    
    sed -i -e ''"${CONTADOR}"'d' ""${temp}"/tmp_num.cont" ""${temp}"/tmp_num_v.cont"

    
}

# Controla que se haya ubicado informacion en el archivo de texto, en las lineas
# especificadas en el array

function control_indispensables {  # ARRAY ARCHIVO>archivo.cont

    declare -a array=("$@")
    declare -r archivo=$(cat ""${temp}"archivo.cont")
    declare VAR_A

    echo "NO UTIL"> ""${temp}"/selection.cont"
    
    CONTADOR=0
    for i in ${array[@]};do
	VAR_A=$(sed ''${i}'q;d' ""${temp}""${archivo}"")
	if test -z ${VAR_A} ;then
	    echo -e "1" '\t' "INCOMPLETO" >> ""${temp}"/selection.cont"
	    ubicar "DATOS"
	    return
	fi
	
    done
    echo -e "1" '\t' "COMPLETO" >> ""${temp}"/selection.cont"
    ubicar "DATOS"
}

function grabacion { # SE CONTROLA QUE ESTEN TODOS LOS DATOS COMPLETOS Y SE PROCEDE A CREAR UNA FILA EN MARIADB CON DICHOS DATOS
 
    declare -r ARCHIVO_CONTROL=$1
    
    declare -r DENOMINACION_UNO=$2
    
    declare -r DENOMINACION_DOS=$3

    declare -r DATA_UNO=$4

    declare -r DATA_DOS=$5

    declare DENOMINACION

    declare DATA

    declare VAR
    
    while read line; do
	if [ "$line" = ".." ] ; then
	    return 1
	fi
    done<${temp}${ARCHIVO_CONTROL}
    
    pre_grabar "${DENOMINACION_UNO}" "${DENOMINACION_DOS}" "${DATA_UNO}" "${DATA_DOS}"

    DENOMINACION=$(cat ${temp}"denominaciones_grabado.cont")

    DATA=$(cat ${temp}"data_grabado.cont")

    echo "${DATA}"
    
    rm ${temp}"log_grabado.cont"

    VAR="INSERT INTO "${DB}"."${ACTOR}" ("${DENOMINACION}") VALUES ("${DATA}");"

    mysql -u "${user}" --password="${pass}" --execute="${VAR}"  2>${temp}"log_grabado.cont"
    
    if test -s ${temp}"log_grabado.cont"; then
	DATA=$(cat ${temp}"log_grabado.cont")
        dialog --msgbox "${DATA}" 0 0
        return 2
    else
	dialog --msgbox "Grabacion de Nuevo Articulo Exitosa" 0 0
	return 0
    fi
    

    
}
    

function pre_grabar { # PREPARA LOS INDICADORES Y LOS DATOS A GRABAR. JUNTA LOS ARCHIVOS QUE SEAN NECESARIOS

    declare -r DENOMINACION_UNO=${temp}$1

    declare -r DENOMINACION_DOS=${temp}$2

    declare -r DATA_UNO=${temp}$3

    declare -r DATA_DOS=${temp}$4


    
    
    sed '$d' ${DENOMINACION_UNO} | tr '\n' ','| sed 's/.$//' >${temp}"tmp_denominaciones_grabado.cont"

    echo ",RUBRO_pr,CATEGORIA_pr,MODELO_pr" >>${temp}"tmp_denominaciones_grabado.cont" 

    #cat ${temp}"tmp_denominaciones_grabado.cont" | tr '\n' ',' >${temp}"tmp_denominaciones_grabado3.cont" 
    
    cat ${DENOMINACION_DOS} | tr '\n' ',' | sed 's/.$//' >${temp}"tmp_denominaciones_grabado2.cont"

    paste ${temp}"tmp_denominaciones_grabado.cont" ${temp}"tmp_denominaciones_grabado2.cont" | tr '\t' ',' >${temp}"denominaciones_grabado.cont"
    
  
    sed 's/^\|$/"/g' ${DATA_UNO} | sed '$d' | paste -d, -s >${temp}"tmp_data_grabado.cont"

    sed 's/^\x24/-&/' ${DATA_DOS} | sed 's/^\|$/"/g' | paste -d, -s >${temp}"tmp_data_grabado2.cont"

    echo "${ARTICULO}" >>${temp}"tmp_data_grabado.cont"

    cat ${temp}"tmp_data_grabado.cont" | tr '\n' ',' | sed 's/..$//' > ${temp}"tmp_data_grabado3.cont"
    
    paste ${temp}"tmp_data_grabado3.cont" ${temp}"tmp_data_grabado2.cont" | tr '\t' ',' >${temp}"data_grabado.cont"

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
		
		return
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
    echo ${fecha} | tr '/' '\n' >${temp}"fecha.cont"
    while read line;do
	data_fecha[${CONTADOR}]="${line}"
	let CONTADOR+=1
    done<${temp}"fecha.cont"
    DIA_ASIGNA=""${data_fecha[2]}"-"${data_fecha[1]}"-"${data_fecha[0]}""
}



function menu_seleccion {

    declare VAR
    
    cat "./"${temp}"/temp2.cont" | awk '{print $1}' >"./"${temp}"/temp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/temp3.cont"

    cat "./"${temp}"/temp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/temp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/temp4.cont"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title "SELECCION EL MOTIVO PARA ""${NOMBRE}"" " \
			--clear \
			--cancel-label "SELECCIONAR MODELO" \
			--help-button \
			--help-label "VER DETALLE INGRESO" \
			--menu "SELECCIONE CON ENTER" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		mysql -u "${user}" --password="${pass}" --execute="SELECT mdID,mod_md FROM "${DB}".MODELO WHERE categoria_md="${CATEGORIA}";" | tail -n +2 >${temp}"temp2.cont"
		CATEG="$(mysql -u "${user}" --password="${pass}" --execute="SELECT clasificacion_cla FROM "${DB}".CATEGORIA WHERE claID="${CATEGORIA}";" | tail -n +2 | head -1)"
		menu_seleccion_MODELO 
		return 1
		;;
	    $DIALOG_ESC)
		clear
		limpiado
		exit 204
		;;
	esac

	break

	
	
    done

    

}

function menu_seleccion_MODELO {

    declare VAR
    
    cat "./"${temp}"/temp2.cont" | awk '{print $1}' >"./"${temp}"/temp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/temp3.cont"

    cat "./"${temp}"/temp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/temp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/temp4.cont"

    
    while true; do

	exec 3>&1
	MODELO=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title "SELECCIONE MODELO PARA LA CATEGORIA ""${CATEG}"" " \
			--clear \
			--cancel-label "CANCELAR" \
			--help-button \
			--help-label "AYUDA" \
			--menu "SELECCIONE CON ENTER" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		
		return
		;;
	    $DIALOG_ESC)
		clear
		limpiado
		exit 204
		;;
	esac

	break
	
    done

    

}





function menu_seleccion_fact {

    declare VAR
    
    cat "./"${temp}"/temp2.cont" | awk '{print $1}' >"./"${temp}"/temp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/temp3.cont"

    #cat "./"${temp}"/temp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/temp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/temp2.cont"

    
    while true; do

	exec 3>&1
	seleccion_comun=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title "ADECUACION DE STOCK" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "ELIMINAR ITEM" \
			--menu "PULSE ENTER PARA CONTINUAR" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		return
		;;
	    $DIALOG_ESC)
		clear
		limpiado
		exit 204
		;;
	    $DIALOG_ITEM_HELP)

		menu_eliminacion

		menu_seleccion_fact
    
		return
		
		;;
	esac

	break
	
    done

    

}


function menu_eliminacion {

    declare VAR
    
    cat "./"${temp}"/temp2.cont" | awk '{print $1}' >"./"${temp}"/temp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/temp3.cont"

    #cat "./"${temp}"/temp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/temp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/temp2.cont"

    
    while true; do

	exec 3>&1
	seleccion_elim=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title "MENU ELIMINACION > """ \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "AYUDA" \
			--menu "SELECCIONE ITEM A ELIMINAR" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		return
		
		;;
	    $DIALOG_ESC)
		limpiado
		exit 204
		;;
	    $DIALOG_ITEM_HELP)
		return
		
		;;
	esac

	mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".RECEPCION_CONTABILIDAD WHERE repID="${seleccion_elim}";"

	mostrado_lista
	
	return
	
		
    done

    

}


function mostrado_lista {


    TABLA="RECEPCION_CONTABILIDAD"
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT repID AS ID,CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS DESCRIPCION,CANTIDAD_RE AS CANTIDAD FROM "${DB}"."${TABLA}" JOIN("${DB}".ARTICULOS,"${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MOTIVO.mtID="${DB}".ARTICULOS.MOTIVO AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".ARTICULOS.artID="${DB}"."${TABLA}".ID_ARTICULO_RE);" | column -t -s $'\t'>${temp}"temp2.cont"


}



function limpiado {

    
    VAR_s=${temp}"*.cont" 

    rm $VAR_s

}


function preparado_radio {


    ENTRADA_DATOS=${temp}${RANDOM}

    IDS_DATOS=${temp}${RANDOM}

    rm ${ENTRADA_DATOS}

    rm ${IDS_DATOS}
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT motivo_mt FROM "${DB}".MOTIVO JOIN("${DB}".ARTICULOS) ON("${DB}".ARTICULOS.MOTIVO="${DB}".MOTIVO.mtID) WHERE modelo_mt="${MODELO}";" | tail -n +2 >${ENTRADA_DATOS}

    mysql -u "${user}" --password="${pass}" --execute="SELECT artID FROM "${DB}".MOTIVO JOIN("${DB}".ARTICULOS) ON("${DB}".ARTICULOS.MOTIVO="${DB}".MOTIVO.mtID) WHERE modelo_mt="${MODELO}";" | tail -n +2 >${IDS_DATOS}

    bash ${scr}"radio_mercaderia.sh" "CONTABILIDAD" "INGRESO MERCADERIA" "INGRESE LAS CANTIDADES" "${ENTRADA_DATOS}" "${IDS_DATOS}"
    
}

	
###############  SCRIPT ###########################



DIA=$(date +%F)

INTERESADO="300"




# SE CREA LA OPERACION

declare -r OPERACION="$((mysql -u "${user}" --password="${pass}" --execute="START TRANSACTION;INSERT INTO "${DB}".OPERACIONES (INTERESADO,SOLICITUD,FECHA,COMPLETADO) VALUES ("""${INTERESADO}""",'51','${DIA}','${DIA}');SELECT MAX(opID) FROM "${DB}".OPERACIONES;COMMIT;" | tail -n +2) || (dialog --msgbox "ERROR FATAL" 0 0 && exit 192))"


# SE CREA LA TABLA PARA FACTURAR

mysql -u "${user}" --password="${pass}" --execute="DROP TABLE "${DB}".RECEPCION_CONTABILIDAD ;"

mysql -u "${user}" --password="${pass}" --execute="CREATE TABLE IF NOT EXISTS "${DB}".RECEPCION_CONTABILIDAD (repID INT NOT NULL PRIMARY KEY AUTO_INCREMENT,ID_ARTICULO_RE INT NOT NULL,CANTIDAD_RE INT NOT NULL);"


# INGRESO DE LOS ARTICULSO ASOCIADOS A DICHA OPERACION


while true; do

    while true; do
    
	bash  ${scr}"busqueda_articulo.sh" "PRECIOS" && break

	case $? in
	    255)
		break 2;;
	    0) break;;
	esac
	    
    done
    
    
    case $? in
	0)
	    
	    RUBRO="$(cat ${temp}"busqueda_mod" | cut -f1)"

	    CATEGORIA="$(cat ${temp}"busqueda_mod" | cut -f2)"

	    MODELO="$(cat ${temp}"busqueda_mod" | cut -f3)"

	    NOMBRE="$(cat ${temp}"busqueda_nom")"

	    preparado_radio

	    while true; do
		
						   
		dialog --yesno "CONTINUAR EN LA MISMA CATEGORIA ?" 0 0 || break

		mysql -u "${user}" --password="${pass}" --execute="SELECT mdID,mod_md FROM "${DB}".MODELO WHERE categoria_md="${CATEGORIA}";" | tail -n +2 >${temp}"temp2.cont"
		CATEG="$(mysql -u "${user}" --password="${pass}" --execute="SELECT clasificacion_cla FROM "${DB}".CATEGORIA WHERE claID="${CATEGORIA}";" | tail -n +2 | head -1)"

		menu_seleccion_MODELO

		test -z "${MODELO}" && break
		
		preparado_radio
		#test -z ${CANTIDAD} || mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".RECEPCION_CONTABILIDAD (ID_ARTICULO_RE,CANTIDAD_RE) VALUES ("${ID}","${CANTIDAD}") ;" && dialog --yesno "SEGUIR INGRESANDO UN ARTICULO SIMILAR ?" 0 0 || break

	    done
	    
	    ;;

	255)
	    break;;
    esac
    
    mostrado_lista
    menu_seleccion_fact

done


mysql -u "${user}" --password="${pass}" --execute="SELECT artID,CANTIDAD_RE FROM "${DB}".RECEPCION_CONTABILIDAD JOIN("${DB}".ARTICULOS,"${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MOTIVO.mtID="${DB}".ARTICULOS.MOTIVO AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".ARTICULOS.artID="${DB}".RECEPCION_CONTABILIDAD.ID_ARTICULO_RE);" 2>${temp}"log_errores_nov.cont" | tail -n +2 | tr '\t' ',' >${temp}"tmp5.cont"

while read line; do
    echo "INSERT INTO "${DB}".ARMADO (OPERACION_REFERENCIA_AR,ID_ARTICULO_AR,CANTIDAD_CST,CANTIDAD_AR) VALUES("${OPERACION}","${line}",0);" >>""${temp}"grabar.cont"
done<${temp}"tmp5.cont"

bash ${scr}"transaccion.sh" ""${temp}"grabar.cont" 

case $? in
    0)

	if test -z ${temp}"log_errores_nov.cont";then
	    dialog --msgbox "OCURRIO UN ERROR EN EL PROCESO, POR FAVOR NOTIFICARLO" 0 0
	    
	else
	    dialog --msgbox "OPERACION EXITOSA" 0 0
	    
	fi

	;;
    1) dialog --msgbox "OCURRIO UN ERROR EN EL PROCESO, POR FAVOR NOTIFICARLO" 0 0;;
esac


################### MANTENIMIENTO ########################################


mysql -u "${user}" --password="${pass}" --execute="DROP TABLE "${DB}".RECEPCION_CONTABILIDAD ;"

VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
