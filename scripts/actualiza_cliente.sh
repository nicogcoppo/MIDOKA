#!/bin/bash
#
# Script para el agregado de un nuevo cliente
#

############## DECLARACIONES ###########################

declare -a foraneos

declare -a flag_f

declare CONTADOR

declare VAR

declare -a INDISPENSABLE=("1" "2")

declare -r ACTOR=$2

declare INDICE

################# FUNCIONES ############################

function control_estados {
    
    CONTADOR=0
    while read line ; do

	if [ "$line" = ".." ] ; then
	    line="INCOMPLETO"
	fi
    	
	flag_f[${CONTADOR}]="${line}"
	let CONTADOR+=1
	
    done < "./"${temp}"/tmp_num_v.ed"


    CONTADOR=0
    foraneos=()
    while read line ; do


	foraneos+=("${line}" "${flag_f[${CONTADOR}]}")
	let CONTADOR+=1
	
    done < "./"${temp}"/tmp.ed"
}


# La funcion ubicar , escribe en la linea de texto correlativa a la ubicacion en el archivo tmp.ed

function ubicar { # $selection
    
    CONTADOR=$(grep -nr "${1}" "./"${temp}"/tmp.ed" | tr ':' '\t' | awk '{print $1}')

    
    cat ""${temp}"/selection.ed" | tail -n +2 | awk '{print $1}' >""${temp}"/a.ed"

    
    cat ""${temp}"/selection.ed" | tail -n +2 | awk 'BEGIN{FS=OFS="\t"}{$1="";}1' >""${temp}"/b.ed"    

    
    VAR="$(cat ""${temp}"/a.ed")"
    
    awk 'NR=='"${CONTADOR}"'{print "'"${VAR}"'"}1' ""${temp}"/tmp_num.ed" > ""${temp}"/tmp3.ed"
   
    
    mv ""${temp}"/tmp3.ed" ""${temp}"/tmp_num.ed" 

    awk 'NR=='"${CONTADOR}"'{print "'"$(cat ""${temp}"/b.ed")"'"}1' ""${temp}"/tmp_num_v.ed" > ""${temp}"/tmp3.ed"


    mv ""${temp}"/tmp3.ed" ""${temp}"/tmp_num_v.ed"

    let CONTADOR+=1
    
    sed -i -e ''"${CONTADOR}"'d' ""${temp}"/tmp_num.ed" ""${temp}"/tmp_num_v.ed"

    
}

# Controla que se haya ubicado informacion en el archivo de texto, en las lineas
# especificadas en el array

function control_indispensables {  # ARRAY ARCHIVO>archivo.ed

    declare -a array=("$@")
    declare -r archivo=$(cat ""${temp}"archivo.ed")
    declare VAR_A

    echo "NO UTIL"> ""${temp}"/selection.ed"
    
    CONTADOR=0
    for i in ${array[@]};do
	VAR_A=$(sed ''${i}'q;d' ""${temp}""${archivo}"")
	if test -z ${VAR_A} ;then
	    echo -e "1" '\t' "INCOMPLETO" >> ""${temp}"/selection.ed"
	    ubicar "DATOS"
	    return
	fi
	
    done
    echo -e "1" '\t' "COMPLETO" >> ""${temp}"/selection.ed"
    ubicar "DATOS"
}

function actualizado { # SE CONTROLA QUE ESTEN TODOS LOS DATOS COMPLETOS Y SE PROCEDE A CREAR UNA FILA EN MARIADB CON DICHOS DATOS
 
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

    INDICE=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | awk '{print $1}'| head -2 | tail -n +2)
    
    DATA=$(cat ${temp}"data_grabado.ed")

    DENOMINACION=$(cat ${temp}"busqueda")
    
    rm ${temp}"log_grabado.ed"

    VAR="UPDATE "${DB}"."${ACTOR}" SET "${DATA}" WHERE "${INDICE}"=""${DENOMINACION}"";"

    mysql -u "${user}" --password="${pass}" --execute="${VAR}"  2>${temp}"log_grabado.ed"
    
    if test -s ${temp}"log_grabado.ed"; then
	DATA=$(cat ${temp}"log_grabado.ed")
        dialog --msgbox "${DATA}" 0 0
        return 2
    else
	dialog --msgbox "Actualizacion de datos Exitosa" 0 0
	return 0
    fi
    

    
}
    

