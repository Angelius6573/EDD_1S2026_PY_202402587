#!/usr/bin/perl
package administrador::Inventario::buscar_medicamento_codigo;
use strict;
use warnings;

use utilidades::leer_json;
use interfaz_usuario::admin;
use utilidades::cerrar;

sub por_codigo { # Método para hallar el nombre de un medicamento por su código
  my ($codigo) = @_;
  my $ruta_inventario = 'administrador/Inventario/inventario.json';
  my $inventario = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta_inventario);

  foreach my $medicamento (@$inventario) {
    return $medicamento if $medicamento->{codigo} eq $codigo;
  }

  return undef;  # No encontrado
}

sub obtener_lab_name {
  my ($ruta) = @_;
  my $inventario = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  if (!defined $inventario || ref($inventario) ne 'ARRAY' || @$inventario == 0) {
    warn "Advertencia: El inventario está vacío o no es válido.\n";
    utilidades::cerrar::cerrar();
    return interfaz_usuario::admin::inicio_sesion_admin_exitoso();  # Retornar referencias a arrays vacíos
  }

  my %nombres_u = ();
  my %laboratorios_u = ();

  foreach my $medicamento ( @$inventario ) {
    $nombres_u{$medicamento->{nombre}} = 1;
    $laboratorios_u{$medicamento->{laboratorio}} = 1;
  }

  my @nombres = keys %nombres_u;
  my @laboratorios = keys %laboratorios_u;

  return (\@nombres, \@laboratorios);
}

sub en_general_lista {
  my ($ruta, $lista, $metodo) = @_;
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  unless ($lista->can($metodo)) {
    warn "Error: El objeto no tiene el método '$metodo'\n";
    utilidades::cerrar::cerrar();
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

sub contar_pendientes {
  my ($ruta) = @_;
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  my $contador = 0;

  return 0 unless defined $datos && ref($datos) eq 'ARRAY';

  foreach my $instancia ( @$datos ) {
    if ( defined $instancia->{estado} && $instancia->{estado} eq "Pendiente" ) {
      $contador++;
    }
    if ( defined $instancia->{nombre} ) {
      $contador++;
    }
  }

  return $contador;
}

sub contar_pendientes_usuarios {
  my ($ruta) = @_;
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  my $contador = 0;

  return 0 unless defined $datos && ref($datos) eq 'ARRAY';

  foreach my $instancia ( @$datos ) {
    if ( defined $instancia->{nombre} ) {
      $contador++;
    }
  }

  return $contador;
}

1;
