#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento_modulos::cambiar_estado;
use warnings;
use strict;

use gestion_datos::lista_circular_doblemente_enlazada;
use administrador::Inventario::buscar_medicamento_codigo;
use utilidades::leer_json;
use administrador::Reabastecimiento::reabastecimiento;

sub cambiar_estado {
  my ($codigo, $prioridad, $codigo_depto, $nombre_med, $cantidad, $fecha_solicitud, $estado, $razon, $codigo_unico) = @_;

  my $lista_depto = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $ruta_depto = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto/solicitudes_reabastecimiento.json";

  $lista_depto = administrador::Inventario::buscar_medicamento_codigo::en_general_lista($ruta_depto, $lista_depto, "insertar_final");

  my %parametros = (
    cantidad => $cantidad,
    codigo => $codigo,
    codigo_departamental => $codigo_depto,
    estado => "Pendiente",
    fecha_solicitud => $fecha_solicitud,
    nombre => $nombre_med,
    prioridad => $prioridad,
    razon => $razon,
    codigo_unico => $codigo_unico
  );

  if ( $lista_depto->cambiar_estado_multi_parametro(\%parametros, "estado", $estado) ) {
    my $datos_depto_nuevos = $lista_depto->almacenar_array_simple();
    utilidades::leer_json::guardar_json($ruta_depto, $datos_depto_nuevos);
    print "Estado cambiado exitosamente a: $estado\n";
    print "Presione Enter para continuar..."; my $pausa = <STDIN>;
    return 1;
  } else {
    print "No se encontró solicitud con los criterios especificados.\n";
    return 0;
  }
}

1;
