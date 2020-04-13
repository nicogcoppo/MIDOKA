#!/bin/bash
#
#
#
# 
# 
#
# 
#
# 
# # SCRIPT para el grabado en tabla de las operaciones de PEDIDO DIRECTO Y SOLICITUD DE VISITA principalmente
# que originan las ordenes de trabajo

######################## DECLARACIONES #####################

declare -r DB='MIDOKA_PGC_B'

declare -r TEMP=${HOME}/${RANDOM}/ && mkdir ${TEMP} || exit 1

declare -a ARRAYB=("OPERACIONES" "COMISIONES" "CUENTA_CORRIENTE" "ARMADO" "PEDIDO" "SOLICITUDES")

declare -a ARRAY_2B=("opID" "OPERACION_REF_C" "OPERACION_REF_CC" "OPERACION_REFERENCIA_AR" "OPERACION_REFERENCIA" "REFERENCIA")

echo "Ingrese numero de operacion a descargar . . ."

read OPERACION

clear

echo "Ingrese password . . ."

read pass

######################## SCRIPT ############################

echo -e "USE "${DB}"" >${TEMP}temp.sql

echo "DROP PROCEDURE IF EXISTS TRANSACCION;
DELIMITER $$
CREATE PROCEDURE TRANSACCION()
BEGIN
DECLARE _rollback BOOL DEFAULT 0;
DECLARE A INT;
DECLARE B INT;
DECLARE C INT;
DECLARE D INT;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET _rollback = 1;
START TRANSACTION;" >>${TEMP}temp.sql

CONTADOR=0
for i in "${ARRAYB[@]}"; do

    mysql -u nico --password="$pass" --execute="USE "${DB}";SELECT * FROM "${i}" WHERE "${ARRAY_2B[${CONTADOR}]}"="${OPERACION}";" | tr '\t' '&' >${TEMP}tempa

    DERECHA=$(cat ${TEMP}tempa | tail -n +2 | sed "s/^/('/" | sed "s/$/');/" | sed "s/&/','/g" | sed "s/^(/INSERT INTO "${i}" VALUES(/")

    echo "${DERECHA}" |  sed "s/'NULL'/NULL/g" >>${TEMP}temp.sql

    let CONTADOR+=1
done


echo "IF _rollback THEN
ROLLBACK;
SELECT 'ERROR';
ELSE
COMMIT;
END IF;
END$$
DELIMITER ;
CALL TRANSACCION;" >>${TEMP}temp.sql


####################### MANTENIMIENTO ##########################

mv ${TEMP}temp.sql ${HOME}/COPIA_OPERACION_${OPERACION}.sql

rm -rf ${TEMP}/

exit 0
