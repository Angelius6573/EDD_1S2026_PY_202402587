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


1;
