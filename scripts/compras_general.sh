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

################### MANTENIMIENTO INICIAL #####################


#shopt -s -o unset

################### DECLARACIONES ########################

declare OPERACION=$2

declare -r GESTION=$(echo $6 | sed 's/[^0-9]*//g')

declare -r DESTINATARIO=$(echo $5 | sed 's/[^0-9]*//g')

declare -a ACTOR=("---" "PROOVEDOR" "CLIENTE")

declare -r PALLET="1000000" ## cm3
 
declare TIPO

declare DIA

declare INTERESADO

declare -a ID

declare CONTADOR

declare TEXTO

declare CANTIDAD

################### FUNCIONES ###############################


function menu2 {


    declare VAR_PRUEBA
    
    cat "./"${temp}"/tmp.ba" | awk '{print $1}' >"./"${temp}"/tmp3.ba"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ba"


     
        

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp.ba"


    while true; do

	exec 3>&1
	BUSQUEDA=$(dialog \
			--backtitle "COMPRA OPTIMA" \
			--title """MONTO $"${MONTO}"     "${CANTPALLET}" PALLETS""" \
			--clear \
			--cancel-label "ANALISIS DE SENSIBILIDAD" \
			--help-button \
			--help-label "DESCARGAR INFORMACION" \
			--menu "EFICIENCIA = "${k}"" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		dialog --file ${temp}sensibilidad
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;
            $DIALOG_ITEM_HELP)

		
		DATA_COMPOSC=""${RANDOM}"-"${DIA}".csv"
		cat "./"${temp}"/tmp_csv.ba" >""${HOME}"/Dropbox/RODRIGO/ULTIMAS_ENTREGAS/"${DATA_COMPOSC}"" && dialog --msgbox "INFORMACION DISPONIBLE EN ARCHIVO: "${DATA_COMPOSC}"" 0 0
		exit 255;;
	    
	esac

	break
	
    done

    
    
}    

function menu_seleccion {


    declare VAR_PRUEBA
    
    cat "./"${temp}"/tmp.ba" | awk '{print $1}' >"./"${temp}"/tmp3.ba"

    ID=()
    CONTADOR=0
    while read line ; do
	
	ID+=("${line}") 
        
    done <"./"${temp}"/tmp3.ba"


     
        

    foraneos=()
    while read line ; do
	
	foraneos+=("${ID[${CONTADOR}]}" """${line}""")  
	
	let CONTADOR+=1
	
    done <"./"${temp}"/tmp.ba"


    while true; do

	exec 3>&1
	RUBRO=$(dialog \
			--backtitle "CONTABILIDAD" \
			--title """PROGRAMACION DE COMPRA""" \
			--clear \
			--cancel-label "SALIR" \
			--help-button \
			--help-label "CONFIGURACION" \
			--menu "SELECCIONE USANDO ENTER" 0 0 0 "${foraneos[@]}" \
			2>&1 1>&3)
	exit_status=$?
	exec 3>&-
	case $exit_status in
	    $DIALOG_CANCEL)
		clear
		
		exit 192
		;;
	    $DIALOG_ESC)
		clear
		
		exit 204
		;;
            $DIALOG_ITEM_HELP)

	
		exit 255;;
	    
	esac

	break
	
    done

    
    
}    


	    
#@@@@@@@@@@@@@@@@@@ SCRIPT ##################################	

## // Determinacion de parametros por usuario

