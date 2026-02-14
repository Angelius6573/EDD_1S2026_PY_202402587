#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento;
use strict;
use warnings;
use feature qw(say switch);

use administrador::Reabastecimiento::reabastecimiento_modulos::mostrar_info;
use utilidades::limite_entrada;
use administrador::Reabastecimiento::reabastecimiento_modulos::aprobado;
use administrador::Reabastecimiento::reabastecimiento_modulos::desaprobado;
use administrador::Reabastecimiento::reabastecimiento_modulos::mostrar_info;
use interfaz_usuario::admin;

sub procesar_solicitud {
  system("clear");
  my ($codigo, $prioridad, $codigo_depto, $nombre_med, $cantidad, $fecha_solicitud, $razon, $codigo_unico) = administrador::Reabastecimiento::reabastecimiento_modulos::mostrar_info::mostrar_info();
  my $mensaje = "¿Desea aprobar la solicitud? (Y/N): ";
  my $confirmacion = utilidades::limite_entrada::comprobacion_y_n($mensaje); ## 5. Solicitar confirmación
  given ($confirmacion) {
    when ("Y") {say administrador::Reabastecimiento::reabastecimiento_modulos::aprobado::aprobado(
        $codigo,
        $prioridad,
        $codigo_depto,
        $nombre_med,
        $cantidad,
        $fecha_solicitud,
        $razon,
        $codigo_unico)}
    when ("N") {say administrador::Reabastecimiento::reabastecimiento_modulos::desaprobado::desaprobado(
        $codigo,
        $prioridad,
        $codigo_depto,
        $nombre_med,
        $cantidad,
        $fecha_solicitud,
        $razon,
        $codigo_unico)}
  }
}

sub verificacion {
  system("clear");
  print "Bienvenido administrador al módulo de aceptación de solicitudes de reabastecimiento\n";
  my $mensaje = "¿Desea ver la solicitud? (Y/N): ";
  my $verificacion = utilidades::limite_entrada::comprobacion_y_n($mensaje);
  given ($verificacion) {
    when ("Y") {say procesar_solicitud()}
    when ("N") {say interfaz_usuario::admin::inicio_sesion_admin_exitoso()}
  }
}

1;
