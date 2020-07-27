#!/bin/bash
#
# Confecciona un INFORME RESUMIDO para contables
#
# uso --> SCRIPT + [FECHA INICIO DE INFORME] + [FECHA FINALIZACION DE INFORME] 
############## DECLARACIONES ###########################

user="nico"

DB="MIDOKA_PGC_B"

Linf=$1

Lsup=$2

resultados=$RANDOM

costos=$RANDOM

############## SCRIPT #################################

echo -e "\nPASSWORD... " 

read pass

###--- ANALISIS ECONOMICO -- ###

cat ./scripts/scriptSql/informeContable.sql | sed "s/Linf/${Linf}/g" | sed "s/Lsup/${Lsup}/g" >/tmp/informeContable.sql

test -f "/tmp/${resultados}" || mysql -u "${user}" --password="${pass}" </tmp/informeContable.sql | head -1 | tr '\t' ';' > /tmp/${resultados}  # Encabezado

mysql -u "${user}" --password="${pass}" </tmp/informeContable.sql | tail -n +2 | tr '\t' ';' | tr '.' ',' >> /tmp/${resultados}

cp /tmp/${resultados} ./informeContable_$RANDOM.csv

###--- DETALLE COSTOS -- ###

cat ./scripts/scriptSql/detalleCostos.sql | sed "s/Linf/${Linf}/g" | sed "s/Lsup/${Lsup}/g" >/tmp/detalleCostos.sql

test -f "/tmp/${costos}" || mysql -u "${user}" --password="${pass}" </tmp/detalleCostos.sql | head -1 | tr '\t' ';' > /tmp/${costos}  # Encabezado

mysql -u "${user}" --password="${pass}" </tmp/detalleCostos.sql | tail -n +2 | tr '\t' ';' | tr '.' ',' >> /tmp/${costos}

cp /tmp/${costos} ./detalleCostos_$RANDOM.csv



############## MANTENIMIENTO #############

exit 0
