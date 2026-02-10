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

sub identificar_codigo { ## Esta subrutinas se usa tanto en la subrutina del registro de medicamentos del administrador y
  ## en la identificación inicial del usuario para comprobar si el medicamento que quiere consultar existe.
  my ($codigo_verificar, $tipo) = @_;
  my $ruta = 'administrador/Inventario/inventario.json';

  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $medicamento ( @$datos ) {
    if ( $medicamento->{codigo} eq $codigo_verificar) {
      if ( $tipo eq "administrador" ) {
        return 1;
      } elsif ( $tipo eq "usuario" ) {
          print "Nombre del medicamento: $medicamento->{nombre}\n";
          print "Cantidad disponible: $medicamento->{cantidad}\n";
          print "Tiempo máximo para el reabastecimiento: $medicamento->{tiempo_reabastecer}\n";
          return 1;
        } 
    }
  }

  if ( $tipo eq "administrador" ) {
    print "El código no existe. Regresando al menú del administrador...\n";
    interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  } elsif ( $tipo eq "usuario") {
    print "El código no existe. Regresando al menú del usuario...\n";
    interfaz_usuario::usuario::inicio_sesion_usuario_exitoso();
  }
  return 0;
}

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
    my $nombre_tiempo = strftime("%Y-%m-%d", localtime);
    my $numero_pseudo_aleatorio = time();
    my $name_dot = "reportes/archivos_dots/Inventario/inventario_$nombre_tiempo-$numero_pseudo_aleatorio.dot";
    my $name_png = "reportes/imagenes/Inventario/PNG/inventario_$nombre_tiempo-$numero_pseudo_aleatorio.png";
    my $name_svg = "reportes/imagenes/Inventario/SVG/inventario_$nombre_tiempo-$numero_pseudo_aleatorio.svg";
    reportes::inventario_dots::generar_diagrama_inventario($lista, $name_dot, $name_png, $name_svg);
    
    return 1;
  } else {
    print "No se pudo actualizar el inventario.\n";
    return 0;
  }
}

1;
