#!/bin/bash
#
#
#
# SCRIPT para el instalado automatico del nuevo sistema de contabilizado de stock, incluyendo los datos
# precvios


function instalado {

    make install && install -v -m755 -d /usr/share/doc/paps-0.6.8 && install -v -m644 doxygen-doc/html/* /usr/share/doc/paps-0.6.8

}

./configure --prefix=/usr --mandir=/usr/share/man && make

sudo bash 1-8-instalado-paps-ROOT.sh && echo "INSTALACION EXITOSA" || echo "FALLO LA INSTALACION"



################### SOMETIDO A MANTENIMIENTO GENERAL ##################

