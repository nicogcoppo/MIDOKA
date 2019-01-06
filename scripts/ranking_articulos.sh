#!/bin/bash
#
# 
# Script para el estimado de compras

# USO --> intervaloDias 0.3 95 NCOMPRA RUBRO

############## DECLARACIONES ###########################

declare -r INTERVAL="$1"

declare -r ALFA="$2" ## Porcentaje de realimentacion real

declare -r BETA="$(maxima --very-quiet --batch-string 'fpprintprec:7$1-'${ALFA}';' | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"

declare -r CONF="$(maxima --very-quiet --batch-string 'fpprintprec:7$float(('$3'/100)+(1-('$3'/100))/2);' | tail -n +4 |sed /^[0-9]/d | sed s/[[:blank:]]//g)"

declare -r COMPRA="$4"

declare -r RUBRO="$5"

user="nico"

pass="macaco12"

############### FUNCIONES ##############################





   
############## SCRIPT ##################################


mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT ID_ARTICULO AS ID,CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS ARTICULO FROM PEDIDO JOIN(OPERACIONES,CATEGORIA,MODELO,MOTIVO,ARTICULOS,PROOVEDOR,PRECIOS) ON(OPERACIONES.opID=OPERACION_REFERENCIA AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr AND ARTICULOS.MODELO=PRECIOS.MODELO_pr) GROUP BY ID_ARTICULO ORDER BY SUM(CANTIDAD * CANTIDAD_MINIMA / CANTIDAD_BULTO) DESC;" | tr '\t' ';' >/home/nico/Desktop/RANKING_$RANDOM.csv



################### SOMETIDO A MANTENIMIENTO GENERAL ##################

exit 0
