#!/bin/bash
#
# Confecciona un estado de resultados por cierre
#
# uso --> SCRIPT +  [FECHA INICIO DE INFORME]
############## DECLARACIONES ###########################

user="nico"

DB="MIDOKA_PGC_B"

INICIO=$1

resultados=$RANDOM

############## SCRIPT #################################

echo -e "\nPASSWORD... " 

read pass

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT FECHA FROM CONTABLES WHERE TIPO_REGISTRO=5 AND FECHA >='"${INICIO}"' ORDER BY FECHA ASC;" | tail -n +2 > /tmp/patrimonio.dat

## fechasTotal=$(expr $(wc -l /tmp/patrimonio.dat | awk '{print $1}') - "1")

fechasTotal=$(wc -l /tmp/patrimonio.dat | awk '{print $1}')

for ((i=1;i<fechasTotal;i++)) ; do

    sup=$(expr $i + "1")
    
    Linf=$(sed "${i}q;d" /tmp/patrimonio.dat)

    Lsup=$(sed "${sup}q;d" /tmp/patrimonio.dat)
    
    cat ./scripts/scriptSql/calculoPatrimonial.sql | sed "s/Linf/${Linf}/g" | sed "s/Lsup/${Lsup}/g" >/tmp/calculoPatrimonial.sql

    test -f "/tmp/${resultados}" || mysql -u "${user}" --password="${pass}" </tmp/calculoPatrimonial.sql | head -1 | tr '\t' ';' > /tmp/${resultados}  # Encabezado
    
    mysql -u "${user}" --password="${pass}" </tmp/calculoPatrimonial.sql | tail -n +2 | tr '\t' ';' | tr '.' ',' >> /tmp/${resultados}

done 

rm ./patrimonio_*.csv 

cp /tmp/${resultados} ./patrimonio_$RANDOM.csv


############## MANTENIMIENTO #############

exit 0
