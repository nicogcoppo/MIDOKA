USE MIDOKA_PGC_B;
SELECT SOLICITUDES.REALIZACION as 'FECHA',opID AS 'REMITO',DENOMINACION AS 'CLIENTE',CONCAT(clasificacion_cla," ",mod_md," ",motivo_mt) AS 'ARTICULO',(CANTIDAD_AR-IF(OPERACIONES.SOLICITUD=42, CANTIDAD_ING, 0))*CANTIDAD_MINIMA AS 'CANTIDAD',t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100) AS 'COSTO',(CANTIDAD_AR-IF(OPERACIONES.SOLICITUD=42, CANTIDAD_ING, 0))*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100) AS 'SUBTOTAL',IF(DENOMINACION IS NULL,0,ROUND(IF(CONDICION = CONDICION_REFERENCIA AND DESCUENTO_ESPECIAL <> 0,(1 - (DESCUENTO_ESPECIAL/100)) * IF(VALOR_AGREGADO>'0',(1 + VALOR_AGREGADO/100) * t1.PRECIO,t1.PRECIO) * IF(IFNULL(CANTIDAD_AR,0)>IFNULL(CANTIDAD_ING,0),CANTIDAD_AR * CANTIDAD_MINIMA,(-1 * CANTIDAD_ING) * CANTIDAD_MINIMA),IF(DESCUENTO_ESPECIFICO > '0',(1 - DESCUENTO_ESPECIFICO/100 ) * IF(VALOR_AGREGADO>'0',(1 + VALOR_AGREGADO/100) * t1.PRECIO,t1.PRECIO) * IF(IFNULL(CANTIDAD_AR,0)>IFNULL(CANTIDAD_ING,0),CANTIDAD_AR * CANTIDAD_MINIMA,(-1 * CANTIDAD_ING) * CANTIDAD_MINIMA),cond_num_cd * IF(VALOR_AGREGADO>'0',(1 + VALOR_AGREGADO/100) * t1.PRECIO,t1.PRECIO) * IF(IFNULL(CANTIDAD_AR,0)>IFNULL(CANTIDAD_ING,0),CANTIDAD_AR * CANTIDAD_MINIMA,(-1 * CANTIDAD_ING) * CANTIDAD_MINIMA))),2)) AS 'FACTURADO',NOMBRE_COMERCIAL AS 'PROVEEDOR',nombre_rhd AS 'VENDEDOR'
   FROM ARMADO JOIN(PRECIOS, CATEGORIA, MODELO, CONDICION, ARTICULOS, CLIENTE, OPERACIONES, PROOVEDOR, SOLICITUDES,MOTIVO,COMISIONES,RECURSOS_HUMANOS_DISPONIBLES) ON(PRECIOS.RUBRO_pr=ARTICULOS.RUBRO
                                                                                                          AND PRECIOS.CATEGORIA_pr=ARTICULOS.CATEGORIA
                                                                                                          AND PRECIOS.MODELO_pr=ARTICULOS.MODELO
                                                                                                          AND CATEGORIA.claID=ARTICULOS.CATEGORIA
                                                                                                          AND MODELO.mdID=ARTICULOS.MODELO
                                                                                                          AND CONDICION.cdID=CLIENTE.CONDICION
                                                                                                          AND CLIENTE.clID=OPERACIONES.INTERESADO
                                                                                                          AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                                                                                                          AND OPERACIONES.opID=ARMADO.OPERACION_REFERENCIA_AR
                                                                                                          AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR
                                                                                                          AND opID=SOLICITUDES.REFERENCIA
                                                                                                          AND mtID=ARTICULOS.MOTIVO
                                                                                                          AND TRABAJADOR=rhdID
                                                                                                          AND OPERACION_REF_C=opID)
   JOIN PRHISTORICOS t1 ON(PRECIOS.RUBRO_pr=t1.RUBRO
                           AND PRECIOS.CATEGORIA_pr=t1.CATEGORIA
                           AND PRECIOS.MODELO_pr=t1.MODELO
                           AND t1.VIGENCIA<=SOLICITUDES.REALIZACION)
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <=SOLICITUDES.REALIZACION)
   WHERE t2.VIGENCIA IS NULL
   	 AND CLASE=9
	 AND SOLICITUDES.REALIZACION>'Linf' AND SOLICITUDES.REALIZACION<='Lsup' AND tipo_rhd=1 ORDER BY opID,CONCAT(clasificacion_cla," ",mod_md," ",motivo_mt);
