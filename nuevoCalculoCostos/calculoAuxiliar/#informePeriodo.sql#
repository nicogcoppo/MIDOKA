SELECT SUM((CANTIDAD_AR-IF(OPERACIONES.SOLICITUD=42, CANTIDAD_ING, 0))*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100)) AS 'COSTO'
   FROM ARMADO JOIN(PRECIOS, CATEGORIA, MODELO, CONDICION, ARTICULOS, CLIENTE, OPERACIONES, PROOVEDOR, SOLICITUDES) ON(PRECIOS.RUBRO_pr=ARTICULOS.RUBRO
                                                                                                          AND PRECIOS.CATEGORIA_pr=ARTICULOS.CATEGORIA
                                                                                                          AND PRECIOS.MODELO_pr=ARTICULOS.MODELO
                                                                                                          AND CATEGORIA.claID=ARTICULOS.CATEGORIA
                                                                                                          AND MODELO.mdID=ARTICULOS.MODELO
                                                                                                          AND CONDICION.cdID=CLIENTE.CONDICION
                                                                                                          AND CLIENTE.clID=OPERACIONES.INTERESADO
                                                                                                          AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                                                                                                          AND OPERACIONES.opID=ARMADO.OPERACION_REFERENCIA_AR
                                                                                                          AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR
                                                                                                          AND opID=SOLICITUDES.REFERENCIA)
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
	 AND SOLICITUDES.REALIZACION>'2019-12-15' AND SOLICITUDES.REALIZACION<='2019-12-31';

SELECT SUM(DEBE) AS 'COMPRA' FROM SALDO_PROOVEDOR JOIN(OPERACIONES) ON(opID=OPERACION_ASOCIADA) WHERE OPERACIONES.FECHA<='2019-12-31' AND OPERACIONES.FECHA>'2019-12-15';

SELECT SUM(DEBE) AS 'FACTURACION' FROM CUENTA_CORRIENTE JOIN(OPERACIONES,SOLICITUDES) ON(opID=OPERACION_REF_CC AND REFERENCIA=opID) WHERE SOLICITUDES.REALIZACION<='2019-12-31' AND SOLICITUDES.REALIZACION>'2019-12-15' AND CLASE=9;
