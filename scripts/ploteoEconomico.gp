#!/usr/bin/gnuplot -persistent

############# VARIABLES ##########################



############# OPCIONES DE VISUALIZACION ############

set term pdfcairo color size 15cm,10cm linewidth 1

set output "./informe-quincenal.pdf"

############# OPCIONES DE TIPO DE PLOTEO ###########

set lmargin 12

set grid

#set multiplot layout 4,1

#set multipage 


############  PLOTEOS  ############################

set title "NIVELES DE VENTA"

set xlabel "MES"

set ylabel "MONTO ($)"

#set xrange [15:24]

set yrange [0:1200000]

set xtics rotate

plot "./nivel_ventas.dat" using 0:($2):xticlabels(1) ti "Facturacion" w l,"" using 0:($3) ti "Devoluciones" w l,"" using 0:($2-$3) ti "Neto" w l,"" using 0:($4) ti "Faltantes" w l


## /////////////////////////////////////////////////////////////

set title "NIVELES DE COBRANZAS"

set xlabel "MES"

set ylabel "MONTO ($)"

#set xrange [15:24]

#set yrange [0:1200000]

set xtics rotate

plot "./nivel_cobranzas.dat" using 0:($2):xticlabels(1) ti "Cobranza" w l

## /////////////////////////////////////////////////////////////

set title "BALANZA COMPRA/PAGO FAIMXPORT S.A"

set xlabel "MES"

set ylabel "MONTO ($)"

#set xrange [15:24]

set yrange [0:900000]

set xtics rotate

plot "./faimexport_compra_pago.dat" using 0:($2):xticlabels(1) ti "Pago" w l,"" using 0:($3) ti "Compra" w l,"" using 0:($4*100000) ti "Ratio P/C" w l


## /////////////////////////////////////////////////////////////

set title "COSTOS"

set xlabel "MES"

set ylabel "MONTO ($)"

#set xrange [15:24]

set yrange [0:600000]

set xtics rotate

plot "./RESULTADOS.dat" using 0:($3):xticlabels(1) ti "Mercaderias" w l,"" using 0:($4) ti "Perdidas" w l,"" using 0:($5+$9) ti "Comisiones" w l,"" using 0:($6) ti "Fijos" w l,"" using 0:($7) ti "Movilidad" w l,"" using 0:($8) ti "Insumos" w l


## /////////////////////////////////////////////////////////////

set title "DETALLE COSTOS"

set xlabel "MES"

set ylabel "MONTO ($)"

#set xrange [15:24]

set yrange [0:150000]

set xtics rotate

plot "./RESULTADOS.dat"  using 0:($4):xticlabels(1) ti "Perdidas" w l,"" using 0:($5+$9) ti "Comisiones" w l,"" using 0:($6) ti "Fijos" w l,"" using 0:($7) ti "Movilidad" w l,"" using 0:($8) ti "Insumos" w l


## /////////////////////////////////////////////////////////////

set title "UTILIDAD"

set xlabel "MES"

set ylabel "MONTO ($)"

#set xrange [15:24]

set yrange [-20000:80000]

set xtics rotate

plot "./RESULTADOS.dat" using 0:($2-$3-$4-$5-$6-$7-$8-$9):xticlabels(1) ti "Utilidad" w l

## /////////////////////////////////////////////////////////////

set title "CANTIDAD DE VENTAS DISCRIMINANDO CLIENTES"

set xlabel "MES"

set ylabel "CANTIDAD DE CLIENTES DISCRIMINADOS"

#set xrange [15:24]

set yrange [0:200]

set xtics rotate

plot "./diferentes_clientes.dat" using 0:($2):xticlabels(1) ti "Cantidad" w l

## /////////////////////////////////////////////////////////////

set title "PARTICIPACION COSTOS MERCADERIA"

set xlabel "MES"

set ylabel "PARTICIPACION (%)"

#set xrange [15:24]

set yrange [60:80]

set xtics rotate

plot "./RESULTADOS.dat" using 0:($2-$3-$4-$5-$6-$7-$8-$9)/$2:xticlabels(1) ti "Utilidad" w l,"" using 0:($3/$2)*100 ti "Mercaderias" w l,"" using 0:($4/$2)*100 ti "Perdidas" w l,"" using 0:($5/$2)*100 ti "Comisiones" w l,"" using 0:($6/$2)*100 ti "Fijos" w l,"" using 0:($7/$2)*100 ti "Movilidad" w l,"" using 0:($8/$2)*100 ti "Insumos" w l,"" using 0:($9/$2)*100 ti "Pablo" w l

## /////////////////////////////////////////////////////////////

set title "DETALLE DE PARTICIPACION COSTOS"

set xlabel "MES"

set ylabel "PARTICIPACION (%)"

#set xrange [15:24]

set yrange [0:12]

set xtics rotate

plot "./RESULTADOS.dat" using 0:($2-$3-$4-$5-$6-$7-$8-$9)/$2:xticlabels(1) ti "Utilidad" w l,"" using 0:($3/$2)*100 ti "Mercaderias" w l,"" using 0:($4/$2)*100 ti "Perdidas" w l,"" using 0:($5/$2)*100 ti "Comisiones" w l,"" using 0:($6/$2)*100 ti "Fijos" w l,"" using 0:($7/$2)*100 ti "Movilidad" w l,"" using 0:($8/$2)*100 ti "Insumos" w l,"" using 0:($9/$2)*100 ti "Pablo" w l

## /////////////////////////////////////////////////////////////



##################### MANTENIMIENTO ###################

unset multiplot


