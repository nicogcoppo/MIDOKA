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

declare -r AGMYSQL=$2

declare CLIENTE

declare DIRECTORIO=""${oper}"/deposito/"${OPERACION}"-DEPO"

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

declare ETAPA_BULTOS

declare ETAPA_UBI

declare ETAPA_COMPLETADO

################### FUNCIONES ###############################

function menu_seleccion {

    declare VAR

    declare VALORES

    declare NUEVO
    
    cat "./"${temp}"/tmp2.depo" | awk '{print $1}' >"./"${temp}"/tmp3.depo"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.depo"


    cat "./"${temp}"/tmp2.depo" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.depo"

    

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.depo"

    
    while true; do

	exec 3>&1
	seleccion[${POSICION}]=$(dialog \
			--backtitle "DEPOSITO" \
			--title "ARMADO DEL PEDIDO DEL CLIENTE: ""${CLIENTE}""" \
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
		if test ! -s "./"${temp}"/tmp2.depo"; then



		    control_pedido_finalizado

		    case $? in
			0)POSICION=4
			  return;;
		    esac

		    


		    
		    let POSICION+=-1

		    return
	       	fi
		clear
		limpieza
		exit 204
		;;
	    $DIALOG_ITEM_HELP)

		control_pedido_finalizado

		case $? in
		    0)POSICION=4
		      return;;
		esac

		

		let POSICION+=-1

		return
		;;
	esac

	LOCACION_FINAL="${seleccion[${POSICION}]}"
	
	let POSICION+=1
	
        break
    done

    

}


function verifico_grabacion {
    
    if test -s ${temp}"log_errores_borrado.depo"; then
	DATA=$(cat ${temp}"log_errores_borrado.depo")
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
    
    CONTADOR=$(grep -nr "${REF}" "./"${temp}"/motivos.depo" | tr ':' '\t' | awk '{print $1}' | head -1)

    
    awk 'NR=='"${CONTADOR}"'{print "'"${INSERTO}"'"}1' ""${DIRECTORIO}"/VISTA_"${CANT_MT}"" > ""${temp}"/tmp3.depo"

    
    mv ""${temp}"/tmp3.depo" ""${DIRECTORIO}"/VISTA_"${CANT_MT}""


    let CONTADOR+=1
    
    sed -i -e ''"${CONTADOR}"'d' ""${DIRECTORIO}"/VISTA_"${CANT_MT}"" 

    
}

function limpieza {
      
    #rm -rf "${DIRECTORIO}"

    VAR_s=${temp}"*.depo" 

    rm $VAR_s

}


function control_pedido_finalizado {

    cat ${temp}"desglose_pedido.depo"  | awk '!seen[$0]++' | cut -f1-3 | tr '\t' '-' >${temp}"desglose_pedido_control.depo"

    while read control;do

	if test ! -f ""${DIRECTORIO}"/"${control}"" ;then

	    return 192
	fi
    done <${temp}"desglose_pedido_control.depo"
}


function ubicar_pedido {

    ORDEN[${POSICION}]="LA UBICACION FINAL DEL PEDIDO EN EL DEPOSITO"
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT locdepID,LOCACIONES FROM "${DB}".LOCACIONES_DEPOSITO;" | tail -n +2 >"./"${temp}"/tmp2.depo"

    menu_seleccion

    echo "INSERT INTO LOCALIZACION_PEDIDO (OPERACION_REF,LOCALIZACION) VALUES ('"${OPERACION}"','"${LOCACION_FINAL}"');" >>${AGMYSQL}

}

