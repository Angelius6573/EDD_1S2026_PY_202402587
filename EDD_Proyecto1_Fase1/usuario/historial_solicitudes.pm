#!/usr/bin/perl
package usuario::historial_solicitudes;
use strict;
use warnings;
use feature qw(say switch);

use interfaz_usuario::usuario;
use utilidades::limite_entrada;
use usuario::historial::ver_codigo;
use usuario::historial::ver_todas;

sub historial_solicitudes {
  my ($nombre_usuario, $codigo_depto) = @_;
  system("clear");
  print "Bienvenido $nombre_usuario al apartado de consultas de su departamento $codigo_depto\n";
  print "Por favor, indique como desea ver la información
  1. Ver todas las que coincidan con el mismo código
  2. Ver todas
  3. Cancelar\n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 3);
  
  return consulta($consulta, $nombre_usuario, $codigo_depto);
}

sub consulta {
  my ($consulta, $nombre_usuario, $codigo_depto) = @_;

  given ( $consulta ) {
    when (1) {say usuario::historial::ver_codigo::ver_codigo($nombre_usuario, $codigo_depto)}
    when (2) {say usuario::historial::ver_todas::ver_todas($nombre_usuario, $codigo_depto)}
    when (3) {say interfaz_usuario::usuario::inicio_sesion_usuario_exitoso($nombre_usuario, $codigo_depto)}
  }
}

1;
