#!/bin/bash
#
# script $(directorio archivos) $(dir temporal) $(directorio mysql) $(base datos)
#
# COPIADO DE ARCHIVOS NECESARIOS PARA CARGAR TABLAS SUPER USUARIO


############################ DECLARACIONES #####################

declare -r arc=("$1")

declare -r temp=("$2")

declare -r DIR=("$3")

declare -r DB=("$4")

declare -r tablas=("tablas")

############################# FUNCIONES ########################

# $(datos) $(archivo salida)

function pic {     # funcion que elimina la primera fila y la primera columna incluyendo "|" , para el cargado en mariadb
   
    sed 's/^[0-9]\+|//g' ${1} | tail -n +2 > ${2}  

}    



############################ SCRIPT ############################

pic ${arc}${tablas} "./"${temp}"/tmp2.su"

while read line; do

   tail -n +2 ${arc}${line} > ${temp}"tmp3.su" 
    
   cp ${temp}"tmp3.su"  ${DIR}${DB}"/"${line}
 
   cp ${arc}"carac_"${line} ${DIR}${DB}"/"
   
done<"./"${temp}"/tmp2.su"




########################## MANTENIMIENTO #######################



VAR_s=${temp}"*.su" 

rm $VAR_s

exit 192