function bultos_pedido {

    declare BULTOS

    declare BULTOS_2

    while true; do
	
	ORDEN[${POSICION}]="LA CANTIDAD DE BULTOS FINAL DEL PEDIDO"

	exec 3>&1
	
	
	BULTOS=$(dialog \
		     --clear \
		     --cancel-label "SALIR" \
		     --help-button \
		     --help-label "AYUDA" \
		     --inputbox " INGRESE ""${ORDEN[${POSICION}]}""" 0 0 2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	
	
	ORDEN[${POSICION}]="CONFIRME LA CANTIDAD DE BULTOS FINAL DEL PEDIDO POR FAVOR"

	exec 3>&1
	
	
	BULTOS_2=$(dialog \
		     --clear \
		     --cancel-label "SALIR" \
		     --help-button \
		     --help-label "AYUDA" \
		     --inputbox " INGRESE ""${ORDEN[${POSICION}]}""" 0 0 2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	
	
	(test "${BULTOS}" -eq "${BULTOS_2}" && test "${BULTOS}" -ne "0" ) && break || dialog --msgbox "LA CANTIDAD DE BULTOS ES INVALIDA O NO COINCIDENTE" 0 0

    done
    

    echo "INSERT INTO "${DB}".BULTOS (OPERACION_REF,BULTOS) VALUES ('"${OPERACION}"','"${BULTOS}"');" >>${AGMYSQL} 
	   
	
}


function impreso_control {

    declare BULTOS

    declare VAR_BULTOS
    
    while true; do

	
	ORDEN[${POSICION}]="CONFIRME POR FAVOR LA CANTIDAD DE BULTOS FINAL DEL PEDIDO"

	exec 3>&1
	
	
	BULTOS=$(dialog \
		     --clear \
		     --cancel-label "SALIR" \
		     --help-button \
		     --help-label "AYUDA" \
		     --inputbox " ""${ORDEN[${POSICION}]}""" 0 0 2>&1 1>&3)
	exit_status=$?
	exec 3>&-

	VAR_BULTOS="$(mysql -u "${user}" --password="${pass}" --execute="SELECT BULTOS FROM "${DB}".BULTOS WHERE OPERACION_REF="${OPERACION}" ;" | tail -n +2)"

	if test "${BULTOS}" -eq "${VAR_BULTOS}"; then
	    rm ${temp}"error_bultos.depo"
	else
	    rm ${temp}"error_bultos.depo"
	    mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".BULTOS SET BULTOS="${BULTOS}" WHERE OPERACION_REF="${OPERACION}";" 2>${temp}"error_bultos.depo"
	fi
	
	    
	
	VAR_BULTOS="$(cat ${temp}"error_bultos.depo")"

	if test -z ${VAR_BULTOS}; then
	    break
	else
	    dialog --msgbox "LA CANTIDAD NO ES VALIDA" 0 0 
	fi
    done

    # IMPRESION ORDEN


    mysql -u "${user}" --password="${pass}" --execute="SELECT opID AS REMITO,DENOMINACION AS CLIENTE FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE,"${DB}".BULTOS) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".BULTOS.OPERACION_REF="${DB}".OPERACIONES.opID) WHERE opID="${OPERACION}";" | column -t -s $'\t'>${temp}"etiqueta.depo"

    echo -e "\n" >>${temp}"etiqueta.depo"
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT DIRECCION FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE,"${DB}".BULTOS) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".BULTOS.OPERACION_REF="${DB}".OPERACIONES.opID) WHERE opID="${OPERACION}";" | column -t -s $'\t'>>${temp}"etiqueta.depo"

    echo -e "\n" >>${temp}"etiqueta.depo"
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT BULTOS FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE,"${DB}".BULTOS) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".BULTOS.OPERACION_REF="${DB}".OPERACIONES.opID) WHERE opID="${OPERACION}";" | column -t -s $'\t'>>${temp}"etiqueta.depo"


    for ((i=1;i<=${BULTOS};i++)); do
	enscript -B ${temp}"etiqueta.depo" -f Courier13 -M MIDOKA -p ${imp}""${user}"/etiqueta"${i}"" 
    done



    
    
    while true;do
	
	dialog --infobox "IMPRIMIENDO ETIQUETAS ." 0 0

	sleep 1

	dialog --infobox "IMPRIMIENDO ETIQUETAS . ." 0 0

	sleep 1

	dialog --infobox "IMPRIMIENDO ETIQUETAS . . ." 0 0

	sleep 1
	
	VAR_BULTOS="$(ls ${imp}""${user}"")"

	
	if test -z ${VAR_BULTOS}; then
	    break
	fi
    done
    
}



