#!/usr/bin/perl
package administrador::Consultas::modulos::obtener_f_c;
use strict;
use warnings;

sub limites {
  my ($nombres, $laboratorios) = @_;

  my $n_cantidad = 0;
  my $l_cantidad = 0;

  foreach my $nombre ( @$nombres ) {
    $n_cantidad++;
  }
  foreach my $laboratorio ( @$laboratorios ) {
    $l_cantidad++;
  }
  return ($n_cantidad, $l_cantidad);
}

1;
