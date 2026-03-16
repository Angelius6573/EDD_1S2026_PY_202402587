#!/usr/bin/perl
package administrador::ver_reportes::matriz::comparacion_precios;
use strict;
use warnings;

use administrador::Inventario::buscar_medicamento_codigo;
use administrador::Consultas::modulos::obtener_f_c;
use gestion_datos::matriz_dispersa;
use administrador::Consultas::modulos::llenar_matriz;
use administrador::Consultas::modulos::opciones;
use interfaz_usuario::admin;
use administrador::ver_reportes::mostrar_imagen;

sub generar {
  my $ruta = "administrador/Inventario/inventario.json";
  my $comprobar_ruta = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);
  if ( !@$comprobar_ruta ) {
    print "No hay elementos en el inventario, por favor, use el registro de recursos previamente.\n";
    utilidades::cerrar::cerrar();
    return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  }

  my ($nombres, $laboratorios) = administrador::Inventario::buscar_medicamento_codigo::obtener_lab_name($ruta); 

  my ($n_cantidad, $l_cantidad) = administrador::Consultas::modulos::obtener_f_c::limites($nombres, $laboratorios);

  my $matrix = gestion_datos::matriz_dispersa->nuevo($l_cantidad, $n_cantidad);

  $matrix->nombre_filas(@$laboratorios);
  $matrix->nombre_columnas(@$nombres);

  administrador::Consultas::modulos::llenar_matriz::llenar($matrix, $ruta);

  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Consultar_Inventario", "consulta-inventario");
  reportes::consultas_administrador_dot::generar_diagrama_matriz($matrix, $nombre_dot, $nombre_png, $nombre_svg);
}

sub mostrar {
  my $directorio = "reportes/imagenes/Consultar_Inventario/SVG";
  administrador::ver_reportes::mostrar_imagen::mostrar($directorio);
}

sub mostrar_nuevo {
  generar();
  mostrar();
}

1;
