#!/bin/bash
#
#
#
# SCRIPT para el instalado automatico del nuevo sistema de contabilizado de stock, incluyendo los datos
# precvios

## PARTE ROOT DE LA INSTALACION

apt-get install libpango1.0-dev

make install && install -v -m755 -d /usr/share/doc/paps-0.6.8 && install -v -m644 doxygen-doc/html/* /usr/share/doc/paps-0.6.8

################### SOMETIDO A MANTENIMIENTO GENERAL ##################

