#!/usr/bin/perl
package administrador::ver_reportes::solicitudes_pendientes::solicitudes_pendientes;
use warnings;
use strict;

use administrador::ver_reportes::mostrar_imagen;

sub generar {
  my ($codigo_depto) = @_;
  my $lista = gestion_datos::lista_circular_doblemente_enlazada->nuevo();
  my $directorio = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto";
  my $ruta = "administrador/Reabastecimiento/Inventario_Departamental/$codigo_depto/solicitudes_reabastecimiento.json";

  unless ( -d $directorio ) {
    make_path($directorio) or die "No se pudo crear el directorio en $directorio: $!";
  }

  unless ( -e $ruta ) {
    open my $fh, '>', $ruta or die "No se pudo crear el archivo en $ruta: $!";
    print $fh "[]";
    close $fh;
  }

  my $solicitudes_existentes = utilidades::leer_json::parsear_json_posiblemente_vacio($ruta);

  if ( !@$solicitudes_existentes ) {
    print "No hay solicitudes pendientes\n";
    utilidades::cerrar::cerrar();
    return interfaz_usuario::admin::inicio_sesion_admin_exitoso();
  }

  foreach my $solicitud ( @$solicitudes_existentes ) {
    $lista->insertar_final($solicitud);
  }

  my $datos = $lista->almacenar_array_simple();
  utilidades::leer_json::guardar_json($ruta, $datos);
  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Solicitud_Reabastecimiento", "solicitud_pendiente");
  reportes::reabastecimiento_dots::generar_diagrama_solicitud_reabastecimiento($lista, $nombre_dot, $nombre_png, $nombre_svg);
}

sub mostrar {
  my $directorio = "reportes/imagenes/Solicitud_Reabastecimiento/SVG";
  administrador::ver_reportes::mostrar_imagen::mostrar($directorio);
}

sub mostrar_nuevo {
  my ($codigo_depto) = @_;
  generar($codigo_depto);
  mostrar();
}

1;
