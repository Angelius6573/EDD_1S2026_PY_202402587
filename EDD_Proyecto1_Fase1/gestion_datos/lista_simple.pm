#!/usr/bin/perl
package gestion_datos::lista_simple;
use warnings;
use strict;

package gestion_datos::lista_simple::nodo;
sub nuevo {
  my ($clase, $datos) = @_;
  return bless {
    datos => $datos,
    siguiente => $undef
  }, $clase;
}

package gestion_datos::lista_simple;
sub nuevo {
  my ($clase) = @_;
  return bless {
    cabeza => undef
  }, $clase;
}

sub insertar_nuevo {
  my ($self, $datos) = @_;
  my $nuevo_nodo = gestion_datos::lista_simple::nodo->nuevo($datos);
  $nuevo_nodo->{siguiente} = $self->{cabeza};
  $self->{cabeza} = $nuevo_nodo;
}

sub imprimir {
  my ($self) = @_;
  my $actual = $self->{cabeza};

  while ( $actual ) {
    print $actual->{datos} . " -> ";
    $actual = $actual->{siguiente};
  }

  print "NULL\n";
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
