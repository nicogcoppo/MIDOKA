#!/bin/bash
#
#
#  SCRIPT PARA LA AUTOCONEXION DE LA MAQUINA CLIENTE
#  RECORDAR QUE LOS DATOS DEL SERVER SE DEBEN ALOJAR EN EL DIRECTORIO
#  HOME CODIFICADOS EN BASE64

########### VARIABLES ##################

declare -r PASS=$(cat ${HOME}'/pass' | base64 -d)

declare -r SERVER=$(cat ${HOME}'/server' | base64 -d)

########### SCRIPT #####################

while true; do

    #ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 user@box.example.com
    
    sshpass -p "${PASS}" ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no "${SERVER}" 

    clear

    clear

    dialog --infobox "RECONECTANDO ." 0 0

    sleep 1

    dialog --infobox "RECONECTANDO . ." 0 0

    sleep 1

    dialog --infobox "RECONECTANDO . . ." 0 0

    clear

done




#################### LIMPIEZA ##########################


exit 0