function pre_grabar { # PREPARA LOS INDICADORES Y LOS DATOS A GRABAR. JUNTA LOS ARCHIVOS QUE SEAN NECESARIOS

    declare -r DENOMINACION_UNO=${temp}$1

    declare -r DENOMINACION_DOS=${temp}$2

    declare -r DATA_UNO=${temp}$3

    declare -r DATA_DOS=${temp}$4

    sed '$d' ${DENOMINACION_UNO}  >${temp}"tmp_denominaciones_grabado.ed"

    cat ${DENOMINACION_DOS} >>${temp}"tmp_denominaciones_grabado.ed"

    cat ${temp}"tmp_denominaciones_grabado.ed" | sed '/^$/d' >${temp}"denominaciones_grabado.ed"

   
    
    cat ${DATA_UNO} >${temp}"tmp_data_grabado.ed"

    sed 's/^\x24/-&/' ${DATA_DOS} >>${temp}"tmp_data_grabado.ed"

    sed -i 's/^\|$/"/g' ${temp}"tmp_data_grabado.ed" 


    
    paste -d '=' ${temp}"denominaciones_grabado.ed" ${temp}"tmp_data_grabado.ed" | tr '\n' ',' | sed 's/.$//' >${temp}"data_grabado.ed"


    
    
}
    

function identificar { # Funcion que lee los encabezados de tabla segun $1 y los guarda en el archivo $2

    declare VAR

    declare CONTADOR

    declare INDICE

    declare JOIN_S

    declare ON_S

    declare VAR2

    declare VAR3=""
    
    VAR=$(cat "./"${temp}${1} | sed '$d' | tr '\n' ',' | sed 's/.$//')

    CONTADOR=$(cat ${temp}"busqueda")

    INDICE=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | awk '{print $1}'| head -2 | tail -n +2)


    if test -z $3; then

	mysql -u "${user}" --password="${pass}" --execute="SELECT "${VAR}" FROM "${DB}"."${ACTOR}" WHERE "${INDICE}"='"${CONTADOR}"';" | tail -n +2 | tr '\t' '\n' >${temp}"tmp_iden.ed"

    else

	

	

	JOIN_S=$(cat "./"${temp}${1} | sed '$d' | sed "s/^/"${DB}"./" | tr '\n' ',' | sed 's/.$//' )

	cat "./"${temp}${1} | sed '$d' | sed "s/^/"${DB}"."${ACTOR}"./" >${temp}"tmp_iden_3.ed"

	cat "./"${temp}${1} | sed '$d' | sed "s/^/"${DB}"./" >${temp}"tmp_iden_2.ed"

	while read line;do
	    
	    VAR2=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${line}";" | awk '{print $1}'| head -2 | tail -n +2)
	    
	    sed -i "/^"${line}"/ s/$/."${VAR2}"/" ${temp}"tmp_iden_2.ed"
	    
	    VAR3+=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${line}";" | grep -E 'varchar.*(([0-9]{2})|[0-9]{3})' | awk '{print $1}')","

	done<${temp}"tmp_iden_2.ed"

	VAR=$(echo "${VAR3}" | sed 's/.$//')
	
	ON_S=$(paste -d = ${temp}"tmp_iden_3.ed" ${temp}"tmp_iden_2.ed" | tr '\n' ',' | sed 's/.$//' | sed "s/,/ AND /g")
	
	VAR="SELECT "${VAR}" FROM "${DB}"."${ACTOR}" JOIN ("${JOIN_S}") ON ("${ON_S}") WHERE "${INDICE}"='"${CONTADOR}"';"
		
	
	mysql -u "${user}" --password="${pass}" --execute="${VAR}" | tail -n +2 | tr '\t' '\n' >${temp}"tmp_iden.ed"
    fi
    
   

    
    mv ${temp}"tmp_iden.ed" ${temp}${2}
}


    
function limpiado {

    
    VAR_s=${temp}"*.ed" 

    rm $VAR_s

}



###############  SCRIPT ###########################

## Se agrupan los campos de las tablas clientes por 1) CLAVES FORANEAS 2) VARCHAR

mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | grep int | awk '{print $1}'| tail -n +2 > "./"${temp}"/tmp.ed"

mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | grep -v int | awk '{print $1}' | tail -n +2  > "./"${temp}"/tmp2.ed"

echo "DATOS" >>"./"${temp}"/tmp.ed"

rm ""${temp}"/tmp_num.ed" ""${temp}"/tmp_num_v.ed"

touch ""${temp}"/tmp_num.ed" ""${temp}"/tmp_num_v.ed"

# Cargado de datos en los archivos temporales segun los datos en MariaDB

bash "./"${scr}"busqueda_tipo.sh" ""${ACTOR}""

identificar "tmp.ed" "tmp_num.ed"

identificar "tmp2.ed" "tmp_radio.ed"

