#!/usr/bin/perl
package reportes::reabastecimiento_dots;
use strict;
use warnings;
use utf8;
sub generar_diagrama_solicitud_reabastecimiento {
  my ($lista_circular_de, $ruta_dot, $ruta_png, $ruta_svg) = @_;
  open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
    or die "No se pudo abrir el archivo en $ruta_dot: $!";
  print $fh "digraph solicitudes_reabastecimiento {\n";
  print $fh "charset=\"UTF-8\";\n";
  print $fh "rankdir=TB;\n";
  print $fh "node [shape=box, style=filled];\n";
  print $fh "graph [nodesep=1.0, ranksep=1.5];\n\n";
  return print $fh "}\n" unless defined $lista_circular_de->{cabeza};
  my $inicio = $lista_circular_de->{cabeza};
  my $actual = $inicio;
  my %nodos;
  my @solicitudes;
  my $index = 0;
  do {
    my $id = "sol$index";
    my $datos = $actual->{datos};
    my $codigo = caracteres_especiales($datos->{codigo} // '');
    my $cantidad = caracteres_especiales($datos->{cantidad} // '');
    my $prioridad = caracteres_especiales($datos->{prioridad} // '');
    my $razon = caracteres_especiales($datos->{razon} // '');
    my $estado = caracteres_especiales($datos->{estado} // '');
    my $color;
    if ($estado eq 'Aprobado') {
      $color = 'green';
    } elsif ($estado eq 'Desaprobado') {
      $color = 'red';
    } elsif ($estado eq 'Pendiente') {
      $color = 'yellow';
    }
    my $solicitud = $index+1;
    my $label = "Número de solicitud: $solicitud\\nCódigo de medicamento: $codigo\\nCantidad: $cantidad\\nPrioridad: $prioridad\\nRazón: $razon\\nEstado: $estado";
    print $fh "$id [label=\"$label\", fillcolor=$color];\n";
    $nodos{$actual} = $id;
    push @solicitudes, $id;
    $actual = $actual->{siguiente};
    $index++;
  } while ($actual != $inicio);
  print $fh "\n";
  print $fh "{ rank=same; " . join("; ", @solicitudes) . "; }\n\n";
  $actual = $inicio;
  do {
    my $nodo_actual = $nodos{$actual};
    my $nodo_siguiente = $nodos{$actual->{siguiente}};
    print $fh "$nodo_actual -> $nodo_siguiente [color=red, penwidth=2.0];\n";
    $actual = $actual->{siguiente};
  } while ($actual != $inicio);
  print $fh "\n";
  $actual = $inicio;
  do {
    my $nodo_actual = $nodos{$actual};
    my $nodo_anterior = $nodos{$actual->{anterior}};
    print $fh "$nodo_actual -> $nodo_anterior [color=black, penwidth=1.5, constraint=false];\n";
    $actual = $actual->{siguiente};
  } while ($actual != $inicio);
  print $fh "\n";
  for (my $i = 0; $i < @solicitudes - 1; $i++) {
    print $fh "$solicitudes[$i] -> $solicitudes[$i+1] [style=invis, weight=10];\n";
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
