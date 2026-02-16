#!/usr/bin/perl
package reportes::inventario_dots;
use strict;
use warnings;
use utf8;
sub generar_diagrama_inventario {
  my ($lista, $ruta_dot, $ruta_png, $ruta_svg) = @_;
  open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
    or die "No se pudo abrir el archivo en $ruta_dot: $!";
  print $fh "digraph inventario {\n";
  print $fh "charset=\"UTF-8\";\n";
  print $fh "rankdir=LR;\n";
  print $fh "node [shape=box, style=filled, width=2, height=1];\n";
  print $fh "graph [nodesep=0.5, ranksep=1, splines=true, overlap=false];\n";
  my $actual = $lista->{cabeza};
  my $contador = 0;
  my %nodos;
  while ($actual) {
    my $id = "n$contador";
    my $codigo = caracteres_especiales($actual->{datos}->{codigo} // '');
    my $nombre = caracteres_especiales($actual->{datos}->{nombre} // '');
    my $fecha = caracteres_especiales($actual->{datos}->{fecha_vencimiento} // '');
    my $cantidad = $actual->{datos}->{cantidad} // 0;
    my $nivel_minimo = $actual->{datos}->{nivel_minimo} // 0;
    my $color = "green";
    if ($cantidad < $nivel_minimo) {
      $color = "red";
    } elsif ($cantidad <= $nivel_minimo + 50) {
      $color = "yellow";
    }
    my $label = "Código: $codigo\\nNombre: $nombre\\nVence: $fecha\\nStock: $cantidad";
    print $fh "$id [label=\"$label\", fillcolor=$color];\n";
    $nodos{$actual} = $id;
    $actual = $actual->{siguiente};
    $contador++;
  }
  $actual = $lista->{cabeza};
  while ($actual && $actual->{siguiente}) {
    my $from = $nodos{$actual};
    my $to = $nodos{$actual->{siguiente}};
    print $fh "$from -> $to;\n";
    print $fh "$to -> $from [style=dashed];\n";
    $actual = $actual->{siguiente};
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