while true; do

       
    exec 3>&1
    
    TIEMPO=$(dialog --inputbox "Ingrese tiempo entre pedidos en DIAS" 0 0 2>&1 1>&3) 

    MONTO=$(dialog --inputbox "Ingrese monto maximo de compra en PESOS" 0 0 2>&1 1>&3)

    CANTPALLET=$(dialog --inputbox "Ingrese volumen maximo de compra en CANTIDAD DE PALLETS" 0 0 2>&1 1>&3)

    VOLUMEN="$(maxima --very-quiet --batch-string "fpprintprec:7$"${PALLET}"*"${CANTPALLET}";" | tail -n +3 | sed /^[0-9]/d | sed s/[[:blank:]]//g)"

    PROVEEDOR=$(dialog --inputbox "Si desea especificar un PROVEEDOR ingrese su Denominacion" 0 0 2>&1 1>&3)

    DENO_PRO="$(mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT NOMBRE_COMERCIAL FROM PROOVEDOR WHERE NOMBRE_COMERCIAL LIKE ""'""%${PROVEEDOR}%""'"" LIMIT 1;" | tail -n +2)"

    PRO_ID="$(mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT pooID FROM PROOVEDOR WHERE NOMBRE_COMERCIAL LIKE ""'""%${PROVEEDOR}%""'"" LIMIT 1;" | tail -n +2)"

    
    exec 3>&-

    mysql -u "${user}" --password="${pass}" --execute="USE MIDOKA_PGC_B;SELECT ruID,rubro_rb FROM RUBRO JOIN(PRECIOS) ON(RUBRO_pr=ruID) WHERE PROOVEDOR=${PRO_ID} GROUP BY ruID,PROOVEDOR;" | tail -n +2 >${temp}"tmp.ba"

    menu_seleccion

    VRU="$(mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT rubro_rb FROM RUBRO WHERE ruID="${RUBRO}";" | tail -n +2 )"
    
    dialog --yesno 'RUBRO : '${VRU}' |  TIEMPO = '${TIEMPO}' DIAS |  MONTO = $'${MONTO}' VOLUMEN = '${CANTPALLET}' PALLETS | PROVEEDOR = '"""${DENO_PRO}"""'' 10 25 && break

done


declare -r COMPRA="$((mysql -u "${user}" --password="${pass}" --execute="START TRANSACTION;INSERT INTO "${DB}".COMPRAS (FECHA,RUBRO,TIEMPO) VALUES ('${DIA}',"${RUBRO}","${TIEMPO}");SELECT MAX(comID) FROM "${DB}".COMPRAS;COMMIT;" | tail -n +2) || (dialog --msgbox "ERROR FATAL" 0 0 && exit 192))"


bash  ${scr}"/estadisticas_compra.sh" "${TIEMPO}" ".3" "95" "${COMPRA}" "${RUBRO}" "${PRO_ID}"


## ///// ESCRITURA GLPK

# // Creo archivo MPS

GLSOL=""${temp}"/"${COMPRA}".mps"

rm ${GLSOL}

test -f "${GLSOL}" || touch "${GLSOL}"

## // Escritura de parametros

echo -e "NAME COMPRA"${COMPRA}"" > ${GLSOL}

echo -e "ROWS" >> ${GLSOL}

echo -e " N COSTO" >> ${GLSOL}

echo -e " L MONTO" >> ${GLSOL}

echo -e " L VOLUMEN" >> ${GLSOL}


mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT CONCAT(' G STOCK',ARTICULO) FROM DEMANDAS WHERE COMPRA="${COMPRA}";" | tail -n +2 >> ${GLSOL} 


echo -e "COLUMNS" >> ${GLSOL}
      
mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT CONCAT(CONCAT('    CANTIDAD',ARTICULO),'        ',CONCAT('STOCK',ARTICULO),'             ','1','#'),CONCAT(CONCAT('    CANTIDAD',ARTICULO),'        ','MONTO','             ',COSTO,'#'),CONCAT(CONCAT('    CANTIDAD',ARTICULO),'        ','VOLUMEN','             ',VOLUMEN,'#'),CONCAT(CONCAT('    CANTIDAD',ARTICULO),'        ','COSTO','             ',(PVENTA - COSTO) * d,'#') FROM DEMANDAS WHERE COMPRA="${COMPRA}";" | tail -n +2 | tr '#' '\n' | sed 's/^\x09//' >> ${GLSOL} 

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT CONCAT('    k','        ',CONCAT('STOCK',ARTICULO),'             ',- 2 * d,'#') FROM DEMANDAS WHERE COMPRA="${COMPRA}";" | tail -n +2 | tr '#' '\n' | sed 's/^\x09//' >> ${GLSOL} 

echo -e "    k      COSTO             1000000000000" >> ${GLSOL}


echo -e "RHS" >> ${GLSOL}

echo -e "    RHS1      MONTO             "${MONTO}"" >> ${GLSOL}

echo -e "    RHS1      VOLUMEN             "${VOLUMEN}"" >> ${GLSOL}


mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT CONCAT('    RHS1','      ',CONCAT('STOCK',ARTICULO),'             ',- IFNULL(STOCK,0),'#') FROM DEMANDAS WHERE COMPRA="${COMPRA}";" | tail -n +2 | tr '#' '\n' | sed 's/^\x09//' >> ${GLSOL} 


