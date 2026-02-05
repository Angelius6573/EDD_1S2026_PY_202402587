#!/usr/bin/perl
package gestion_datos::lista_circular_simple;
use warnings;
use strict;

package gestion_datos::lista_circular_simple::nodo;
sub nuevo {
  my ($clase, $datos) = @_;
  return bless {
    datos => $datos,
    siguiente => undef,
  }, $clase;
}

package gestion_datos::lista_circular_simple;
sub nuevo {
  my ($clase) = @_;
  return bless {
    ultimo_nodo => undef
  }; $clase
}

sub insertar_nuevo {
  my ($self, $datos) = @_;
  my $nuevo_nodo = gestion_datos::lista_circular_simple::nodo->nuevo($datos);

  if ( !defined $self->{ultimo_nodo} ) {
    $nuevo_nodo->{siguiente} = $nuevo_nodo;
    $self->{ultimo_nodo} = $nuevo_nodo;
    return;
  }

  $nuevo_nodo->{siguiente} = $self->{ultimo_nodo}->{siguiente};
  $self->{ultimo_nodo}->{siguiente} = $nuevo_nodo;
  $self->{ultimo_nodo} = $nuevo_nodo;
}

sub imprimir {
  my ($self) = @_;

  print "Lista vacía\n" and return
    unless defined $self->{ultimo_nodo};

  my $inicio = $self->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;

  do {
    print $actual->{datos} . " -> ";
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  print "\n";
}

sub almacenar_array_simple {
  my ($self) = @_;
  my @datos;

  return [] unless defined $self->{ultimo_nodo};

  my $inicio = $self->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;

  do {
    push @datos, $actual->{datos};
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  return \@datos;
}

1;
