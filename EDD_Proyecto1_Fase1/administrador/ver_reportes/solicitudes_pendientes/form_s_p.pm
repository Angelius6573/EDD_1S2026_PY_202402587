#!/usr/bin/perl
package administrador::ver_reportes::solicitudes_pendientes::form_s_p;
use strict;
use warnings;
use feature qw(say switch);

use administrador::ver_reportes::solicitudes_pendientes::solicitudes_pendientes;

sub form {
  system("clear");
  print "Bienvenido administrador\n";
  my $codigo_depto = verificar_code_depto();
  print "¿Qué desea hacer?";
  print "
  1. Generar un nuevo reporte
  2. Ver el último reporte existente
  3. Generar un nuevo reporte y verlo automáticamente
  4. Cancelar\n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 4);
  seleccion($consulta, $codigo_depto);

  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

sub seleccion {
  my ($consulta, $codigo_depto) = @_;
  given($consulta) {
    when (1) {administrador::ver_reportes::solicitudes_pendientes::solicitudes_pendientes::generar($codigo_depto)}
    when (2) {administrador::ver_reportes::solicitudes_pendientes::solicitudes_pendientes::mostrar()}
    when (3) {administrador::ver_reportes::solicitudes_pendientes::solicitudes_pendientes::mostrar_nuevo($codigo_depto)}
    when (4) {interfaz_usuario::admin::inicio_sesion_admin_exitoso()}
  }
}

sub verificar_code_depto {
  print "Ingrese el código departamental: "; chomp(my $codigo_depto = <STDIN>);
  my $ruta = "interfaz_usuario/usuarios.json";
  my $usuarios = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $usuario ( @$usuarios ) {
    return $codigo_depto if $usuario->{codigo_departamental} eq $codigo_depto;
  }

  print "El código departamental ingresado no existe\n";
  print "Regresando al menú\n";
  utilidades::cerrar::cerrar();
  return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
}

1;
