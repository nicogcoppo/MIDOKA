#!/bin/bash
#
#
#
# SCRIPT para el instalado automatico del nuevo sistema de contabilizado de stock, incluyendo los datos
# precvios


./configure --prefix=/usr --mandir=/usr/share/man && make

sudo -s <<EOF

apt-get install libpango1.0-dev

make install && install -v -m755 -d /usr/share/doc/paps-0.6.8 && install -v -m644 doxygen-doc/html/* /usr/share/doc/paps-0.6.8

EOF





################### SOMETIDO A MANTENIMIENTO GENERAL ##################

