#!/bin/bash
#
# Script para el agregado de un nuevo cliente
#

############## DECLARACIONES ###########################

declare -a foraneos

declare -a flag_f

declare CONTADOR

declare VAR

declare -a INDISPENSABLE=("1" "2" "3" "4")

declare -r ACTOR="PRECIOS"

declare CONTADOR

declare SOLICITUD

declare ARTICULO

declare NOMBRE_ARTICULO

################# FUNCIONES ############################


function busqueda_novedad {

    
    mysql -u "${user}" --password="${pass}" --execute="SELECT nartID,rubro_rb,clasificacion_cla,mod_md FROM "${DB}".NUEVO_ARTICULO JOIN ("${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO) ON ("${DB}".RUBRO.ruID="${DB}".NUEVO_ARTICULO.RUBRO AND "${DB}".CATEGORIA.claID="${DB}".NUEVO_ARTICULO.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".NUEVO_ARTICULO.MODELO) WHERE REALIZACION IS NULL AND FECHA IS NOT NULL ORDER BY FECHA ASC ;" | tail -n +2 | column -t -s $'\t'>${temp}"tmp2.cont"
    
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
		
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;
	esac

	break
	
    done

    ARTICULO=$(mysql -u "${user}" --password="${pass}" --execute="SELECT RUBRO,CATEGORIA,MODELO FROM "${DB}".NUEVO_ARTICULO WHERE nartID="${SOLICITUD}" ;" | tail -n +2 | tr '\t' '\n' | sed 's/^\|$/"/g' | tr '\n' ',')

    NOMBRE_ARTICULO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT clasificacion_cla,mod_md FROM "${DB}".NUEVO_ARTICULO JOIN ("${DB}".RUBRO,"${DB}".CATEGORIA,"${DB}".MODELO) ON ("${DB}".RUBRO.ruID="${DB}".NUEVO_ARTICULO.RUBRO AND "${DB}".CATEGORIA.claID="${DB}".NUEVO_ARTICULO.CATEGORIA AND "${DB}".MODELO.mdID="${DB}".NUEVO_ARTICULO.MODELO) WHERE nartID="${SOLICITUD}" ;" | tail -n +2 )"
    
    
    
    
}




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
    
function limpiado {

    
    VAR_s=${temp}"*.cont" 

    rm $VAR_s

}

###############  SCRIPT ###########################

## Se agrupan los campos de las tablas clientes por 1) CLAVES FORANEAS 2) VARCHAR




busqueda_novedad

rm ${temp}"log_errores_nov.cont"


mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | tail -n +3 | head -2 | awk '{print $1}'> "./"${temp}"/tmp.cont"

mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | tail -n +12 | awk '{print $1}'> "./"${temp}"/tmp2.cont"

echo "DATOS" >>"./"${temp}"/tmp.cont"

rm ""${temp}"/tmp_num.cont" ""${temp}"/tmp_num_v.cont"

touch ""${temp}"/tmp_num.cont" ""${temp}"/tmp_num_v.cont"

while read line;do

    echo ".." >>""${temp}"/tmp_num.cont"

    echo ".." >>""${temp}"/tmp_num_v.cont"

done < "./"${temp}"/tmp.cont"



while true; do
  control_estados  
  exec 3>&1
  selection=$(dialog \
    --backtitle "CONTABILIDAD" \
    --title """${NOMBRE_ARTICULO}""" \
    --clear \
    --cancel-label "SALIR" \
    --help-button \
    --help-label "FINALIZAR" \
    --menu "SELECCIONAR USANDO ENTER:" 0 0 0 "${foraneos[@]}" \
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
	
      grabacion "tmp_num_v.cont" "tmp.cont" "tmp2.cont" "tmp_num.cont" "tmp_radio.cont"
	
      case $? in
	  1) selection="ERROR";;
	  2) selection="ERROR_mdb";;
	  *) limpiado
	     break;;
      esac
      
      
      ;;
  esac
  case $selection in


     "ERROR")
        dialog --msgbox "ERROR DE GUARDADO : No todos los campos necesarios han sido completados" 0 0;;

     "ERROR_mdb")
        dialog --msgbox "Se acaba de producir un error de guardado en la base de datos" 0 0;;
      
     
    "DATOS" )
	
		
 	bash ""${scr}"/radio_std.sh" "CONTABILIDAD" "INGRESO NUEVO "${ACTOR}"" "DATOS "${ACTOR}"" "tmp2.cont" "tmp_radio.cont"

	echo "tmp_radio.cont" > ""${temp}"archivo.cont"

	control_indispensables "${INDISPENSABLE[@]}" 

      ;;

    "PROOVEDOR")

      mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -1 > ""${temp}"/b.cont"

      echo "pooID,NOMBRE_COMERCIAL" > ""${temp}"/a.cont"
      
      bash ""${scr}"/seleccion_std.sh" "CONTABILIDAD" "INGRESO NUEVO "${ACTOR}"" "${selection}" "${selection}" "$(cat ""${temp}"/a.cont")" "$(cat ""${temp}"/b.cont")" "" "" "" "" "selection.cont"
      
      rm ""${temp}"/a.cont" ""${temp}"/b.cont"
      
      ubicar "$selection"

      
      ;;

    
    *)

      mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -1 > ""${temp}"/b.cont"

      mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -2 | tr '\n' ',' | sed 's/.$//g' > ""${temp}"/a.cont"
            
      
      bash ""${scr}"/seleccion_std.sh" "CONTABILIDAD" "INGRESO NUEVO "${ACTOR}"" "${selection}" "${selection}" "$(cat ""${temp}"/a.cont")" "$(cat ""${temp}"/b.cont")" "" "" "" "" "selection.cont"
      
      rm ""${temp}"/a.cont" ""${temp}"/b.cont"
      
      ubicar "$selection"

      
      ;;
    
  esac
done





case $? in
    0)

	if test -z ${temp}"log_errores_nov.cont";then
	    dialog --msgbox "OCURRIO UN ERROR EN EL ACTUALIZADO DE LA NOVEDAD" 0 0
	    exit 192
	else
	    dialog --msgbox "NOVEDAD ACTUALIZADA CORRECTAMENTE" 0 0
	    mysql -u "${user}" --password="${pass}" --execute="UPDATE "${DB}".NUEVO_ARTICULO SET REALIZACION='${DIA}' WHERE nartID="${SOLICITUD}";"
	fi

	;;
esac



################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 0
