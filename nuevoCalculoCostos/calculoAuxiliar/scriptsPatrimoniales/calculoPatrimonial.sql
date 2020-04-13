USE MIDOKA_PGC_B;
SELECT t4.FECHA AS 'FECHA',
       ROUND(t1.STOCK, 0) AS 'STOCK',
       ROUND(t5.armadosFacturados, 0) AS 'ARMADOS FACTURADOS',
       ROUND(IFNULL(t6.armados,0), 0) AS 'ARMADOS',
       ROUND(t2.CLIENTES, 0) AS 'CLIENTES',
       ROUND(t2.CLIENTES, 0)*.1 AS 'COMISIONES FUTURAS',
       ROUND(t3.PROVEEDOR, 0) AS 'PROVEEDORs',
       ROUND(t4.CAJA, 0) AS 'CAJA'
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
                           AND t1.VIGENCIA<='LIMITACION')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='LIMITACION')
   WHERE t2.VIGENCIA IS NULL AND OPERACIONES.FECHA<='LIMITACION') t1
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
                           AND t1.VIGENCIA<='LIMITACION')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='LIMITACION')
   WHERE t2.VIGENCIA IS NULL
   	 AND CLASE=9 AND SOLICITUDES.REALIZACION<='LIMITACION') t5 JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          SUM(CANTIDAD_AR*CANTIDAD_MINIMA*t1.PRECIO*(1 - IFNULL(DESCUENTO, 0) / 100)) AS 'armados'
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
                           AND t1.VIGENCIA<='LIMITACION')
   LEFT JOIN PRHISTORICOS t2 ON(t1.RUBRO=t2.RUBRO
                                AND t1.CATEGORIA=t2.CATEGORIA
                                AND t1.MODELO=t2.MODELO
                                AND t2.VIGENCIA > t1.VIGENCIA
                                AND t2.VIGENCIA <='LIMITACION')
   WHERE t2.VIGENCIA IS NULL
   	 AND ((SOLICITUDES.COMIENZO<='LIMITACION' AND IFNULL(SOLICITUDES.REALIZACION,'5000-01-01')>'LIMITACION' AND CLASE=8) OR (SOLICITUDES.COMIENZO<='LIMITACION' AND IFNULL(SOLICITUDES.REALIZACION,'5000-01-01')>'LIMITACION' AND CLASE=9))) t6   
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(IFNULL(DEBE, 0) - IFNULL(HABER, 0) - IFNULL(DEVOLUCION, 0) - IFNULL(PERDIDAS, 0)) AS 'CLIENTES'
   FROM CUENTA_CORRIENTE
   JOIN (OPERACIONES) ON(opID=OPERACION_REF_CC)
   WHERE OPERACIONES.FECHA<='LIMITACION') t2 ON(t1.ACTUAL=t2.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL, SUM(IFNULL(DEBE, 0) - IFNULL(HABER, 0)) AS 'PROVEEDOR'
   FROM SALDO_PROOVEDOR JOIN(OPERACIONES) ON(OPERACION_ASOCIADA=opID)
   WHERE OPERACIONES.FECHA<='LIMITACION') t3 ON(t1.ACTUAL=t3.ACTUAL)
JOIN
  (SELECT 'ACTUAL' AS ACTUAL,
          REGISTRO AS 'CAJA',
          FECHA
   FROM CONTABLES
   WHERE TIPO_REGISTRO=5
     AND FECHA='LIMITACION') t4 ON(t1.ACTUAL=t4.ACTUAL);
