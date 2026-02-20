#!/usr/bin/perl
package reportes::nombre_archivos;
use strict;
use warnings;
use Data::UUID;
use POSIX qw(strftime); #Facilita formatear la fecha de localtime a un formato en concreto Año/Mes/Día, Día/Mes/Año, etc.

sub nombre {
  my ($tipo, $para) = @_;
  my $codigo = substr(Data::UUID->new->create_str, 0, 10);
  my $nombre_tiempo = strftime("%Y-%m-%d", localtime);

  my $nombre_dot = "reportes/archivos_dots/$tipo/$para-$nombre_tiempo-$codigo.dot";
  my $nombre_png = "reportes/imagenes/$tipo/PNG/$para-$nombre_tiempo-$codigo.png";
  my $nombre_svg = "reportes/imagenes/$tipo/SVG/$para-$nombre_tiempo-$codigo.svg";
  
  return ($nombre_dot, $nombre_png, $nombre_svg);
}

1;
