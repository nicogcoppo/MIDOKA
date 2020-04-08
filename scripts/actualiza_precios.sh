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

declare CONTADOR

declare SOLICITUD

declare OPERACION

declare CLASE

declare SIGUIENTE_SOL

declare RECURSO

declare DIA_ASIGNA

declare TIPO_RECURSO

declare TEXTO

declare VAR_TEX
################### FUNCIONES ###############################

function busqueda_novedad {

    
    mysql -u "${user}" --password="${pass}" --execute="SELECT scID,DENOMINACION,tipo_oop,DATE_FORMAT(COMIENZO,'%d %b %Y') FROM "${DB}".SOLICITUDES JOIN ("${DB}".CLIENTE,"${DB}".ORDEN_OPERACION,"${DB}".OPERACIONES) ON ("${DB}".CLIENTE.clID="${DB}".OPERACIONES.INTERESADO AND "${DB}".OPERACIONES.opID="${DB}".SOLICITUDES.REFERENCIA AND "${DB}".ORDEN_OPERACION.oopID="${DB}".SOLICITUDES.CLASE) WHERE ASIGNADA='5' AND REALIZACION IS NULL AND COMIENZO IS NOT NULL ORDER BY COMIENZO DESC;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.cont"

    
    cat "./"${temp}"/tmp2.cont" | awk '{print $1}' >"./"${temp}"/tmp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.cont"

    cat "./"${temp}"/tmp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.cont"


    while true; do

	exec 3>&1
	SOLICITUD=$(dialog \
			--backtitle "TAREAS A REALIZAR" \
			--title """${INTERESADO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE LA OPERACION A GESTIONAR" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		limpieza
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		limpieza
		exit 204
		;;
	esac

	break
	
    done


    mysql -u "${user}" --password="${pass}" --execute="SELECT REFERENCIA,CLASE FROM "${DB}".SOLICITUDES WHERE scID="${SOLICITUD}";" | tail -n +2 >${temp}"tmp5.cont"

    OPERACION=$(cat ${temp}"tmp5.cont" | awk '{print $1}')

    CLASE=$(cat ${temp}"tmp5.cont" | awk '{print $2}')

    let SIGUIENTE_SOL=${SOLICITUD}+1

    TIPO_RECURSO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT tipo_recurso_oop FROM "${DB}".ORDEN_OPERACION WHERE oopID="${CLASE}";" | tail -n +2) 
}


function buscar_asignantes {


    declare -r TITULO=$1

    
    
    
    mysql -u "${user}" --password="${pass}" --execute="SELECT rhdID,nombre_rhd FROM "${DB}".RECURSOS_HUMANOS_DISPONIBLES JOIN ("${DB}".RECURSOS_HUMANOS) ON ("${DB}".RECURSOS_HUMANOS_DISPONIBLES.tipo_rhd="${DB}".RECURSOS_HUMANOS.rhID) WHERE tipo_rhd="${TIPO_RECURSO}" ;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.cont"
    
    cat "./"${temp}"/tmp2.cont" | awk '{print $1}' >"./"${temp}"/tmp3.cont"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.cont"

    cat "./"${temp}"/tmp2.cont" | sed 's/^[0-9]\+//' >"./"${temp}"/tmp4.cont"

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp4.cont"


    while true; do

	exec 3>&1
	RECURSO=$(dialog \
			--backtitle "RECURSOS HUMANOS" \
			--title """${TITULO}""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "FINALIZAR" \
			--menu "SELECCIONE EL RECURSO A ASIGNAR LA TAREA" 0 0 0 "${foraneos[@]}" \
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
		
		exit 192
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


function limpieza {

    
    VAR_s=${temp}"*.cont" 

    rm $VAR_s

}
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	




rm ${temp}"log_errores_nov.cont"

buscar_dia "SELECCIONAR FECHA DE ENTRADA EN VIGENCIA DEL NUEVO PRECIO"

while true; do
    
    bash  ${scr}"busqueda_articulo.sh" "PRECIOS"

    while true; do
	
	ID="$(cat ${temp}"busqueda")"

	NOMBRE="$(cat ${temp}"busqueda_nom")"
	
	mysql -u "${user}" --password="${pass}" --execute="SELECT IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (VIGENCIA_B IS NULL),VIGENCIA_A,VIGENCIA_B),IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (PRECIO_B IS NULL),PRECIO_A,PRECIO_B) FROM "${DB}".PRECIOS WHERE precioID='${ID}' ;" | tail -n +2 >${temp}"precio_sel.cont"

	FECHA="$(cat ${temp}"precio_sel.cont" | awk '{print $1}')"

	PRECIO="$(cat ${temp}"precio_sel.cont" | awk '{print $2}')"

	rm ${temp}"precio_sel2.cont"

	mysql -u "${user}" --password="${pass}" --execute="SELECT IF(VIGENCIA_A > CURDATE(),PRECIO_A,''),IF(VIGENCIA_B > CURDATE(),PRECIO_B,'') FROM "${DB}".PRECIOS WHERE precioID='${ID}' ;" | tail -n +2 >${temp}"precio_sel2.cont"

	VAR_TEX="$(cat ${temp}"precio_sel2.cont")"    

	if test -z ${VAR_TEX}; then
	    TEXTO="INTRODUCIR NUEVO PRECIO"
	else
	    TEXTO="ATENCION: YA EXISTE UN PRECIO DE MAGNITUD ="${VAR_TEX}" POR ENTRAR EN VIGENCIA"
	fi
	
	
	
	exec 3>&1
	NUEVO_PRECIO=$(dialog \
			   --backtitle "CONTABILIDAD" \
			   --title """${NOMBRE} : ULTIMO PRECIO ${PRECIO} , VIGENTE DESDE: ${FECHA}""" \
			   --clear \
			   --cancel-label "SALIR" \
			   --help-button \
			   --help-label "FINALIZAR" \
			   --inputbox """${TEXTO}""" 0 0\
			   2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		
		VAR_s=${temp}"*.cont" 

		rm $VAR_s

		exit 192
		;;
	    $DIALOG_ESC)
		clear

		
		VAR_s=${temp}"*.cont" 

		rm $VAR_s

		exit 204
		;;
	esac

	ARTICULO_DAT=$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT RUBRO_pr,CATEGORIA_pr,MODELO_pr FROM PRECIOS WHERE precioID='${ID}';" | tail -n +2 | tr '\t' ',')
	
	mysql -u "${user}" --password="${pass}" --execute="START TRANSACTION;USE "${DB}";UPDATE PRECIOS SET VIGENCIA_A=IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()),VIGENCIA_A,'${DIA_ASIGNA}'),VIGENCIA_B=IF(VIGENCIA_A = '${DIA_ASIGNA}',VIGENCIA_B,'${DIA_ASIGNA}'),PRECIO_B=IF(VIGENCIA_A = '${DIA_ASIGNA}',PRECIO_B,'${NUEVO_PRECIO}'),PRECIO_A=IF(VIGENCIA_A = '${DIA_ASIGNA}','${NUEVO_PRECIO}',PRECIO_A) WHERE precioID='${ID}' ;INSERT INTO PRHISTORICOS (RUBRO,CATEGORIA,MODELO,PRECIO,VIGENCIA) VALUES ("${ARTICULO_DAT}",'${NUEVO_PRECIO}','${DIA_ASIGNA}');COMMIT;"  && dialog --msgbox "PRECIO ACTUALIZADO CORRECTAMENTE" 0 0 

	mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";DELETE t1 FROM PRHISTORICOS t1 INNER JOIN PRHISTORICOS t2 WHERE t1.prhID < t2.prhID AND t1.RUBRO = t2.RUBRO AND t1.CATEGORIA = t2.CATEGORIA AND t1.MODELO = t2.MODELO AND t1.VIGENCIA = t2.VIGENCIA;"
	
	dialog --yesno "SEGUIR CON UN ARTICULO SIMILAR" 0 0 || break

	bash -o xtrace ${scr}"busqueda_articulo.sh" "PRECIOS" "SI"
	
	done
done   
    



################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
