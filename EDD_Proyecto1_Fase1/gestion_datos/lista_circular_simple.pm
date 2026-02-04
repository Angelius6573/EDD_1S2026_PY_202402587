#!/usr/bin/perl
package gestion_datos::lista_circular_simple;
use warnings;
use strict;

package gestion_datos::lista_circular_simple::nodo;
sub nodo {
  my ($datos) = @_;
  return {
    datos => $datos,
    siguiente => undef
  };
}

package gestion_datos::lista_circular_simple;
## Variables para lista como tal
my $ultimo_nodo = undef;

sub insertar_nuevo {
  my ($datos) = @_;
  my $nuevo_nodo = gestion_datos::lista_circular_simple::nodo->nuevo($datos);

  if ( !defined $ultimo ) {
    $nuevo_nodo->{siguiente} = $nuevo_nodo;
    $ultimo_nodo = $nuevo_nodo;
  } else {
    $nuevo_nodo->{siguiente} = $ultimo_nodo->{siguiente};
    $ultimo_nodo->{siguiente} = $nuevo_nodo;
  }
}

sub imprimir {
  my $nodo_actual = $ultimo_nodo->{siguiente};

  do {
    print $nodo_actual->{datos} . " -> ";
    $nodo_actual = $nodo_actual->{siguiente};
  } while ( $nodo_actual != $ultimo_nodo->{siguiente} );
}

sub almacenar_array_simple {
  my $self = shift;
  my @datos;

  my $actual = $self->{cabeza};
  while ( $actual ) {
    push @datos, $actual->{datos};
    $actual = $actual->{siguiente};
  }
  return \@datos;
}

1;
