#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento_modulos::aprobado;
use warnings;
use strict;

use administrador::Reabastecimiento::reabastecimiento_modulos::verificar_inventario;
use administrador::Reabastecimiento::reabastecimiento_modulos::desaprobado;
use administrador::Reabastecimiento::reabastecimiento_modulos::cambiar_estado;
use administrador::Reabastecimiento::reabastecimiento_modulos::eliminar_nodo;
use usuario::reabastecimiento::operar_lista_cde;
use administrador::Reabastecimiento::reabastecimiento;

sub aprobado {
  my ($codigo, $prioridad, $codigo_depto, $nombre_med, $cantidad, $fecha_solicitud, $razon, $codigo_unico) = @_;

  if ( !administrador::Reabastecimiento::reabastecimiento_modulos::verificar_inventario::validar_cantidad_disponible($codigo, $cantidad) ) {
    print "No hay suficiente stock en el inventario.\n";
    print "Desaprobando solicitud...\n";
    print "Presione Enter para continuar..."; my $pausa = <STDIN>;
    return administrador::Reabastecimiento::reabastecimiento_modulos::desaprobado::desaprobado(
      $codigo,
      $prioridad,
      $codigo_depto,
      $nombre_med,
      $cantidad,
      $fecha_solicitud,
      $razon,
      $codigo_unico);
  }

  administrador::Reabastecimiento::reabastecimiento_modulos::cambiar_estado::cambiar_estado(
    $codigo, 
    $prioridad, 
    $codigo_depto, 
    $nombre_med, 
    $cantidad, 
    $fecha_solicitud, 
    "Aprobado",
    $razon,
    $codigo_unico);

  administrador::Reabastecimiento::reabastecimiento_modulos::eliminar_nodo::eliminar_nodo(
    $codigo, 
    $prioridad, 
    $codigo_depto, 
    $nombre_med, 
    $cantidad, 
    $fecha_solicitud, 
    $razon,
    "Aprobada",
    $codigo_unico);

  usuario::reabastecimiento::operar_lista_cde::agregar_tras_aprobar($codigo_depto);

  return administrador::Reabastecimiento::reabastecimiento::verificacion();
}

1;
