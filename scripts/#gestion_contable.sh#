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

declare OPERACION=$2

declare -r GESTION=$(echo $6 | sed 's/[^0-9]*//g')

declare -r DESTINATARIO=$(echo $5 | sed 's/[^0-9]*//g')

declare -a ACTOR=("---" "PROOVEDOR" "CLIENTE")

declare TIPO

declare DIA

declare INTERESADO

declare -a ID

declare CONTADOR

declare TEXTO

declare CANTIDAD

################### FUNCIONES ###############################

function borrado {

    INTERESADO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT DENOMINACION FROM "${DB}"."${ACTOR[${DESTINATARIO}]}" WHERE clID='"${VAR}"';" | tail -n +2)

    mysql -u "${user}" --password="${pass}" --execute="SELECT opID AS 'ID',nombre_nm AS 'OPERACION',IF(HABER > 0,HABER,IF(DEBE > 0,DEBE,IF(DEVOLUCION > 0,DEVOLUCION,PERDIDAS))) AS MONTO,DATE_FORMAT(FECHA,'%d %b %Y') AS 'FECHA' FROM "${DB}".OPERACIONES JOIN ("${DB}".NOMBRE_MENU,"${DB}".CUENTA_CORRIENTE) ON ("${DB}".NOMBRE_MENU.nmID="${DB}".OPERACIONES.SOLICITUD AND "${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${VAR}" ;" | column -t -s $'\t'>${temp}"tmp2.cont"

    cat "./"${temp}"/tmp2.cont" | awk '{print $1}' >"./"${temp}"/tmp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.cont"

    #cat "./"${temp}"/tmp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.cont"

    cat "./"${temp}"/tmp2.cont" >"./"${temp}"/tmp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.cont"


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

    
    dialog --yesno "ESTA REALMENTE SEGURO QUE DESEA ELIMINAR LA OPERACION : ""$(mysql -u "${user}" --password="${pass}" --execute="SELECT nombre_nm AS 'OPERACION',IF(HABER > 0,HABER,IF(DEBE > 0,DEBE,IF(DEVOLUCION > 0,DEVOLUCION,PERDIDAS))) AS MONTO,DATE_FORMAT(FECHA,'%d %b %Y') AS 'FECHA' FROM "${DB}".OPERACIONES JOIN ("${DB}".NOMBRE_MENU,"${DB}".CUENTA_CORRIENTE) ON ("${DB}".NOMBRE_MENU.nmID="${DB}".OPERACIONES.SOLICITUD AND "${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE opID="${selection}" ;" | tail -n +2 | column -t -s $'\t')""" 0 0 && mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".OPERACIONES WHERE opID="${selection}";" 2>${temp}"log_errores.cont"
    
    
}



function borrado_proovedor {

    INTERESADO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT NOMBRE_COMERCIAL FROM "${DB}"."${ACTOR[${DESTINATARIO}]}" WHERE pooID='"${VAR}"';" | tail -n +2)

    mysql -u "${user}" --password="${pass}" --execute="SELECT OPERACION_ASOCIADA AS 'ID',nombre_nm AS 'GESTION',REFERENCIA,DEBE,HABER,DATE_FORMAT("${DB}".OPERACIONES.FECHA,'%d %b %Y') AS 'FECHA' FROM "${DB}".SALDO_PROOVEDOR JOIN ("${DB}".PROOVEDOR,"${DB}".NOMBRE_MENU,"${DB}".OPERACIONES) ON ("${DB}".PROOVEDOR.pooID="${DB}".SALDO_PROOVEDOR.PROOVEDOR AND "${DB}".OPERACIONES.PROVEEDOR_REFERENCIA="${DB}".PROOVEDOR.pooID AND "${DB}".OPERACIONES.SOLICITUD="${DB}".NOMBRE_MENU.nmID) WHERE pooID="${VAR}" ;" | column -t -s $'\t'>${temp}"tmp2.cont"

    cat "./"${temp}"/tmp2.cont" | awk '{print $1}' >"./"${temp}"/tmp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.cont"

    #cat "./"${temp}"/tmp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.cont"

    cat "./"${temp}"/tmp2.cont" >"./"${temp}"/tmp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.cont"


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

    dialog --yesno "ESTA REALMENTE SEGURO QUE DESEA ELIMINAR LA OPERACION : ""$(mysql -u "${user}" --password="${pass}" --execute="SELECT nombre_nm AS 'GESTION',REFERENCIA,IF(DEBE > 0,DEBE,HABER),DATE_FORMAT("${DB}".OPERACIONES.FECHA,'%d %b %Y') AS 'FECHA' FROM "${DB}".SALDO_PROOVEDOR JOIN ("${DB}".PROOVEDOR,"${DB}".NOMBRE_MENU,"${DB}".OPERACIONES) ON ("${DB}".PROOVEDOR.pooID="${DB}".SALDO_PROOVEDOR.PROOVEDOR AND "${DB}".OPERACIONES.PROVEEDOR_REFERENCIA="${DB}".PROOVEDOR.pooID AND "${DB}".OPERACIONES.SOLICITUD="${DB}".NOMBRE_MENU.nmID) WHERE opID="${selection}" ;" | tail -n +2 | column -t -s $'\t')""" 0 0 && mysql -u "${user}" --password="${pass}" --execute="DELETE FROM "${DB}".OPERACIONES WHERE opID="${selection}";" 2>${temp}"log_errores.con"t

    
}


function cliente_comision {

    while true; do
    
         TEXTO="INGRESE EL NUMERO DE REMITO DE REFERENCIA POR FAVOR:"

	 exec 3>&1
	 
	 
	 REMITO_REF=$(dialog \
		      --clear \
		      --cancel-label "SALIR" \
		      --help-button \
		      --help-label "AYUDA" \
		      --inputbox """${TEXTO}""" 0 0 2>&1 1>&3)
	 exit_status=$?
	 exec 3>&-

	 VAR="$(mysql -u "${user}" --password="${pass}" --execute="SELECT DEBE FROM "${DB}".CUENTA_CORRIENTE WHERE OPERACION_REF_CC="${REMITO_REF}";" | tail -n+2 | head -1)"
	 
	 if test -z "${VAR}"; then
	     dialog --msgbox "NO EXISTE UNA OPERACION REGISTRADA DE NUMERO ""${REMITO_REF}""" 0 0 || exit 192
	 else
	     dialog --yesno "REMITO : "${REMITO_REF}" MONTO INICIAL : "${VAR}"" 0 0 && break
	 fi

	 
    done

    # CALCULO DE LA PROPORCION DE PAGO
    
    PROPORCION="$(maxima --very-quiet --batch-string "fpprintprec:7$"${CANTIDAD}"/"${VAR}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"

    MONTO_BRUTO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT TRABAJADOR,MONTO FROM "${DB}".COMISIONES WHERE OPERACION_REF_C="${REMITO_REF}" AND VIGENCIA IS NULL AND CANCELACION IS NULL;" | tail -n +2)"

    MONTO_NETO="$(echo ${MONTO_BRUTO} | head -1)"
    
    if test -z "${MONTO_NETO}"; then
	dialog --msgbox "ESTAS COMISIONES SE ENCUENTRAN ASIGNADAS O OCURRIO UN ERROR" 0 0 && exit 1
    fi
    
    echo "${MONTO_BRUTO}" >${temp}"/tmp_comisiones.cont"


    #A ASIGNACION PROPORCIONAL DE COMISIONES
    
    while read comision ; do
	TRABAJADOR=$(echo ${comision} | awk '{print $1}')

	MONTO_BRUTO=$(echo ${comision} | awk '{print $2}')

	MONTO_NETO="$(maxima --very-quiet --batch-string "fpprintprec:7$"${PROPORCION}"*"${MONTO_BRUTO}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)" 

	echo "INSERT INTO "${DB}".COMISIONES (OPERACION_REF_C,TRABAJADOR,MONTO,VIGENCIA) VALUES ("${OPERACION}","${TRABAJADOR}","${MONTO_NETO}",'${DIA}');" >>${AGMYSQL}
	
	
    done <${temp}"/tmp_comisiones.cont"

    # SE ACTULIZA EL SALDO
    
    echo "INSERT INTO "${DB}".CUENTA_CORRIENTE (OPERACION_REF_CC,DEBE,HABER,DEVOLUCION,PERDIDAS) VALUES ("${OPERACION}",'0',"${CANTIDAD}",'0','0');" >>${AGMYSQL}

    echo "UPDATE COMISIONES JOIN(OPERACIONES,CLIENTE) ON(OPERACION_REF_C=opID AND INTERESADO=clID) SET MONTO=0 WHERE clID=275 OR clID=303 OR clID=340 OR clID=337 OR clID=314;" >>${AGMYSQL}
    
    bash  ${scr}"transaccion.sh" "${AGMYSQL}" && rm ${AGMYSQL} || exit 1  
    
    # CALCULO DEL SALDO
    
    SALDO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT (SUM(DEBE) - SUM(HABER) - SUM(DEVOLUCION) - SUM(PERDIDAS)) AS 'SALDO' FROM "${DB}".CUENTA_CORRIENTE JOIN("${DB}".OPERACIONES)ON("${DB}".OPERACIONES.opID="${DB}".CUENTA_CORRIENTE.OPERACION_REF_CC) WHERE INTERESADO="${INTERESADO}" GROUP BY INTERESADO ;" | tail -n +2)" 


    # SI EL CASO ESTA CERRADO, DOY POR CERRADA LA COMISION

    # TAMBIEN DOY POR RENDONDEADO EL SALDO

    touch ${AGMYSQL}
    
    (test "$(echo "${SALDO} < 51" | bc -l )" -eq "0")  || ((test "$(echo "${SALDO} > 0" | bc -l )" -eq "0") || (echo "UPDATE "${DB}".CUENTA_CORRIENTE SET PERDIDAS="${SALDO}" WHERE OPERACION_REF_CC="${OPERACION}" ;" >>${AGMYSQL} || (dialog --msgbox "OCURRIO UN ERROR EN EL PROCESO" 0 0 && exit 1) && dialog --msgbox "SE EFECTUO UN REDONDEO AUTOMATICO POR LA DIFERENCIA" 0 0 ) &&  echo "UPDATE "${DB}".COMISIONES SET CANCELACION='${DIA}' WHERE OPERACION_REF_C="${REMITO_REF}" AND VIGENCIA IS NULL AND CANCELACION IS NULL;" >>${AGMYSQL} || (dialog --msgbox "OCURRIO UN ERROR EN EL PROCESO" 0 0 && exit 1))


    
    test -z "$(cat ${AGMYSQL} | head -1)" || (bash -o xtrace ${scr}"transaccion.sh" "${AGMYSQL}" && dialog --msgbox "PROCESO REALIZADO CON EXITO" 0 0 )  
       
    # QUEDA INCONVENIENTE A RESOLVER, A LA HORA DE QUERER ESTIMAR EL MONTO A ABONAR EN COMISIONES, RESULTARA EL CASO EN EL QUE QUEDARAN COMISIONES ASIGNADAS POR PAGOS ( LAS QUE SI TIENEN FECHA DE VIGENCIA NO NULL ) Y COMSIONES MADRES ( LAS QUE CREA LA FACTURACION ) CON UNA FECHA DE ABONACION QUE EN REALIDAD ES LA FECHA EN LA QUE SE PERCIBIO EL PAGO POR EL TOTAL DEL REMITO , PERO AUN NO FUE ABONADA AL COMISIONANTE. 
}

	    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


bash "./"${scr}"busqueda_tipo.sh" ""${ACTOR[${DESTINATARIO}]}""

case $? in
    192)exit 192;;
    204)exit 204;;
