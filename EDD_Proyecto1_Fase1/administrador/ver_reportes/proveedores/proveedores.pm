#!/usr/bin/perl
package administrador::ver_reportes::proveedores::proveedores;
use warnings;
use strict;

use administrador::ver_reportes::mostrar_imagen;

sub generar {
  my $lista_circular = gestion_datos::lista_circular_simple->nuevo();
  my $ruta = 'administrador/Proveedores/proveedores.json';
  my $proveedores = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  foreach my $proveedor ( @$proveedores ) {
    $lista_circular->insertar_nuevo($proveedor);
  }

  my $proveedor_instancia = $lista_circular->almacenar_array_simple();
  utilidades::leer_json::guardar_json('administrador/Proveedores/proveedores.json', $proveedor_instancia);

  my ($dot_name, $png_name, $svg_name) = reportes::nombre_archivos::nombre("Proveedores", "proveedores");
  reportes::proveedores_dots::generar_diagrama_proveedores($lista_circular, $dot_name, $png_name, $svg_name);
}

sub mostrar {
  my $directorio = "reportes/imagenes/Proveedores/SVG";
  administrador::ver_reportes::mostrar_imagen::mostrar($directorio);
}

sub mostrar_nuevo {
  generar();
  mostrar();
}

1;
