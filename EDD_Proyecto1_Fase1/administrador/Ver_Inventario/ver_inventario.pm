#!/usr/bin/perl
package administrador::Ver_Inventario::ver_inventario;
use strict;
use warnings;

use interfaz_usuario::admin;

sub ver_inventario {
  my $ruta_inventario = "administrador/Inventario/inventario.json";
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta_inventario);

  print "Waos\n";
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
