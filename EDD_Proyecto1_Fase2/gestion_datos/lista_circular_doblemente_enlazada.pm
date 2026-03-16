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

sub cambiar_estado_multi_parametro {
  my ($self, $parametros, $campo, $nuevo_valor) = @_;

  return 0 unless defined $self->{cabeza};

  my $actual = $self->{cabeza};
  my $inicio = $actual;

  do {
    if ( ref($actual->{datos}) eq 'HASH' ) {
      my $coincide = 1;

      # Comprobamos que todos los parámetros coinciden
      #! Importante: Consultar más acerca del "keys", es sumamente importante, si esto no existe
      #              no procesa correctamente el cambio de información.
      foreach my $clave ( keys %$parametros ) {
        if ( !defined $actual->{datos}->{$clave} ||
             !defined $parametros->{$clave} ||
             $actual->{datos}->{$clave} ne $parametros->{$clave} ) {
          $coincide = 0;
          last;
        }
      }
      
      if ( $coincide ) {
        $actual->{datos}->{$campo} = $nuevo_valor;
        return 1;
      }
    }
    $actual = $actual->{siguiente};
  } while ($actual != $inicio);
  return 0;
}

sub eliminar_multi_parametro {
  my ($self, $parametros) = @_;

  return 0 unless defined $self->{cabeza};

  my $actual = $self->{cabeza};
  my $inicio = $actual;

  do {
    if ( ref($actual->{datos}) eq 'HASH' ) {
      my $coincide = 1;

      # Verificar que todos los parámetros coincidan, al igual que con el cambio de estado
      # el uso de keys es brutalmente necesario
      foreach my $clave ( keys %$parametros ) {
        if ( !defined $actual->{datos}->{$clave} ||
             !defined $parametros->{$clave} ||
             $actual->{datos}->{$clave} ne $parametros->{$clave} ) {
          $coincide = 0;
          last;
        }
      }
      # Si todos los criterios coinciden, eliminar este nodo
      if ( $coincide ) {
        # Caso: único nodo en la lista
        if ($actual->{siguiente} == $actual) {
          $self->{cabeza} = undef;
          return 1;
        }

        # Ajustar enlaces para eliminar el nodo
        $actual->{anterior}->{siguiente} = $actual->{siguiente};
        $actual->{siguiente}->{anterior} = $actual->{anterior};

        # Si eliminamos la cabeza, actualizar referencia
        if ($actual == $self->{cabeza}) {
          $self->{cabeza} = $actual->{siguiente};
        }

        return 1;  # Éxito
      }
    }
    $actual = $actual->{siguiente};
  } while ($actual != $inicio);
  return 0;
}

1;
