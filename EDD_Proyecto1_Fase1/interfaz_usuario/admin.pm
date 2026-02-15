#!/usr/bin/perl
package interfaz_usuario::admin;
use strict;
use warnings;
use feature qw(say switch);

use utilidades::limite_entrada;
use utilidades::leer_json;
use administrador::Inventario::inventario;
use administrador::Proveedores::proveedores;
use administrador::Reabastecimiento::reabastecimiento;
use administrador::Ver_Inventario::ver_inventario;

sub inicio_sesion_admin_exitoso {
  print "Bienvenido nuevamente administrador \n";
  print "¿Qué haremos hoy?";
  print "
  1. Registrar medicamento
  2. Carga masiva de medicamentos
  3. Gestionar proveedores
  4. Registrar engrega de proveedor
  5. Procesar solicitudes de reabastecimiento
  6. Visualizar inventario
  7. Consultar inventario //Matriz Dispersa
  8. Gestionar usuarios //Función aún por valuar su implementación
  9. Cerrar sesión
";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 9);
  return seleccion($consulta);
}

sub seleccion {
  my ($opcion_seleccionada) = @_;
  given ($opcion_seleccionada) {
    when (1) {say administrador::Inventario::inventario::registrar_medicamento()}
    when (2) {say administrador::Inventario::inventario::registrar_medicamento_masivo()}
    when (3) {say administrador::Proveedores::proveedores::gestionar_proveedor()}
    when (4) {say administrador::Proveedores::proveedores::registrar_entrega()}
    when (5) {say administrador::Reabastecimiento::reabastecimiento::verificacion()}
    when (6) {say administrador::Ver_Inventario::ver_inventario::ver_inventario()}
    when (9) {say interfaz_usuario::inicio::consultar_usuario()}
  }
}

1;

