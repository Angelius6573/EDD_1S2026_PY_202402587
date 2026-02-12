#!/usr/bin/perl
package usuario::reabastecimiento::operar_lista_cde;
use strict;
use warnings;
use File::Path qw(make_path);
use JSON::PP;

use gestion_datos::lista_circular_doblemente_enlazada;
use utilidades::copiar_contenido_json;
use utilidades::leer_json;
use administrador::Inventario::buscar_medicamento_codigo;
use reportes::nombre_archivos;
use reportes::reabastecimiento_dots;

sub agregar_aprobado_o_desaprobado {
  my ($codigo, $cantidad, $prioridad, $razon, $codigo_depto, $fecha_solicitud) = @_;
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $lista_doblemente_enlazada = gestion_datos::lista_doblemente_enlazada->nuevo();

  my $directorio = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto";
  my $ruta = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto/solicitudes_reabastecimiento.json";
  my $copia_admin = "administrador/Reabastecimiento/solicitudes_reabastecimiento.json";

  unless ( -d $directorio ) {
    make_path($directorio) or die "No se pudo crear el directorio en $directorio: $!";
  }

  unless ( -e $ruta ) {
    open my $fh, '>', $ruta or die "No se pudo crear el archivo en $ruta: $!";
    print $fh "[]";
    close $fh;
  }

  my $solicitudes_existentes = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  foreach my $solicitud ( @$solicitudes_existentes ) {
    $lista->insertar_final($solicitud);
  }

  my $datos = $lista->almacenar_array_simple();
  utilidades::leer_json::guardar_json($ruta, $datos);

  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Solicitud_Reabastecimiento", "solicitud_pendiente");
  reportes::reabastecimiento_dots::generar_diagrama_solicitud_reabastecimiento($lista, $nombre_dot, $nombre_png, $nombre_svg);
}

1;
