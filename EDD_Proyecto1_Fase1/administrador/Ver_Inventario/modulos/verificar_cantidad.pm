#!/usr/bin/perl
package administrador::Ver_Inventario::modulos::verificar_cantidad;
use warnings;
use strict;

sub verificar_cantidad {
  my ($cantidad_minima, $cantidad_existente) = @_;
  my @rangos = (
    { factor => 0.2 , estado => "<= 20% requerido"},
    { factor => 0.5 , estado => "<= 50% requerido"},
    { factor => 1 ,   estado => "Mínimo requerido"},
    { factor => 1.5 , estado => "Mínima asegurada"},
    { factor => 2 ,   estado => "Media asegurada"},
    { factor => 3 ,   estado => "Alta asegurada"},
    { factor => 4 ,   estado => "Suficiente"}
  );
  foreach my $rango ( @rangos ) {
    if ( $cantidad_existente <= $rango->{factor} * $cantidad_minima ) {
      return $rango->{estado};
    }
  }
  return $rangos[-1]->{estado};
}

1;
