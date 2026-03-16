#!/usr/bin/perl
package utilidades::comparar_cantidades;
use strict;
use warnings;

use feature qw(say switch);

sub comparar_cantidades {
  my ($cantidad, $cantidad_minima) = @_;

  my @rangos = (
    { factor => 0.2 , estado => "24 horas"},
    { factor => 0.5 , estado => "48 horas"},
    { factor => 1 , estado => "3 días"},
    { factor => 1.5 , estado => "4 días"},
    { factor => 2 , estado => "5 días"},
    { factor => 3 , estado => "10 días"},
    { factor => 4 , estado => "20 días"}
  );

  foreach my $rango ( @rangos ) {
    if ( $cantidad <= $rango->{factor} * $cantidad_minima ) {
      return $rango->{estado};
    }
  }
  return $rangos[-1]->{estado}; # Si no coincide con ningún factor, regresa "20 días"
}

1;
=begin comment
  my $tiempo_reabastecimiento = 0;

  my @Estados = ("24 horas", "48 horas", "3 días", "4 días", "5 días", "10 días", "20 días");

  my @valores = (
      0.2 * $cantidad_minima, 
      0.5 * $cantidad_minima, 
      $cantidad_minima, 
      $cantidad_minima+50, 
      $cantidad_minima+150,
      $cantidad_minima+300
  );

  $tiempo_reabastecimiento++ while $tiempo_reabastecimiento < @valores && $cantidad > $valores[$tiempo_reabastecimiento];

  return $Estados[$tiempo_reabastecimiento];
}

1;

  cantidad mayor que 0 y menor que el 20% de cantidad_minima -> Estados[0]
  cantidad mayor que 20% de cantidad_minima y menor que 50% de cantidad_minima -> Estados[1]
  cantidad mayor que 50% de cantidad_minima y menor que cantidad_minima -> Estados[2] 
  cantidad mayor que cantidad_minima y menor que cantidad_minima+50 -> Estados[3] 
  cantidad mayor que cantidad_minima+50 y menor que cantidad_minima+150 -> Estados[4] 
  cantidad mayor que cantidad_minima+150 y menor que cantidad_minima+300 -> Estados[5] 
  cantidad mayor que cantidad_minima+300 -> Estados[6]
=cut