function etiqueta_apb {

    declare BULTOS

    declare VAR_BULTOS
    
    while true; do

	
	ORDEN[${POSICION}]="CONFIRME POR ULTIMA VEZ LA CANTIDAD DE BULTOS FINAL DEL PEDIDO"

	exec 3>&1
	
	
	BULTOS=$(dialog \
		     --clear \
		     --cancel-label "SALIR" \
		     --help-button \
		     --help-label "AYUDA" \
		     --inputbox " ""${ORDEN[${POSICION}]}""" 0 0 2>&1 1>&3)
	exit_status=$?
	exec 3>&-

	VAR_BULTOS="$(mysql -u "${user}" --password="${pass}" --execute="SELECT BULTOS FROM "${DB}".BULTOS WHERE OPERACION_REF="${OPERACION}" ;" | tail -n +2)"

	if test "${BULTOS}" -eq "${VAR_BULTOS}"; then
	    return
	else
	    rm ${temp}"error_bultos.depo"
	    mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".BULTOS SET BULTOS="${BULTOS}" WHERE OPERACION_REF="${OPERACION}";" 2>${temp}"error_bultos.depo"
	fi
	
	    
	
	VAR_BULTOS="$(cat ${temp}"error_bultos.depo")"

	if test -z ${VAR_BULTOS}; then
	    break
	else
	    dialog --msgbox "LA CANTIDAD NO ES VALIDA" 0 0 
	fi
    done

    # IMPRESION ORDEN

    mysql -u "${user}" --password="${pass}" --execute="SELECT opID AS REMITO,DENOMINACION AS CLIENTE,DIRECCION,BULTOS FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE,"${DB}".BULTOS) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".BULTOS.OPERACION_REF="${DB}".OPERACIONES.opID) WHERE opID="${OPERACION}";" | column -t -s $'\t'>${temp}"etiqueta.depo"


    for ((i=1;i<=${BULTOS};i++)); do
	cp ${temp}"etiqueta.depo" ${imp}""${user}"/etiqueta"${i}""
    done
    
    
    while true;do
	
	dialog --infobox "IMPRIMIENDO ETIQUETAS ." 0 0

	sleep 1

	dialog --infobox "IMPRIMIENDO ETIQUETAS . ." 0 0

	sleep 1

	dialog --infobox "IMPRIMIENDO ETIQUETAS . . ." 0 0

	sleep 1
	
	VAR_BULTOS="$(ls ${imp}${user})"

	
	if test -z ${VAR_BULTOS}; then
	    break
	fi
    done
    
}



    
    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

echo "DELETE FROM "${DB}".PEDIDO WHERE CANTIDAD=0;" >>${AGMYSQL}

# Existe el archivo de acumulado de comandos mysql ?

test -f "${AGMYSQL}" || touch "${AGMYSQL}"

CLIENTE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO) WHERE opID="${OPERACION}";" | tail -n +2)"

mysql -u "${user}" --password="${pass}" --execute="SELECT RUBRO,CATEGORIA,MODELO,MOTIVO,CANTIDAD FROM "${DB}".PEDIDO JOIN ("${DB}".ARTICULOS) ON ("${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}";" | tail -n +2 >${temp}"desglose_pedido.depo"