esac

rm ${temp}"log_errores.cont"



case ${GESTION} in
    255)

	VAR=$(cat ${temp}"busqueda" | head -1)
	
	case ${DESTINATARIO} in
	    1)borrado_proovedor;;
	    2)borrado;;
	esac
	
	;;
	 
     1)    	
	 ## CREO OPERACION PARA PAGO Y LO REGISTRO EN CUENTA CORRIENTE
		 
	 	 
	 DIA=$(date +%F)

	 INTERESADO=$(cat ${temp}"busqueda" | head -1)

	 while true; do
	     
	     TEXTO="INGRESE EL MONTO EN PESOS DE LA OPERACION: "${OPERACION}""

	     exec 3>&1
	     
	     
	     CANTIDAD=$(dialog \
			    --clear \
			    --cancel-label "SALIR" \
			    --help-button \
			    --help-label "AYUDA" \
			    --inputbox """${TEXTO}""" 0 0 2>&1 1>&3)
	     exit_status=$?
	     exec 3>&-

	     dialog --yesno "LA CANTIDAD ES $ "${CANTIDAD}"" 0 0 && break
	 done
	 
	     
	 case ${DESTINATARIO} in

	     2)
	 	 
		 
		 AGMYSQL=""${temp}"/"${RANDOM}".grabado"

		 rm ${AGMYSQL}

		 test -f "${AGMYSQL}" || touch "${AGMYSQL}"

		 
		 mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".OPERACIONES (INTERESADO,SOLICITUD,FECHA,COMPLETADO) VALUES ("""${INTERESADO}""",'41','${DIA}','${DIA}');
" 2>${temp}"log_errores.cont"

		 OPERACION="$(mysql -u "${user}" --password="${pass}" --execute="SELECT MAX(opID) FROM "${DB}".OPERACIONES WHERE SOLICITUD='41' LIMIT 1 ;" 2>${temp}"log_errores.cont" | tail -n +2)"

		 cliente_comision
		 
		 ;;
	     1)

		 declare RECIBO

		 while true; do

		     TEXTO="INGRESE EL NUMERO DE RECIBO ASOCIADO AL PAGO :"

		     exec 3>&1
		     
		     
		     RECIBO=$(dialog \
				  --clear \
				  --cancel-label "SALIR" \
				  --help-button \
				  --help-label "AYUDA" \
				  --inputbox """${TEXTO}""" 0 0 2>&1 1>&3)
		     exit_status=$?
		     exec 3>&-

		     dialog --yesno "RECIBO --> "${RECIBO}" es correcto ?" 0 0 && break
		     
		 done
		 
		 declare -r OPERACION="$((mysql -u "${user}" --password="${pass}" --execute="START TRANSACTION;INSERT INTO "${DB}".OPERACIONES (INTERESADO,SOLICITUD,FECHA,COMPLETADO,PROVEEDOR_REFERENCIA) VALUES ('300','41','${DIA}','${DIA}',"${INTERESADO}");SELECT MAX(opID) FROM "${DB}".OPERACIONES;COMMIT;" | tail -n +2) || (dialog --msgbox "ERROR FATAL" 0 0 && exit 192))"

	         mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".SALDO_PROOVEDOR (FECHA,REFERENCIA,PROOVEDOR,DEBE,HABER,OPERACION_ASOCIADA) VALUES ('${DIA}','${RECIBO}',"${INTERESADO}",'0',"${CANTIDAD}","${OPERACION}");" 2>${temp}"log_errores.cont" ;;

	 esac
	 
	;;


     2)    	
	 ## CREO OPERACION PARA UNA PERDIDA Y LA REGISTRO EN CUENTA CORRIENTE
		 
	 
	 DIA=$(date +%F)

	 INTERESADO=$(cat ${temp}"busqueda")


	 TEXTO="INGRESE EL MONTO EN PESOS DE LA OPERACION: "${OPERACION}""

	 exec 3>&1
	 
	 
	 CANTIDAD=$(dialog \
		      --clear \
		      --cancel-label "SALIR" \
		      --help-button \
		      --help-label "AYUDA" \
		      --inputbox """${TEXTO}""" 0 0 2>&1 1>&3)
	 exit_status=$?
	 exec 3>&-

	 
	 	 
	 mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".OPERACIONES (INTERESADO,SOLICITUD,FECHA,COMPLETADO) VALUES ("""${INTERESADO}""",'43','${DIA}','${DIA}');
" 2>${temp}"log_errores.cont"
	 OPERACION="$(mysql -u "${user}" --password="${pass}" --execute="SELECT MAX(opID) FROM "${DB}".OPERACIONES WHERE SOLICITUD='43' LIMIT 1 ;" 2>${temp}"log_errores.cont" | tail -n +2)"
	 
	 mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".CUENTA_CORRIENTE (OPERACION_REF_CC,DEBE,HABER,DEVOLUCION,PERDIDAS) VALUES ("${OPERACION}",'0','0','0',"${CANTIDAD}");" 2>${temp}"log_errores.cont"
	 ;;
     

     3)    	
	 
	 ## CREO OPERACION PARA UNA DEVOLUCION Y LA REGISTRO EN CUENTA-CORRIENTE
		 
	 
	 DIA=$(date +%F)

	 INTERESADO=$(cat ${temp}"busqueda")

	 
	 TEXTO="INGRESE EL REMITO O NOTA DE REFERENCIA PARA REGISTRAR JUNTO A LA OPERACION: "${OPERACION}""

	 exec 3>&1
	 
	 
	 REMITO=$(dialog \
		      --clear \
		      --cancel-label "SALIR" \
		      --help-button \
		      --help-label "AYUDA" \
		      --inputbox """${TEXTO}""" 0 0 2>&1 1>&3)
	 exit_status=$?
	 exec 3>&-

	 
	 mysql -u "${user}" --password="${pass}" --execute="INSERT INTO "${DB}".OPERACIONES (INTERESADO,SOLICITUD,FECHA,COMPLETADO) VALUES ("""${INTERESADO}""",'42','${DIA}','${DIA}');
" 2>${temp}"log_errores.cont"
	 OPERACION="$(mysql -u "${user}" --password="${pass}" --execute="SELECT MAX(opID) FROM "${DB}".OPERACIONES WHERE SOLICITUD='42' LIMIT 1 ;" 2>${temp}"log_errores.cont" | tail -n +2)"



	 bash "./"${scr}"devolucion_mercaderia.sh" ""${OPERACION}"" ""${REMITO}""
	 	 
	 
	 ;;


esac




case $? in
    0)

	if test -z ${temp}"log_errores.cont";then
	    dialog --msgbox "OCURRIO UN PROBLEMA DURANTE EL PROCESO : "$(cat ${temp}"log_errores.cont")"" 0 0
	else
	    dialog --msgbox "OPERACION PROCESADA CORRECTAMENTE" 0 0
	fi
	;;
    *)
	dialog --msgbox "SE INTERRUMPIO EL PROCESO" 0 0
	;;
esac


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
