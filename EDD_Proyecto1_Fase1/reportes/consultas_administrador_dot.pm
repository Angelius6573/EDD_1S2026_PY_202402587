#!/usr/bin/perl
package reportes::consultas_administrador_dot;

use strict;
use warnings;
use utf8;  # Declarar UTF-8 en el código fuente

sub generar_diagrama_matriz {
  my ($matrix, $ruta_dot, $ruta_png, $ruta_svg) = @_;

  # Abrir archivo con encoding UTF-8 explícito
  open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
    or die "No se pudo crear $ruta_dot: $!\n";

  # Declarar charset en el grafo
  print $fh "digraph MatrizInventario {\n";
  print $fh "charset=\"UTF-8\";\n";
  print $fh "node [shape=plaintext];\n\n";

  print $fh "matriz [label=<\n";
  print $fh "<TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\">\n";

  my ($filas, $columnas) = $matrix->obtener_dimensiones();

  # Encabezado con nombres de laboratorios
  print $fh "<TR>\n";
  print $fh "<TD BGCOLOR=\"lightblue\"><B>Medicamento / Laboratorio</B></TD>\n";

  for my $idx_c (0 .. $columnas - 1) {
    my $lab = caracteres_especiales($matrix->{nombres_columnas}[$idx_c]);  #  Escapar HTML
    print $fh "<TD BGCOLOR=\"lightgreen\"><B>$lab</B></TD>\n";
  }

  print $fh "</TR>\n";

  # Filas de datos
  for my $idx_f (0 .. $filas - 1) {
    print $fh "<TR>\n";

    my $medicamento = caracteres_especiales($matrix->{nombres_filas}[$idx_f]);  #  Escapar HTML
    print $fh "<TD BGCOLOR=\"lightyellow\"><B>$medicamento</B></TD>\n";

    for my $idx_c (0 .. $columnas - 1) {
      my $datos = $matrix->obtener($idx_f, $idx_c);
      my $precio = $datos->{precio};
      my $cantidad = $datos->{cantidad};

      if ($precio > 0 || $cantidad > 0) {
        my $precio_formateado = sprintf("%.2f", $precio);
        my $color = colores($cantidad);
        print $fh "  <TD BGCOLOR=\"$color\">Q $precio_formateado<BR/>";
        print $fh "$cantidad unidades</TD>\n";
      } else {
        print $fh "  <TD BGCOLOR=\"lightgray\">-</TD>\n";
      }
    }
    print $fh "</TR>\n";
  }

  print $fh "</TABLE>\n";
  print $fh ">];\n";
  print $fh "}\n";

  close($fh);

  print "Archivo DOT generado en: $ruta_dot\n";

  # Generar imágenes con charset UTF-8
  generar_imagenes($ruta_dot, $ruta_png, $ruta_svg);
}

##! Escapar caracteres especiales para HTML en Graphviz
sub caracteres_especiales {
  my ($texto) = @_;
  return "" unless defined $texto;

  # Escapar entidades HTML
  $texto =~ s/&/&amp;/g;   # Ampersand primero
  $texto =~ s/</&lt;/g;    # Menor que
  $texto =~ s/>/&gt;/g;    # Mayor que
  $texto =~ s/"/&quot;/g;  # Comillas

  return $texto;
}

# Función para asignar color según cantidad
sub colores {
  my ($cantidad) = @_;

  return "#ffcccc" if $cantidad < 50; # Crítico
  return "#ffffcc" if $cantidad < 100; # Amarillo claro (bajo)
  return "#ccffcc"; # Verde claro (normal)
}

# Generar imágenes con Graphviz
sub generar_imagenes {
  my ($dot_file, $png_file, $svg_file) = @_;

  # Generar PNG con charset UTF-8
  my $cmd_png = "dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$dot_file' -o '$png_file' 2>&1";
  my $resultado_png = `$cmd_png`;

  if ($? == 0) {
    print "Imagen PNG generada en: $png_file\n";
  } else {
    warn "Falló la generación del reporte PNG\n";
    warn "Detalles: $resultado_png\n" if $resultado_png;
  }

  # Generar SVG con charset UTF-8
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

