#!/usr/bin/perl
package usuario::historial_solicitudes;
use strict;
use warnings;
use feature qw(say switch);

use interfaz_usuario::usuario;
use utilidades::limite_entrada;
use usuario::historial::ver_codigo;
use usuario::historial::ver_todas;
use usuario::historial::comprobaciones;

sub historial_solicitudes {
  my ($nombre_usuario, $codigo_depto) = @_;
  system("clear");
  print "Bienvenido $nombre_usuario al apartado de consultas de su departamento $codigo_depto\n";

  my $reabastecimiento_depto = usuario::historial::comprobaciones::comprobar_existencia($nombre_usuario, $codigo_depto);

  print "A continuación se muestran las solicitudes de su departamento: \n";

  return usuario::historial::ver_todas::ver_todas($nombre_usuario, $codigo_depto, $reabastecimiento_depto);
}

1;
