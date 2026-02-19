#!/usr/bin/perl
package administrador::Inventario::leer_inventario_json;
use strict;
use warnings;

use POSIX qw(strftime);
use utilidades::leer_json;
use interfaz_usuario::admin;
use interfaz_usuario::usuario;
use gestion_datos::lista_doblemente_enlazada;
use utilidades::copiar_contenido_json;
use reportes::inventario_dots;
use reportes::nombre_archivos;
use utilidades::cerrar;

## Las siguientes subrutinas se usan en las subrutina del registro de medicamentos del administrador,
# en la identificación inicial del usuario para comprobar si el medicamento que quiere consultar existe
# y para solicitud de reabastecimiento.
## Se separa en dos subrutinas para evitar caer en las validaciones internas, y porque el usuario puede ingresar
# un nombre de medicamento y no solo el código

sub identificar_codigo_nombre_disponible {
  my ($validar) = @_;
  my $ruta = 'administrador/Inventario/inventario.json';

  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $medicamento ( @$datos ) {
    if ( $medicamento->{codigo} eq $validar || $medicamento->{nombre} eq $validar ) {
      print " Nombre del medicamento: $medicamento->{nombre}\n";
      print " Cantidad disponible: $medicamento->{cantidad}\n";
      print " Tiempo de reabastecimiento: $medicamento->{tiempo_reabastecer}\n\n";
      return 1;
    }
  }
  print "La información solicitada no existe. Regresando al menú del usuario...\n";
  return 0;
}

sub identificar_codigo_reabastecimiento {
  my ($codigo, $nombre_usuario, $codigo_depto) = @_;
  my $ruta = 'administrador/Inventario/inventario.json';
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $medicamento (@$datos) {
    if ( $medicamento->{codigo} eq $codigo ) {
      return 1
    }
  }

  print "El medicamento solicitado no existe en el inventario. Regresando al menú de usuario...\n";
  utilidades::cerrar::cerrar();
  interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($nombre_usuario, $codigo_depto);
  return 0;
}

sub identificar_codigo_registro_medicamentos { 
  my ($codigo_verificar) = @_;
  my $ruta = 'administrador/Inventario/inventario.json';

  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $medicamento ( @$datos ) {
    if ( $medicamento->{codigo} eq $codigo_verificar) {
        return 1;
    }
  }
  print "El código ingresado no existe en el inventario. Regresando al menú del administrador...\n\n";
  utilidades::cerrar::cerrar();
  interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

## Esta es la subrutina que permite sumar cantidades cuando se registra nuevas entregas.
sub agregar_cantidad {
  my ($codigo, $cantidad_nueva) = @_;

  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();

  my $copia_inventario = [];
  my $ruta = 'administrador/Inventario/inventario.json';
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_inventario, $ruta, $metodo, $lista);

  if ( $lista->modificar_cantidad($codigo, $cantidad_nueva) ) {
    my $datos = $lista->almacenar_array_simple();

    utilidades::leer_json::guardar_json($ruta, $datos);
    print "Inventario actualizado.\n";
  
    ## Reportes
    my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Inventario", "inventario");
    reportes::inventario_dots::generar_diagrama_inventario($lista, $nombre_dot, $nombre_png, $nombre_svg); 
    return 1;
  } else {
    print "No se pudo actualizar el inventario.\n";
    utilidades::cerrar::cerrar();
    return 0;
  }
}

1;
