#!/bin/bash
#
# Script para la confeccion de una transanccion mediante un protocolo
# Si es exitosa, se elimina el archivo, si no lo es se queda

############## DECLARACIONES ###########################

declare -r MYSQL_SCRIPT="$1" 

declare SCRIPT_FINAL

declare SCRIPT_PRUEBA=""${temp}"/script_prueba"

############### FUNCIONES ##############################

function correo {

    #mail -s "ERROR TRANSACCION:"${user}"-"${DIA}"-"${RANDOM}".sql" nico@midoka.com.ar || mail -s "ERROR TRANSACCION:"${user}"-"${DIA}"-"${RANDOM}".sql" nico@B590DEBIAN871

    cp ${SCRIPT_FINAL} ./${sql}/transaccionesFallidas/
    
    
}

   
############## SCRIPT ##################################

# PRUEBO SI EXISTE EL ARCHIVO EN EL DESTINO, SINO LE CAMBIO EL NOMBRE

while true; do

    SCRIPT_FINAL=""${sql}""${user}"-"${DIA}"-"${RANDOM}".sql"
    test -e ${SCRIPT_FINAL} || break
done

echo "USE "${DB}";" >${SCRIPT_FINAL}

cat ${arc}"transaccion_a" >>${SCRIPT_FINAL}

test -z $(cat ${MYSQL_SCRIPT} | head -1) && (dialog --msgbox "ERROR IMPORTANTE DE TRANSACCION, INFORMARLO POR FAVOR" 0 0 && echo "El archivo estaba vacio" >>${SCRIPT_FINAL} && exit 1 )

cat ${MYSQL_SCRIPT} >>${SCRIPT_FINAL} 

cat ${arc}"transaccion_b" >>${SCRIPT_FINAL}

#cat ${SCRIPT_FINAL} | sed 's/COMMIT/ROLLBACK/' >${SCRIPT_PRUEBA}

#mysql -u "${user}" --password="${pass}" <${SCRIPT_PRUEBA} && (test -z "$(mysql -u "${user}" --password="${pass}" <${SCRIPT_FINAL} | grep ERROR | head -1)" && echo "eliminado") || (dialog --msgbox "ERROR IMPORTANTE DE TRANSACCION, INFORMARLO POR FAVOR" 0 0 && correo && exit 1) || (dialog --msgbox "ERROR IMPORTANTE DE TRANSACCION, INFORMARLO POR FAVOR" 0 0 && correo && exit 1)

#(test -z "$(mysql -u "${user}" --password="${pass}" <${SCRIPT_FINAL} 2>&1 | grep ERROR | head -1)" && rm ${SCRIPT_FINAL} && exit 0) || (dialog --msgbox "ERROR IMPORTANTE DE TRANSACCION, INFORMARLO POR FAVOR" 0 0 && correo && exit 1)

(test -z "$(mysql -u "${user}" --password="${pass}" <${SCRIPT_FINAL} 2>&1 | grep ERROR | head -1)" && exit 0) || (dialog --msgbox "ERROR IMPORTANTE DE TRANSACCION, INFORMARLO POR FAVOR" 0 0 && correo && exit 1) 

################### SOMETIDO A MANTENIMIENTO GENERAL ##################
