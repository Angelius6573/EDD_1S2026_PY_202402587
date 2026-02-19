#!/usr/bin/perl
package administrador::Consultas::modulos::opciones;
use strict;
use warnings;
use feature qw(say switch);

use utilidades::limite_entrada;
use reportes::nombre_archivos;
use reportes::consultas_administrador_dot;
use interfaz_usuario::admin;
use utilidades::cerrar;

sub opciones {
  system("clear");
  my ($matrix) = @_;
  print "Bienvenido administrador al gestor de consultas de inventario\n";
  print "Elija una opción:
  1. Consultar medicamento
  2. Generar reporte
  3. Volver al menú de administración\n";
  my $consulta = utilidades::limite_entrada::comprobacion_menu(1, 3);
  comprobar_entrada($consulta, $matrix);
}

sub comprobar_entrada {
  my ($consulta, $matrix) = @_;

  given ($consulta) {
    when (1) {say consultar_medicamento($matrix)}
    when (2) {say reporte($matrix)}
    when (3) {say interfaz_usuario::admin::inicio_sesion_admin_exitoso()}
  }
}

sub consultar_medicamento {
  my ($matrix) = @_;

  system("clear");
  print "Ingrese el nombre del medicamento que desea consultar \n";
  print " Nombre: "; chomp(my $nombre = <STDIN>);
  print "\n";

  my @datos = $matrix->consultar_medicamento($nombre);

  if ( @datos > 0 ) {
    printf "%-15s | %-10s | %-8s\n", "Laboratorio", "Precio", "Cantidad";
    print "-" x 45, "\n";
    foreach my $medicamento ( @datos ) {
      printf "%-15s | \$%-9.2f | %-8d\n",
        $medicamento->{laboratorio},
        $medicamento->{precio},
        $medicamento->{cantidad};
    }
  } else {
    print "No hay datos para el medicamento solicitado.\n";
    print "Volviendo al menú...\n\n";
    utilidades::cerrar::cerrar();
    return opciones($matrix);
  }
  print "\n";
  utilidades::cerrar::cerrar();
  return opciones($matrix);
}

sub reporte {
  my ($matrix) = @_;

  my ($nombre_dot, $nombre_png, $nombre_svg) = reportes::nombre_archivos::nombre("Consultar_Inventario", "consulta-inventario");
  reportes::consultas_administrador_dot::generar_diagrama_matriz($matrix, $nombre_dot, $nombre_png, $nombre_svg);
  
  print "Reportes generados correctamente.\n\n";
  utilidades::cerrar::cerrar();

  return opciones($matrix);
}

1;
