USE MIDOKA_PGC_B;
SELECT OPERACIONES.FECHA as 'FECHA',opID AS 'OPERACION',nombre_nm AS 'SOLICITUD',IF(clID=300,IFNULL(NOMBRE_COMERCIAL,'MOV.INTERNO'),DENOMINACION) AS 'INTERESADO',CONCAT(clasificacion_cla," ",mod_md," ",motivo_mt) AS 'ARTICULO',(IFNULL(CANTIDAD_CST,0)+IFNULL(CANTIDAD_ING,0)+IFNULL(CANTIDAD_EGR,0)+IFNULL(CANTIDAD_DEVOL,0))*CANTIDAD_MINIMA AS 'CANTIDAD',ROUND(t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100),2) AS 'COSTO',ROUND(CANTIDAD_MINIMA*(IFNULL(CANTIDAD_CST,0)+IFNULL(CANTIDAD_ING,0)+IFNULL(CANTIDAD_EGR,0)+IFNULL(CANTIDAD_DEVOL,0))*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100),2) AS 'SUBTOTAL', t3.REFERENCIA AS 'REMITO'
   FROM ARMADO JOIN(PRECIOS, CATEGORIA, MODELO, CONDICION, ARTICULOS, CLIENTE, OPERACIONES, PROOVEDOR, MOTIVO, NOMBRE_MENU) ON(PRECIOS.RUBRO_pr=ARTICULOS.RUBRO
                                                                                                          AND PRECIOS.CATEGORIA_pr=ARTICULOS.CATEGORIA
                                                                                                          AND PRECIOS.MODELO_pr=ARTICULOS.MODELO
                                                                                                          AND CATEGORIA.claID=ARTICULOS.CATEGORIA
                                                                                                          AND MODELO.mdID=ARTICULOS.MODELO
                                                                                                          AND CONDICION.cdID=CLIENTE.CONDICION
                                                                                                          AND CLIENTE.clID=OPERACIONES.INTERESADO
                                                                                                          AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                                                                                                          AND OPERACIONES.opID=ARMADO.OPERACION_REFERENCIA_AR
                                                                                                          AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR
                                                                                                          AND mtID=ARTICULOS.MOTIVO
                                                                                                          AND OPERACIONES.SOLICITUD=nmID)
   JOIN PRHISTORICOS t1 ON(PRECIOS.RUBRO_pr=t1.RUBRO
                           AND PRECIOS.CATEGORIA_pr=t1.CATEGORIA
                           AND PRECIOS.MODELO_pr=t1.MODELO
                           AND t1.VIGENCIA<=OPERACIONES.FECHA)
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <=OPERACIONES.FECHA)
   LEFT JOIN SALDO_PROOVEDOR t3 ON(opID=OPERACION_ASOCIADA)
   WHERE t2.VIGENCIA IS NULL
   	 AND OPERACIONES.FECHA>'Linf' AND OPERACIONES.FECHA<='Lsup' AND (CANTIDAD_AR=0 OR CANTIDAD_AR IS NULL) ORDER BY opID,CONCAT(clasificacion_cla," ",mod_md," ",motivo_mt);