identificar "tmp.ed" "tmp_num_v.ed" "x"

echo "COMPLETO" >>${temp}"tmp_num_v.ed"




while true; do
  control_estados  
  exec 3>&1
  selection=$(dialog \
    --backtitle "ADMINISTRACION" \
    --title "EDICION "${ACTOR}" EXISTENTE" \
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
	
      actualizado "tmp_num_v.ed" "tmp.ed" "tmp2.ed" "tmp_num.ed" "tmp_radio.ed"
	
      case $? in
	  1) selection="ERROR";;
	  2) selection="ERROR_mdb";;
	  *) limpiado
	     exit 192;;
      esac
      
      
      ;;
  esac
  case $selection in


     "ERROR")
        dialog --msgbox "ERROR DE GUARDADO : No todos los campos necesarios han sido completados" 0 0;;

     "ERROR_mdb")
        dialog --msgbox "Se acaba de producir un error de guardado en la base de datos" 0 0;;
      
     
    "DATOS" )
	

	bash ""${scr}"/radio_std.sh" "ADMINISTRACION" "EDICION "${ACTOR}" EXISTENTE" "DATOS "${ACTOR}"" "tmp2.ed" "tmp_radio.ed"

       	echo "tmp_radio.ed" > ""${temp}"archivo.ed"

	control_indispensables "${INDISPENSABLE[@]}" 

      ;;
    "LOCALIDAD")

      if test ! -f ""${temp}"/c.ed" -a ! -f ""${temp}"/d.ed" ; then

	  dialog --msgbox "DEBE SELECCIONAR UNA PROVINCIA PRIMERO" 0 0
      else
	  	  	  
	  dialog --inputbox "BUSQUEDA DE LOCALIDAD" 0 0 2>""${temp}"/c.ed"
	  
	  mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -1 > ""${temp}"/b.ed"

	  
	  VAR=$(cat ""${temp}"/c.ed" | sed 's/\\//g')

	  CONTADOR=$(cat ""${temp}"/d.ed" | sed 's/\\//g')
	  
	  mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -3 | sed -e 2d | sed -e 2d | tr '\n' ',' | sed 's/.$//g'  > ""${temp}"/a.ed"

	  mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -1 > ""${temp}"/b.ed"

	  bash ""${scr}"/seleccion_std.sh" "ADMINISTRACION" "EDICION "${ACTOR}" EXISTENTE" "${selection}" "${selection}" "lcID,estaf_lc" "$(cat ""${temp}"/b.ed")" "letra_lc" '"'${CONTADOR}'"' "estaf_lc" '"%'${VAR}'%"'

	  case $? in
	      192)
		  rm ""${temp}"/a.ed" ""${temp}"/b.ed"
		  dialog --msgbox "No hay ningun resultado que coincida con el criterio de busqueda" 0 0
		  ;;
	      *)	  
		rm ""${temp}"/a.ed" ""${temp}"/b.ed"
		ubicar "$selection";;
	  esac
	  
	  
	  

      fi
      
      ;;
    "PROVINCIA")
        mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -3 | sed -e 2d | tr '\n' ',' | sed 's/.$//g' > ""${temp}"/a.ed"
	mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -1 > ""${temp}"/b.ed"
	
        bash ""${scr}"/seleccion_std.sh" "ADMINISTRACION" "EDICION "${ACTOR}" EXISTENTE" "${selection}" "${selection}" "$(cat ""${temp}"/a.ed")" "$(cat ""${temp}"/b.ed")"
	VAR=$(cat ""${temp}"/selection.ed" | tail -n +2 | awk '{print $1}')
	
        mysql -u "${user}" --password="${pass}" --execute="SELECT letra_pr FROM "${DB}"."${selection}" WHERE prID="${VAR}";" | tail -n +2 >""${temp}"/d.ed"  

        rm ""${temp}"/a.ed" ""${temp}"/b.ed"
      
        ubicar "$selection"

	;;

    *)

      mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -1 > ""${temp}"/b.ed"

      mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${selection}";" | tail -n +2 | awk '{print $1}' | head -2 | tr '\n' ',' | sed 's/.$//g' > ""${temp}"/a.ed"
            
      
      bash ""${scr}"/seleccion_std.sh" "ADMINISTRACION" "EDICION "${ACTOR}" EXISTENTE" "${selection}" "${selection}" "$(cat ""${temp}"/a.ed")" "$(cat ""${temp}"/b.ed")"
      
      rm ""${temp}"/a.ed" ""${temp}"/b.ed"
      
      ubicar "$selection"

      
      ;;
    
  esac
done




################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 0
