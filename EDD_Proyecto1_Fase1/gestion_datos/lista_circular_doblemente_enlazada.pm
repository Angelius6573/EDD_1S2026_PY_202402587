#!/usr/bin/perl
package gestion_datos::lista_circular_doblemente_enlazada;
use strict;
use warnings;

package gestion_datos::lista_circular_doblemente_enlazada::nodo;
sub nuevo {
  my ($clase, $datos) = @_;
  return bless {
    datos => $datos,
    siguiente => undef,
    anterior => undef
  }, $clase;
}

package gestion_datos::lista_circular_doblemente_enlazada;
sub nuevo {
  my ($clase) = @_;
  return bless {
    cabeza => undef
  }, $clase;
}

sub insertar_final {
  my ($self, $datos) = @_;
  my $nuevo_nodo = gestion_datos::lista_circular_doblemente_enlazada::nodo->nuevo($datos);

  if ( !$self->{cabeza} ) {
    $nuevo_nodo->{siguiente} = $nuevo_nodo;
    $nuevo_nodo->{anterior} = $nuevo_nodo;
    $self->{cabeza} = $nuevo_nodo;
  } else {
    my $cola = $self->{cabeza}->{anterior};
    $cola->{siguiente} = $nuevo_nodo;
    $nuevo_nodo->{anterior} = $cola;
    $nuevo_nodo->{siguiente} = $self->{cabeza};
    $self->{cabeza}->{anterior} = $nuevo_nodo;
  }
}

sub almacenar_array_simple {
  my ($self) = @_;
  my @datos;

  return [] unless defined $self->{cabeza};

  my $inicio = $self->{cabeza};
  my $actual = $inicio;

  do {
    push @datos, $actual->{datos};
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  return \@datos;
}

1;
