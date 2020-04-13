USE MIDOKA2019;
SELECT 'DELOREAN' AS ACTUAL,
          (IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0)) AS 'STOCK',
	  mod_md AS 'MODELO',
	  opID AS 'REMITO',
	  IF(IFNULL(PRECIO_A, 0) > IFNULL(PRECIO_B, 0), IFNULL(PRECIO_A, 0), IFNULL(PRECIO_B, 0)) AS 'PRECIO'
   FROM ARMADO
   JOIN (OPERACIONES,
         RUBRO,
         CATEGORIA,
         MODELO,
         MOTIVO,
         PROOVEDOR,
         PRECIOS,
         ARTICULOS) ON (opID=OPERACION_REFERENCIA_AR
                        AND RUBRO.ruID=PRECIOS.RUBRO_pr
                        AND CATEGORIA.claID=PRECIOS.CATEGORIA_pr
                        AND MODELO.mdID=PRECIOS.MODELO_pr
                        AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR
                        AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr
                        AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr
                        AND ARTICULOS.MODELO=PRECIOS.MODELO_pr
                        AND ARTICULOS.artID=ARMADO.ID_ARTICULO_AR
                        AND ARTICULOS.MOTIVO=MOTIVO.mtID)
   WHERE OPERACIONES.FECHA<='2019-10-31' ORDER BY opID,mod_md DESC LIMIT 50;
   
USE MIDOKA_PGC_B;
SELECT 'UTIL' AS ACTUAL,
          (IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0)) AS 'STOCK',
	  mod_md AS 'MODELO',
	  opID AS 'REMITO',
	  t1.PRECIO AS 'PRECIO'
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
   WHERE t2.VIGENCIA IS NULL ORDER BY opID,mod_md DESC LIMIT 50;
