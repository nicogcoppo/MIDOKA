USE MIDOKA_PGC_B;
SELECT t1.REMITO AS 'REMITO',
       t1.FECHA AS 'FECHA',
       t1.CLIENTE AS 'CLIENTE',
       t1.MONTO AS 'TOTAL DELOREAN',
       t2.MONTO AS 'TOTAL UTIL'
FROM
  (SELECT 'DELOREAN' AS ACTUAL,
          SUM(IF(IFNULL(PRECIO_A, 0) > IFNULL(PRECIO_B, 0), IFNULL(PRECIO_A, 0), IFNULL(PRECIO_B, 0))*(1 - (DESCUENTO / 100))*CANTIDAD_MINIMA*(IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0))) AS 'MONTO',
	  DENOMINACION AS 'CLIENTE',
	  opID AS 'REMITO',
	  MIDOKA2019.OPERACIONES.FECHA AS 'FECHA'	 
   FROM MIDOKA2019.ARMADO
   JOIN (MIDOKA2019.OPERACIONES,
         MIDOKA2019.RUBRO,
         MIDOKA2019.CATEGORIA,
         MIDOKA2019.MODELO,
         MIDOKA2019.MOTIVO,
         MIDOKA2019.PROOVEDOR,
         MIDOKA2019.PRECIOS,
         MIDOKA2019.ARTICULOS,
	 MIDOKA2019.CLIENTE) ON (opID=OPERACION_REFERENCIA_AR
                        AND RUBRO.ruID=PRECIOS.RUBRO_pr
                        AND CATEGORIA.claID=PRECIOS.CATEGORIA_pr
                        AND MODELO.mdID=PRECIOS.MODELO_pr
                        AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR
                        AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr
                        AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr
                        AND ARTICULOS.MODELO=PRECIOS.MODELO_pr
                        AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                        AND ARTICULOS.MOTIVO=MOTIVO.mtID AND MIDOKA2019.CLIENTE.clID=INTERESADO)
   WHERE MIDOKA2019.OPERACIONES.FECHA<='2019-10-31' GROUP BY opID ORDER BY opID) t1
JOIN
  (SELECT 'UTIL' AS ACTUAL,
          SUM((IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0))*CANTIDAD_MINIMA*t1.PRECIO* (1 - (DESCUENTO / 100))) AS 'MONTO',
	  DENOMINACION AS 'CLIENTE',
	  opID AS 'REMITO',
	  OPERACIONES.FECHA AS 'FECHA'
   FROM ARMADO JOIN(PRECIOS, CATEGORIA, MODELO, CONDICION, ARTICULOS, CLIENTE, OPERACIONES, PROOVEDOR) ON(PRECIOS.RUBRO_pr=ARTICULOS.RUBRO
                                                                                                          AND PRECIOS.CATEGORIA_pr=ARTICULOS.CATEGORIA
                                                                                                          AND PRECIOS.MODELO_pr=ARTICULOS.MODELO
                                                                                                          AND CATEGORIA.claID=ARTICULOS.CATEGORIA
                                                                                                          AND MODELO.mdID=ARTICULOS.MODELO
                                                                                                          AND CONDICION.cdID=CLIENTE.CONDICION
                                                                                                          AND CLIENTE.clID=OPERACIONES.INTERESADO
                                                                                                          AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                                                                                                          AND OPERACIONES.opID=ARMADO.OPERACION_REFERENCIA_AR
                                                                                                          AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR)
   JOIN PRHISTORICOS t1 ON(PRECIOS.RUBRO_pr=t1.RUBRO
                           AND PRECIOS.CATEGORIA_pr=t1.CATEGORIA
                           AND PRECIOS.MODELO_pr=t1.MODELO
                           AND t1.VIGENCIA<='2019-10-31')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='2019-10-31')
   WHERE t2.VIGENCIA IS NULL GROUP BY opID ORDER BY opID) t2 ON t1.REMITO=t2.REMITO;
