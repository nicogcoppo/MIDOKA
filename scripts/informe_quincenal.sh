#!/bin/bash
#
# Script para la confecccion del informe administrativo-contable quincenal
#

############## DECLARACIONES ###########################

user="nico"

pass="macaco12"

DB="MIDOKA_PGC_B"



############## FUNCIONES ###############################

function enscript {

    paps --font=Monospace\ 14 ./data_texto.dat >./informe-quincenal-data.eps

    #cat data_texto.dat | tail -n +6 >./data_texto-b.dat # recorto patrimonio
    
    #paps --font=Monospace\ 14 ./data_texto-b.dat >./informe-quincenal-data-b.eps

    #gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -sOutputFile=./informe-contable-parte-b.pdf ./informe-quincenal-data-b.eps
}


############## SCRIPT #################################

rm -rf informeQuincenal 

mkdir "informeQuincenal"

cp ./scripts/ploteoEconomico.gp ./informeQuincenal/

### VENTAS

#mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,ROUND(SUM(DEBE),2) AS FACTURACION,ROUND(SUM(DEVOLUCION),2) AS DEVOLUCION FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ASC;" >./informeQuincenal/nivel_ventas.dat

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT t1.MES AS MES,t2.FACTURACION AS FACTURACION,t2.DEVOLUCION AS DEVOLUCION,IFNULL(t1.COSTO,0) AS FALTANTES FROM (SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,SUM(CANTIDAD_FL*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO,0) / 100)) AS 'COSTO' FROM FALTANTE JOIN(PRECIOS,CATEGORIA,MODELO,CONDICION,ARTICULOS,CLIENTE,OPERACIONES,PROOVEDOR) ON(PRECIOS.RUBRO_pr=ARTICULOS.RUBRO AND PRECIOS.CATEGORIA_pr=ARTICULOS.CATEGORIA AND PRECIOS.MODELO_pr=ARTICULOS.MODELO AND CATEGORIA.claID=ARTICULOS.CATEGORIA AND MODELO.mdID=ARTICULOS.MODELO AND CONDICION.cdID=CLIENTE.CONDICION AND CLIENTE.clID=OPERACIONES.INTERESADO AND ARTICULOS.artID=ID_ARTICULO_FL AND OPERACIONES.opID=OPERACION_REFERENCIA_FL AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR) JOIN PRHISTORICOS t1 ON(PRECIOS.RUBRO_pr=t1.RUBRO AND PRECIOS.CATEGORIA_pr=t1.CATEGORIA AND PRECIOS.MODELO_pr=t1.MODELO AND t1.VIGENCIA<=OPERACIONES.FECHA) LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO AND t1.CATEGORIA=t2.CATEGORIA AND t1.MODELO=t2.MODELO AND t2.VIGENCIA > t1.VIGENCIA AND t2.VIGENCIA <=OPERACIONES.FECHA) WHERE t2.VIGENCIA IS NULL  GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY YEAR(OPERACIONES.FECHA),MONTH(OPERACIONES.FECHA) ASC) t1 RIGHT JOIN(SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,ROUND(SUM(DEBE),2) AS FACTURACION,ROUND(SUM(DEVOLUCION),2) AS DEVOLUCION FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ASC) t2 ON(t1.MES=t2.MES);" >./informeQuincenal/nivel_ventas.dat

### COBRANZAS

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,ROUND(SUM(HABER),2) AS COBRANZAS FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ASC;" >./informeQuincenal/nivel_cobranzas.dat

### FAIMXPORT BALANZA

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DATE_FORMAT(FECHA,'%Y-%m') AS MES,ROUND(SUM(HABER),2) AS PAGOS,ROUND(SUM(DEBE),2) AS COMPRA,ROUND(SUM(HABER)/SUM(DEBE),2) AS RATIO FROM SALDO_PROOVEDOR JOIN(PROOVEDOR) ON(pooID=PROOVEDOR) WHERE PROOVEDOR=1 GROUP BY DATE_FORMAT(FECHA,'%Y-%m') ORDER BY DATE_FORMAT(FECHA,'%Y-%m') ASC;" | grep -v FAIM >./informeQuincenal/faimexport_compra_pago.dat
## SALDO  SELECT SUM(DEBE)-SUM(HABER) AS DEUDA FROM SALDO_PROOVEDOR WHERE PROOVEDOR=1;


### COSTOS DESMENUZADOS CON PERDIDAS SUMADAS


mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT t1.MES AS MES,t8.NETO AS NETO,ROUND(t1.COSTO,2) AS 'COSTO MERCADERIAS',IFNULL(t2.PERDIDAS,0) AS PERDIDAS,ROUND(t3.MONTO,2) AS COMISIONES,IFNULL(t4.REGISTRO,0) AS 'FIJOS',IFNULL(t5.REGISTRO,0) AS 'MOVILIDAD',IFNULL(t6.REGISTRO,0) AS 'INSUMOS',ROUND(t7.INGRESO_PABLO,2) AS 'INGRESOS PABLO' FROM (SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,SUM((CANTIDAD_AR-IF(OPERACIONES.SOLICITUD=42,CANTIDAD_ING,0))*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO,0) / 100)) AS 'COSTO' FROM ARMADO JOIN(PRECIOS,CATEGORIA,MODELO,CONDICION,ARTICULOS,CLIENTE,OPERACIONES,PROOVEDOR) ON(PRECIOS.RUBRO_pr=ARTICULOS.RUBRO AND PRECIOS.CATEGORIA_pr=ARTICULOS.CATEGORIA AND PRECIOS.MODELO_pr=ARTICULOS.MODELO AND CATEGORIA.claID=ARTICULOS.CATEGORIA AND MODELO.mdID=ARTICULOS.MODELO AND CONDICION.cdID=CLIENTE.CONDICION AND CLIENTE.clID=OPERACIONES.INTERESADO AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR AND OPERACIONES.opID=ARMADO.OPERACION_REFERENCIA_AR AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR) JOIN PRHISTORICOS t1 ON(PRECIOS.RUBRO_pr=t1.RUBRO AND PRECIOS.CATEGORIA_pr=t1.CATEGORIA AND PRECIOS.MODELO_pr=t1.MODELO AND t1.VIGENCIA<=OPERACIONES.FECHA) LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO AND t1.CATEGORIA=t2.CATEGORIA AND t1.MODELO=t2.MODELO AND t2.VIGENCIA > t1.VIGENCIA AND t2.VIGENCIA <=OPERACIONES.FECHA) WHERE t2.VIGENCIA IS NULL  GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY YEAR(OPERACIONES.FECHA),MONTH(OPERACIONES.FECHA) ASC) t1 LEFT JOIN(SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,ROUND(SUM(PERDIDAS),2) AS PERDIDAS FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m')) t2 ON(t1.MES=t2.MES) RIGHT JOIN(SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,SUM(MONTO) AS MONTO FROM COMISIONES JOIN(OPERACIONES) ON(opID=OPERACION_REF_C) WHERE (VIGENCIA IS NULL AND CANCELACION IS NULL) OR (VIGENCIA IS NULL AND CANCELACION IS NOT NULL) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m')) t3 ON(t1.MES=t3.MES) LEFT JOIN(SELECT DATE_FORMAT(FECHA,'%Y-%m') AS MES,SUM(REGISTRO) AS REGISTRO FROM CONTABLES WHERE TIPO_REGISTRO=1 GROUP BY DATE_FORMAT(FECHA,'%Y-%m')) t4 ON(t1.MES=t4.MES) LEFT JOIN(SELECT DATE_FORMAT(FECHA,'%Y-%m') AS MES,SUM(REGISTRO) AS REGISTRO FROM CONTABLES WHERE TIPO_REGISTRO=2 GROUP BY DATE_FORMAT(FECHA,'%Y-%m')) t5 ON(t1.MES=t5.MES) LEFT JOIN(SELECT DATE_FORMAT(FECHA,'%Y-%m') AS MES,SUM(REGISTRO) AS REGISTRO FROM CONTABLES WHERE TIPO_REGISTRO=3 GROUP BY DATE_FORMAT(FECHA,'%Y-%m')) t6 ON(t1.MES=t6.MES) LEFT JOIN(SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,SUM(DEBE-DEVOLUCION-PERDIDAS)*.05 AS INGRESO_PABLO FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m')) t7 ON(t1.MES=t7.MES) LEFT JOIN(SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,ROUND(SUM(DEBE-IFNULL(DEVOLUCION,0)),2) AS NETO FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ASC) t8 ON(t1.MES=t8.MES);" | grep -v NULL >./informeQuincenal/RESULTADOS.dat

### CANTIDAD DE CLIENTES DIFERENTES QUE COMPRAN POR MES

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,COUNT(DISTINCT(DENOMINACION)) AS COMPRAS FROM CUENTA_CORRIENTE JOIN(OPERACIONES,CLIENTE,LOCALIDAD,PROVINCIA,COMERCIO) ON(opID=OPERACION_REF_CC AND clID=INTERESADO AND lcID=LOCALIDAD AND prID=PROVINCIA AND CLIENTE.COMERCIO=COMERCIO.coID) WHERE DEBE>0 GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') ORDER BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m'),SUM(DEBE) DESC;" >./informeQuincenal/diferentes_clientes.dat


