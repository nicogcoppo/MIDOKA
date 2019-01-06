#!/bin/bash
#
#
#
#Configuracion automatica MIDOKA 3.0



################## DECLARACIONES #############################

declare -r user="root"


declare -rx SCRIPT=${0##*/}

# /////// ARRAY DE COMANDOS NECESARIOS ///////

declare -rx MYSQL="/usr/bin/mysql"

declare -rx DIALOG="/usr/bin/dialog"

declare -rx SED="/bin/sed"

declare -rx AWK="/usr/bin/awk"

declare -rx SUDO="/usr/bin/sudo"

declare -rx ENSCRIPT="/usr/bin/enscript"

declare -rx MAXIMA="/usr/bin/maxima"

declare -rx BASE64="/usr/bin/base64"

declare -a COMANDOS=($MYSQL $DIALOG $SED $AWK $SUDO $ENSCRIPT $MAXIMA $BASE64)

declare -a DETALLES=("mysql (base de datos)" "dialog (menu grafico)" "sed" "awk" "sudo" "GNU ENSCRIPT" "MAXIMA" "BASE64 DECODER")

# ////////////////////////////////////////////


declare -r DIR="/var/lib/mysql/"  # Directorio de trabajo de la BASE DE DATOS

declare -r scr="scripts/"

declare -r arc="archivos/"

declare -r temp="temporales/"

declare -r act="actualizaciones/mysql/"

declare -i CONTADOR=0

declare -r pipe='"|"'

################## SANIDADES #################################

clear

cat ${arc}"LEEME" | head -8



echo -e "\nINGRESE EL NOMBRE DE LA EMPRESA : " 

read DATABASE

declare -r DB=${DATABASE}


#### Reemplazamientos segun database #######################

sed -i "s/.*DB=.*/declare -rx DB="${DB}"/" MIDOKA3.sh

sed -i  "s/.*USE.*/USE "${DB}"/" ${act}MIDOKA_3_01.sql

sed -i "s/.*USE.*/USE "${DB}"/" ${arc}transaccion_a

############################################################


for i in ${COMANDOS[@]};do
   
    if test ! -x "$i" ;then
	printf "\n$SCRIPT:$LINENO: El comando necesario ${DETALLES[$CONTADOR]} no se encuentra disponible--> ABORTANDO\n\n" >&2
	exit 192
    fi
    let CONTADOR=CONTADOR+1

done

CONTADOR=0

cat ${arc}"tablas" | tr '|' '\t' | tail -n +2 | cut -f2 >"./"${arc}"/listado_archivos.txt"

cat ${arc}"tablas" | tr '|' '\t' | tail -n +2 | cut -f2 >>"./"${arc}"/SCRIPTS.txt"

cat ${arc}"tablas" | tr '|' '\t' | tail -n +2 | cut -f2 | sed 's/^/carac_/' >>"./"${arc}"/listado_archivos.txt"  	 

echo " ">${arc}RECURSOS_HUMANOS_DISPONIBLES ## Ver ejemplo para completar

while read line
do
    
    if test ! -f ${arc}${line} ;then
	printf "\n$SCRIPT:$LINENO: El archivo $line no esta disponible --> ABORTANDO\n\n" >&2
	exit 192
    fi   

    
done<"./"${arc}"/listado_archivos.txt"  	

    

################## FUNCIONES ##################################

function crear_tabla_array {    # formato >>  "${array[@]}"

    
    declare -a array=("$@")
         
    if test -z "$1" ;then
	printf "\n$SCRIPT:$LINENO: No es porsible crear tabla sin array --> ABORTANDO\n\n" >&2
	exit 192
    fi

       
    for i in ${array[@]};do   # CREA TABLA A PARTIR DE ARCHIVO carac_?.txt

	VAR="CREATE TABLE IF NOT EXISTS "${DB}"."${i}" "$(cat "./"${arc}"/carac_"${i} )";" 
	
	mysql -u "${user}" --password="${pass}"  --execute="${VAR}"


	VAR=$(cat ${arc}${i} | tail -n +2)

	if test ! -z """${VAR}""";then
	    VAR="LOAD DATA INFILE '"${i}"' INTO TABLE "${DB}"."${i}" FIELDS TERMINATED BY "$pipe"; "
	
	    mysql -u "${user}" --password="${pass}"  --execute="$VAR"
	else
	    echo "El archivo : "${i}" se encuentra vacio, no hay informacion preeliminar para cargar en la base de datos."
	fi
	
	
        
    done
    
}


function compilar_tablas_archivo { # Compila las tablas segun lo indica el archivo que se le asigna como argumento

    declare -r archivo=("$1")

    if test -z "$1" ;then
	printf "\n$SCRIPT:$LINENO: No es posible compilar sin definir archivo guia --> ABORTANDO\n\n" >&2
	exit 192
    fi

    sed 's/^[0-9]\+|//g' ${archivo} | tail -n +2 >"./"${temp}"/tmp2" 
    
    while read line
    do

	crear_tabla_array "${line}"
    done<"./"${temp}"/tmp2"  	
    

}    


function creo_usuarios {

    while true; do

    clear

    echo -e "'\n INGRESE NOMBRE COMPLETO"

    read NOMBRE

    echo -e "'\n INGRESE CODIGO CORRESPONDIENTE...\n"
    
    mysql -u "${user}" --password="${pass}" --execute="USE "${DB}";SELECT rhID as CODIGO, rh_rh AS TIPO FROM RECURSOS_HUMANOS;" 
        
    read CODIGO

    echo -e "'\n INGRESE NIVEL ASIGNADO"

    read NIVEL

    echo -e "'\n INGRESE NOMBRE DE USUARIO"

    read USUARIO

    echo -e "'\n INGRESE PALABRA CLAVE"

    read CLAVE
    
    CLAVE_ascii="no_util"

    mysql -u "${user}" --password="${pass}"  --execute="CREATE USER IF NOT EXISTS '${USUARIO}'@'localhost';GRANT ALL PRIVILEGES ON  *.* to '${USUARIO}'@'localhost' WITH GRANT OPTION;SET PASSWORD FOR '${USUARIO}'@'localhost' = PASSWORD('${CLAVE}');"

    mysql -u "${user}" --password="${pass}"  --execute="USE "${DB}";INSERT INTO RECURSOS_HUMANOS_DISPONIBLES (nombre_rhd,tipo_rhd,USUARIO,ACCESO,NIVEL) VALUES ('${NOMBRE}',"${CODIGO}",'${USUARIO}','${CLAVE_ascii}',"${NIVEL}");" 

    clear

    echo "ok. ENTER para seguir creando" && read resp

    test !-z $resp && break 
    
    
done

}


################## SCRIPT PRINCIPAL #############################

#### ///// 

echo -e "\n Ingrese pass. SuperUsuario: "

read pass

#### //////   CREO BASE DE DATOS


mysql -u "${user}" --password="${pass}"  --execute="CREATE DATABASE IF NOT EXISTS "$DB" COLLATE ='utf8_general_ci' ;"  # CREO BASE DE DATOS 


## // USUARIOS

cat ${arc}"RECURSOS_HUMANOS_DISPONIBLES" | tr '|' '\t' | tail -n +2 | cut -f4-5 | awk 'NF' | grep -v root >${temp}"usuarios"

while read line; do

    USUARIO="$(echo "${line}" | awk '{print $1}')"
    CLAVE="$(echo "${line}" | awk '{print $2}' | base64 -d)"
    mysql -u "${user}" --password="${pass}"  --execute="CREATE USER IF NOT EXISTS '${USUARIO}'@'localhost';GRANT ALL PRIVILEGES ON  *.* to '${USUARIO}'@'localhost' WITH GRANT OPTION;SET PASSWORD FOR '${USUARIO}'@'localhost' = PASSWORD('${CLAVE}');"

done<${temp}"usuarios"



#### ////////  COPIADO DE ARCHIVOS NECESARIOS


sudo bash "./"${scr}su_copiado.sh $arc $temp $DIR $DB

compilar_tablas_archivo ${arc}"tablas"

#### ///// Actualizacion 1.01

echo -e "\n actualizando a version 3.01 . . ."

mysql -u "${user}" <./${act}/MIDOKA_3_01.sql

creo_usuarios

############## MANTENIMIENTO #######################################################


rm -rf "./"${temp}"/*"

exit 192

