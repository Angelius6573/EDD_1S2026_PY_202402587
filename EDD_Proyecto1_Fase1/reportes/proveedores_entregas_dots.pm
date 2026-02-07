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
  print $fh "node [shape=box, style=filled];\n";
  print $fh "graph [nodesep=0.6, ranksep=1];\n\n";

  # Nodo proveedor
  my $label_prov =
    "Empresa: $proveedor->{Empresa}\\n" .
    "Contacto: $proveedor->{Contacto}\\n" .
    "NIT: $proveedor->{NIT}";

  print $fh "prov [label=\"$label_prov\", fillcolor=lightblue];\n\n";

  my $index = 0;
  my $anterior = "prov";

  foreach my $entrega ( @{ $proveedor->{Entregas} || [] } ) {
    my $id = "e$index";

    my $label = "Código: $entrega->{Codigo}\\nCantidad: $entrega->{Cantidad}\\nFecha: $entrega->{FechaDeEntrega}\\nFactura: $entrega->{Factura}";

    print $fh "$id [label=\"$label\", fillcolor=gray90];\n";
    print $fh "$anterior -> $id;\n\n";

    $anterior = $id;
    $index++;
  }

  print $fh "}\n";
  close $fh;

  system("dot -Tpng $ruta_dot -o $ruta_png") == 0
    or warn "Falló generación PNG";
  system("dot -Tsvg $ruta_dot -o $ruta_svg") == 0
    or warn "Falló generación SVG";
}

1;

