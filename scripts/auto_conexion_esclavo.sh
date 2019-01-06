#!/bin/bash
#
#
#


while true; do

    #ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 user@box.example.com
    
    sshpass -p "36729038macaco12cat0class" ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no playcolor@mail.midoka.com.ar 

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
