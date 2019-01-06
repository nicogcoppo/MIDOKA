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
# SCRIPT PARA LA VISUALIZACION RACIONAL DE LOS CLIENTES CON PEDIDO DIRECTO

################### MANTENIMIENTO INICIAL #####################

rm log_errores


##########################################################



#shopt -s -o unset

################### DECLARACIONES ########################


declare -r OPERACION=$1

declare CLIENTE

declare DIRECTORIO=""${temp}""${OPERACION}"-DEPO"

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
    
    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

CLIENTE="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}".OPERACIONES JOIN ("${DB}".CLIENTE) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO) WHERE opID="${OPERACION}";" | tail -n +2)"

if [ ! -d "${DIRECTORIO}" ]; then
    


    mkdir ${DIRECTORIO}


    mysql -u "${user}" --password="${pass}" --execute="SELECT RUBRO,CATEGORIA,MODELO,MOTIVO,CANTIDAD FROM "${DB}".PEDIDO JOIN ("${DB}".ARTICULOS) ON ("${DB}".ARTICULOS.artID="${DB}".PEDIDO.ID_ARTICULO) WHERE OPERACION_REFERENCIA="${OPERACION}";" | tail -n +2 >${temp}"desglose_pedido.depo"




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
				mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".PEDIDO SET FLAG='1' WHERE ID_ARTICULO="${line}" AND OPERACION_REFERENCIA="${OPERACION}";"
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

	    
	    mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".ARMADO WHERE OPERACION_REFERENCIA_AR="${OPERACION}";"

	    mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".FALTANTE WHERE OPERACION_REFERENCIA_FL="${OPERACION}";"

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

			
			case $laguia in

			    "ARMADO") mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".ARMADO (OPERACION_REFERENCIA_AR,ID_ARTICULO_AR,CANTIDAD_AR) VALUES ('${OPERACION}','${ID}','${seleccion[4]}');" ;;
			    
			    "FALTANTE") mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".FALTANTE (OPERACION_REFERENCIA_FL,ID_ARTICULO_FL,CANTIDAD_FL) VALUES ('${OPERACION}','${ID}','${seleccion[4]}');" ;;
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


ETAPA_BULTOS=$(mysql -u "${user}" --password="${pass}" --execute="SELECT OPERACION_REF,BULTOS FROM "${DB}".BULTOS WHERE OPERACION_REF="${OPERACION}";" | tail -n +2)

ETAPA_UBI=$(mysql -u "${user}" --password="${pass}" --execute="SELECT OPERACION_REF,LOCALIZACION FROM "${DB}".LOCALIZACION_PEDIDO WHERE OPERACION_REF="${OPERACION}" ;" | tail -n +2)

if test -z "${ETAPA_BULTOS}"; then
    

    bultos_pedido

    ubicar_pedido

    impreso_control

    etiqueta_apb

else

    if test -z "${ETAPA_UBI}"; then

	ubicar_pedido

	impreso_control

	etiqueta_apb

    else

	impreso_control

	etiqueta_apb

    fi
fi

	
    
rm -rf "${DIRECTORIO}"
 


################## MANTENIMIENTO FINAL ###################



VAR_s=${temp}"*.depo" 

rm $VAR_s

exit 0

