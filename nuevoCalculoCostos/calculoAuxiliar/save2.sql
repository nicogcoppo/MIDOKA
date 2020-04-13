USE MIDOKA_PGC_B;
SELECT '2019-12-31' AS 'QUINCENA',
       ROUND(t1.STOCK+t5.armadosFacturados, 0) AS 'EXISTENCIA'
FROM
  (SELECT 'ACTUAL' AS ACTUAL,
          SUM((IFNULL(CANTIDAD_CST, 0) + IFNULL(CANTIDAD_ING, 0) + IFNULL(CANTIDAD_DEVOL, 0) - IFNULL(CANTIDAD_EGR, 0))*CANTIDAD_MINIMA*t1.PRECIO*(1 - (DESCUENTO / 100))) AS 'STOCK'
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
                           AND t1.VIGENCIA<='2019-12-31')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='2019-12-31')
   WHERE t2.VIGENCIA IS NULL AND OPERACIONES.FECHA<='2019-12-31') t1
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          SUM(-IFNULL(CANTIDAD_AR,0)*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100)) AS 'armadosFacturados'
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
                           AND t1.VIGENCIA<='2019-12-31')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='2019-12-31')
   WHERE t2.VIGENCIA IS NULL
   	 AND CLASE=9 AND SOLICITUDES.REALIZACION<='2019-12-31') t5
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          IFNULL(SUM(CANTIDAD_AR*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100)),0) AS 'armados'
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
                           AND t1.VIGENCIA<='2019-12-31')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='2019-12-31')
   WHERE t2.VIGENCIA IS NULL
   	 AND ((SOLICITUDES.COMIENZO<='2019-12-31' AND IFNULL(SOLICITUDES.REALIZACION,'5000-01-01')>'2019-12-31' AND CLASE=8) OR (SOLICITUDES.COMIENZO<='2019-12-31' AND IFNULL(SOLICITUDES.REALIZACION,'5000-01-01')>'2019-12-31' AND CLASE=9))) t6   
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(- IFNULL(HABER, 0) - IFNULL(DEVOLUCION, 0) - IFNULL(PERDIDAS, 0)) AS 'PAGOS'
   FROM CUENTA_CORRIENTE
   JOIN (OPERACIONES) ON(opID=OPERACION_REF_CC)
   WHERE OPERACIONES.FECHA<='2019-12-31') t2 ON(t1.ACTUAL=t2.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(DEBE) AS 'FACTURACION'
   FROM CUENTA_CORRIENTE
   JOIN(OPERACIONES,SOLICITUDES) ON(opID=OPERACION_REF_CC AND REFERENCIA=opID)
   WHERE SOLICITUDES.REALIZACION<='2019-12-31' AND CLASE=9) t7 ON(t1.ACTUAL=t7.ACTUAL)	
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(IFNULL(DEBE, 0) - IFNULL(HABER, 0)) AS 'PROVEEDOR'
   FROM SALDO_PROOVEDOR JOIN(OPERACIONES) ON(OPERACION_ASOCIADA=opID)
   WHERE OPERACIONES.FECHA<='2019-12-31') t3 ON(t1.ACTUAL=t3.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS 'CAJA',
          FECHA
   FROM CONTABLES
   WHERE TIPO_REGISTRO=5
     AND FECHA='2019-12-31') t4 ON(t1.ACTUAL=t4.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM((CANTIDAD_AR-IF(OPERACIONES.SOLICITUD=42, CANTIDAD_ING, 0))*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100)) AS 'COSTO'
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
	 AND SOLICITUDES.REALIZACION>'2019-12-15' AND SOLICITUDES.REALIZACION<='2019-12-31') t8 ON(t1.ACTUAL=t8.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          ROUND(SUM(PERDIDAS), 2) AS PERDIDAS
   FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC)
   WHERE OPERACIONES.FECHA>'2019-12-15' AND OPERACIONES.FECHA<='2019-12-31') t9 ON(t1.ACTUAL=t9.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          ROUND(SUM(DEVOLUCION), 2) AS DEVOLUCIONES
   FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC)
   WHERE OPERACIONES.FECHA>'2019-12-15' AND OPERACIONES.FECHA<='2019-12-31') t20 ON(t1.ACTUAL=t20.ACTUAL)   
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          SUM(MONTO) AS 'comisionesFacturadas'
   FROM COMISIONES JOIN(OPERACIONES,SOLICITUDES) ON(opID=OPERACION_REF_C
   	AND opID=SOLICITUDES.REFERENCIA)
   WHERE ((VIGENCIA IS NULL
          AND CANCELACION IS NULL)
     OR (VIGENCIA IS NULL
         AND CANCELACION IS NOT NULL))
	AND CLASE=9 AND REALIZACION>'2019-12-15' AND REALIZACION<='2019-12-31') t10 ON(t1.ACTUAL=t10.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          SUM(MONTO) AS 'comisionesPagas'
   FROM COMISIONES JOIN(OPERACIONES) ON(opID=OPERACION_REF_C)
   WHERE VIGENCIA IS NOT NULL
	AND CANCELACION>'2019-12-15' AND CANCELACION<='2019-12-31') t11 ON(t1.ACTUAL=t11.ACTUAL)	
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS FIJO
   FROM CONTABLES
   WHERE TIPO_REGISTRO=1 AND FECHA='2019-12-31') t12 ON(t1.ACTUAL=t12.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS MOVILIDAD
   FROM CONTABLES
   WHERE TIPO_REGISTRO=2 AND FECHA='2019-12-31') t13 ON(t1.ACTUAL=t13.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS INSUMOS
   FROM CONTABLES
   WHERE TIPO_REGISTRO=3 AND FECHA='2019-12-31') t14 ON(t1.ACTUAL=t14.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS 'comisionesPagasPablo'
   FROM CONTABLES
   WHERE TIPO_REGISTRO=4 AND FECHA='2019-12-31') t15 ON(t1.ACTUAL=t15.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS 'comisionesPagasExtra'
   FROM CONTABLES
   WHERE TIPO_REGISTRO=6 AND FECHA='2019-12-31') t16 ON(t1.ACTUAL=t16.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(DEBE) AS 'COMPRA' FROM SALDO_PROOVEDOR JOIN(OPERACIONES) ON(opID=OPERACION_ASOCIADA) WHERE OPERACIONES.FECHA<='2019-12-31' AND OPERACIONES.FECHA>'2019-12-15') t17 ON(t1.ACTUAL=t17.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(HABER) AS 'PAGO' FROM SALDO_PROOVEDOR JOIN(OPERACIONES) ON(opID=OPERACION_ASOCIADA) WHERE OPERACIONES.FECHA<='2019-12-31' AND OPERACIONES.FECHA>'2019-12-15') t21 ON(t1.ACTUAL=t21.ACTUAL)  
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(DEBE) AS 'FACTURACION' FROM CUENTA_CORRIENTE JOIN(OPERACIONES,SOLICITUDES) ON(opID=OPERACION_REF_CC AND REFERENCIA=opID) WHERE SOLICITUDES.REALIZACION<='2019-12-31' AND SOLICITUDES.REALIZACION>'2019-12-15' AND CLASE=9) t18 ON(t1.ACTUAL=t18.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SELECT SUM(HABER) AS 'COBRANZA' FROM CUENTA_CORRIENTE JOIN(OPERACIONES) ON(opID=OPERACION_REF_CC) WHERE OPERACIONES.FECHA<='2019-12-31' AND OPERACIONES.FECHA>'2019-12-15') t19 ON(t1.ACTUAL=t19.ACTUAL)  
