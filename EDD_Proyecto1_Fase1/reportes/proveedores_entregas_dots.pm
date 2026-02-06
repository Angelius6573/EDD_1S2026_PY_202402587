#!/usr/bin/perl
package reportes::proveedores_entregas_dots;
use strict;
use warnings;

sub generar_diagrama_entregas {
  my ($proveedor, $ruta_dot, $ruta_png, $ruta_svg) = @_;

  open my $fh, '>', $ruta_dot
    or die "No se pudo abrir el archivo en $ruta_dot: $!";

  print $fh "digraph entregas {\n";
  print $fh "rankdir=LR;\n";
  print $fh "node [shape=box, style=filled, width=2, height=1];\n";

  my $index = 0;
  my $anterior;

  foreach my $entrega ( @{$proveedor->{Entregas} || []} ) {
    my $id = "e$index";
    my $label = "
      Código: $entrega->{Codigo}\\n
      Cantidad: $entrega->{Cantidad}\\n
      Fecha de Entrega: $entrega->{FechaDeEntrega}\\n
      Factura: $entrega->{Factura}
    ";
    print $fh "$anterior->$id;\n" if defined  $anterior;
    $anterior = $id;
    $index++;
  }

  print $fh "}\n";
  close $fh;

  # Generar imágenes
  system("dot -Tpng $ruta_dot -o $ruta_png") == 0
    or warn "Falló en generación de reporte .png";
  system("dot -Tsvg $ruta_dot -o $ruta_svg") == 0
    or warn "Falló en generación de reporte .svg";
}

1;
