USE MIDOKA_PGC_B;
SELECT t1.ID AS 'ID',
       t1.FECHA AS 'FECHA D',
       t1.MODELO AS 'MODELO D',
       ROUND(t1.PRECIO,2) AS 'PRECIO D',
       t1.STOCK AS 'CANT D',
       ROUND(t1.PRECIO*t1.STOCK,2) AS 'TOTAL D',
       t2.ID AS 'ID',
       t2.FECHA AS 'FECHA U',
       t2.MODELO AS 'MODELO U',
       ROUND(t2.PRECIO,2) AS 'PRECIO U',
       t2.STOCK AS 'CANT U',
       ROUND(t2.PRECIO*t2.STOCK,2) AS 'TOTAL U'
FROM
  (SELECT 'DELOREAN' AS ACTUAL,
          (IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0)) AS 'STOCK',
	  mod_md AS 'MODELO',
	  opID AS 'REMITO',
	  IF(IFNULL(PRECIO_A, 0) > IFNULL(PRECIO_B, 0), IFNULL(PRECIO_A, 0), IFNULL(PRECIO_B, 0))*(1 - (DESCUENTO / 100)) AS 'PRECIO',
	  armadoID AS 'ID',
	  MIDOKA2019.OPERACIONES.FECHA AS 'FECHA'
   FROM MIDOKA2019.ARMADO
   JOIN (MIDOKA2019.OPERACIONES,
         MIDOKA2019.RUBRO,
         MIDOKA2019.CATEGORIA,
         MIDOKA2019.MODELO,
         MIDOKA2019.MOTIVO,
         MIDOKA2019.PROOVEDOR,
         MIDOKA2019.PRECIOS,
         MIDOKA2019.ARTICULOS) ON (opID=OPERACION_REFERENCIA_AR
                        AND RUBRO.ruID=PRECIOS.RUBRO_pr
                        AND CATEGORIA.claID=PRECIOS.CATEGORIA_pr
                        AND MODELO.mdID=PRECIOS.MODELO_pr
                        AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR
                        AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr
                        AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr
                        AND ARTICULOS.MODELO=PRECIOS.MODELO_pr
                        AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                        AND ARTICULOS.MOTIVO=MOTIVO.mtID)
   WHERE MIDOKA2019.OPERACIONES.FECHA<='2019-10-31' AND opID=408 ORDER BY armadoID) t1
JOIN
  (SELECT 'UTIL' AS ACTUAL,
          (IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0)) AS 'STOCK',
	  mod_md AS 'MODELO',
	  opID AS 'REMITO',
	  t1.PRECIO* (1 - (DESCUENTO / 100)) AS 'PRECIO',
	  armadoID AS 'ID',
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
   WHERE t2.VIGENCIA IS NULL AND opID=408 ORDER BY armadoID) t2 ON t1.ID=t2.ID;
