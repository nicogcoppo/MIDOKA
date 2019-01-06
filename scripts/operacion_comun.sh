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
# # SCRIPT para el grabado en tabla de las operaciones de PEDIDO DIRECTO Y SOLICITUD DE VISITA principalmente
# que originan las ordenes de trabajo

################### MANTENIMIENTO INICIAL #####################


#shopt -s -o unset

################### DECLARACIONES ########################

declare -r OPERACION=$2

declare -a INICIAL=$(echo $5 | sed 's/[^0-9]*//g')

declare -a FINAL=$(echo $6 | sed 's/[^0-9]*//g')

declare -r ACTOR="CLIENTE"

declare TIPO

declare DIA

declare INTERESADO

declare -a ID

declare CONTADOR

declare OPERACION_F

declare TIPO_SOLICITUD

declare -r PREOPER=${temp}${RANDOM}".grabado" && test -f ${PREOPER} && exit 192 || touch ${PREOPER}

################### FUNCIONES ###############################

function borrado {

    INTERESADO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}"."${ACTOR}" WHERE clID='"${VAR}"';" | tail -n +2)

    mysql -u "${user}" --password="${pass}" --execute="SELECT opID,nombre_nm,DATE_FORMAT(FECHA,'%d %b %Y') FROM "${DB}".OPERACIONES JOIN ("${DB}".NOMBRE_MENU) ON ("${DB}".NOMBRE_MENU.nmID="${DB}".OPERACIONES.SOLICITUD) WHERE INTERESADO="${VAR}" AND COMPLETADO IS NULL;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.ed"

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
	selection=$(dialog \
			--backtitle "ELIMINAR SOLICITUD" \
			--title """${INTERESADO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE LA OPERACION A ELIMINAR" 0 0 0 "${foraneos[@]}" \
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
    PREGUNTA="$(mysql -u "${user}" --password="${pass}" --execute="SELECT FECHA FROM "${DB}".OPERACIONES WHERE opID="${selection}";" | tail -n +2)"
    dialog --yesno "ESTA SEGURO QUE DESEA ELIMINAR LA OPERACION CON FECHA: """${PREGUNTA}""" ?" 0 0 && mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".OPERACIONES WHERE opID="${selection}";" 2>${temp}"log_errores.ed"
}


function nueva_orden_operacion {

    
	 
	 mysql -u "${user}" --password="${pass}" --execute="SELECT oopID,xdefecto_oop FROM "${DB}".ORDEN_OPERACION WHERE oopID <="${FINAL}" AND oopID >="${INICIAL}";"| tail -n +2 | tr '\t' ',' >${temp}"tmp.ed"

	 CONTADOR=0
	 while read line;do
	     case $CONTADOR in
		 0)echo "INSERT INTO "${DB}".SOLICITUDES (REFERENCIA,CLASE,ASIGNADA,COMIENZO) VALUES ("${TIPO}","""${line}""",'${DIA}');" >>${PREOPER};;
		 *)echo "INSERT INTO "${DB}".SOLICITUDES (REFERENCIA,CLASE,ASIGNADA) VALUES ("${TIPO}","""${line}""");" >>${PREOPER};;
	     esac
	     let CONTADOR+=1
	 done<${temp}"tmp.ed"

	 # SI SE TRATA DE UN FALTANTE
	 
	 if [ "${TIPO_SOLICITUD}" -eq "46" ] ; then

	     OPERACION_F="$(mysql -u "${user}" --password="${pass}" --execute="SELECT MAX(opID) FROM "${DB}".FALTANTE JOIN("${DB}".OPERACIONES,"${DB}".CLIENTE) ON("${DB}".OPERACIONES.INTERESADO="${DB}".CLIENTE.clID AND "${DB}".FALTANTE.OPERACION_REFERENCIA_FL="${DB}".OPERACIONES.opID) WHERE clID="${INTERESADO}";" | tail -n +2)"

	     mysql -u "${user}" --password="${pass}" --execute="SELECT '"${TIPO}"',ID_ARTICULO_FL,CANTIDAD_FL FROM "${DB}".FALTANTE WHERE OPERACION_REFERENCIA_FL="${OPERACION_F}";" | tail -n +2 | tr '\t' ',' >${temp}"tmp.ed"

	     
	     
	     CONTADOR=0
	     while read line;do
		 echo "INSERT INTO "${DB}".PEDIDO (OPERACION_REFERENCIA,ID_ARTICULO,CANTIDAD) VALUES ("""${line}""");" >>${PREOPER}
		 let CONTADOR+=1
	     done<${temp}"tmp.ed"

	     VAR_COMISION_VENTA=$(mysql -u "${user}" --password="${pass}" --execute="SELECT ASIGNADA FROM "${DB}".SOLICITUDES WHERE CLASE=2 AND REFERENCIA="${OPERACION_F}";" | tail -n +2)

	     REALIZO_COMISION_VENTA=$(mysql -u "${user}" --password="${pass}" --execute="SELECT REALIZACION FROM "${DB}".SOLICITUDES WHERE CLASE=2 AND REFERENCIA="${OPERACION_F}";" | tail -n +2)

	     #test ! -z ${VAR_COMISION_VENTA} && echo "INSERT INTO "${DB}".SOLICITUDES (REFERENCIA,CLASE,ASIGNADA,COMIENZO,REALIZACION) VALUES ("${TIPO}",2,"${VAR_COMISION_VENTA}",'${REALIZO_COMISION_VENTA}','${REALIZO_COMISION_VENTA}');" && echo "INSERT INTO "${DB}".SOLICITUDES (REFERENCIA,CLASE,ASIGNADA,COMIENZO,REALIZACION) VALUES ("${TIPO}",4,'5','${REALIZO_COMISION_VENTA}','${REALIZO_COMISION_VENTA}');" >>${PREOPER}

	     if test ! -z ${VAR_COMISION_VENTA}; then
		 echo "INSERT INTO "${DB}".SOLICITUDES (REFERENCIA,CLASE,ASIGNADA,COMIENZO,REALIZACION) VALUES ("${TIPO}",2,"${VAR_COMISION_VENTA}",'${REALIZO_COMISION_VENTA}','${REALIZO_COMISION_VENTA}');" >>${PREOPER}
		 echo "INSERT INTO "${DB}".SOLICITUDES (REFERENCIA,CLASE,ASIGNADA,COMIENZO,REALIZACION) VALUES ("${TIPO}",4,'5','${REALIZO_COMISION_VENTA}','${REALIZO_COMISION_VENTA}');" >>${PREOPER}

	     fi
	     
	 fi
}



#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

bash "./"${scr}"busqueda_tipo.sh" ""${ACTOR}""

case $? in
    192)exit 192;;
    204)exit 204;;
esac

rm ${temp}"log_errores.ed"


case ${INICIAL} in
    255)

	VAR=$(cat ${temp}"busqueda")
	borrado
	;;
	 
     0)    	
	 
		 
	 TIPO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT nmID FROM "${DB}".NOMBRE_MENU WHERE nombre_nm LIKE '%""${OPERACION}""%';" | tail -n +2 | awk '{print $1}')

	 DIA=$(date +%F)

	 INTERESADO=$(cat ${temp}"busqueda")

	 echo "INSERT INTO "${DB}".OPERACIONES (INTERESADO,SOLICITUD,FECHA,COMPLETADO) VALUES ("""${INTERESADO}""","${TIPO}",'${DIA}','${DIA}');" >>${PREOPER}
	 ;;

     
     *)
	     
	 	 
	 TIPO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT nmID FROM "${DB}".NOMBRE_MENU WHERE nombre_nm LIKE '%""${OPERACION}""%';" | tail -n +2 | awk '{print $1}')

	 DIA=$(date +%F)

	 INTERESADO=$(cat ${temp}"busqueda")

	 TIPO_SOLICITUD="${TIPO}"	 
	 
	 TIPO="$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";START TRANSACTION;INSERT INTO OPERACIONES (INTERESADO,SOLICITUD,FECHA) VALUES ("""${INTERESADO}""","${TIPO}",'${DIA}');SELECT MAX(opID) FROM OPERACIONES;COMMIT;" | tail -n +2)" && nueva_orden_operacion || exit 192

  	 	      
	 ;;
esac


bash ${scr}"transaccion.sh" "${PREOPER}" && dialog --msgbox "SOLICITUD ACTUALIZADA CORRECTAMENTE" 0 0 || dialog --msgbox "OCURRIO UN ERROR EN EL ACTUALIZADO DE LA SOLICITUD" 0 0


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 192
