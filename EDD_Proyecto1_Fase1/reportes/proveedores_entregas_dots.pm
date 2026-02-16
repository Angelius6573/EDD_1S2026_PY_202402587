#!/usr/bin/perl
package reportes::proveedores_entregas_dots;
use strict;
use warnings;
use utf8;
sub generar_diagrama_entregas {
  my ($proveedor, $ruta_dot, $ruta_png, $ruta_svg) = @_;
  open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
    or die "No se pudo abrir el archivo en $ruta_dot: $!";
  print $fh "digraph entregas {\n";
  print $fh "charset=\"UTF-8\";\n";
  print $fh "rankdir=LR;\n";
  print $fh "node [shape=box, style=filled];\n";
  print $fh "graph [nodesep=0.6, ranksep=1];\n\n";
  my $empresa = caracteres_especiales($proveedor->{Empresa} // '');
  my $contacto = caracteres_especiales($proveedor->{Contacto} // '');
  my $nit = caracteres_especiales($proveedor->{NIT} // '');
  my $label_prov = "Empresa: $empresa\\nContacto: $contacto\\nNIT: $nit";
  print $fh "prov [label=\"$label_prov\", fillcolor=lightblue];\n\n";
  my $index = 0;
  my $anterior = "prov";
  foreach my $entrega (@{$proveedor->{Entregas} || []}) {
    my $id = "e$index";
    my $codigo = caracteres_especiales($entrega->{Codigo} // '');
    my $cantidad = caracteres_especiales($entrega->{Cantidad} // '');
    my $fecha = caracteres_especiales($entrega->{FechaDeEntrega} // '');
    my $factura = caracteres_especiales($entrega->{Factura} // '');
    my $label = "Código: $codigo\\nCantidad: $cantidad\\nFecha: $fecha\\nFactura: $factura";
    print $fh "$id [label=\"$label\", fillcolor=gray90];\n";
    print $fh "$anterior -> $id;\n\n";
    $anterior = $id;
    $index++;
  }
  print $fh "}\n";
  close($fh);
  print "Archivo DOT generado en: $ruta_dot\n";
  generar_imagenes($ruta_dot, $ruta_png, $ruta_svg);
}
sub caracteres_especiales {
  my ($texto) = @_;
  return "" unless defined $texto;
  $texto =~ s/\\/\\\\/g;
  $texto =~ s/"/\\"/g;
  $texto =~ s/\n/\\n/g;
  $texto =~ s/\r//g;
  return $texto;
}
sub generar_imagenes {
  my ($dot_file, $png_file, $svg_file) = @_;
  my $cmd_png = "dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$dot_file' -o '$png_file' 2>&1";
  my $resultado_png = `$cmd_png`;
  if ($? == 0) {
    print "Imagen PNG generada en: $png_file\n";
  } else {
    warn "Falló la generación del reporte PNG\n";
    warn "Detalles: $resultado_png\n" if $resultado_png;
  }
  my $cmd_svg = "dot -Tsvg -Gcharset=UTF-8 '$dot_file' -o '$svg_file' 2>&1";
  my $resultado_svg = `$cmd_svg`;
  if ($? == 0) {
    print "Imagen SVG generada en: $svg_file\n";
  } else {
    warn "Falló la generación del reporte SVG\n";
    warn "Detalles: $resultado_svg\n" if $resultado_svg;
  }
}
1;
