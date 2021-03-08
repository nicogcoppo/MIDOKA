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

declare -r PROOVEDOR="$6"

############### FUNCIONES ##############################





   
############## SCRIPT ##################################

#### Seteo inicial

AGMYSQL=""${temp}"/"${RANDOM}".grabado"

rm ${AGMYSQL}

test -f "${AGMYSQL}" || touch "${AGMYSQL}"

#### Consumo segun intervalo

mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT ID_ARTICULO AS ARTICULO,SUM(CANTIDAD) AS CANTIDAD,STDDEV(CANTIDAD) AS S,AVG(CANTIDAD) AS MEDIA,COUNT(CANTIDAD) AS N,ROUND((IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),(1 + VALOR_AGREGADO / 100) * IFNULL(PRECIO_A,0),(1 + VALOR_AGREGADO / 100) * IFNULL(PRECIO_B,0))) * CANTIDAD_MINIMA,2) AS PRECIO,ROUND(IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),IFNULL(PRECIO_A,0) * CANTIDAD_MINIMA *(1 - DESCUENTO / 100) ,IFNULL(PRECIO_B,0) * CANTIDAD_MINIMA * (1 - DESCUENTO / 100)) ,2) AS COSTO,VOLUMEN_CM3 AS VOLUMEN FROM PEDIDO JOIN(OPERACIONES,PRECIOS,ARTICULOS,PROOVEDOR) ON(OPERACIONES.opID=OPERACION_REFERENCIA AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr AND ARTICULOS.MODELO=PRECIOS.MODELO_pr AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR) WHERE FECHA BETWEEN DATE_SUB(CURDATE(),INTERVAL "${INTERVAL}" DAY) AND CURDATE() AND RUBRO="${RUBRO}" AND PROOVEDOR="${PROOVEDOR}" AND INTERESADO<>275 AND INTERESADO<>303 AND INTERESADO<>340 AND INTERESADO<>337 AND INTERESADO<>314 GROUP BY ID_ARTICULO;" | tail -n +2  >"temp1.compras"
### ACA SE DESESTIMAN LOS INTERESADOS COMO LA TERMINAL SERRANO Y OTROS PARA LA COMPRA

while read line; do

    N="$(echo ${line} | awk '{print $5}')"

    let N_1=$N-1
    
    MED="$(echo ${line} | awk '{print $4}')"

    S="$(echo ${line} | awk '{print $3}')"

    REAL="$(echo ${line} | awk '{print $2}')"

    ID="$(echo ${line} | awk '{print $1}')"

    PVENTA="$(echo ${line} | awk '{print $6}')"

    COSTO="$(echo ${line} | awk '{print $7}')"

    VOLUMEN="$(echo ${line} | awk '{print $8}')"
    
    ## Estimacion de intervalos al 95% de confianza

    if [[ "$N" -gt '39' ]]; then

	ST="$(R -q -e '('${MED}'+qnorm('${CONF}')*'${S}'/sqrt('${N}'))*'${N}'' | grep -v '>' | awk '{print $2 $3}')"

	TIPO="1"

    elif [[ "$N" -lt '10' ]]; then

	
	ST=$REAL

	TIPO="0"


	
    else

	ST="$(R -q -e '('${MED}'+qt('${CONF}','${N_1}')*'${S}'/sqrt('${N}'))*'${N}'' | grep -v '>' | awk '{print $2 $3}')"

	TIPO="2"
	
    fi
    
    D="$(maxima --very-quiet --batch-string "fpprintprec:7$"${ALFA}"*"${REAL}"+"${BETA}"*"${ST}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"

    STOCK="$(mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT (SUM(IFNULL(CANTIDAD_CST,0)) + SUM(IFNULL(CANTIDAD_ING,0)) + SUM(IFNULL(CANTIDAD_DEVOL,0)) - SUM(IFNULL(CANTIDAD_EGR,0)) - SUM(IFNULL(CANTIDAD_AR,0))) AS CANTIDAD FROM ARMADO WHERE ID_ARTICULO_AR="${ID}";" | tail -n +2)"

    if [[ "$STOCK" -lt '0' ]]; then

	STOCK="0"
    fi
    
    ### ID // COMPRA // DEMANDA REAL // $VENTA // $COSTO // N // ESTIMADA // DEMANDA ESTIMADA // NORMALoSTUDENT // CONFIAZA // REALIDAD // STOCK // VOLUMEN
    
    echo -e "${COMPRA}\t${ID}\t${REAL}\t${PVENTA}\t${COSTO}\t${N}\t${ST}\t${D}\t${TIPO}\t${CONF}\t${ALFA}\t${STOCK}\t${VOLUMEN}" | grep -v "NaN" | tr '\t' ',' | sed 's/^/INSERT INTO DEMANDAS (COMPRA,ARTICULO,D_REAL,PVENTA,COSTO,n,D_EST,d,METODO,CONFIANZA,REALIDAD,STOCK,VOLUMEN) VALUES(/' | sed 's/$/);/'  >>${AGMYSQL}
																	    
    
    
    
done<"temp1.compras"


bash ${scr}"transaccion.sh" "${AGMYSQL}"

################### SOMETIDO A MANTENIMIENTO GENERAL ##################

exit 0
