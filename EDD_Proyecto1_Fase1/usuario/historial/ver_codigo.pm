#!/usr/bin/perl
package usuario::historial::ver_codigo;
use strict;
use warnings;
use Term::ANSIColor;

sub ver_color {
  my ($estado) = @_;

  my %colores = (
    "Pendiente" => 'yellow',
    "Aprobado" => 'green',
    "Desaprobado" => 'red'
  );

  return exists $colores{$estado} ? colored($estado, $colores{$estado}) : $estado;
}

1;
