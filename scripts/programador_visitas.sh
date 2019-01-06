#!/bin/bash
#
# Script para programar visitas
#

############## DECLARACIONES ###########################

declare INDICE

declare COLUMNA_REFERENCIA

declare VALOR

declare CONTADOR

declare VAR

declare VAR_a

declare -r DB="MIDOKA_PGC_B"




################# FUNCIONES ############################




###############  SCRIPT ###########################


mysql -u "${USER}" -p --execute="USE "${DB}";SELECT DENOMINACION,DIRECCION,estaf_lc,HORARIO FROM CLIENTE JOIN(SOLICITUDES,OPERACIONES,LOCALIDAD) ON(CLIENTE.clID=OPERACIONES.INTERESADO AND SOLICITUDES.REFERENCIA=OPERACIONES.opID AND CLIENTE.LOCALIDAD=LOCALIDAD.lcID) WHERE CLASE=1 AND COMIENZO IS NOT NULL AND REALIZACION IS NULL ORDER BY COMIENZO;"



################### MANTENIMIENTO ########################################


exit 0
