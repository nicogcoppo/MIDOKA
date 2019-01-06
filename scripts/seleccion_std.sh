#!/bin/bash
#
#
#
# script: Contiene al menu principal
# 
#
#
#
# $FONDO $TITULO $SUB-TITULO $TABLA $COLUMNAS $SELECCION ${condicion}
#
#
# 
#

#shopt -s -o unset

################### DECLARACIONES ########################

declare -r TABLA=$4

declare -r COLUMNAS=$5

declare -r FONDO="$1"

declare -r TITULO="$2"

declare -r SUBT="${3}"

declare -r COND_A=$7

declare -r COND_B=$8

declare -r COND_C=$9

declare -r COND_D=${10}

declare SALIDA=${11}

declare -r SEL=$6

declare -r SCRIPT=${0##*/}




if test -z ${SALIDA} ;then
   SALIDA="selection.ed"
fi
   

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

## Ejecuto MYSQL con determinadas filas segun seleccion argumentada al llamar a este script
## las adecuo para su visualizacion, guardo adecuacion en array

if test -z "${COND_A}" ;then
    mysql -u "${user}" --password="${pass}" --execute="SELECT "${COLUMNAS}" FROM "${DB}"."${TABLA}"; " >"./"${temp}"tmp.s"
else
   
    mysql -u "${user}" --password="${pass}" --execute="SELECT "${COLUMNAS}" FROM "${DB}"."${TABLA}" WHERE "${COND_A}" LIKE "${COND_B}" AND "${COND_C}" LIKE ""${COND_D}""; " >"./"${temp}"tmp.s"
fi

if test ! -s "./"${temp}"tmp.s";then
    rm "./"${temp}"tmp.s"
    exit 192
fi




sed 's/\x09/\t/g' <"./"${temp}"tmp.s" | tail -n +2 | column -t -s $'\t' >"./"${temp}"tmp2.s"


ar=()
while read n s ; do
    ar+=($n "$s")
done < "./"${temp}"tmp2.s"




## Muestro menu segun parametros argumentados y array previamente adecuado

while true; do
  exec 3>&1
  selection=$(dialog --column-separator '\t' --backtitle "${FONDO}" --title "${TITULO}" --menu "${SUBT}" 0 0 0 "${ar[@]}" 2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL) 
      clear
      echo "SE CANCELO LA OPERACION "
      break
      ;;
    $DIALOG_ESC)
      clear
      echo "SE ABORTO LA OPERACION" >&2
      break
      ;;
  esac
 
  if ! [[ $selection =~ $re ]] ; then
      no=5
  else
      
      mysql -u "${user}" --password="${pass}" --execute="SELECT "${COLUMNAS}" FROM "${DB}"."${TABLA}" WHERE "${SEL}"="${selection}";" > ""${temp}""${SALIDA}"" 
      break          
  fi

  
done


################## MANTENIMIENTO ###################



POSICION=0

VAR_s=${temp}"*.s" 

rm $VAR_s

exit 0

