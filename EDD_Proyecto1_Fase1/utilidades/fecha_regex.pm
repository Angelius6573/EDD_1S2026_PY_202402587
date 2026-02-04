#!/usr/bin/perl
package utilidades::fecha_regex;
use strict;
use warnings;
use Time::Piece;

## Expresión regular
# qr/...$/ -> Operador propio de perl que facilita la compilación de la expresión regular
# ^ -> Se encarga de usar el método regex, es decir, de izquierda a derecha
# ([0-2][0-9]|3[0-1]) -> Determina el número de día, 1 (0-0 ; 0-1) hasta 29 (0-2 ; 0 9) ó 30, 31 
# \/ -> Delimitador entre expresiones
# (0[1-9]|1[0-2]) -> Determina el número de mes, 1 hasta 9, ó 10 a 12
# ([0-9]{4}) -> Determina el año, 0001 hasta el 9999
our $fecha_regex = qr/^([0-2][0-9]|3[0-1])\/(0[1-9]|1[0-2])\/([0-9]{4})$/;

sub validar_fecha {
  my ($fecha_comprobar) = @_;
  return $fecha_comprobar =~ $fecha_regex;
}

sub es_vencida {
  my ($fecha_comprobar) = @_;
  my $fecha_hoy = localtime;

  return undef unless validar_fecha($fecha_comprobar);
  my ($dia, $mes, $anio) = $fecha_comprobar =~ $fecha_regex;

  my $fecha_simbolica = Time::Piece->strptime("$dia/$mes/$anio", "%d/%m/%Y");

  if ( $fecha_simbolica < $fecha_hoy ) {
    return 1;
  } else {
    return 0;
  }
}

1;
