#!/usr/bin/perl
package gestion_datos::lista_doblemente_enlazada;
use strict;
use warnings;

# Clase Nodo
package gestion_datos::lista_doblemente_enlazada::nodo;
sub nuevo {
    my ($clase, $datos) = @_;
    return bless {
      datos => $datos,      #Información (array) almacenada en el nodo
      siguiente => undef,   #Definición del nodo siguiente
      anterior => undef,    #Definición del nodo anterior
    }, $clase;
}

# Clase "Lista Doblemente Enlazada"
package gestion_datos::lista_doblemente_enlazada;
sub nuevo {
    my $clase = shift;
    return bless { 
      cabeza => undef, 
      cola => undef 
    }, $clase;
}

# Método crítico para llenar Información
sub insertar_final {
    my ($self, $datos) = @_;
    my $nuevo = gestion_datos::lista_doblemente_enlazada::nodo->nuevo($datos);
    if (!defined $self->{cabeza}) {
        $self->{cabeza} = $nuevo;   #Primer nodo
        $self->{cola} = $nuevo;     #Último nodo
    } else {
        $nuevo->{anterior} = $self->{cola};
        $self->{cola}->{siguiente} = $nuevo;
        $self->{cola} = $nuevo;
    }
}

# Método para recorrer la lista
sub imprimir {
    my $self = shift;
    my $actual = $self->{cabeza};
    while ($actual) {
        print $actual->{datos}, " <-> ";
        $actual = $actual->{siguiente};
    }
    print "NULL\n";
}

# Método para llenar los archivos JSON, preparar para los reportes
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

# Método para buscar el elemento cuyo código coincida y modificar su cantidad
# Esto es para modificar el inventario.json desde el formulario de nueva entrega
sub modificar_cantidad {
  my ($self, $codigo, $cantidad) = @_;
  my $actual = $self->{cabeza};

  while ( $actual ) {
    if ( $actual->{datos}->{codigo} eq $codigo ) {
      $actual->{datos}->{cantidad} += $cantidad;
      return 1;
    }
    $actual = $actual->{siguiente};
  }
  return 0;
}

# Método para ordenar la lista por un campo específico
sub ordenar_por_campo {
  my ($self, $campo) = @_;

  return if !$self->{cabeza};  # Lista vacía

  my $intercambiado;
  do {
    $intercambiado = 0;
    my $actual = $self->{cabeza};

    while ($actual && $actual->{siguiente}) {
      # Comparar el campo del nodo actual con el siguiente
      if ($actual->{datos}->{$campo} gt $actual->{siguiente}->{datos}->{$campo}) {
        # Intercambiar los datos completos
        my $temp = $actual->{datos};
        $actual->{datos} = $actual->{siguiente}->{datos};
        $actual->{siguiente}->{datos} = $temp;
        $intercambiado = 1;
      }
      $actual = $actual->{siguiente};
    }
  } while ($intercambiado);  # Repetir hasta que no haya intercambios
}

sub eliminar_multi_parametro {
  my ($self, $parametros) = @_;

  return 0 unless defined $self->{cabeza};

  my $actual = $self->{cabeza};

  while ($actual) {

    if ( ref($actual->{datos}) eq 'HASH' ) {

      my $coincide = 1;

      foreach my $clave (keys %$parametros) {

        if ( !defined $actual->{datos}->{$clave}
          || !defined $parametros->{$clave}
          || $actual->{datos}->{$clave} ne $parametros->{$clave} ) {

          $coincide = 0;
          last;
        }
      }

      if ($coincide) {

        # Caso 1: único nodo
        if ($actual == $self->{cabeza} && $actual == $self->{cola}) {
          $self->{cabeza} = undef;
          $self->{cola}   = undef;
        }

        # Caso 2: es cabeza
        elsif ($actual == $self->{cabeza}) {
          $self->{cabeza} = $actual->{siguiente};
          $self->{cabeza}->{anterior} = undef if $self->{cabeza};
        }

        # Caso 3: es cola
        elsif ($actual == $self->{cola}) {
          $self->{cola} = $actual->{anterior};
          $self->{cola}->{siguiente} = undef if $self->{cola};
        }

        # Caso 4: nodo intermedio
        else {
          $actual->{anterior}->{siguiente} = $actual->{siguiente};
          $actual->{siguiente}->{anterior} = $actual->{anterior};
        }

        return 1;  # eliminado correctamente
      }
    }

    $actual = $actual->{siguiente};
  }

  return 0; # no encontrado
}

1;
