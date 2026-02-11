#!/usr/bin/perl
package usuario::reabastecimiento::operar_lista_cde;
use strict;
use warnings;

use gestion_datos::lista_circular_doblemente_enlazada;
use utilidades::copiar_contenido_json;
use utilidades::leer_json;
use reportes::nombre_archivos;
use reportes::reabastecimiento_dots;

sub agregar {
  my ($codigo, $cantidad, $prioridad, $razon) = @_;
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();

  my $copia_solicitudes = [];
  my $ruta = 'administrador/Reabastecimiento/solicitudes_reabastecimiento.json';
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_solicitudes, $ruta, $metodo, $lista);

  $lista->insertar_final({
      codigo => $codigo,
      cantidad => $cantidad,
      prioridad => $prioridad,
      razon => $razon,
      estado => "Pendiente"
  });
  my $datos = $lista->almacenar_array_simple();
  utilidades::leer_json::guardar_json($ruta, $datos);

  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Solicitud_Reabastecimiento", "solicitud_pendiente");
  reportes::reabastecimiento_dots::generar_diagrama_solicitud_reabastecimiento($lista, $nombre_dot, $nombre_png, $nombre_svg);
}

1;
