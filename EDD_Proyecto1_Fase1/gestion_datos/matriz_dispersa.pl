#!/usr/bin/perl
package gestion_datos::matriz_dispera;
use warnings;
use strict;

sub nuevo {
  my ($clase, $filas, $columnas) = @_;

  my $self = {
    filas => $filas,
    columnas => $columnas,
    datos => {},
  };

  bless $self, $clase;
  return $self;
}

sub insertar {
  my ($self, $fila, $columna, $valor) = @_;

  if ( $fila < 0 || $fila >= $self->{filas} ) {
    print "Índice fuera del rango de la fila...\n";
  }
  if ( $columna < 0 || $columna >= $self->{columnas} ) {
    print "Índice fuera del rango de la columna...\n";
  }

  my $idx = "$fila,$columna";

  ## Si el valor es cero se elimina para ahorrar espacio en memoria
  ## De lo contrario nos llevamos la coordenada
  if ( $valor == 0 ) {
    delete $self->{datos}{$idx};
  } else {
    $self->{datos}{$idx} = $value;
  }
}


