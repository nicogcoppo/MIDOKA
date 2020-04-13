/* VISUALIZACION DE LAS COMISIONES, BUSQUEDA POR VENDEDOR
   
   REGISTRO		ACCION		VIGENCIA	CANCELACION

   INICIAL		FACTURADO	NULL		NULL
   (AL FACTURAR)	
   UNICO		ABONADA		NULL		NOT NULL
   			TOTALMENETE	


    AL PAGAR		POR PAGAR	NOT NULL	NULL			
    (SE CREA EN
     CADA PAGO)		LIQUIDADA
    HASTA CANCELAR 	EN QUINCENA	NOT NULL	NOT NULL
    BOLETA


*/

	
USE MIDOKA_PGC_B;

SELECT FECHA,
       nombre_rhd AS 'VENDEDOR',
       DENOMINACION AS 'CLIENTE',
       nombre_nm AS SOLICITUD,
       MONTO,
       VIGENCIA,
       CANCELACION
FROM COMISIONES JOIN(OPERACIONES, NOMBRE_MENU, CLIENTE, RECURSOS_HUMANOS_DISPONIBLES) ON(opID=OPERACION_REF_C
                                                                                         AND SOLICITUD=nmID
                                                                                         AND clID=INTERESADO
                                                                                         AND rhdID=TRABAJADOR)
WHERE nombre_rhd LIKE "%RODOLFO%"
ORDER BY FECHA ASC
LIMIT 30;