echo -e "BOUNDS" >> ${GLSOL}


mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT CONCAT(' UI BND1','      ',CONCAT('CANTIDAD',ARTICULO),'             ',IF(2 * d - IFNULL(STOCK,0) <= 0,'0',2 * d - IFNULL(STOCK,0)),'#') FROM DEMANDAS WHERE COMPRA="${COMPRA}";" | tail -n +2 | tr '#' '\n' | sed 's/^\x09//' >> ${GLSOL}



echo -e " UP BND1      k             1" >> ${GLSOL}

echo -e " LO BND1      k             0" >> ${GLSOL}


echo -e "ENDATA" >> ${GLSOL}

cp ${GLSOL} ${GLSOL}"post"

cat ${GLSOL}"post" | sed '/^$/d' >${GLSOL}


## // Solver

bash -o xtrace ${glp} --freemps --max --nopresol --wlp ${temp}formato_lp -o ${temp}resultado --ranges ${temp}sensibilidad ${GLSOL} 


## // Post - procesado

# / Grabado

AGMYSQL=""${temp}"/"${RANDOM}".grabado"

rm ${AGMYSQL}

test -f "${AGMYSQL}" || touch "${AGMYSQL}"


cat ${temp}resultado | grep CANTIDAD[:0-9:] | awk '{print $4 "," $2 ";" }' | sed 's/CANTIDAD//' | sed 's/^/UPDATE DEMANDAS SET PEDIDO=/' | sed 's/,/ WHERE ARTICULO=/' >${AGMYSQL}

bash ${scr}"transaccion.sh" "${AGMYSQL}"

# / Visualizacion

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT ARTICULO AS 'ID',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',PEDIDO AS UNIDADES,PEDIDO * CANTIDAD_MINIMA / CANTIDAD_BULTO AS BULTOS FROM DEMANDAS JOIN (ARTICULOS,CATEGORIA,MODELO,MOTIVO,PRECIOS,PROOVEDOR) ON (DEMANDAS.ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr AND ARTICULOS.MODELO=PRECIOS.MODELO_pr AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR) WHERE COMPRA="${COMPRA}" ORDER BY CATEGORIA,MODELO,MOTIVO;" | column -t -s $'\t' | grep -v " 0 " >${temp}"tmp.ba"

mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT ARTICULO AS 'ID',CONCAT(clasificacion_cla,' ',mod_md,' ',motivo_mt) AS 'ARTICULO',PEDIDO AS UNIDADES,PEDIDO * CANTIDAD_MINIMA / CANTIDAD_BULTO AS BULTOS FROM DEMANDAS JOIN (ARTICULOS,CATEGORIA,MODELO,MOTIVO,PRECIOS,PROOVEDOR) ON (DEMANDAS.ARTICULO=ARTICULOS.artID AND ARTICULOS.CATEGORIA=CATEGORIA.claID AND ARTICULOS.MODELO=MODELO.mdID AND ARTICULOS.MOTIVO=MOTIVO.mtID AND ARTICULOS.RUBRO=PRECIOS.RUBRO_pr AND ARTICULOS.CATEGORIA=PRECIOS.CATEGORIA_pr AND ARTICULOS.MODELO=PRECIOS.MODELO_pr AND PROOVEDOR.pooID=PRECIOS.PROOVEDOR) WHERE COMPRA="${COMPRA}" ORDER BY CATEGORIA,MODELO,MOTIVO;" | tr '\t' ';' | tr '.' ',' | grep -v " 0 " >${temp}"tmp_csv.ba"

MONTO=$(cat ${temp}resultado | grep MONTO | awk '{print $3}')

VOLUMEN=$(cat ${temp}resultado | grep VOLUMEN | awk '{print $3}')

CANTPALLET="$(maxima --very-quiet --batch-string "fpprintprec:7$"${VOLUMEN}"/"${PALLET}";" | tail -n +3 | sed /^[0-9]/d | head -1 | sed s/[[:blank:]]//g)"

k=$(cat ${temp}resultado | grep  k  | awk '{print $3}')

menu2


################## MANTENIMIENTO FINAL ###################


VAR_s=${temp}"*.cont" 

rm $VAR_s

exit 192
