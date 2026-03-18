#!/usr/bin/perl
package reportes::proveedores_dots;
use strict;
use warnings;
use utf8;

sub generar_diagrama_proveedores {
  my ($lista_circular, $ruta_dot, $ruta_png, $ruta_svg) = @_;

  open(my $fh, '>:encoding(UTF-8)', $ruta_dot)
    or die "No se pudo abrir el archivo en $ruta_dot: $!";

  print $fh "digraph proveedores {\n";
  print $fh "charset=\"UTF-8\";\n";
  print $fh "rankdir=TB;\n";
  print $fh "node [shape=box, style=filled, fillcolor=gray90];\n";
  print $fh "graph [nodesep=1.2, ranksep=0.7];\n\n";

  # Bug fix: la LCDE usa {cabeza}, no {ultimo_nodo}
  unless (defined $lista_circular->{cabeza}) {
    print $fh "  vacio [label=\"(Sin proveedores registrados)\", fillcolor=\"#f3f4f6\"];\n";
    print $fh "}\n";
    close($fh);
    generar_imagenes($ruta_dot, $ruta_png, $ruta_svg);
    return;
  }

  my $inicio = $lista_circular->{cabeza};
  my $actual = $inicio;
  my %nodos;
  my @proveedores;
  my %entregas_por_proveedor;
  my $index = 0;

  do {
    my $id    = "prov$index";
    my $datos = $actual->{datos};

    # Soportar tanto snake_case (Fase 2) como PascalCase (Fase 1)
    my $nombre    = caracteres_especiales($datos->{nombre}    // $datos->{Empresa}   // '');
    my $nit       = caracteres_especiales($datos->{nit}       // $datos->{NIT}       // '');
    my $telefono  = caracteres_especiales($datos->{telefono}  // $datos->{Telefono}  // '');
    my $direccion = caracteres_especiales($datos->{direccion} // $datos->{Direccion} // '');

    my $label = "NIT: $nit\\nNombre: $nombre\\nTel: $telefono\\nDir: $direccion";
    print $fh "  $id [label=\"$label\", fillcolor=lightblue];\n";

    $nodos{$actual} = $id;
    push @proveedores, $id;

    # Soportar tanto entregas (Fase 2) como Entregas (Fase 1)
    my $entregas = $datos->{entregas} // $datos->{Entregas} // [];
    if (@$entregas) {
      $entregas_por_proveedor{$id} = $entregas;
    }

    $actual = $actual->{siguiente};
    $index++;
  } while ($actual != $inicio);

  print $fh "\n";

  # Nodos de entregas
  foreach my $prov_id (@proveedores) {
    if (exists $entregas_por_proveedor{$prov_id}) {
      my $entregas = $entregas_por_proveedor{$prov_id};
      my $index_sub = 0;

      foreach my $entrega (@$entregas) {
        my $id_sub = "${prov_id}_e$index_sub";
        # Soportar campos de Fase 2 y Fase 1
        my $tipo    = caracteres_especiales($entrega->{tipo}    // $entrega->{Tipo}    // '');
        my $codigo  = caracteres_especiales($entrega->{codigo}  // $entrega->{Codigo}  // '');
        my $nombre  = caracteres_especiales($entrega->{nombre}  // '');
        my $cantidad = caracteres_especiales($entrega->{cantidad} // $entrega->{Cantidad} // '');

        my $label_sub = "[$tipo] $codigo\\n$nombre\\nCantidad: $cantidad";
        print $fh "  $id_sub [label=\"$label_sub\", fillcolor=lightyellow];\n";
        $index_sub++;
      }
    }
  }

  print $fh "\n";
  if (@proveedores > 0) {
    print $fh "  {rank=same; " . join("; ", @proveedores) . "; }\n\n";
  }

  # Aristas proveedor -> entregas
  foreach my $prov_id (@proveedores) {
    if (exists $entregas_por_proveedor{$prov_id}) {
      my $entregas = $entregas_por_proveedor{$prov_id};
      my $num_entregas = scalar @$entregas;
      if ($num_entregas > 0) {
        print $fh "  $prov_id -> ${prov_id}_e0;\n";
      }
      for (my $i = 0; $i < $num_entregas - 1; $i++) {
        print $fh "  ${prov_id}_e$i -> ${prov_id}_e" . ($i+1) . ";\n";
      }
    }
  }

  print $fh "\n";

  # Aristas circulares entre proveedores
  $actual = $inicio;
  do {
    my $nodo_inicio = $nodos{$actual};
    my $nodo_final  = $nodos{$actual->{siguiente}};
    print $fh "  $nodo_inicio -> $nodo_final [constraint=false, style=dashed, color=gray];\n";
    $actual = $actual->{siguiente};
  } while ($actual != $inicio);

  # Aristas invisibles para alinear horizontalmente
  for (my $i = 0; $i < @proveedores - 1; $i++) {
    print $fh "  $proveedores[$i] -> $proveedores[$i+1] [style=invis, weight=10];\n";
  }

  print $fh "}\n";
  close($fh);
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
  my ($ruta_dot, $ruta_png, $ruta_svg) = @_;

  my $cmd_png = "dot -Tpng -Gcharset=UTF-8 -Gdpi=150 '$ruta_dot' -o '$ruta_png' 2>&1";
  my $resultado_png = `$cmd_png`;
  if ($? != 0) {
    warn "Falló la generación del reporte PNG\n";
    warn "Detalles: $resultado_png\n" if $resultado_png;
  }

  my $cmd_svg = "dot -Tsvg -Gcharset=UTF-8 '$ruta_dot' -o '$ruta_svg' 2>&1";
  my $resultado_svg = `$cmd_svg`;
  if ($? != 0) {
    warn "Falló la generación del reporte SVG\n";
    warn "Detalles: $resultado_svg\n" if $resultado_svg;
  }
}

1;
