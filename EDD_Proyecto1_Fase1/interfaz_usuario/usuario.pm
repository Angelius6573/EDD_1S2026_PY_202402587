#!/usr/bin/perl
package interfaz_usuario::usuario;
use strict;
use warnings;
use feature qw(say switch);

use utilidades::limite_entrada;
use interfaz_usuario::inicio;
use usuario::consultar_disponibilidad;
use usuario::historial_solicitudes;
use usuario::solicitar_reabastecimiento;

sub inicio_sesion_usuario_exitoso {
  my ($nombre_usuario, $codigo_depto) = @_;

  system("clear");
  print "Bienvenido nuevamente $nombre_usuario\n";
  print "Elige tu siguiente acción:
  1. Consultar disponibilidad de un producto
  2. Solicitar reabastecimiento
  3. Visualizar historial de solicitudes
  4. Cerrar Sesión \n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 4);
  return consulta($consulta, $nombre_usuario, $codigo_depto);
}

sub consulta {
  my ($opcion, $nombre_usuario, $codigo_depto) = @_;
  given($opcion) {
    when (1) {say usuario::consultar_disponibilidad::consulta_medicamento($nombre_usuario, $codigo_depto)} # No realmente
    when (2) {say usuario::solicitar_reabastecimiento::solicitud_medicamentos($nombre_usuario, $codigo_depto)}
    when (3) {say usuario::historial_solicitudes::historial_solicitudes($nombre_usuario, $codigo_depto)}
    when (4) {say interfaz_usuario::inicio::consultar_usuario()}
  }
}

1;