if [ ! -d "${DIRECTORIO}" ]; then
    
    mkdir ${DIRECTORIO}



    while read line ; do  #Ubica las cantidades pedidas en los archivos de visualizacion de la radio lista  

	
	ARCHIVO="$(echo """${line}""" | cut -f1-3 | tr '\t' '-')"

	seleccion="$(echo """${line}""" | cut -f3 )"
	

	
	mysql -u "${user}" --password="${pass}" --execute="SELECT mtID FROM "${DB}".PEDIDO JOIN("${DB}".MOTIVO,"${DB}".ARTICULOS) ON ("${DB}".MOTIVO.mtID="${DB}".ARTICULOS.MOTIVO AND "${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}" AND modelo_mt="${seleccion}";" | tail -n +2 >""${temp}"motivos.depo"
	
	
	MOTIVO="$(echo """${line}""" | cut -f4 )"

	INSERT="$(echo """${line}""" | cut -f5 )"
	
	if test ! -f ""${DIRECTORIO}"/VISTA_"${ARCHIVO}"" ;then
	    while read linez;do
		echo " " >> ""${DIRECTORIO}"/VISTA_"${ARCHIVO}""
	    done <""${temp}"motivos.depo"
	fi

	ubicar "${MOTIVO}" "${ARCHIVO}" "${INSERT}"
	



	
    done <${temp}"desglose_pedido.depo"


fi

# CHEKEO SI ME QUEDAN ARTICULOS POR COMPLETAR

ETAPA_COMPLETADO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT RUBRO,CATEGORIA,MODELO,MOTIVO,CANTIDAD FROM "${DB}".PEDIDO JOIN ("${DB}".ARTICULOS) ON ("${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}" AND FLAG IS NULL ;" | tail -n +2 | head -1 | awk '{print $1}')"

if test ! -z "${ETAPA_COMPLETADO}"; then



    while [ "${POSICION}" -lt "${#ORDEN[@]}" ];do

	POSICION=0

	VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2 | sed '$d' | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"

	INDICE="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2 | head -1 | awk '{print $1}')"

	GRUPEADOR="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +3 | head -1 | awk '{print $1}')"
	
	

	mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}".PEDIDO JOIN("${DB}"."${ORDEN[${POSICION}]}","${DB}".ARTICULOS) ON ("${DB}"."${ORDEN[${POSICION}]}"."${INDICE}"="${DB}".ARTICULOS."${ORDEN[${POSICION}]}" AND "${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}" AND FLAG IS NULL GROUP BY "${GRUPEADOR}";" | tail -n +2 >"./"${temp}"/tmp2.depo"

	menu_seleccion

	if test ${POSICION} -lt 0;then
	    limpieza
	    exit 192
	fi


	
	while [ "${POSICION}" -lt "${#ORDEN[@]}" -a "${POSICION}" -ne 0 ];do

	    let PREVIO=${POSICION}-1
	    
	    VALORES="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2 | sed '$d' | awk '{print $1}' | tr '\n' ',' | sed 's/.$//')"

            INDICE="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +2 | head -1 | awk '{print $1}')"

	    GRUPEADOR="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n +3 | head -1 | awk '{print $1}')"

	    CORRESPONDENCIA="$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ORDEN[${POSICION}]}";" | tail -n -1 | awk '{print $1}')"
	    
	    case "${POSICION}" in
		
		3)




		    NUEVO=$(echo ${seleccion[@]} | tr ' ' '\n'|tr '\n' '-' | sed 's/.$//')

		    mysql -u "${user}" --password="${pass}" --execute="SELECT mtID,motivo_mt,ID_ARTICULO FROM "${DB}".PEDIDO JOIN("${DB}"."${ORDEN[${POSICION}]}","${DB}".ARTICULOS) ON ("${DB}"."${ORDEN[${POSICION}]}"."${INDICE}"="${DB}".ARTICULOS."${ORDEN[${POSICION}]}" AND "${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}" AND "${CORRESPONDENCIA}"="${seleccion[${PREVIO}]}" GROUP BY "${GRUPEADOR}" ORDER BY mtID ASC;" | tail -n +2 >"./"${temp}"/tmp2_repartir.depo"

		    cat "./"${temp}"/tmp2_repartir.depo" | cut -f2 >"./"${temp}"/tmp2.depo"

		    cat "./"${temp}"/tmp2_repartir.depo" | cut -f1 >""${DIRECTORIO}"/REFERENCIA_"${NUEVO}""

		    cat "./"${temp}"/tmp2_repartir.depo" | cut -f3 >"./"${temp}"/tmp_terminado.depo"
		    
		    PRODUCTO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DISTINCT (mod_md) FROM "${DB}".ARTICULOS JOIN ("${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO) ON ("${DB}".RUBRO.ruID="${DB}".ARTICULOS.RUBRO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO) WHERE RUBRO="${seleccion[0]}" AND CATEGORIA="${seleccion[1]}" AND MODELO="${seleccion[2]}";" | tail -n +2)" 

		    
		    
		    bash ${scr}"radio_armado_pedido.sh" "DEPOSITO" "ARMADO DEL PEDIDO DEL CLIENTE : '${CLIENTE}'" "UNIDADES DE '${PRODUCTO}'" "tmp2.depo" ""${NUEVO}"" ""${OPERACION}""

		    case $? in
			0)
			    
			    while read line; do
				test -f ""${DIRECTORIO}"/"${NUEVO}"" && mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".PEDIDO SET FLAG='1' WHERE ID_ARTICULO="${line}" AND OPERACION_REFERENCIA="${OPERACION}";"
			    done<"./"${temp}"/tmp_terminado.depo"
			    ;;
		    esac
		    
		    
		    
	            let POSICION+=-1
		    ;;
		
		
		*)

		    mysql -u "${user}" --password="${pass}" --execute="SELECT "${VALORES}" FROM "${DB}".PEDIDO JOIN("${DB}"."${ORDEN[${POSICION}]}","${DB}".ARTICULOS) ON ("${DB}"."${ORDEN[${POSICION}]}"."${INDICE}"="${DB}".ARTICULOS."${ORDEN[${POSICION}]}" AND "${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}" AND "${CORRESPONDENCIA}"="${seleccion[${PREVIO}]}" AND FLAG IS NULL GROUP BY "${GRUPEADOR}";" | tail -n +2 >"./"${temp}"/tmp2.depo"

		    menu_seleccion;;
	    esac
	    
	    

	done
	
    done

    case $? in
	0)

	    
	    #echo "DELETE FROM ARMADO WHERE OPERACION_REFERENCIA_AR="${OPERACION}";" >>${AGMYSQL}

	    #echo "DELETE FROM FALTANTE WHERE OPERACION_REFERENCIA_FL="${OPERACION}";" >>${AGMYSQL}

	    echo "ARMADO" >${temp}"guia.depo"

	    echo "FALTANTE" >>${temp}"guia.depo"

	    while read laguia ;do
		

		case $laguia in

		    "ARMADO") ls ""${DIRECTORIO}"" | grep -e '^[0-9]' >""${temp}"pedido_listo.depo";;

		    "FALTANTE") ls ""${DIRECTORIO}""  | grep -e '^##' >""${temp}"pedido_listo.depo";;
		esac
		


		while read line ; do

		    echo ""${line}"" | tr '-' '\n' >""${temp}"articulo_listo.depo" 

		    cat ""${DIRECTORIO}"/"${line}"" | tr ',' '\t' >""${temp}"articulo_listo_cantidad.depo"

		    CONTADOR=0
		    while read linea ; do
			while read lineb ; do

			    
			    seleccion[${CONTADOR}]="$(echo "${lineb}" | sed 's/^##//' )"

			    let CONTADOR+=1
			    
			done <""${temp}"articulo_listo.depo"

			seleccion[${CONTADOR}]="$(echo ""${linea}"" | awk '{print $1}')" 

			let CONTADOR+=1

			seleccion[${CONTADOR}]="$(echo ""${linea}"" | awk '{print $2}')" 

			ID="$(mysql -u "${user}" --password="${pass}" --execute="SELECT artID FROM "${DB}".ARTICULOS WHERE RUBRO="${seleccion[0]}"  AND CATEGORIA="${seleccion[1]}" AND MODELO="${seleccion[2]}" AND MOTIVO="${seleccion[3]}" ;" | tail -n +2)"

			echo ${AGMYSQL}
			
			case $laguia in

			    "ARMADO") echo "INSERT INTO ARMADO (OPERACION_REFERENCIA_AR,ID_ARTICULO_AR,CANTIDAD_AR) VALUES ('${OPERACION}','${ID}','${seleccion[4]}');" >>${AGMYSQL} ;;
			    
			    "FALTANTE") echo "INSERT INTO FALTANTE (OPERACION_REFERENCIA_FL,ID_ARTICULO_FL,CANTIDAD_FL) VALUES ('${OPERACION}','${ID}','${seleccion[4]}');" >>${AGMYSQL} ;;
			esac
	    		
			
			CONTADOR=0
			
		    done <""${temp}"articulo_listo_cantidad.depo"
		    
		    
		    
		done <""${temp}"pedido_listo.depo"

	    done <${temp}"guia.depo"

	    
	    ;;
	*)  limpieza
	    exit 255;;
    esac

fi    


ETAPA_BULTOS=$(cat ${AGMYSQL} | grep BULTOS | tail -n +2 |  head -1)

ETAPA_UBI=$(cat ${AGMYSQL} | grep LOCALIZACION_PEDIDO | tail -n +2 | head -1)

if test -z "${ETAPA_BULTOS}"; then
    

    bultos_pedido

    ubicar_pedido

    #impreso_control

    #etiqueta_apb

else

    if test -z "${ETAPA_UBI}"; then

	ubicar_pedido

	#impreso_control

	#etiqueta_apb

    else

	#impreso_control

	#etiqueta_apb

	echo "hola"
    fi
fi

	
    
#rm -rf "${DIRECTORIO}"
 
echo "DELETE FROM "${DB}".ARMADO WHERE CANTIDAD_AR=0 AND CANTIDAD_EGR IS NULL AND CANTIDAD_ING IS NULL AND CANTIDAD_DEVOL IS NULL AND CANTIDAD_CST IS NULL;" >>${AGMYSQL}

#echo "DELETE FROM "${DB}".ARMADO WHERE CANTIDAD_AR=0;" >>${AGMYSQL}

################## MANTENIMIENTO FINAL ###################



VAR_s=${temp}"*.depo" 

rm $VAR_s

exit 0

