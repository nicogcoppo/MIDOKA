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

echo "Ingrese password"

read pass

function instalar {

    while true; do
	
	echo "INGRESE MES"

	read MES

	echo "INGRESE DIA"

	read DIA

	mysql -u ${USER} --password="${pass}" -DMIDOKA_PGC_B </home/nico/RESGUARDO/MIDOKA_PGC_B/2019-${MES}-${DIA}_${HOSTNAME}.sql && break

	clear
	
    done
}

	

echo -e "1) DESCARGAR\n2) INSTALAR EXISTENTE"

read UNO

while true; do

    case $UNO in
	1) mysql -u ${USER} --password="${pass}" --execute="DROP DATABASE MIDOKA_PGC_B;CREATE DATABASE MIDOKA_PGC_B;" && bash ./scripts/rutina_esclavo_deposito.sh && instalar && break;;
	2) mysql -u ${USER} --password="${pass}" --execute="DROP DATABASE MIDOKA_PGC_B;CREATE DATABASE MIDOKA_PGC_B;" && instalar && break ;;
	*) echo "no se reconocio la orden . . . " ;;
    esac

done
  
		     

	

clear

echo "BASE DE DATOS SATISFACTORIAMENTE INSTALADA VERSION ${MES}-${DIA}"

exit 0



