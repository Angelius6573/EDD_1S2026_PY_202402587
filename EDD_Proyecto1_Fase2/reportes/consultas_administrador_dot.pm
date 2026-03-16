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
  print $fh "<TD BGCOLOR=\"lightblue\"><B> Laboratorio / Nombre </B></TD>\n";

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
      my $cantidad_minima = $datos->{cantidad_minima};

      if ($precio > 0 || $cantidad > 0) {
        my $precio_formateado = sprintf("%.2f", $precio);
        my $color = colores($cantidad, $cantidad_minima);
        print $fh "<TD BGCOLOR=\"$color\">Q $precio_formateado<BR/>";
        print $fh "$cantidad unidades</TD>\n";
      } else {
        print $fh "<TD BGCOLOR=\"lightgray\">-</TD>\n";
      }
    }
    print $fh "</TR>\n";
  }

  print $fh "</TABLE>\n";
  print $fh ">];\n";
  print $fh "}\n";

  close($fh);

  # print "Archivo DOT generado en: $ruta_dot\n";

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
    my ($cantidad, $cantidad_minima) = @_;

    return "#7f0000" if $cantidad_minima == 0; # evitar división por cero

    my $factor = $cantidad / $cantidad_minima;

    # Limitar el rango entre 0.2 y 4
    $factor = 0.2 if $factor < 0.2;
    $factor = 4 if $factor > 4;

    # Normalizar a rango 0 → 1
    my $normal = ($factor - 0.2) / (4 - 0.2);

    my ($r, $g, $b);

    if ($normal <= 0.5) {
        # Rojo oscuro → Amarillo
        my $t = $normal / 0.5;
        $r = 139 + (255 - 139) * $t;   # 139 → 255
        $g = 0 + (255 - 0) * $t;   # 0   → 255
        $b = 0;
    } else {
        # Amarillo → Verde oscuro
        my $t = ($normal - 0.5) / 0.5;
        $r = 255 - (255 - 0) * $t;     # 255 → 0
        $g = 255 - (255 - 100) * $t;   # 255 → 100
        $b = 0;
    }

    return sprintf("#%02x%02x%02x", $r, $g, $b);
}

# Generar imágenes con Graphviz
sub generar_imagenes {
  my ($ruta_dot, $ruta_png, $ruta_svg) = @_;

  # Generar PNG con charset UTF-8
  my $cmd_png = "dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>&1";
  my $resultado_png = `$cmd_png`;

  if ($? == 0) {
    # print "Imagen PNG generada en: $ruta_png\n";
  } else {
    warn "Falló la generación del reporte PNG\n";
    warn "Detalles: $resultado_png\n" if $resultado_png;
  }

  # Generar SVG con charset UTF-8
  my $cmd_svg = "dot -Tsvg -Gcharset=UTF-8 '$ruta_dot' -o '$ruta_svg' 2>&1";
  my $resultado_svg = `$cmd_svg`;

  if ($? == 0) {
    # print "Imagen SVG generada en: $ruta_svg\n";
  } else {
    warn "Falló la generación del reporte SVG\n";
    warn "Detalles: $resultado_svg\n" if $resultado_svg;
  }
}

1;

