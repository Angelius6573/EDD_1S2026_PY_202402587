#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento_modulos::desaprobado;
use warnings;
use strict;

use administrador::Reabastecimiento::reabastecimiento_modulos::cambiar_estado;
use administrador::Reabastecimiento::reabastecimiento_modulos::eliminar_nodo;
use administrador::Reabastecimiento::reabastecimiento;

sub desaprobado {
  my ($codigo, $prioridad, $codigo_depto, $nombre_med, $cantidad, $fecha_solicitud, $razon, $codigo_unico) = @_;

  administrador::Reabastecimiento::reabastecimiento_modulos::cambiar_estado::cambiar_estado(
    $codigo, 
    $prioridad, 
    $codigo_depto, 
    $nombre_med, 
    $cantidad, 
    $fecha_solicitud, 
    "Desaprobado",
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
    "Desaprobada",
    $codigo_unico);

  return administrador::Reabastecimiento::reabastecimiento::verificacion();
}

1;
