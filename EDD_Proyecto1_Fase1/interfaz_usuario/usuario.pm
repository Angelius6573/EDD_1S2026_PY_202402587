#!/usr/bin/perl
package interfaz_usuario::usuario;
use strict;
use warnings;

use interfaz_usuario::leer_json;
use utilidades::limite_entrada;

my $nombre_usuario = interfaz_usuario::leer_json::ver_nombre_usuario; 

sub inicio_sesion_usuario_exitoso {
  print "Bienvenido nuevamente $nombre_usuario\n";
  print "Elige tu siguiente acción:
  1. Consultar disponibilidad de un producto
  2. Solicitar reabastecimiento
  3. Visualizar historial de solicitudes
  4. Cerrar Sesión
  ";

  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 4);
}

1;
