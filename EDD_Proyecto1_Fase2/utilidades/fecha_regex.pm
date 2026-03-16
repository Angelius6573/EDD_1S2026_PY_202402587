#!/usr/bin/perl
package utilidades::fecha_regex;
use strict;
use warnings;
use Time::Piece;

## Expresión regular
# qr/...$/ -> Operador propio de perl que facilita la compilación de la expresión regular
# ^ -> Se encarga de usar el método regex, es decir, de izquierda a derecha
# ([0-9]{4}) -> Determina el año, 0001 hasta el 9999
# \/ -> Delimitador entre expresiones
# (0[1-9]|1[0-2]) -> Determina el número de mes, 1 hasta 9, ó 10 a 12
# ([0-2][0-9]|3[0-1]) -> Determina el número de día, 1 (0-0 ; 0-1) hasta 29 (0-2 ; 0 9) ó 30, 31 
## our $fecha_regex = qr/^([0-9]{4})\/(0[1-9]|1[0-2])\/([0-2][0-9]|3[0-1])$/;
# Modificado para que solo espere años entre 1990 a 2050, razonable margen de tiempo
our $fecha_regex = qr/^(199[0-9]|20[0-4][0-9]|2050)\/(0[1-9]|1[0-2])\/([0-2][0-9]|3[0-1])$/;

sub validar_fecha {
  my ($fecha_comprobar) = @_;
  if ($fecha_comprobar =~ $fecha_regex) {
    return $fecha_comprobar;
  } else {
    return undef;
  }
}

sub es_vencida {
  my ($fecha_comprobar) = @_;
  my $fecha_hoy = localtime;

  return undef unless validar_fecha($fecha_comprobar);
  my ($anio, $mes, $dia) = $fecha_comprobar =~ $fecha_regex;

  my $fecha_simbolica = Time::Piece->strptime("$anio/$mes/$dia", "%d/%m/%Y");

  if ( $fecha_simbolica < $fecha_hoy ) {
    return 1;
  } else {
    return 0;
  }
}

1;
