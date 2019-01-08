#!/bin/bash
#
# Script para el desplegado del menu de tipo RADIO
#

############## DECLARACIONES ###########################

declare CONTADOR

declare -a foraneos

declare -a ESTADO

declare -a CANTIDAD_PEDIDA

declare -a REFERENCIADOR

declare -a CANT_NUM_PED

declare -r FONDO="$1"

declare -r TITULO="$2"

declare -r SUBTITULO="$3"

declare -r ENTRADA="$4"

declare -r SALIDA="$5"

declare -r OPERACION="$6"

declare VAR

declare DIRECTORIO=""${oper}"/deposito/"${OPERACION}"-DEPO"

declare CANTIDAD_CONTROLADA

################# FUNCIONES ############################

function control_estados { 

    CONTADOR=0
    while read line ; do

	REFERENCIADOR[${CONTADOR}]=""${line}""
	let CONTADOR+=1
	
    done < "./"${DIRECTORIO}"/REFERENCIA_"${SALIDA}""
  
    
    CONTADOR=0
    while read line ; do

	CANT_NUM_PED[${CONTADOR}]="${line}"

	CANTIDAD_PEDIDA[${CONTADOR}]=" > "${line}" <"

	let CONTADOR+=1
	
    done < "./"${DIRECTORIO}"/VISTA_"${SALIDA}""


    
    CONTADOR=0
    while read line ; do

	ESTADO[${CONTADOR}]=""${line}""
	let CONTADOR+=1
	
    done < "./"${DIRECTORIO}"/DEPOVISTA_"${SALIDA}""

    
    CONTADOR=0
    foraneos=()
    while read line ; do
	let VAR=${CONTADOR}+1 
	foraneos+=("""${line}""${CANTIDAD_PEDIDA[${CONTADOR}]}""" ""${VAR}"" "3" """${ESTADO[${CONTADOR}]}""" ""${VAR}"" "30" "30" "50")
	let CONTADOR+=1
	echo "${foraneos[@]}"
    done < "./"${temp}"/"${ENTRADA}""
}


function control_cantidades {
    CONTADOR=0
    CANTIDAD_CONTROLADA=0
    while read line ; do

	if test ! -z ""${line}"";then

	    if test "${line}" -gt "${CANT_NUM_PED[${CONTADOR}]}" ;then

		dialog --msgbox "SE ASIGNO MERCADERIA POR DEMAS, POR FAVOR CONTROLAR" 0 0

		return 1
		
	    else
		
		echo ""${REFERENCIADOR[${CONTADOR}]}","${line}"" >>"./"${DIRECTORIO}"/"${SALIDA}""

		let FALTANTE=${CANT_NUM_PED[${CONTADOR}]}-${line}
		
		if test "${FALTANTE}" -ne 0;then
		    
		    echo ""${REFERENCIADOR[${CONTADOR}]}","${FALTANTE}"" >>"./"${DIRECTORIO}"/##"${SALIDA}""
		fi
		
		 
		
	    fi
	    
	else

	    dialog --msgbox "UNA DE LAS CANTIDADES NO SE COMPLETO, POR FAVOR CONTROLAR" 0 0

	    return 1
	fi

	let CANTIDAD_CONTROLADA+="${line}"
	
	let CONTADOR+=1
	
    done < "./"${DIRECTORIO}"/DEPOVISTA_"${SALIDA}""
    
    return 0
}

function cambioOporCero {

    cat "./"${DIRECTORIO}"/DEPOVISTA_"${SALIDA}"" | sed 's/o/0/g' >${temp}/depoOporCero

    mv ${temp}/depoOporCero "./"${DIRECTORIO}"/DEPOVISTA_"${SALIDA}""

}

###############  SCRIPT ###########################

# TRES ARCHIVOS >> REFERENCIA_1-1-1 : ID DE LOS MOTIVOS
#               >> 1-1-1 : EL ARCHIVO CONTIENE IDMOTIVO,CANTIDAD LISTO PARA GRABAR EN MARIADB
#               >> VISTA_1-1-1 : CONTIENE LAS CANTIDADES PARA SU VISUALIZACION

while true;do

    control_estados

    dialog --backtitle "${FONDO}" --title "${TITULO}" \
	   --form "\n${SUBTITULO}" 0 0 0 "${foraneos[@]}" \
	   2>"./"${DIRECTORIO}"/DEPOVISTA_"${SALIDA}""


    # Reemplazo de la tecla 0

    cambioOporCero
    
    # ESCRITURA DEL ARCHIVO PARA GRABAR

    rm "./"${DIRECTORIO}"/"${SALIDA}"" "./"${DIRECTORIO}"/##"${SALIDA}""
    control_cantidades

    case $? in
	0)  exec 3>&1
	    
	    CUENTA="$(dialog --inputbox "CUENTE LA CANTIDAD TOTAL DE PRODUCTOS QUE ACABA DE PREPARAR E INGRESELA PORFAVOR" 0 0 2>&1 1>&3)"

	    exec 3>&-
	    
	    if test "${CUENTA}" -eq "${CANTIDAD_CONTROLADA}" ;then
		break
	    fi
	    dialog --msgbox "LA CANTIDAD INGRESADA NO SE CONDICE CON LOS VALORES PREVIOS, CONTAR DE VUELTA LA MERCADERIA Y CORROBORAR POR FAVOR" 0 0 ;;
    esac
    
        
   
    
done



################### MANTENIMIENTO ########################################



VAR_s=${temp}"*.r " 

rm $VAR_s

exit 0
