#!/bin/bash
#
# Script para la busqueda y visualizacion de datos del cliente
#

############## DECLARACIONES ###########################


declare VAR

declare -r ACTOR=$2



################# FUNCIONES ############################



function join_total { #Ingresa archivo texto con encabezados de tabla en columna uno y ID en archivo busqueda , devuleve una presentacion referenciada a las claves foraneas
    # HIPOTESIS >> los denominadores de las tablas foraneas son  los unicos  VARCHAR de mas de un digito en dicha tabla
    # EN la tabla ACTOR todos los INT son referenciados a claves foraneas excepto el PRIMARY_KEY 

    
    declare archivo=$1

    declare VAR_A

    declare VAR_select=""

    declare VAR_join

    declare VAR_on

    declare VAR_join2
    
    array=()
    while read line;do
	VAR_A=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | grep -E ''"""${line}"""'.*int')
	if test ! -z """${VAR_A}""";then
	    VAR_select+=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${line}";" | grep -E 'varchar.*(([0-9]{2})|[0-9]{3})' | awk '{print $1}')","
	    VAR_join+=""${DB}"."${line}","
	    VAR_on+=""${DB}"."${ACTOR}"."${line}"="${DB}"."${line}"."$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${line}";" | awk '{print $1}'| head -2 | tail -n +2)" AND "
	else
	    VAR_select+=""${line}""","
	fi
        
    done<${temp}${archivo}

    
    
    VAR_join2=$(echo ""${VAR_join}"" | sed 's/.$//')  

    VAR_join=$(echo ""${VAR_on}"" | sed -e "s/AND $//")

    VAR_on=$(echo ""${VAR_select}"" | sed 's/.$//')
    
    VAR_A="SELECT "${VAR_on}" FROM "${DB}"."${ACTOR}" JOIN (""${VAR_join2}"") ON (""${VAR_join}"") WHERE "${INDICE}"='"${VAR}"';"
    
    mysql -u "${user}" --password="${pass}" --execute="${VAR_A}">${temp}"join_salida.ed"
}

###############  SCRIPT ###########################



bash "./"${scr}"busqueda_tipo.sh" ""${ACTOR}""

case $? in
    192) exit 192;;
    204) exit 204;;
esac


VAR=$(cat ${temp}"busqueda")

INDICE=$(mysql -u "${user}" --password="${pass}" --execute="DESCRIBE "${DB}"."${ACTOR}";" | awk '{print $1}'| head -2 | tail -n +2)

mysql -u "${user}" --password="${pass}" --execute="SELECT * FROM "${DB}"."${ACTOR}" WHERE "${INDICE}"=""${VAR}"";" | head -n +1 | tr '\t' '\n' | tail -n +2 >${temp}"tmp.ed"

join_total "tmp.ed"

cat ${temp}"join_salida.ed" | tail -n +2 | tr '\t' '\n' >${temp}"tmp2.ed"

paste -d '\t' ${temp}"tmp.ed" ${temp}"tmp2.ed" | column -t -s $'\t'| sed '/$/G' | sed 's/^$/_______________________________________________/' > ${temp}"tmp3.ed"

dialog --textbox  ${temp}"tmp3.ed" 0 0




################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.ed" 

rm $VAR_s

exit 0
