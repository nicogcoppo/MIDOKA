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
# # SCRIPT para el seleccionado de la orden de carga a realizar

################### MANTENIMIENTO INICIAL #####################


#shopt -s -o unset

################### DECLARACIONES ########################

declare -r TABLA="$1"

declare TOTAL

declare CONTADOR

declare ENTRADA="9"

declare PROOVEDOR="$2"

declare BRUTO

declare DESCUENTO

#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	


mysql -u "${user}" --password="${pass}" --execute="SELECT repID AS ID,CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS DESCRIPCION,CANTIDAD_RE,ROUND(CANTIDAD_RE * CANTIDAD_MINIMA * IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (PRECIO_B IS NULL),PRECIO_A,PRECIO_B),2) AS MONTO FROM "${DB}"."${TABLA}" JOIN("${DB}".ARTICULOS,"${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MOTIVO.mtID="${DB}".ARTICULOS.MOTIVO AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".ARTICULOS.artID="${DB}"."${TABLA}".ID_ARTICULO_RE);" | column -t -s $'\t'>${temp}"tmp5.fact"


mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND(CANTIDAD_RE * CANTIDAD_MINIMA * IF((VIGENCIA_A <= CURDATE() AND VIGENCIA_A > VIGENCIA_B) OR (VIGENCIA_A <= CURDATE() AND VIGENCIA_B > CURDATE()) OR (PRECIO_B IS NULL),PRECIO_A,PRECIO_B),2) AS MONTO FROM "${DB}"."${TABLA}" JOIN("${DB}".ARTICULOS,"${DB}".PRECIOS,"${DB}".CATEGORIA,"${DB}".MODELO,"${DB}".MOTIVO) ON("${DB}".PRECIOS.RUBRO_pr="${DB}".ARTICULOS.RUBRO AND "${DB}".PRECIOS.CATEGORIA_pr="${DB}".ARTICULOS.CATEGORIA AND "${DB}".PRECIOS.MODELO_pr="${DB}".ARTICULOS.MODELO AND "${DB}".CATEGORIA.claID="${DB}".ARTICULOS.CATEGORIA AND "${DB}".MOTIVO.mtID="${DB}".ARTICULOS.MOTIVO AND "${DB}".MODELO.mdID="${DB}".ARTICULOS.MODELO AND "${DB}".ARTICULOS.artID="${DB}"."${TABLA}".ID_ARTICULO_RE);" | tail -n +2 >${temp}"tmp6.fact"



TOTAL=0
while read line_b; do
    TOTAL="$(maxima --very-quiet --batch-string "fpprintprec:7$"${TOTAL}"+"${line_b}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"
    
done<${temp}"tmp6.fact"

DESCUENTO="$(mysql -u "${user}" --password="${pass}" --execute="SELECT ROUND(1 - DESCUENTO/100,2) AS DESCUENTO FROM "${DB}".PROOVEDOR WHERE pooID="${PROOVEDOR}";" | tail -n +2)"

BRUTO="$(maxima --very-quiet --batch-string "fpprintprec:7$"${TOTAL}"*"${DESCUENTO}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"


echo -e "\n*  BRUTO -->  "${TOTAL}"              NETO -->  "${BRUTO}"     ">>${temp}"tmp5.fact"


cp ${temp}"tmp5.fact" ${temp}"temp2.cont"



################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.fact" 

rm $VAR_s

exit 192
