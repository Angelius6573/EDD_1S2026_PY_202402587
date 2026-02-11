#!/usr/bin/perl
package reportes::reabastecimiento_dots;
use strict;
use warnings;

sub generar_diagrama_solicitud_reabastecimiento {
  my ($lista_circular_de, $ruta_dot, $ruta_png, $ruta_svg) = @_;
  open my $fh, '>', $ruta_dot
    or die "No se pudo abrir el archivo en $ruta_dot: $!";
  print $fh "digraph solicitudes_reabastecimiento {\n";
  print $fh "rankdir=TB;\n"; # Conexión horizontal
  print $fh "node [shape=box, style=filled];\n";
  print $fh "graph [nodesep=1.0, ranksep=1.5];\n\n";

  # Si la lista está vacía
  return print $fh "}\n" unless defined $lista_circular_de->{cabeza};

  my $inicio = $lista_circular_de->{cabeza};
  my $actual = $inicio;
  my %nodos;
  my @solicitudes;
  my $index = 0;

  ## Crear nodos para cada solicitud de reabastecimiento
  do {
    my $id = "sol$index";
    my $datos = $actual->{datos};

    my $codigo = $datos->{codigo} // '';
    my $cantidad = $datos->{cantidad} // '';
    my $prioridad = $datos->{prioridad} // '';
    my $razon = $datos->{razon} // '';
    my $estado = $datos->{estado} // '';

    # Determinar color según el estado
    my $color = 'lightcyan';
    if ($estado eq 'Aprobado') {
      $color = 'green';
    } elsif ($estado eq 'Rechazado') {
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
  } while ( $actual != $inicio );

  print $fh "\n";

  ## Forzar que los nodos queden en una línea horizontal
  print $fh "{ rank=same; " . join("; ", @solicitudes) . "; }\n\n";

  ## Conexiones hacia adelante (siguiente) - flechas rojas
  $actual = $inicio;
  do {
    my $nodo_actual = $nodos{$actual};
    my $nodo_siguiente = $nodos{$actual->{siguiente}};
    print $fh "$nodo_actual -> $nodo_siguiente [color=red, penwidth=2.0];\n";
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  print $fh "\n";

  ## Conexiones hacia atrás (anterior) - flechas negras
  $actual = $inicio;
  do {
    my $nodo_actual = $nodos{$actual};
    my $nodo_anterior = $nodos{$actual->{anterior}};
    print $fh "$nodo_actual -> $nodo_anterior [color=black, penwidth=1.5, constraint=false];\n";
    $actual = $actual->{siguiente};
  } while ( $actual != $inicio );

  print $fh "\n";

  ## Conexiones invisibles para mantener el orden horizontal
  for (my $i = 0; $i < @solicitudes - 1; $i++) {
    print $fh "$solicitudes[$i] -> $solicitudes[$i+1] [style=invis, weight=10];\n";
  }

  print $fh "}\n";
  close $fh;

  # Generar imágenes PNG y SVG
  system("dot -Tpng $ruta_dot -o $ruta_png") == 0
    or warn "Falló en generación de reporte .png";
  system("dot -Tsvg $ruta_dot -o $ruta_svg") == 0
    or warn "Falló en generación de reporte .svg";
}

1;