cd ./informeQuincenal/ && gnuplot <ploteoEconomico.gp 




### PATRIMONIO


### PATRIMONIO #################

echo -e "\n##### PATRIMONIO #####\n" >./data_texto.dat

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT ROUND(t1.STOCK,0) AS 'STOCK',ROUND(t2.CLIENTES,0) AS 'CLIENTES',ROUND(t4.CAJA,0) AS 'LIQUIDEZ',ROUND(t3.PROVEEDOR,0) AS 'PROVEEDORs',ROUND((t1.STOCK + t2.CLIENTES +t4.CAJA - t3.PROVEEDOR),0) AS PATRIMONIO FROM (SELECT 'ACTUAL' AS ACTUAL,SUM((IFNULL(CANTIDAD_CST,0) + IFNULL(CANTIDAD_ING,0) + IFNULL(CANTIDAD_DEVOL,0) - IFNULL(CANTIDAD_EGR,0) - IFNULL(CANTIDAD_AR,0)) * CANTIDAD_MINIMA * IF(IFNULL(PRECIO_A,0) > IFNULL(PRECIO_B,0),IFNULL(PRECIO_A,0) * (1 - (DESCUENTO / 100)),IFNULL(PRECIO_B,0) * (1 - (DESCUENTO / 100)))) AS 'STOCK' FROM ARMADO JOIN (RUBRO,CATEGORIA,MODELO,MOTIVO,PROOVEDOR,PRECIOS,ARTICULOS) ON (RUBRO.ruID=PRECIOS.RUBRO_pr AND CATEGORIA.claID=PRECIOS.CATEGORIA_pr AND MODELO.mdID=PRECIOS.MODELO_pr AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr AND ARTICULOS.MODELO=PRECIOS.MODELO_pr AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR AND ARTICULOS.MOTIVO=MOTIVO.mtID)) t1 JOIN(SELECT 'ACTUAL' AS ACTUAL,SUM(IFNULL(DEBE,0) - IFNULL(HABER,0) - IFNULL(DEVOLUCION,0) - IFNULL(PERDIDAS,0)) AS 'CLIENTES' FROM CUENTA_CORRIENTE) t2 ON(t1.ACTUAL=t2.ACTUAL) JOIN(SELECT 'ACTUAL' AS ACTUAL,SUM(IFNULL(DEBE,0) - IFNULL(HABER,0)) AS 'PROVEEDOR' FROM SALDO_PROOVEDOR) t3 ON(t1.ACTUAL=t3.ACTUAL) JOIN((SELECT 'ACTUAL' AS ACTUAL,REGISTRO AS CAJA FROM CONTABLES WHERE TIPO_REGISTRO=5 ORDER BY contablesID DESC LIMIT 1)) t4 ON(t1.ACTUAL=t4.ACTUAL);" | column -t -s $'\t' >>./data_texto.dat

### RANKING DE CLIENTES POR MONTO

echo -e "\n##### RANKING COMPRA CLIENTES #######\n" >>./data_texto.dat

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m') AS MES,DENOMINACION,CONCAT('$ ',ROUND(SUM(DEBE),0)) AS MONTO FROM CUENTA_CORRIENTE JOIN(OPERACIONES,CLIENTE,LOCALIDAD,PROVINCIA,COMERCIO) ON(opID=OPERACION_REF_CC AND clID=INTERESADO AND lcID=LOCALIDAD AND prID=PROVINCIA AND CLIENTE.COMERCIO=COMERCIO.coID) WHERE DEBE>0 GROUP BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m'),DENOMINACION ORDER BY DATE_FORMAT(OPERACIONES.FECHA,'%Y-%m'),SUM(DEBE) DESC;" | column -t -s $'\t' >>./data_texto.dat

### RANKING DE PRODUCTOS POR BULTO

echo -e "\n##### RANKING DE PRODUCTOS #######\n" >>./data_texto.dat

mysql -u "${user}" --password="${pass}" --execute="USE ${DB};SELECT rubro_rb AS 'RUBRO',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS ARTICULO FROM PEDIDO JOIN(OPERACIONES,CATEGORIA,MODELO,MOTIVO,ARTICULOS,PROOVEDOR,PRECIOS,RUBRO) ON(OPERACIONES.opID=OPERACION_REFERENCIA AND PEDIDO.ID_ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr AND ARTICULOS.RUBRO=ruID AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr AND ARTICULOS.MODELO=PRECIOS.MODELO_pr) GROUP BY ID_ARTICULO ORDER BY ruID,SUM(CANTIDAD * CANTIDAD_MINIMA / CANTIDAD_BULTO) DESC;" | column -t -s $'\t' >>./data_texto.dat

enscript

############## MANTENIMIENTO #############

exit 0
