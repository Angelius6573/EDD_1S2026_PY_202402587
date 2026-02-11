#!/usr/bin/perl
package usuario::historial::ver_todas;
use strict;
use warnings;

use interfaz_usuario::usuario;
use usuario::historial::comprobaciones;

sub ver_todas {
  my ($usuario, $codigo_depto) = @_;
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();

  my $reabastecimiento_depto = usuario::historial::comprobaciones::comprobar_existencia($usuario, $codigo_depto);

  print "Código del medicamento: "; chomp(my $codigo = <STDIN>);

  return interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($usuario, $codigo_depto);
}

1;
