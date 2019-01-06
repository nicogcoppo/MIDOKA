import sys

from math import cos,sin,degrees,radians,log1p,atan,tan,pow

		
def cartesianas():	
	global cartx
	global carty				# TRANSFORMA COORDENADAS ESFERICAS TERRESTRES AL PLANO CON (SUDAMERICANO)
	l3=6399617.224
	k3=.0067396605
	h6=radians(lon)
	h7=radians(lat)
	i6=int((lon/int(6))+31)
	j6=6*i6-183
	j6r=radians(j6)
	k6=h6-j6r
	l6=cos(h7)*sin(k6)
	m6=0.5*log1p(((int(1)+l6)/(int(1)-l6))-int(1))
	n6=atan(tan(h7)/cos(k6))-h7
	o6=(l3/pow((int(1)+k3*pow(cos(h7),2)),.5))*.9996
	p6=(k3/int(2))*pow(m6,int(2))*pow(cos(h7),int(2))
	q6=sin(2*h7)
	r6=q6*(pow(cos(h7),int(2)))
	s6=h7+(q6/2)
	t6=((3*s6)+r6)/int(4)
	u6=(5*t6+r6*(pow(cos(h7),int(2))))/int(3)
	v6=.75*k3
	w6=(5/3)*pow(v6,int(2))
	x6=(35/27)*pow(v6,int(3))
	y6=.9996*l3*(h7-(v6*s6)+(w6*t6)-(x6*u6))
	cartx=m6*o6*(1+p6/3)+500000
	carty=n6*o6*(1+p6)+y6+10000000
	return


###############################################################################




lat=float(sys.argv[1])

lon=float(sys.argv[2])


cartesianas()


print cartx,carty

exit
