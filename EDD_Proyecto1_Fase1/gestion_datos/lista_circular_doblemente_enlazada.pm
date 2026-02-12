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

# Método para eliminar la solicitud de la copia del administrador
sub eliminar_por_posicion {
  my ($self, $pos) = @_;
  
  return 0 unless defined $self->{cabeza};
  return 0 if $pos < 0;
  
  my $actual = $self->{cabeza};
  my $indice = 0;
  
  do {
    if ($indice == $pos) {
      # Caso: único nodo
      if ($actual->{siguiente} == $actual) {
        $self->{cabeza} = undef;
        return 1;
      }
      
      # Ajustar enlaces
      $actual->{anterior}->{siguiente} = $actual->{siguiente};
      $actual->{siguiente}->{anterior} = $actual->{anterior};
      
      # Si eliminamos la cabeza
      if ($actual == $self->{cabeza}) {
        $self->{cabeza} = $actual->{siguiente};
      }
      
      return 1;
    }
    $actual = $actual->{siguiente};
    $indice++;
  } while ($actual != $self->{cabeza});
  
  return 0;  # Posición fuera de rango
}

sub modificar_general {
  my ($self, $parametro_buscar, $termino_comprobar, $campo, $nuevo_valor) = @_;
  
  return 0 unless defined $self->{cabeza};
  
  my $actual = $self->{cabeza};
  my $inicio = $actual;
  
  do {
    # Verificar si los datos son un hash ref y tienen el código
    if (ref($actual->{datos}) eq 'HASH' && 
        defined $actual->{datos}->{$parametro_buscar} &&
        $actual->{datos}->{$parametro_buscar} eq $termino_comprobar) {
      
      # Modificar el campo específico
      $actual->{datos}->{$campo} = $nuevo_valor;
      return 1;  # Éxito
    }
    $actual = $actual->{siguiente};
  } while ($actual != $inicio);
  
  return 0;  # No encontrado
}

1;
