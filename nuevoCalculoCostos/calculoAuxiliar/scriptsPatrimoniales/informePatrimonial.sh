#!/bin/bash
#
# Script para la confecccion del informe administrativo-contable quincenal
#

############## DECLARACIONES ###########################

user="nico"

pass="macaco12"

DB="MIDOKA_PGC_B"

resultados=$RANDOM

############## SCRIPT #################################


mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT FECHA FROM CONTABLES WHERE TIPO_REGISTRO=5 AND FECHA >='2019-06-01' ORDER BY FECHA ASC;" | tail -n +2 > /tmp/patrimonio.dat


while read line ; do


    cat ./calculoPatrimonial.sql | sed "s/LIMITACION/$line/g" >/tmp/calculoPatrimonial.sql

    test -f "/tmp/${resultados}" || mysql -u "${user}" --password="${pass}" </tmp/calculoPatrimonial.sql | head -1 | tr '\t' ';' >> /tmp/${resultados}  # Encabezado
    
    mysql -u "${user}" --password="${pass}" </tmp/calculoPatrimonial.sql | tail -n +2 | tr '\t' ';' | tr '.' ',' >> /tmp/${resultados}

done < /tmp/patrimonio.dat

rm ./patrimonio_*.csv 

cp /tmp/${resultados} ./patrimonio_$RANDOM.csv


############## MANTENIMIENTO #############

exit 0
