#!/usr/bin/perl 
package administrador::Proveedores::comprobaciones;
use strict;
use warnings;

use utilidades::leer_json;

# Metodo para parsear todo el archivo proveedores.json para identificar que no haya NITs repetidos
sub validar_nit {
  my ($lista_circular, $validar_nit) = @_;

  # Si la lista esta vacía, el NIT no existe, valga la redundancia :P
  return 1 unless defined $lista_circular->{ultimo_nodo}; 

  my $inicio = $lista_circular->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;

  do {
    if ( $actual->{datos}->{NIT} eq $validar_nit ) {
      return 0; # El NIT si existe
    }
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio);

  return 1;
}

sub validar_telefono {
  my ($lista_circular, $validar_telefono) = @_;

  return 1 unless defined $lista_circular->{ultimo_nodo};

  my $contador = 0;
  my $inicio = $lista_circular->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;

  do {
    if ( $actual->{datos}->{Telefono} eq $validar_telefono ) {
      return 0; # Lo mismo que con el nit pero con el telefono 
    }
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio);

  return ($contador <= 1) ? 1 : 0; # Operador ternario en Perl
}

sub validar_factura {
  my ($lista_circular, $validar_factura) = @_;

  return 1 unless defined $lista_circular->{ultimo_nodo};

  my $inicio = $lista_circular->{ultimo_nodo}->{siguiente};
  my $actual = $inicio;

  ## Doble foreach, porque se tiene que analizar elemento por elemento de codigo, y entre medias, entrar a cada
  ## entrega existente para verificar que no se repite ninguna factura a nivel global dentro de proveedores.json
  do {
    if ( exists $actual->{datos}->{Entregas} && ref $actual->{datos}->{Entregas} eq 'ARRAY' ) {
      foreach my $entrega ( @{$actual->{datos}->{Entregas}} ) {
        if ( $entrega->{Factura} eq $validar_factura ) {
          return 0;
        }
      }
    }
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio);

  return 1;
}

1;
