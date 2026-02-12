#!/usr/bin/perl
package administrador::Inventario::buscar_medicamento_codigo;
use strict;
use warnings;
use utilidades::leer_json;

sub por_codigo { # Método para hallar el nombre de un medicamento por su código
  my ($codigo) = @_;
  my $ruta_inventario = 'administrador/Inventario/inventario.json';
  my $inventario = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta_inventario);
  
  foreach my $medicamento (@$inventario) {
    return $medicamento if $medicamento->{codigo} eq $codigo;
  }
  
  return undef;  # No encontrado
}

sub en_general_lista {
  my ($ruta, $lista, $metodo) = @_;
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  unless ($lista->can($metodo)) {
    warn "Error: El objeto no tiene el método '$metodo'\n";
    return $lista;
  }

  return $lista unless defined $datos && ref($datos) eq 'ARRAY';

  foreach my $instancia ( @$datos ) {
    $lista->$metodo($instancia);
  }

  return $lista;
}

sub en_general {
  my ($ruta) = @_;
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  return $datos;
}

sub ver_primero {
  my ($ruta) = @_;
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  return $datos->[0] if @$datos > 0;
  return undef;
}

1;
