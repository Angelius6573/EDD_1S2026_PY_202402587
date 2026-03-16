#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento_modulos::mostrar_info;
use warnings;
use strict;

use administrador::Inventario::buscar_medicamento_codigo;
use administrador::Reabastecimiento::reabastecimiento;

sub mostrar_info {
  my $ruta = "administrador/Reabastecimiento/solicitudes_reabastecimiento.json";
  my $datos = administrador::Inventario::buscar_medicamento_codigo::ver_primero($ruta); ## 1, 2 y 3

  if ( !defined $datos ) {
    print "Los datos no son válidos.\n";
    return administrador::Reabastecimiento::reabastecimiento::verificacion();
  }

  my $codigo = $datos->{codigo};

  my $prioridad = $datos->{prioridad};
  my $codigo_depto = $datos->{codigo_departamental};
  my $nombre_med = $datos->{nombre};
  my $cantidad = $datos->{cantidad};
  my $fecha_solicitud = $datos->{fecha_solicitud};
  my $razon = $datos->{razon};
  my $codigo_unico = $datos->{codigo_unico};
  
  ## 4. Imprimir los datos
  if ( defined $datos ) {
    print "Solicitud de nivel: $prioridad \n";
    print "Departamento solicitante: $codigo_depto \n";
    print "Medicamento requerido: $nombre_med \n";
    print "Cantidad requerida: $cantidad \n";
    print "Fecha de solicitud: $fecha_solicitud \n";
    print "Razón de la solicitud: $razon \n\n";
  }

  return ($codigo, $prioridad, $codigo_depto, $nombre_med, $cantidad, $fecha_solicitud, $razon, $codigo_unico);
}

1;
