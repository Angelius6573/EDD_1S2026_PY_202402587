#!/usr/bin/perl
package administrador::Reabastecimiento::reabastecimiento_modulos::eliminar_nodo;
use strict;
use warnings;

use utilidades::leer_json;
use gestion_datos::lista_circular_doblemente_enlazada;

sub eliminar_nodo {
  my ($codigo, $prioridad, $codigo_depto, $nombre_med, $cantidad, $fecha_solicitud, $razon, $estado, $codigo_unico) = @_;

  my $ruta = "administrador/Reabastecimiento/solicitudes_reabastecimiento.json";
  my $datos = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  # Cargar datos en la lista circular
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  foreach my $solicitud (@$datos) {
    $lista->insertar_final($solicitud);
  }

  my %parametros = (
    cantidad => $cantidad,
    codigo => $codigo,
    codigo_departamental => $codigo_depto,
    fecha_solicitud => $fecha_solicitud,
    nombre => $nombre_med,
    prioridad => $prioridad,
    razon => $razon,
    codigo_unico => $codigo_unico
  );

  # Eliminar usando múltiples parámetros para mayor precisión
  if ($lista->eliminar_multi_parametro(\%parametros)) {
    my $datos_actualizados = $lista->almacenar_array_simple();
    utilidades::leer_json::guardar_json($ruta, $datos_actualizados);
    print "Solicitud $estado procesada correctamente, retirando de la lista...\n";
    print "Presione Enter para continuar..."; my $pausa = <STDIN>;
    return 1;
  } else {
    print "No se encontró solicitud con los criterios especificados.\n";
    print "Presione Enter para continuar..."; my $pausa = <STDIN>;
    return 0;
  }
}

1;
