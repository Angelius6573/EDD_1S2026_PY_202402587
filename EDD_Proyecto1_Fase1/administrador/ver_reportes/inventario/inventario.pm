#!/usr/bin/perl
package administrador::ver_reportes::inventario::inventario;
use warnings;
use strict;

use administrador::ver_reportes::mostrar_imagen;

sub generar {
  my $lista = gestion_datos::lista_doblemente_enlazada->nuevo();
  my $copia_inventario = [];
  my $ruta = 'administrador/Inventario/inventario.json';
  my $metodo = "insertar_final";
  utilidades::copiar_contenido_json::copiar($copia_inventario, $ruta, $metodo, $lista);

  my $datos = $lista->gestion_datos::lista_doblemente_enlazada::almacenar_array_simple();
  utilidades::leer_json::guardar_json('administrador/Inventario/inventario.json', $datos);

  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Inventario", "inventario");
  reportes::inventario_dots::generar_diagrama_inventario($lista, $nombre_dot, $nombre_png, $nombre_svg);
}

sub mostrar {
  my $directorio = "reportes/imagenes/Inventario/SVG";
  administrador::ver_reportes::mostrar_imagen::mostrar($directorio);
}

sub mostrar_nuevo {
  generar();
  mostrar();
}

1;
