#!/usr/bin/perl
package administrador::ver_reportes::formulario;
use warnings;
use strict;
use feature qw(say switch);

use administrador::ver_reportes::inventario::form_inv;
use administrador::ver_reportes::solicitudes_pendientes::form_s_p;
use administrador::ver_reportes::proveedores::form_proveedores;
use administrador::ver_reportes::matriz::form_matriz;

sub formulario {
  system("clear");
  print "Bienvenido administrador al gestor de reportes\n";
  print "Ingrese el número de reporte que desea ver:";
  print "
  1. Inventario
  2. Solicitudes Pendientes
  3. Proveedores
  4. Comparación de Precios
  5. Cancelar\n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 5);
  return seleccion($consulta);
}

sub seleccion {
  my ($consulta) = @_;
  given($consulta) {
    when (1) {say administrador::ver_reportes::inventario::form_inv::form()}
    when (2) {say administrador::ver_reportes::solicitudes_pendientes::form_s_p::form()}
    when (3) {say administrador::ver_reportes::proveedores::form_proveedores::form()}
    when (4) {say administrador::ver_reportes::matriz::form_matriz::form()}
    when (5) {say interfaz_usuario::admin::inicio_sesion_admin_exitoso()}
  }
}

1;
