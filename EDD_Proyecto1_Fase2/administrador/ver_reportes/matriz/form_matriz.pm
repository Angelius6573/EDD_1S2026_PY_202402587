#!/usr/bin/perl
package administrador::ver_reportes::matriz::form_matriz;
use strict;
use warnings;

use feature qw(say switch);

use administrador::ver_reportes::matriz::comparacion_precios;

sub form {
  system("clear");
  print "Bienvenido administrador\n";
  print "¿Qué desea hacer?";
  print "
  1. Generar un nuevo reporte
  2. Ver el último reporte existente
  3. Generar un nuevo reporte y verlo automáticamente
  4. Cancelar\n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 4);
  seleccion($consulta);

  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub seleccion {
  my ($consulta) = @_;
  given($consulta) {
    when (1) {administrador::ver_reportes::matriz::comparacion_precios::generar()}
    when (2) {administrador::ver_reportes::matriz::comparacion_precios::mostrar()}
    when (3) {administrador::ver_reportes::matriz::comparacion_precios::mostrar_nuevo()}
    when (4) {interfaz_usuario::admin::inicio_sesion_admin_exitoso()}
  }
}

1;
