#!/usr/bin/perl
package utilidades::validar_numeros;
use warnings;
use strict;

our $int_positivo_regex = qr/^\d+$/;
our $float_positivo_regex = qr/^\d+(?:\.\d+)?$/;

sub validar_int_positivo {
  my ($numero) = @_;
  if ($numero =~ $int_positivo_regex) {
    return $numero;
  } else {
    return undef;
  }
}

sub validar_float_positivo {
  my ($numero) = @_;
  if ($numero =~ $float_positivo_regex) {
    return $numero;
  } else {
    return undef;
  }
}

1;
